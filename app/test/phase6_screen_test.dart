import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kolumn/data/database.dart';
import 'package:kolumn/data/lanes.dart';
import 'package:kolumn/data/repository.dart';
import 'package:kolumn/main.dart';
import 'package:kolumn/planner/planner_model.dart';
import 'package:kolumn/state/providers.dart';
import 'package:kolumn/sync/hub_client.dart';
import 'package:kolumn/sync/sync_service.dart';

const phone = Size(390, 844);
const smallPhone = Size(320, 640);
const computer = Size(1280, 820);

class H {
  H(this.db, this.repo, this.board, this.cards);
  final KolumnDb db;
  final KolumnRepository repo;
  final String board;
  final Map<String, String> cards;
}

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// The app signed in as Clay (7), with Riley (8) on the team, a Kolumn with
/// some history today, and two alerts.
Future<H> pumpApp(WidgetTester tester, Size size, {String start = 'kolumns'}) async {
  tester.view.devicePixelRatio = 3;
  tester.view.physicalSize = size * 3;
  addTearDown(tester.view.reset);
  final db = KolumnDb.forTesting(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
  final repo = KolumnRepository(db);
  late String board;
  final cards = <String, String>{};
  await tester.runAsync(() async {
    await repo.setSetting('me.id', '7');
    await repo.setSetting('home.start', start);
    await db.into(db.kPeople).insert(KPeopleCompanion.insert(id: const Value(7), name: 'Clay Aiken'));
    await db.into(db.kPeople).insert(KPeopleCompanion.insert(id: const Value(8), name: 'Riley Stone'));
    board = await repo.createBoard('Fall tour');
    for (final t in ['Finalize setlist', 'Book the van', 'Merch restock']) {
      cards[t] = await repo.addCard(board, t);
    }
    await repo.addComment(cards['Book the van']!, 'Ask the venue about the dock height');
    await repo.moveCard(cards['Merch restock']!, const Lane.done());
    final now = DateTime.now();
    var id = 1;
    Future<void> ev(String card, String action, String particulars, {int user = 8}) => db
        .into(db.kEvents)
        .insert(KEventsCompanion.insert(id: Value(id++), cardId: cards[card]!, userId: user, action: action, particulars: Value(particulars), createdAt: now.millisecondsSinceEpoch - id * 1000));
    await ev('Finalize setlist', 'card_published', '{}');
    await ev('Book the van', 'card_published', '{}', user: 7);
    await ev('Merch restock', 'card_moved', '{"to":"done"}');
    await ev('Finalize setlist', 'comment_created', '{}');
    // As if all of that already reached the hub.
    await repo.removeOutbox((await repo.pendingOutbox()).map((e) => e.mutationId));
    await repo.applyPull({
      'cursor': 1,
      'boardIds': [board],
      'people': [
        {'id': 7, 'name': 'Clay Aiken'},
        {'id': 8, 'name': 'Riley Stone'},
      ],
      'notifications': [
        {'cardId': cards['Finalize setlist'], 'boardId': board, 'creatorId': 8, 'action': 'mentioned', 'particulars': {}, 'unreadCount': 1, 'updatedAt': now.millisecondsSinceEpoch},
        {'cardId': cards['Book the van'], 'boardId': board, 'creatorId': 8, 'action': 'card_assigned', 'particulars': {'userId': 7}, 'unreadCount': 1, 'updatedAt': now.millisecondsSinceEpoch - 5000},
      ],
    });
    await repo.removeOutbox((await repo.pendingOutbox()).map((e) => e.mutationId));
  });
  addTearDown(() => tester.runAsync(db.close));
  final sync = SyncService(repo: repo, hub: HubClient(credentials: MemoryCredentialStore(), server: 'https://hub.invalid'));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        repositoryProvider.overrideWithValue(repo),
        syncServiceProvider.overrideWithValue(sync),
        syncStatusProvider.overrideWith((ref) => Stream.value(SyncStatus(SyncState.upToDate, lastSynced: DateTime.now()))),
        plannerTodayProvider.overrideWithValue(DateTime.now().toIso8601String().substring(0, 10)),
      ],
      child: const KolumnApp(),
    ),
  );
  await settle(tester);
  return H(db, repo, board, cards);
}

void main() {
  for (final size in [phone, smallPhone, computer]) {
    testWidgets('four tabs, with the alert count on Alerts (${size.width.toInt()} wide)', (tester) async {
      await pumpApp(tester, size);
      for (final t in ['Kolumns', 'Activity', 'Planner', 'Alerts']) {
        expect(find.text(t), findsWidgets);
      }
      expect(find.text('2'), findsWidgets, reason: 'two new alerts');
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Activity shows today in Added / Updated / Done, in plain words', (tester) async {
    await pumpApp(tester, phone, start: 'activity');
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('All Kolumns'), findsOneWidget);
    await tester.tap(find.textContaining('Added'));
    await settle(tester);
    expect(find.text('Riley Stone added Finalize setlist'), findsOneWidget);
    expect(find.text('You added Book the van'), findsOneWidget);
    await tester.tap(find.textContaining('Done'));
    await settle(tester);
    expect(find.text('Riley Stone moved Merch restock to Done'), findsOneWidget);
    await tester.tap(find.textContaining('Updated'));
    await settle(tester);
    expect(find.text('Riley Stone commented on Finalize setlist'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Alerts: new ones first; opening one marks it read; Mark all read', (tester) async {
    final h = await pumpApp(tester, phone);
    await tester.tap(find.text('Alerts'));
    await settle(tester);
    expect(find.text('2 new'), findsOneWidget);
    expect(find.text('Riley Stone mentioned you on Finalize setlist'), findsOneWidget);
    expect(find.text('Riley Stone assigned you to Book the van'), findsOneWidget);
    await tester.tap(find.text('Riley Stone mentioned you on Finalize setlist'));
    await settle(tester);
    expect(find.byType(BackButton), findsOneWidget, reason: 'the card opened');
    await tester.pageBack();
    await settle(tester);
    expect(find.text('1 new'), findsOneWidget);
    await tester.tap(find.text('Mark all read'));
    await settle(tester);
    expect(find.text('All caught up'), findsOneWidget);
    final names = (await tester.runAsync(() => h.repo.pendingOutbox()))!.map((e) => e.name).toList();
    expect(names, ['notification.read', 'notification.readall']);
  });

  testWidgets('Find: words in a comment find the card; a filter narrows it; a view is saved', (tester) async {
    final h = await pumpApp(tester, phone);
    await tester.tap(find.byTooltip('Find cards'));
    await settle(tester);
    await tester.enterText(find.byType(TextField).first, 'dock');
    await settle(tester);
    expect(find.text('Book the van'), findsOneWidget);
    expect(find.textContaining('In a comment'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '');
    await settle(tester);
    expect(find.text('2 cards'), findsOneWidget, reason: 'open cards: one is Done');
    await tester.tap(find.text('Open'));
    await settle(tester);
    await tester.tap(find.text('Done').last);
    await settle(tester);
    expect(find.text('Merch restock'), findsOneWidget);
    expect(find.text('1 card'), findsOneWidget);
    await tester.tap(find.byTooltip('Save this view'));
    await settle(tester);
    await tester.enterText(find.byType(TextField).last, 'Finished');
    await tester.tap(find.text('Save'));
    await settle(tester);
    final views = await tester.runAsync(() => h.repo.watchViews().first);
    expect(views!.single.name, 'Finished');
    expect(find.widgetWithText(ChoiceChip, 'Finished'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Alerts: choosing which Kolumns tell me everything', (tester) async {
    final h = await pumpApp(tester, phone);
    await tester.tap(find.text('Alerts'));
    await settle(tester);
    await tester.tap(find.byTooltip('Which Kolumns tell me everything'));
    await settle(tester);
    final sw = find.widgetWithText(SwitchListTile, 'Fall tour');
    expect(tester.widget<SwitchListTile>(sw).value, isTrue, reason: 'Clay made it, so Clay follows it until he says not to');
    await tester.tap(sw);
    await settle(tester);
    expect(tester.widget<SwitchListTile>(sw).value, isFalse);
    final w = await tester.runAsync(() => h.repo.watchBoardWatches().first);
    expect(w!.single.watching, isFalse);
  });

  testWidgets('Settings: Opens on offers Kolumns, Activity and Planner', (tester) async {
    await pumpApp(tester, phone);
    await tester.tap(find.byTooltip('Settings'));
    await settle(tester);
    expect(find.descendant(of: find.byType(SegmentedButton<String>), matching: find.text('Activity')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
