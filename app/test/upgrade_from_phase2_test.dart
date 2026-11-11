// Opens a database written by the Phase 2 app (schema 1) with today's code.
// Run with KOLUMN_V1_DB=<path to a Phase 2 database file>; skipped otherwise.
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kolumn/data/database.dart';
import 'package:kolumn/data/repository.dart';

void main() {
  final path = Platform.environment['KOLUMN_V1_DB'];
  test('a Phase 2 phone keeps every board, card and unsent change after the update', () async {
    final copy = File('${path!}.copy')..writeAsBytesSync(File(path).readAsBytesSync());
    final db = KolumnDb.forTesting(NativeDatabase(copy));
    final repo = KolumnRepository(db);
    final boards = await repo.watchBoards().first;
    expect(boards.single.name, 'Playground');
    expect(boards.single.allAccess, isTrue);
    final cards = await repo.watchCards(boards.single.id).first;
    expect(cards, hasLength(8));
    expect(cards.where((c) => c.title == 'Made in Phase 2').single.closedAt, isNotNull);
    expect(cards.every((c) => !c.synced), isTrue, reason: 'nothing is marked as sent before it is');
    expect(await repo.pendingCount(), greaterThan(10), reason: 'all of Phase 2 waits to go up on first sign-in');
    await repo.editCard(cards.first.id, title: 'Edited after update');
    expect((await repo.watchPeople().first), isEmpty, reason: 'the new team list exists');
    await db.close();
    copy.deleteSync();
  }, skip: path == null ? 'needs KOLUMN_V1_DB' : null);
}
