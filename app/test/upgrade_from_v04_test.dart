// Opens a database written by Kolumn 0.4 (schema 3) with today's code.
// Run with KOLUMN_V3_DB=<path>; skipped otherwise.
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kolumn/data/database.dart';
import 'package:kolumn/data/repository.dart';
import 'package:kolumn/planner/planner_model.dart';

void main() {
  final path = Platform.environment['KOLUMN_V3_DB'];
  test('a 0.4 phone keeps everything after the 0.5 update, and the Planner works', () async {
    final copy = File('${path!}.copy')..writeAsBytesSync(File(path).readAsBytesSync());
    final db = KolumnDb.forTesting(NativeDatabase(copy));
    final repo = KolumnRepository(db);
    final boards = await repo.watchBoards().first;
    final cards = await repo.watchCards(boards.single.id).first;
    expect(cards, hasLength(8));
    final old = cards.where((c) => c.title == 'Made in 0.4').single;
    expect(old.closedAt, isNotNull);
    expect(await repo.watchSteps(old.id).first, hasLength(1));
    expect(await repo.watchComments(old.id).first, hasLength(1));
    // The new parts.
    final p = await repo.ensureStarterPlanner();
    await repo.addTodo(p, const TodoSlot.day('2026-11-11'), 'First to-do after the update');
    await repo.setCardDue(old.id, '2026-11-13');
    await repo.setReminder(old.id, 'card', 1790000000000);
    expect((await repo.watchTodos(p).first).single.title, 'First to-do after the update');
    expect((await repo.card(old.id))!.dueAt, isNotNull);
    expect(plannerTodayProvider, isNotNull);
    await db.close();
    copy.deleteSync();
  }, skip: path == null ? 'needs KOLUMN_V3_DB' : null);
}
