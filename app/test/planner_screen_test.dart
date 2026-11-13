import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kolumn/data/database.dart';
import 'package:kolumn/data/repository.dart';
import 'package:kolumn/main.dart';
import 'package:kolumn/planner/planner_model.dart';
import 'package:kolumn/state/providers.dart';
import 'package:kolumn/sync/hub_client.dart';
import 'package:kolumn/sync/sync_service.dart';
import 'package:kolumn/ui/item_sheet.dart';

const phone = Size(390, 844);
const smallPhone = Size(320, 640);
const computer = Size(1280, 820);

class P {
  P(this.db, this.repo, this.planner);
  final KolumnDb db;
  final KolumnRepository repo;
  final String planner;

  Future<List<KTodo>> todos(WidgetTester t) async => (await t.runAsync(() => db.select(db.kTodos).get()))!;
}

/// The app, signed in, on the Planner tab, with "today" pinned to Wed 11 Nov 2026.
Future<P> pumpPlanner(WidgetTester tester, Size size, {String theme = 'light'}) async {
  tester.view.devicePixelRatio = 3;
  tester.view.physicalSize = size * 3;
  addTearDown(tester.view.reset);
  final db = KolumnDb.forTesting(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
  final repo = KolumnRepository(db);
  late String planner;
  await tester.runAsync(() async {
    await repo.setSetting('me.id', '7');
    final board = await repo.ensureStarterBoard();
    planner = await repo.ensureStarterPlanner();
    await repo.setSetting('theme', theme);
    await repo.setSetting('home.start', 'planner');
    await repo.addTodo(planner, const TodoSlot.day('2026-11-11'), 'Vocal warm-up');
    await repo.addTodo(planner, const TodoSlot.day('2026-11-12'), 'Rehearsal at the studio');
    await repo.addTodo(planner, const TodoSlot.someday(1), 'Learn the new arrangement');
    final card = await repo.addCard(board, 'Confirm hotel block');
    await repo.setCardDue(card, '2026-11-09');
    await repo.setBoardPlanners(board, [planner]);
  });
  addTearDown(() => tester.runAsync(db.close));
  final sync = SyncService(repo: repo, hub: HubClient(credentials: MemoryCredentialStore(), server: 'https://hub.invalid'));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        repositoryProvider.overrideWithValue(repo),
        syncServiceProvider.overrideWithValue(sync),
        syncStatusProvider.overrideWith((ref) => Stream.value(SyncStatus(SyncState.upToDate, lastSynced: DateTime.now()))),
        plannerTodayProvider.overrideWithValue('2026-11-11'),
        plannerNowProvider.overrideWithValue(() => DateTime(2026, 11, 11, 10).millisecondsSinceEpoch),
      ],
      child: const KolumnApp(),
    ),
  );
  await settle(tester);
  return P(db, repo, planner);
}

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  for (final size in [phone, smallPhone, computer]) {
    testWidgets('the week shows each day, its to-dos, the late card in red, and Someday (${size.width.toInt()} wide)', (tester) async {
      await pumpPlanner(tester, size);
      expect(find.text('9 Nov'), findsOneWidget);
      expect(find.text('11 Nov'), findsOneWidget);
      expect(find.text('Vocal warm-up'), findsOneWidget);
      expect(find.text('Confirm hotel block'), findsOneWidget);
      expect(tester.takeException(), isNull);
      // Someday is below the week; scroll to it on a phone.
      await tester.scrollUntilVisible(find.text('Learn the new arrangement'), 300, scrollable: find.byType(Scrollable).first);
      expect(find.text('Someday'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('tapping an empty line and typing adds a to-do; Enter keeps the next line open', (tester) async {
    final p = await pumpPlanner(tester, phone);
    // The first empty line under Wednesday 11 Nov (after "Vocal warm-up").
    final lines = find.bySemanticsLabel('Add a to-do');
    expect(lines, findsWidgets);
    final wedHeading = tester.getTopLeft(find.text('11 Nov'));
    final firstUnderWed = lines.evaluate().map((e) => find.byWidget(e.widget)).firstWhere((f) => tester.getTopLeft(f.first).dy > wedHeading.dy);
    await tester.tap(firstUnderWed.first);
    await settle(tester);
    await tester.enterText(find.byType(TextField).first, 'Radio interview prep');
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await settle(tester);
    await tester.enterText(find.byType(TextField).first, 'Text Jamie');
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await settle(tester);
    final wed = (await p.todos(tester)).where((t) => t.day == '2026-11-11').map((t) => t.title).toList();
    expect(wed, ['Vocal warm-up', 'Radio interview prep', 'Text Jamie']);
  });

  testWidgets('ticking a to-do crosses it out and sinks it', (tester) async {
    final p = await pumpPlanner(tester, phone);
    final row = find.ancestor(of: find.text('Vocal warm-up'), matching: find.byType(Row)).first;
    await tester.tap(find.descendant(of: row, matching: find.bySemanticsLabel('Mark done')));
    await settle(tester);
    final t = (await p.todos(tester)).firstWhere((t) => t.title == 'Vocal warm-up');
    expect(t.doneAt, isNotNull);
    final text = tester.widget<Text>(find.text('Vocal warm-up'));
    expect(text.style!.decoration, TextDecoration.lineThrough);
  });

  testWidgets('holding a to-do and dragging it onto another day moves it there', (tester) async {
    final p = await pumpPlanner(tester, phone);
    final from = tester.getCenter(find.text('Vocal warm-up'));
    final to = tester.getCenter(find.text('12 Nov'));
    final g = await tester.startGesture(from);
    await tester.pump(const Duration(milliseconds: 500));
    for (var i = 1; i <= 10; i++) {
      await g.moveTo(Offset.lerp(from, to + const Offset(0, 30), i / 10)!);
      await tester.pump(const Duration(milliseconds: 16));
    }
    await g.up();
    await settle(tester);
    expect((await p.todos(tester)).firstWhere((t) => t.title == 'Vocal warm-up').day, '2026-11-12');
  });

  testWidgets('on a computer, a mouse drag moves a to-do to Someday', (tester) async {
    final p = await pumpPlanner(tester, computer);
    final from = tester.getCenter(find.text('Vocal warm-up'));
    final to = tester.getCenter(find.text('Learn the new arrangement'));
    final g = await tester.startGesture(from, kind: PointerDeviceKind.mouse);
    for (var i = 1; i <= 12; i++) {
      await g.moveTo(Offset.lerp(from, to, i / 12)!);
      await tester.pump(const Duration(milliseconds: 16));
    }
    await g.up();
    await settle(tester);
    final t = (await p.todos(tester)).firstWhere((t) => t.title == 'Vocal warm-up');
    expect([t.day, t.list], [null, 1]);
  });

  testWidgets('tapping a to-do opens its sheet with the bottom bar', (tester) async {
    await pumpPlanner(tester, phone);
    await tester.tap(find.text('Rehearsal at the studio'));
    await settle(tester);
    expect(find.text('Add a note'), findsOneWidget);
    expect(find.byTooltip('Repeat'), findsOneWidget);
    expect(find.byTooltip('Reminder'), findsOneWidget);
    expect(find.byTooltip('Who it\'s for'), findsOneWidget);
    expect(find.textContaining('Tomorrow'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the to-do pop-up: a due pill, no tick beside the title, no Heading button, the card\'s buttons', (tester) async {
    await pumpPlanner(tester, phone);
    await tester.tap(find.text('Rehearsal at the studio'));
    await settle(tester);
    expect(find.text('Add a due date'), findsOneWidget);
    expect(find.text('Heading'), findsNothing);
    expect(find.descendant(of: find.byType(ItemSheetFrame), matching: find.byType(CheckCircle)), findsNothing, reason: 'the big check at the bottom marks it done');
    for (final b in ['Photo', 'Camera', 'File']) {
      expect(find.widgetWithText(ActionChip, b), findsOneWidget);
    }
    // "Add a step" and the title stretch to the same right edge as the note.
    final note = tester.getTopRight(find.widgetWithText(TextField, 'Add a note'));
    final step = tester.getTopRight(find.widgetWithText(TextField, 'Add a step'));
    final title = tester.getTopRight(find.widgetWithText(TextField, 'Rehearsal at the studio'));
    expect(step.dx, note.dx);
    expect(title.dx, note.dx);
    await tester.tap(find.byTooltip('More'));
    await settle(tester);
    expect(find.text('Stop following'), findsOneWidget, reason: 'its maker follows it automatically');
    expect(find.text('Move to a different date'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('month view shows tags and today; tapping a day opens it', (tester) async {
    await pumpPlanner(tester, phone, theme: 'dark');
    await tester.tap(find.byTooltip('Month'));
    await settle(tester);
    expect(find.text('Nov 2026'), findsOneWidget);
    expect(find.text('Vocal warm-up'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel(RegExp(r'^Thu, 12 Nov')));
    await settle(tester);
    expect(find.text('12 Nov'), findsOneWidget);
    expect(find.text('Thursday'), findsOneWidget);
    expect(find.text('Rehearsal at the studio'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the arrows step through weeks; the title goes back to today', (tester) async {
    await pumpPlanner(tester, phone);
    await tester.tap(find.byTooltip('Next week'));
    await settle(tester);
    expect(find.text('16 Nov'), findsOneWidget);
    expect(find.text('Vocal warm-up'), findsNothing);
    await tester.tap(find.text('Nov 2026'));
    await settle(tester);
    expect(find.text('Vocal warm-up'), findsOneWidget);
  });

  testWidgets('searching finds a to-do and a card', (tester) async {
    await pumpPlanner(tester, phone);
    await tester.tap(find.byTooltip('Search'));
    await settle(tester);
    await tester.enterText(find.byType(TextField).first, 'hotel');
    await settle(tester);
    expect(find.text('Confirm hotel block'), findsOneWidget);
    expect(find.textContaining('card #'), findsOneWidget);
  });

  testWidgets('the planner settings show the switches and the Kolumns', (tester) async {
    await pumpPlanner(tester, phone);
    await tester.tap(find.text('My planner'));
    await settle(tester);
    await tester.tap(find.byTooltip('Settings for My planner'));
    await settle(tester);
    expect(find.text('Move unfinished to the next day'), findsOneWidget);
    expect(find.text('Playground'), findsOneWidget);
    expect(find.text('Cards from Kolumns'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the bottom bar switches between Kolumns and the Planner', (tester) async {
    await pumpPlanner(tester, phone);
    await tester.tap(find.text('Kolumns'));
    await settle(tester);
    expect(find.text('Playground'), findsOneWidget);
    await tester.tap(find.text('Planner'));
    await settle(tester);
    expect(find.text('Vocal warm-up'), findsOneWidget);
  });

  testWidgets('Settings: "Opens on" chooses the first screen; switching tabs does not change it', (tester) async {
    final p = await pumpPlanner(tester, phone);
    expect(find.text('Vocal warm-up'), findsOneWidget, reason: 'set to open on the Planner');
    await tester.tap(find.text('My planner'));
    await settle(tester);
    await tester.tap(find.text('App settings'));
    await settle(tester);
    expect(find.text('Opens on'), findsOneWidget);
    await tester.tap(find.descendant(of: find.byType(SegmentedButton<String>), matching: find.text('Kolumns')));
    await settle(tester);
    expect(await tester.runAsync(() => p.repo.setting('home.start')), 'kolumns');
    await tester.tapAt(const Offset(20, 20));
    await settle(tester);
    await tester.tap(find.text('Kolumns').last);
    await settle(tester);
    await tester.tap(find.text('Planner').last);
    await settle(tester);
    expect(await tester.runAsync(() => p.repo.setting('home.start')), 'kolumns', reason: 'moving between tabs never changes the choice');
    expect(tester.takeException(), isNull);
  });

  testWidgets('with no choice made, Kolumn opens on Kolumns', (tester) async {
    final p = await pumpPlanner(tester, phone);
    await tester.runAsync(() async {
      await (p.db.delete(p.db.kSettings)..where((s) => s.key.equals('home.start'))).go();
    });
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          repositoryProvider.overrideWithValue(p.repo),
          syncServiceProvider.overrideWithValue(SyncService(repo: p.repo, hub: HubClient(credentials: MemoryCredentialStore(), server: 'https://hub.invalid'))),
          syncStatusProvider.overrideWith((ref) => Stream.value(SyncStatus(SyncState.upToDate, lastSynced: DateTime.now()))),
          plannerTodayProvider.overrideWithValue('2026-11-11'),
        ],
        child: const KolumnApp(),
      ),
    );
    await settle(tester);
    expect(find.text('Playground'), findsOneWidget);
    expect(find.byTooltip('Add a card'), findsOneWidget);
  });
}
