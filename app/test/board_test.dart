import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kolumn/board/board_screen.dart';
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
    expect(find.text('Add a card'), findsOneWidget);
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
    expect(find.text('Add a card'), findsNothing, reason: 'To-do folded into a strip');
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

  testWidgets('tablet: To-do stays open and at most one more column opens beside it', (tester) async {
    await pumpApp(tester, tablet);
    expect(find.text('Add a card'), findsOneWidget);
    await tester.tap(stripFor('In progress'));
    await _settle(tester);
    expect(find.text('Add a card'), findsOneWidget, reason: 'To-do is still open');
    expect(find.text(priorityCard), findsOneWidget);
    expect(tester.getRect(stripFor('Later')).left, greaterThanOrEqualTo(0), reason: 'everything fits on a tablet');
    await tester.tap(stripFor('Later'));
    await _settle(tester);
    expect(find.text(laterCard), findsOneWidget);
    expect(find.text(priorityCard), findsNothing, reason: 'opening Later folded In progress');
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
    await tester.tap(find.byTooltip('Make Priority'));
    await _settle(tester);
    expect((await h.cardTitled(tester, title)).priorityAt, isNotNull);
  });

  testWidgets('dark theme draws the board', (tester) async {
    await pumpApp(tester, phone, theme: 'dark');
    final ctx = tester.element(find.text('Add a card'));
    expect(Theme.of(ctx).brightness, Brightness.dark);
    expect(Theme.of(ctx).colorScheme.surface, const Color(0xFF111318));
  });

  testWidgets('a new card lands at the top of To-do', (tester) async {
    await pumpApp(tester, phone);
    await tester.tap(find.text('Add a card'));
    await _settle(tester);
    await tester.enterText(find.byType(TextField), 'Book rehearsal room');
    await tester.tap(find.text('Add card'));
    await _settle(tester);
    final first = tester.getTopLeft(find.text('Book rehearsal room')).dy;
    final other = tester.getTopLeft(find.text(holdCard)).dy;
    expect(first, lessThan(other));
  });
}
