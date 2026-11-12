import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kolumn/card/card_screen.dart';
import 'package:kolumn/data/database.dart';
import 'package:kolumn/data/lanes.dart';
import 'package:kolumn/data/repository.dart';
import 'package:kolumn/main.dart';
import 'package:kolumn/state/providers.dart';
import 'package:kolumn/sync/hub_client.dart';
import 'package:kolumn/sync/sync_service.dart';
import 'package:kolumn/theme/app_theme.dart';

KolumnDb memoryDb() => KolumnDb.forTesting(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump(const Duration(milliseconds: 100));
  }
  await tester.pumpAndSettle();
}

Future<(KolumnRepository, String, String)> seed(KolumnDb db) async {
  final repo = KolumnRepository(db);
  await repo.setSetting('me.id', '7');
  await repo.setSetting('me.level', 'write');
  await db.into(db.kPeople).insert(KPeopleCompanion.insert(id: const Value(7), name: 'Clay Aiken'));
  await db.into(db.kPeople).insert(KPeopleCompanion.insert(id: const Value(9), name: 'Jamie Moss'));
  final board = await repo.createBoard('Tour');
  await repo.setSetting('board.current', board);
  final card = await repo.addCard(board, 'Load-in plan');
  return (repo, board, card);
}

Future<void> pumpCard(WidgetTester tester, KolumnRepository repo, String board, String card) async {
  tester.view.devicePixelRatio = 3;
  tester.view.physicalSize = const Size(390, 1600) * 3;
  addTearDown(tester.view.reset);
  final sync = SyncService(repo: repo, hub: HubClient(credentials: MemoryCredentialStore(), server: 'https://hub.invalid'));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        repositoryProvider.overrideWithValue(repo),
        syncServiceProvider.overrideWithValue(sync),
        syncStatusProvider.overrideWith((ref) => Stream.value(SyncStatus(SyncState.upToDate, lastSynced: DateTime.now()))),
      ],
      child: MaterialApp(theme: KolumnTheme.light(), home: CardScreen(cardId: card, boardId: board)),
    ),
  );
  await settle(tester);
}

void main() {
  group('on the phone', () {
    late KolumnDb db;
    late KolumnRepository repo;
    late String board, card;

    setUp(() async {
      db = memoryDb();
      (repo, board, card) = await seed(db);
    });
    tearDown(() => db.close());

    Future<List<Map<String, dynamic>>> outbox() async =>
        [for (final e in await repo.pendingOutbox(limit: 500)) {'name': e.name, ...jsonDecode(e.args) as Map<String, dynamic>}];

    test('steps: added, ticked, removed, each one change for the hub', () async {
      final s = await repo.addStep(card, ' Call the venue ');
      final step = (await repo.watchSteps(card).first).single;
      expect(step.content, 'Call the venue');
      await repo.updateStep(step, done: true);
      await repo.deleteStep(step);
      expect(await repo.watchSteps(card).first, isEmpty);
      final names = (await outbox()).map((e) => e['name']).toList();
      expect(names.sublist(names.length - 3), ['step.create', 'step.update', 'step.delete']);
      expect((await outbox()).firstWhere((e) => e['name'] == 'step.update'), containsPair('id', s));
    });

    test('a comment makes me follow the card', () async {
      await repo.addComment(card, 'Dock is 4 ft');
      expect((await repo.watchWatch(card).first)!.watching, isTrue);
    });

    test('a reaction is a toggle: tap again to take it back', () async {
      await repo.toggleReaction(card, '👍');
      expect(await repo.watchReactions(card).first, hasLength(1));
      await repo.toggleReaction(card, '👍');
      expect(await repo.watchReactions(card).first, isEmpty);
      expect((await outbox()).where((e) => e['name'] == 'reaction.remove'), hasLength(1));
    });

    test('tags are tidied: "#Venue" is stored as venue', () async {
      await repo.setTag(card, '  #Venue ', true);
      expect((await repo.watchTags().first).single.tag, 'venue');
      await repo.setTag(card, 'VENUE', false);
      expect(await repo.watchTags().first, isEmpty);
    });

    test('assigning myself makes me follow the card', () async {
      await repo.setWatching(card, false);
      await repo.setAssigned(card, 7, true);
      expect((await repo.watchWatch(card).first)!.watching, isTrue);
      expect((await repo.watchAssignees().first).single.userId, 7);
    });

    test('drafts stay off the board until posted', () async {
      final d = await repo.addCard(board, 'Surprise', draft: true);
      expect((await repo.card(d))!.status, 'draft');
      expect((await outbox()).lastWhere((e) => e['name'] == 'card.create'), containsPair('draft', true));
      await repo.publishCard(d);
      expect((await repo.card(d))!.status, 'published');
    });

    test('a file waits on the phone, then is marked sent', () async {
      final tmp = File('${Directory.systemTemp.path}/kolumn-test-${DateTime.now().microsecondsSinceEpoch}.txt')..writeAsStringSync('rider');
      final f = await repo.addFile(card, localPath: tmp.path, filename: 'rider.txt', mime: 'text/plain', size: 5);
      expect((await repo.file(f))!.uploaded, isFalse);
      expect((await outbox()).last, containsPair('name', 'file.upload'));
      await repo.markFileUploaded(f);
      expect((await repo.file(f))!.uploaded, isTrue);
      tmp.deleteSync();
    });

    test('moving a card to another board sends it to To-do there', () async {
      final col = await repo.addColumn(board, 'Doing', 0);
      await repo.moveCard(card, Lane.column(col));
      final other = await repo.createBoard('Studio');
      await repo.moveCardToBoard(card, other);
      final c = (await repo.card(card))!;
      expect(c.boardId, other);
      expect(c.columnId, isNull);
    });

    test('pins are my own shortcuts', () async {
      await repo.setPinned(card, true);
      expect((await repo.watchPins().first).single.cardId, card);
      await repo.setPinned(card, false);
      expect(await repo.watchPins().first, isEmpty);
    });
  });

  group('sync carries files in order', () {
    test('a card reaches the hub before its photo, and the photo is sent as its own upload', () async {
      final db = memoryDb();
      final (repo, board, card) = await seed(db);
      final log = <String>[];
      final client = MockClient((req) async {
        if (req.url.path.endsWith('/auth/device/refresh')) {
          return http.Response(jsonEncode({'token': 't', 'expires_in': 900, 'refresh': 'r', 'user': {'id': 7}}), 200);
        }
        if (req.url.path.endsWith('/kolumn/files')) {
          log.add('upload ${req.url.queryParameters['filename']} ${req.bodyBytes.length} bytes');
          return http.Response(jsonEncode({'outcome': 'applied'}), 200);
        }
        if (req.method == 'POST') {
          final muts = ((jsonDecode(req.body) as Map)['mutations'] as List).cast<Map>();
          log.add('push ${muts.map((m) => m['name']).join(',')}');
          return http.Response(jsonEncode({'results': [for (final m in muts) {'mutation_id': m['mutation_id'], 'outcome': 'applied'}]}), 200);
        }
        return http.Response(jsonEncode({'cursor': 1, 'boardIds': [board], 'boards': [], 'cards': [], 'people': []}), 200);
      });
      final creds = MemoryCredentialStore()..value = 'r';
      final sync = SyncService(repo: repo, hub: HubClient(credentials: creds, httpClient: client, server: 'https://hub.test'));
      final tmp = File('${Directory.systemTemp.path}/kolumn-photo-${DateTime.now().microsecondsSinceEpoch}.jpg')..writeAsBytesSync(List.filled(1234, 7));
      final f = await repo.addFile(card, localPath: tmp.path, filename: 'stage.jpg', mime: 'image/jpeg', size: 1234, cover: true);
      await repo.addComment(card, 'Photo is up');
      await sync.syncNow();
      expect(log[0], startsWith('push board.create,card.create'));
      expect(log[1], 'upload stage.jpg 1234 bytes');
      expect(log[2], 'push comment.create');
      expect((await repo.file(f))!.uploaded, isTrue);
      expect(await repo.pendingCount(), 0);
      tmp.deleteSync();
      await db.close();
    });
  });

  group('the card screen', () {
    testWidgets('adding a step, ticking it, and seeing the count', (tester) async {
      final db = memoryDb();
      late KolumnRepository repo;
      late String board, card;
      await tester.runAsync(() async => (repo, board, card) = await seed(db));
      await pumpCard(tester, repo, board, card);
      await tester.enterText(find.widgetWithText(TextField, 'Add a step'), 'Call the venue');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await settle(tester);
      expect(find.text('Call the venue'), findsOneWidget);
      expect(find.text('Checklist · 0 of 1'), findsOneWidget);
      await tester.tap(find.text('Call the venue'));
      await settle(tester);
      expect(find.text('Checklist · 1 of 1'), findsOneWidget);
      await tester.runAsync(db.close);
    });

    testWidgets('typing @ offers the team and sends a real mention', (tester) async {
      final db = memoryDb();
      late KolumnRepository repo;
      late String board, card;
      await tester.runAsync(() async => (repo, board, card) = await seed(db));
      await pumpCard(tester, repo, board, card);
      final box = find.widgetWithText(TextField, 'Write a comment… (@ mentions, # links)');
      await tester.enterText(box, 'Ask @Ja');
      await settle(tester);
      await tester.tap(find.widgetWithText(ActionChip, 'Jamie Moss'));
      await settle(tester);
      await tester.tap(find.byTooltip('Send'));
      await settle(tester);
      final c = (await tester.runAsync(() => repo.watchComments(card).first))!.single;
      expect(c.body, 'Ask @[Jamie Moss](9)');
      expect(find.text('Ask @Jamie Moss', findRichText: true), findsOneWidget, reason: 'shown as @Name, not the code underneath');
      await tester.runAsync(db.close);
    });

    testWidgets('pinning from the card screen', (tester) async {
      final db = memoryDb();
      late KolumnRepository repo;
      late String board, card;
      await tester.runAsync(() async => (repo, board, card) = await seed(db));
      await pumpCard(tester, repo, board, card);
      await tester.tap(find.byTooltip('Pin to my shortcuts'));
      await settle(tester);
      expect(find.byTooltip('Unpin'), findsOneWidget);
      await tester.runAsync(db.close);
    });
  });

  testWidgets('the board leaves drafts out and offers them in a list', (tester) async {
    final db = memoryDb();
    late KolumnRepository repo;
    late String board;
    await tester.runAsync(() async {
      (repo, board, _) = await seed(db);
      await repo.addCard(board, 'Secret surprise', draft: true);
    });
    tester.view.devicePixelRatio = 3;
    tester.view.physicalSize = const Size(390, 844) * 3;
    addTearDown(tester.view.reset);
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
    await settle(tester);
    expect(find.text('Load-in plan'), findsOneWidget);
    expect(find.text('Secret surprise'), findsNothing);
    await tester.tap(find.text('Drafts 1'));
    await settle(tester);
    expect(find.text('Secret surprise'), findsOneWidget);
    await tester.runAsync(db.close);
  });
}
