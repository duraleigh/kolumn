import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kolumn/board/board_screen.dart';
import 'package:kolumn/card/card_screen.dart';
import 'package:kolumn/data/database.dart';
import 'package:kolumn/data/lanes.dart';
import 'package:kolumn/data/repository.dart';
import 'package:kolumn/main.dart';
import 'package:kolumn/state/providers.dart';
import 'package:kolumn/sync/hub_client.dart';
import 'package:kolumn/sync/sync_service.dart';

/// Phone sizes the board must work on, in logical pixels.
const smallPhone = Size(320, 640);
const phone = Size(390, 844);
const largePhone = Size(430, 932);
const tablet = Size(1024, 720);

const holdCard = 'Hold a card, then drag it onto a kolumn in the tray';
const priorityCard = 'Priority cards always sit at the top';
const laterCard = "Cards you're not ready for wait here in Later";

class Harness {
  Harness(this.db, this.repo);
  final KolumnDb db;
  final KolumnRepository repo;

  Future<KCard> cardTitled(WidgetTester tester, String title) async {
    final all = await tester.runAsync(() => db.select(db.kCards).get());
    return all!.firstWhere((c) => c.title == title);
  }

  Future<Lane> laneOf(WidgetTester tester, String title) async {
    final card = await cardTitled(tester, title);
    final cols = await tester.runAsync(() => repo.columns(card.boardId));
    return Lane.of(card, cols!.map((c) => c.id).toSet());
  }
}

Future<Harness> pumpApp(WidgetTester tester, Size size, {String theme = 'light', int extraColumns = 0}) async {
  tester.view.devicePixelRatio = 3;
  tester.view.physicalSize = size * 3;
  addTearDown(tester.view.reset);
  final db = KolumnDb.forTesting(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
  final repo = KolumnRepository(db);
  await tester.runAsync(() async {
    final board = await repo.ensureStarterBoard();
    await repo.setSetting('theme', theme);
    for (var i = 0; i < extraColumns; i++) {
      await repo.addColumn(board, 'Extra ${i + 1}', i % 8);
    }
  });
  addTearDown(() => tester.runAsync(db.close));
  // Signed in and up to date; no hub is contacted in these tests.
  final sync = SyncService(
    repo: repo,
    hub: HubClient(credentials: MemoryCredentialStore(), server: 'https://hub.invalid'),
  );
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
  await _settle(tester);
  return Harness(db, repo);
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump(const Duration(milliseconds: 100));
  }
  await tester.pumpAndSettle();
}

Finder stripFor(String name) => find.byWidgetPredicate((w) => w is Semantics && (w.properties.label ?? '').startsWith('Open $name,'));

Finder trayText(String text) => find.descendant(of: find.byType(DropTray), matching: find.text(text));

Future<TestGesture> holdAndLift(WidgetTester tester, String title) async {
  final g = await tester.startGesture(tester.getCenter(find.text(title)));
  await tester.pump(const Duration(milliseconds: 420));
  await tester.pump(const Duration(milliseconds: 300));
  return g;
}

void main() {
  testWidgets('phone: only To-do is open, the rest are strips', (tester) async {
    await pumpApp(tester, phone);
    expect(find.byTooltip('Add a card'), findsOneWidget, reason: 'one + button for the whole Kolumn');
    expect(find.text(holdCard), findsOneWidget);
    expect(stripFor('In progress'), findsOneWidget);
    expect(stripFor('Later'), findsOneWidget);
    expect(stripFor('Done'), findsOneWidget);
  });

  testWidgets('phone: tapping a strip opens it and folds To-do (one open at a time)', (tester) async {
    await pumpApp(tester, phone);
    await tester.tap(stripFor('In progress'));
    await _settle(tester);
    expect(find.text(priorityCard), findsOneWidget);
    expect(find.text(holdCard), findsNothing, reason: 'To-do folded into a strip');
    expect(stripFor('To-do'), findsOneWidget);
    await tester.tap(stripFor('Waiting on'));
    await _settle(tester);
    expect(find.text(priorityCard), findsNothing, reason: 'In progress folded again');
  });

  for (final size in [smallPhone, phone, largePhone]) {
    testWidgets('${size.width.toInt()} wide: hold a card, drop it on the tray, it moves', (tester) async {
      final h = await pumpApp(tester, size);
      final g = await holdAndLift(tester, holdCard);
      expect(find.text('Drop on a kolumn'), findsOneWidget);
      expect(trayText('here now'), findsOneWidget, reason: 'the card\'s own column is marked');
      await g.moveTo(tester.getCenter(trayText('Waiting on')));
      await tester.pump(const Duration(milliseconds: 100));
      await g.moveBy(const Offset(1, 1));
      await tester.pump(const Duration(milliseconds: 100));
      expect(trayText('release to drop'), findsOneWidget);
      await g.up();
      await _settle(tester);
      final lane = await h.laneOf(tester, holdCard);
      expect(lane.kind, LaneKind.column);
      expect(find.textContaining('Moved to Waiting on'), findsOneWidget);
    });
  }

  for (final size in [smallPhone, phone, largePhone]) {
    testWidgets('${size.width.toInt()} wide, 10 columns: every tray target fits on screen and is finger-sized', (tester) async {
      await pumpApp(tester, size, extraColumns: 5);
      final g = await holdAndLift(tester, holdCard);
      final targets = find.descendant(of: find.byType(DropTray), matching: find.byType(DragTarget<String>));
      expect(targets, findsNWidgets(10));
      for (final e in targets.evaluate()) {
        final r = tester.getRect(find.byWidget(e.widget));
        expect(r.height, greaterThanOrEqualTo(60));
        expect(r.width, greaterThanOrEqualTo(88));
        expect(r.left, greaterThanOrEqualTo(0));
        expect(r.right, lessThanOrEqualTo(size.width));
        expect(r.bottom, lessThanOrEqualTo(size.height));
        expect(r.top, greaterThan(size.height * 0.25), reason: 'room is left above the tray to see the lifted card');
      }
      await g.up();
      await _settle(tester);
    });
  }

  testWidgets('phone: holding a card at the left edge flips to the column on the left', (tester) async {
    await pumpApp(tester, phone);
    final g = await holdAndLift(tester, holdCard);
    await g.moveTo(const Offset(6, 300));
    await tester.pump(const Duration(milliseconds: 100));
    await g.moveBy(const Offset(0, 2));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text(laterCard), findsOneWidget, reason: 'Later is open now');
    await g.up();
    await _settle(tester);
  });

  testWidgets('phone: dropping on nothing leaves the card where it was', (tester) async {
    final h = await pumpApp(tester, phone);
    final g = await holdAndLift(tester, holdCard);
    await g.moveBy(const Offset(0, -40));
    await tester.pump(const Duration(milliseconds: 100));
    await g.up();
    await _settle(tester);
    expect(await h.laneOf(tester, holdCard), const Lane.todo());
    expect(find.text('Drop on a kolumn'), findsOneWidget, reason: 'the tray is still built, just slid away');
  });

  testWidgets('tablet: the main kolumn and every kolumn to its right stay open; Later opens on a tap', (tester) async {
    await pumpApp(tester, tablet);
    expect(find.text(holdCard), findsOneWidget, reason: 'To-do is open');
    expect(find.text(priorityCard), findsOneWidget, reason: 'In progress, right of To-do, is open too');
    expect(stripFor('In progress'), findsNothing);
    expect(stripFor('Waiting on'), findsNothing);
    expect(stripFor('Later'), findsOneWidget, reason: 'left of the main kolumn: a strip until tapped');
    await tester.tap(stripFor('Later'));
    await _settle(tester);
    expect(find.text(laterCard), findsOneWidget);
    expect(find.text(priorityCard), findsOneWidget, reason: 'opening Later folds nothing');
    expect(tester.takeException(), isNull);
  });

  testWidgets('a tapped card opens, and Move to moves it without dragging', (tester) async {
    final h = await pumpApp(tester, phone);
    await tester.tap(find.text(holdCard));
    await _settle(tester);
    expect(find.textContaining('Playground'), findsWidgets);
    await tester.tap(find.text('To-do').first);
    await _settle(tester);
    expect(find.text('Move to…'), findsOneWidget);
    await tester.tap(find.text('Done').last);
    await _settle(tester);
    expect(await h.laneOf(tester, holdCard), const Lane.done());
  });

  testWidgets('Priority from the card screen puts the card on top', (tester) async {
    final h = await pumpApp(tester, phone);
    const title = 'Tap a thin strip to open that kolumn';
    await tester.tap(find.text(title));
    await _settle(tester);
    await tester.tap(find.descendant(of: find.byType(CardScreen), matching: find.text('Priority')));
    await _settle(tester);
    expect((await h.cardTitled(tester, title)).priorityAt, isNotNull);
  });

  testWidgets('dark theme draws the board', (tester) async {
    await pumpApp(tester, phone, theme: 'dark');
    final ctx = tester.element(find.byTooltip('Add a card'));
    expect(Theme.of(ctx).brightness, Brightness.dark);
    expect(Theme.of(ctx).colorScheme.surface, const Color(0xFF111318));
  });

  testWidgets('a new card lands at the top of To-do', (tester) async {
    await pumpApp(tester, phone);
    await tester.tap(find.byTooltip('Add a card'));
    await _settle(tester);
    await tester.enterText(find.byType(TextField), 'Book rehearsal room');
    await tester.tap(find.text('Add card'));
    await _settle(tester);
    final first = tester.getTopLeft(find.text('Book rehearsal room')).dy;
    final other = tester.getTopLeft(find.text(holdCard)).dy;
    expect(first, lessThan(other));
  });

  testWidgets('To-do, Later and Done can be renamed and recolored on a Kolumn', (tester) async {
    final h = await pumpApp(tester, phone);
    await tester.tap(find.byTooltip('Options for this kolumn'));
    await _settle(tester);
    await tester.tap(find.text('Rename or recolor'));
    await _settle(tester);
    expect(find.text('Rename or recolor'), findsOneWidget, reason: 'the editor\'s title');
    await tester.enterText(find.byType(TextField).last, 'Ideas');
    await tester.tap(find.bySemanticsLabel('Green'));
    await tester.tap(find.text('Save'));
    await _settle(tester);
    expect(find.text('Ideas'), findsWidgets, reason: 'the open kolumn (and the hidden tray) use its new name');
    expect(find.text('To-do'), findsNothing);
    final board = (await tester.runAsync(() => h.db.select(h.db.kBoards).get()))!.single;
    expect(board.lanes, contains('"Ideas"'));
    // Done gets a new name too; its strip and the drop tray use it.
    await tester.runAsync(() => h.repo.setLaneLook(board.id, 'done', name: 'Released', color: 1));
    await _settle(tester);
    expect(stripFor('Released'), findsOneWidget);
    final g = await holdAndLift(tester, holdCard);
    expect(trayText('Released'), findsOneWidget);
    await g.up();
    await _settle(tester);
    // And back to the usual name.
    await tester.tap(find.byTooltip('Options for this kolumn'));
    await _settle(tester);
    await tester.tap(find.text('Rename or recolor'));
    await _settle(tester);
    await tester.tap(find.text('Back to "To-do"'));
    await tester.tap(find.text('Save'));
    await _settle(tester);
    expect(find.text('To-do'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('To-do has the same menu as every kolumn: move it, delete it, bring it back', (tester) async {
    final h = await pumpApp(tester, phone);
    await tester.tap(find.byTooltip('Options for this kolumn'));
    await _settle(tester);
    for (final item in ['Rename or recolor', 'Move left', 'Move right', 'Delete kolumn']) {
      expect(find.text(item), findsOneWidget, reason: item);
    }
    await tester.tap(find.text('Delete kolumn'));
    await _settle(tester);
    expect(find.textContaining('go to In progress'), findsOneWidget, reason: 'the open cards go to the next ordinary kolumn');
    await tester.tap(find.widgetWithText(FilledButton, 'Delete kolumn'));
    await _settle(tester);
    expect(stripFor('To-do'), findsNothing);
    final board = (await tester.runAsync(() => h.db.select(h.db.kBoards).get()))!.single;
    final cols = (await tester.runAsync(() => h.repo.columns(board.id)))!;
    final inProgress = cols.firstWhere((c) => c.name == 'In progress').id;
    expect((await h.cardTitled(tester, holdCard)).columnId, inProgress);
    await tester.tap(find.byTooltip('Add a card'));
    await _settle(tester);
    expect(find.text('New card in In progress'), findsOneWidget, reason: 'the + button adds to the kolumn in the middle, In progress now');
    await tester.tapAt(const Offset(20, 60));
    await _settle(tester);
    final c = await tester.runAsync(() => h.repo.addCard(board.id, 'After To-do went'));
    expect((await tester.runAsync(() => h.repo.card(c!)))!.columnId, inProgress);
    // Bring it back from the + button at the end of the row.
    await tester.ensureVisible(find.byTooltip('Add a kolumn'));
    await _settle(tester);
    await tester.tap(find.byTooltip('Add a kolumn'));
    await _settle(tester);
    await tester.tap(find.text('Bring back "To-do"'));
    await _settle(tester);
    expect(stripFor('To-do'), findsOneWidget, reason: 'To-do is back, as a strip beside the open kolumn');
    final back = await tester.runAsync(() => h.repo.addCard(board.id, 'After To-do came back'));
    expect((await tester.runAsync(() => h.repo.card(back!)))!.columnId, isNull, reason: 'new cards land in To-do again');
    expect(tester.takeException(), isNull);
  });

  testWidgets('Done moves like any kolumn', (tester) async {
    final h = await pumpApp(tester, phone);
    final board = (await tester.runAsync(() => h.db.select(h.db.kBoards).get()))!.single;
    await tester.runAsync(() => h.repo.moveLane(board.id, const Lane.done(), -1));
    await _settle(tester);
    final xs = [for (final name in ['Later', 'To-do', 'In progress', 'Waiting on', 'Done']) tester.getTopLeft(find.text(name).first).dx];
    expect(xs[4] < xs[3], isTrue, reason: 'Done is now left of Waiting on');
    expect(tester.takeException(), isNull);
  });

  testWidgets('the + button adds to the kolumn in the middle of the screen', (tester) async {
    final h = await pumpApp(tester, phone);
    await tester.tap(stripFor('In progress'));
    await _settle(tester);
    await tester.tap(find.byTooltip('Add a card'));
    await _settle(tester);
    expect(find.text('New card in In progress'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Order the merch');
    await tester.tap(find.text('Add card'));
    await _settle(tester);
    final c = await h.cardTitled(tester, 'Order the merch');
    expect((await h.laneOf(tester, 'Order the merch')).kind, LaneKind.column);
    expect(c.closedAt, isNull);
    expect(find.text('Order the merch'), findsOneWidget);
  });

  testWidgets('on a phone, swiping brings the next kolumn to the middle and it opens by itself', (tester) async {
    await pumpApp(tester, phone);
    expect(find.text(priorityCard), findsNothing);
    await tester.fling(find.byType(SingleChildScrollView).first, const Offset(-160, 0), 600);
    await _settle(tester);
    expect(find.text(priorityCard), findsOneWidget, reason: 'In progress came to the middle and opened');
    expect(stripFor('To-do'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('holding a card and dragging it down its kolumn puts it there, and the order stays', (tester) async {
    final h = await pumpApp(tester, phone);
    const target = 'Tap a card to open it, rename it, or make it Priority';
    final board = (await tester.runAsync(() => h.db.select(h.db.kBoards).get()))!.single;
    Future<List<String>> order() async {
      final cards = (await tester.runAsync(() => h.db.select(h.db.kCards).get()))!.where((c) => c.boardId == board.id && c.columnId == null && c.laterAt == null && c.closedAt == null);
      return sortForLane(const Lane.todo(), cards).map((c) => c.title).toList();
    }
    final before = await order();
    expect(before.first, holdCard);
    final start = tester.getCenter(find.text(holdCard));
    final to = tester.getBottomLeft(find.text(target)) + const Offset(40, 6);
    final g = await holdAndLift(tester, holdCard);
    for (var i = 1; i <= 10; i++) {
      await g.moveTo(Offset.lerp(start, to, i / 10)!);
      await tester.pump(const Duration(milliseconds: 30));
    }
    await g.up();
    await _settle(tester);
    final after = await order();
    expect(after.last, holdCard, reason: 'dropped below the last card');
    expect(after.toSet(), before.toSet());
    final positions = (await tester.runAsync(() => h.repo.pendingOutbox()))!.where((e) => e.name == 'card.position');
    expect(positions, isNotEmpty, reason: 'the new order goes to the hub');
    expect(tester.getTopLeft(find.text(holdCard).first).dy, greaterThan(tester.getTopLeft(find.text(target)).dy));
  });

  testWidgets('the card face has no number', (tester) async {
    await pumpApp(tester, phone);
    expect(find.textContaining(RegExp(r'^#\d')), findsNothing);
    expect(find.text('New'), findsNothing);
  });
}
