// Opens a database written by Kolumn 0.7.0 (schema 8) with today's code.
// Run with KOLUMN_V8_DB=<path>; skipped otherwise.
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kolumn/data/database.dart';
import 'package:kolumn/data/due.dart';
import 'package:kolumn/data/repository.dart';
import 'package:kolumn/planner/days.dart';
import 'package:kolumn/planner/planner_model.dart';

void main() {
  final path = Platform.environment['KOLUMN_V8_DB'];
  test('a 0.7 phone keeps everything after the 0.8 update; the new parts work', () async {
    final copy = File('${path!}.copy')..writeAsBytesSync(File(path).readAsBytesSync());
    final db = KolumnDb.forTesting(NativeDatabase(copy));
    final repo = KolumnRepository(db);
    final b = (await repo.watchBoards().first).single;
    expect(b.name, 'Fall tour');
    expect(b.plannerIds, '[]', reason: 'an existing Kolumn starts at None');
    expect(b.shareKey, isNull);
    expect(b.lanes, contains('Ideas'));
    final cards = await repo.watchCards(b.id).first;
    final old = cards.firstWhere((c) => c.title == 'Made in 0.7');
    expect(dueDay(old.dueAt!, hasTime: old.dueHasTime), '2026-11-20', reason: 'a day-only date from 0.7 keeps its day');
    expect(old.pinnedAt, isNull);
    expect(dueState(dueAt: old.dueAt, hasTime: old.dueHasTime, doneAt: null, now: DateTime(2026, 11, 20, 22).millisecondsSinceEpoch), DueState.dueToday);
    expect(dueState(dueAt: old.dueAt, hasTime: old.dueHasTime, doneAt: null, now: DateTime(2026, 11, 21, 0, 1).millisecondsSinceEpoch), DueState.late, reason: 'late after 11:59 PM of its day');
    final p = (await repo.watchPlanners().first).single;
    final t = (await repo.watchTodos(p.id).first).single;
    expect(t.title, 'A to-do from 0.7');
    expect(t.dueAt, isNull);
    expect((await repo.watchNotifications().first).single.kind, 'card');
    expect(await repo.setting('home.start'), 'planner');
    // The new parts.
    await repo.setTodoDue(t, endOfDayMs('2026-11-30'));
    await repo.setTodoWatch(t.id, true);
    await repo.setPinTop(old.id, true);
    await repo.setBoardPlanners(b.id, [p.id]);
    expect(kolumnAllowsPlanner((await repo.watchBoards().first).single, p.id), isTrue);
    expect((await repo.card(old.id))!.pinnedAt, isNotNull);
    expect((await repo.todo(t.id))!.dueAt, endOfDayMs('2026-11-30'));
    expect(await repo.watchAllTodoEvents().first, isEmpty);
    await db.close();
    copy.deleteSync();
  }, skip: path == null ? 'needs KOLUMN_V8_DB' : null);
}
