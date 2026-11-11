// Opens a database written by Kolumn 0.5.1 (schema 4) with today's code.
// Run with KOLUMN_V4_DB=<path>; skipped otherwise.
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kolumn/data/database.dart';
import 'package:kolumn/data/repository.dart';

void main() {
  final path = Platform.environment['KOLUMN_V4_DB'];
  test('a 0.5 phone keeps everything after the 0.6 update, and alerts and saved views work', () async {
    final copy = File('${path!}.copy')..writeAsBytesSync(File(path).readAsBytesSync());
    final db = KolumnDb.forTesting(NativeDatabase(copy));
    final repo = KolumnRepository(db);
    final boards = await repo.watchBoards().first;
    final cards = await repo.watchCards(boards.single.id).first;
    expect(cards, hasLength(8));
    expect(cards.where((c) => c.title == 'Made in 0.5').single.dueAt, isNotNull);
    final planners = await repo.watchPlanners().first;
    expect((await repo.watchTodos(planners.single.id).first).single.title, 'A to-do from 0.5');
    expect(await repo.setting('home.start'), 'planner', reason: 'the Opens on choice is kept');
    await repo.saveView('Mine', {'status': 'priority'});
    await repo.setBoardFollow(boards.single.id, false);
    expect((await repo.watchViews().first).single.name, 'Mine');
    expect(await repo.watchNotifications().first, isEmpty);
    await db.close();
    copy.deleteSync();
  }, skip: path == null ? 'needs KOLUMN_V4_DB' : null);
}
