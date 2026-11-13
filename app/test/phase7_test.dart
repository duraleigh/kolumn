import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kolumn/board/kolumn_settings.dart';
import 'package:kolumn/data/database.dart';
import 'package:kolumn/data/export.dart';
import 'package:kolumn/data/lanes.dart';
import 'package:kolumn/data/repository.dart';
import 'package:kolumn/main.dart';
import 'package:kolumn/state/providers.dart';
import 'package:kolumn/sync/hub_client.dart';
import 'package:kolumn/sync/sync_service.dart';

void main() {
  late KolumnDb db;
  late KolumnRepository repo;
  setUp(() async {
    db = KolumnDb.forTesting(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
    repo = KolumnRepository(db);
    await repo.setSetting('me.id', '7');
    await db.into(db.kPeople).insert(KPeopleCompanion.insert(id: const Value(7), name: 'Clay Aiken'));
  });
  tearDown(() => db.close());

  group('export', () {
    test('a Kolumn: its kolumns in order, every card with notes, checklist, comments and history', () async {
      final b = await repo.createBoard('Fall tour');
      final col = await repo.addColumn(b, 'Booked', 1);
      final c1 = await repo.addCard(b, 'Book the van', lane: Lane.column(col), priority: true);
      await repo.editCard(c1, description: 'Ask about the dock');
      await repo.addStep(c1, 'Call the venue');
      await repo.addComment(c1, 'Done, dock is 4 ft');
      await repo.setTag(c1, 'venue', true);
      await repo.setCardDue(c1, '2026-11-13');
      await repo.addCard(b, 'Secret', draft: true);
      await repo.addCard(b, 'Finished', lane: const Lane.done());
      final k = await KolumnExport(repo).kolumn(b);
      expect(k['name'], 'Fall tour');
      final lanes = (k['kolumns'] as List).cast<Map<String, Object?>>();
      expect(lanes.map((l) => l['kolumn']), ['Later', 'To-do', 'Booked', 'Done']);
      final van = (lanes[2]['cards'] as List).single as Map<String, Object?>;
      expect(van['title'], 'Book the van');
      expect(van['notes'], 'Ask about the dock');
      expect(van['priority'], isTrue);
      expect(van['dueDay'], '2026-11-13');
      expect(van.containsKey('tags'), isFalse, reason: 'tags are shown nowhere (2026-11-13)');
      expect(jsonEncode(k), isNot(contains('"venue"')));
      expect((van['checklist'] as List).single, {'step': 'Call the venue', 'done': false});
      expect(((van['comments'] as List).single as Map)['by'], 'Clay Aiken');
      expect(jsonEncode(k), isNot(contains('Secret')), reason: 'drafts are left out');
      expect((lanes[3]['cards'] as List).single['finished'], isNotEmpty);
    });

    test('the spreadsheet: one row per card, commas and quotes safe, nothing a spreadsheet would run', () async {
      final b = await repo.createBoard('Tour');
      await repo.addCard(b, 'Pack: shirts, "good" shoes');
      await repo.addCard(b, '=HYPERLINK("http://x")');
      final csv = await KolumnExport(repo).kolumnCsv(b);
      final lines = csv.split('\r\n');
      expect(lines.first, startsWith('Kolumn,In,Number,Title'));
      expect(lines, hasLength(3));
      expect(csv, contains('"Pack: shirts, ""good"" shoes"'));
      expect(csv, contains('"\'=HYPERLINK(""http://x"")"'), reason: 'a formula is written as text');
    });

    test('everything: every Kolumn and every planner', () async {
      await repo.createBoard('Tour');
      final p = await repo.createPlanner('Mine');
      await repo.addTodo(p, const TodoSlot.day('2026-11-12'), 'Warm-up');
      final all = await KolumnExport(repo).everything();
      expect((all['kolumns'] as List), hasLength(1));
      expect(((all['planners'] as List).single as Map)['toDos'], [
        {'title': 'Warm-up', 'day': '2026-11-12', 'someday': null, 'done': false, 'dueDay': null, 'dueTime': null, 'repeats': null, 'note': '', 'checklist': <Object>[]},
      ]);
      expect(KolumnExport.fileName('Fall/tour: 2026?'), startsWith('Kolumn - Falltour 2026 - '));
    });
  });

  group('view-only links', () {
    test('turning a link on, renewing and off goes to the hub; the link arrives with the Kolumn', () async {
      final b = await repo.createBoard('Tour');
      await repo.setShare(b, on: true);
      await repo.setShare(b, on: true, renew: true);
      await repo.setShare(b, on: false);
      final sent = [for (final e in await repo.pendingOutbox()) if (e.name == 'board.share') jsonDecode(e.args)];
      expect(sent, [
        {'id': b, 'on': true, 'renew': false},
        {'id': b, 'on': true, 'renew': true},
        {'id': b, 'on': false, 'renew': false},
      ]);
      await repo.removeOutbox((await repo.pendingOutbox()).map((e) => e.mutationId));
      await repo.applyPull({
        'cursor': 3,
        'boardIds': [b],
        'boards': [
          {'id': b, 'name': 'Tour', 'shareKey': 'a' * 32, 'allAccess': true, 'canManage': true, 'createdAt': 1, 'updatedAt': 2},
        ],
      });
      expect((await db.select(db.kBoards).getSingle()).shareKey, 'a' * 32);
      expect(shareUrl('a' * 32), endsWith('/wp-json/hub/v1/kolumn-share/${'a' * 32}'));
    });
  });

  group('Kolumn settings', () {
    Future<void> pump(WidgetTester tester, {required bool manager}) async {
      tester.view.devicePixelRatio = 3;
      tester.view.physicalSize = const Size(390, 844) * 3;
      addTearDown(tester.view.reset);
      await tester.runAsync(() async {
        final b = await repo.ensureStarterBoard();
        await (db.update(db.kBoards)..where((x) => x.id.equals(b))).write(KBoardsCompanion(canManage: Value(manager), shareKey: Value(manager ? 'b' * 32 : null)));
      });
      final sync = SyncService(repo: repo, hub: HubClient(credentials: MemoryCredentialStore(), server: 'https://hub.invalid'));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            repositoryProvider.overrideWithValue(repo),
            syncServiceProvider.overrideWithValue(sync),
            syncStatusProvider.overrideWith((ref) => Stream.value(SyncStatus(SyncState.upToDate, lastSynced: DateTime.now()))),
          ],
          child: const KolumnApp(),
        ),
      );
      for (var i = 0; i < 6; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.tap(find.text('Playground').first);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Kolumn settings'));
      await tester.pumpAndSettle();
    }

    testWidgets('its maker sees everything, including the view-only link', (tester) async {
      await pump(tester, manager: true);
      for (final t in ['Rename', 'Who can see it', 'View-only link', 'Tidy-up time', 'Tell me about everything', 'Export', 'Delete Kolumn']) {
        expect(find.text(t), findsOneWidget, reason: t);
      }
      await tester.tap(find.text('View-only link'));
      await tester.pumpAndSettle();
      expect(find.textContaining('kolumn-share/${'b' * 32}'), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.runAsync(db.close);
    });

    testWidgets('someone else may follow and export, but not change it', (tester) async {
      await pump(tester, manager: false);
      expect(find.text('Tell me about everything'), findsOneWidget);
      expect(find.text('Export'), findsOneWidget);
      for (final t in ['Rename', 'Who can see it', 'View-only link', 'Delete Kolumn']) {
        expect(find.text(t), findsNothing, reason: t);
      }
      await tester.runAsync(db.close);
    });
  });
}
