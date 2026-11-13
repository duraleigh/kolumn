import 'package:drift/drift.dart' hide isNull, isNotNull, Column;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kolumn/board/show_in_planners.dart';
import 'package:kolumn/data/database.dart';
import 'package:kolumn/data/lanes.dart';
import 'package:kolumn/data/repository.dart';
import 'package:kolumn/planner/planner_model.dart';
import 'package:kolumn/state/providers.dart';
import 'package:kolumn/theme/app_theme.dart';

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('Show in planners: the Kolumn chooses None or Only these; a kolumn can narrow it; a planner shows it only when both agree', (tester) async {
    final db = KolumnDb.forTesting(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
    final repo = KolumnRepository(db);
    late String board, col, tour, family;
    await tester.runAsync(() async {
      await repo.setSetting('me.id', '7');
      board = await repo.createBoard('Life');
      col = await repo.addColumn(board, 'Laws I intend to break', 1);
      tour = await repo.createPlanner('Tour planner', boardIds: [board]);
      family = await repo.createPlanner('Evil-doing planner', boardIds: [board]);
      final c = await repo.addCard(board, 'Jaywalk');
      await repo.moveCard(c, Lane.column(col));
      await repo.setCardDue(c, '2026-11-20');
    });
    addTearDown(() => tester.runAsync(db.close));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [repositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          theme: KolumnTheme.light(),
          home: Consumer(
            builder: (context, ref, _) => Scaffold(
              body: Column(
                children: [
                  TextButton(onPressed: () => showKolumnPlanners(context, ref, board), child: const Text('kolumn settings')),
                  TextButton(onPressed: () => showLanePlanners(context, ref, boardId: board, lane: col, laneName: 'Laws I intend to break'), child: const Text('kolumn menu')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await settle(tester);
    Future<KBoard> b() async => (await tester.runAsync(() => repo.watchBoards().first))!.single;
    Future<PlannerData> data(String p) async => (await tester.runAsync(() async => PlannerData(
          planner: (await repo.watchPlanners().first).firstWhere((x) => x.id == p),
          todos: const [],
          marks: const {},
          cards: await repo.watchAllCards().first,
          boards: await repo.watchBoards().first,
          columns: await db.select(db.kColumns).get(),
          today: '2026-11-13',
        )))!;

    expect((await data(tour)).entries('2026-11-20'), isEmpty, reason: 'a Kolumn starts at None');
    await tester.tap(find.text('kolumn settings'));
    await settle(tester);
    expect(find.text('None'), findsOneWidget);
    await tester.tap(find.text('Only these'));
    await settle(tester);
    await tester.tap(find.text('Evil-doing planner'));
    await settle(tester);
    expect(kolumnAllowsPlanner(await b(), family), isTrue);
    expect(kolumnAllowsPlanner(await b(), tour), isFalse);
    expect((await data(family)).entries('2026-11-20').single.title, 'Jaywalk');
    expect((await data(tour)).entries('2026-11-20'), isEmpty, reason: 'the Tour planner has it switched on, but the Kolumn did not allow it');
    Navigator.of(tester.element(find.text('Only these'))).pop();
    await settle(tester);

    await tester.tap(find.text('kolumn menu'));
    await settle(tester);
    await tester.tap(find.text('Only some of those (or none)'));
    await settle(tester);
    await tester.tap(find.widgetWithText(CheckboxListTile, 'Evil-doing planner'));
    await settle(tester);
    expect((await data(family)).entries('2026-11-20'), isEmpty, reason: '"Laws I intend to break" narrowed to no planners');
    final sent = [for (final e in (await tester.runAsync(repo.pendingOutbox))!) e.name];
    expect(sent, containsAll(['board.planners', 'column.planners']));
  });
}
