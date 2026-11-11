// Opens a database written by Kolumn 0.3 (schema 2) with today's code.
// Run with KOLUMN_V2_DB=<path>; skipped otherwise.
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kolumn/data/database.dart';
import 'package:kolumn/data/repository.dart';

void main() {
  final path = Platform.environment['KOLUMN_V2_DB'];
  test('a 0.3 phone keeps everything after the 0.4 update, and the new details work', () async {
    final copy = File('${path!}.copy')..writeAsBytesSync(File(path).readAsBytesSync());
    final db = KolumnDb.forTesting(NativeDatabase(copy));
    final repo = KolumnRepository(db);
    final boards = await repo.watchBoards().first;
    final cards = await repo.watchCards(boards.single.id).first;
    expect(cards, hasLength(8));
    expect(cards.every((c) => c.status == 'published'), isTrue, reason: 'old cards are not drafts');
    expect(cards.where((c) => c.title == 'Made in 0.3').single.closedAt, isNotNull);
    await repo.addStep(cards.first.id, 'A step after the update');
    await repo.addComment(cards.first.id, 'A comment after the update');
    expect(await repo.watchSteps(cards.first.id).first, hasLength(1));
    expect(await repo.watchComments(cards.first.id).first, hasLength(1));
    await db.close();
    copy.deleteSync();
  }, skip: path == null ? 'needs KOLUMN_V2_DB' : null);
}
