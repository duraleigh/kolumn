import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kolumn/activity/activity_model.dart';
import 'package:kolumn/data/database.dart';
import 'package:kolumn/data/lane_looks.dart';
import 'package:kolumn/data/lanes.dart';
import 'package:kolumn/data/repository.dart';
import 'package:kolumn/ui/bits.dart';

void main() {
  late KolumnDb db;
  late KolumnRepository repo;
  setUp(() {
    db = KolumnDb.forTesting(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
    repo = KolumnRepository(db);
  });
  tearDown(() => db.close());

  Future<KBoard> board(String id) async => (await db.select(db.kBoards).get()).firstWhere((b) => b.id == id);

  test('a Kolumn uses the usual names until it chooses its own', () async {
    final b = await repo.createBoard('Studio album');
    final x = await board(b);
    expect([laneLook(x, 'later').name, laneLook(x, 'todo').name, laneLook(x, 'done').name], ['Later', 'To-do', 'Done']);
    expect(laneLook(x, 'later').custom, isFalse);
  });

  test('renaming and recoloring one of the three goes to the hub, and a blank name means the usual one', () async {
    final b = await repo.createBoard('Studio album');
    await repo.setLaneLook(b, 'todo', name: 'Ideas', color: 1);
    await repo.setLaneLook(b, 'done', name: '', color: 3);
    final x = await board(b);
    expect(laneLook(x, 'todo').name, 'Ideas');
    expect(laneLook(x, 'todo').color, 1);
    expect(laneLook(x, 'done').name, 'Done');
    expect(laneLook(x, 'done').color, 3);
    final sent = [for (final e in await repo.pendingOutbox()) if (e.name == 'board.lane') jsonDecode(e.args)];
    expect(sent.first, {'id': b, 'lane': 'todo', 'name': 'Ideas', 'color': 1});
    expect(sent.last, {'id': b, 'lane': 'done', 'name': null, 'color': 3});
  });

  test('the names other people chose arrive with the Kolumn', () async {
    await repo.applyPull({
      'cursor': 1,
      'boardIds': ['b1'],
      'boards': [
        {
          'id': 'b1',
          'name': 'Releases',
          'lanes': {
            'later': {'name': 'Parked', 'color': 3},
            'done': {'name': 'Released'},
          },
          'allAccess': true,
          'createdAt': 1,
          'updatedAt': 1,
        },
        {'id': 'b2', 'name': 'Plain', 'lanes': <String, Object>{}, 'allAccess': true, 'createdAt': 1, 'updatedAt': 1},
      ],
    });
    final x = await board('b1');
    expect(laneLook(x, 'later').name, 'Parked');
    expect(laneLook(x, 'later').color, 3);
    expect(laneLook(x, 'done').name, 'Released');
    expect(laneLook(x, 'done').color, 7, reason: 'no color chosen: the usual one');
    expect(laneLook(await board('b2'), 'todo').name, 'To-do');
  });

  test('history and Activity say the name the kolumn had when the card moved', () {
    expect(historyLine('card_moved', {'to': 'done', 'column': 'Released'}, 'Riley'), 'Riley moved this to Released');
    expect(historyLine('card_moved', {'to': 'done', 'column': ''}, 'Riley'), 'Riley moved this to Done', reason: 'older history lines');
    expect(activityLine('card_moved', {'to': 'later', 'column': 'Parked'}, who: 'You', title: 'Track 4', me: 7), 'You moved Track 4 to Parked');
  });

  test('the usual order, moving Done to the far left, and where open cards go', () async {
    final b = await repo.createBoard('Releases');
    final c1 = await repo.addColumn(b, 'Mixing', 0);
    var x = await board(b);
    final cols = await repo.columns(b);
    expect(laneOrder(x, cols).map((e) => e.$1.key), ['later', 'todo', 'col:$c1', 'done']);
    await repo.moveLane(b, const Lane.done(), -1);
    await repo.moveLane(b, const Lane.done(), -1);
    await repo.moveLane(b, const Lane.done(), -1);
    x = await board(b);
    expect(laneOrder(x, cols).first.$1, const Lane.done());
    expect(homeLane(x, cols), const Lane.todo());
    expect(homeLane(x, cols, exclude: const Lane.todo()), Lane.column(c1), reason: 'not Later while an ordinary kolumn is left');
    expect(homeLane(x, const [], exclude: const Lane.todo()), const Lane.later(), reason: 'Later only when nothing else is left');
    final moves = [for (final e in await repo.pendingOutbox()) if (e.name == 'board.lane' || e.name == 'column.move') jsonDecode(e.args)];
    expect(moves.where((m) => m['lane'] == 'done').map((m) => m['pos']), isNotEmpty);
  });

  test('deleting To-do moves its open cards; deleting Later stops the tidy-up; the last place cannot go', () async {
    final b = await repo.createBoard('Releases');
    final c1 = await repo.addColumn(b, 'Mixing', 0);
    final open = await repo.addCard(b, 'Open');
    final done = await repo.addCard(b, 'Finished', lane: const Lane.done());
    final later = await repo.addCard(b, 'Parked', lane: const Lane.later());
    expect(await repo.setLaneHidden(b, 'todo', true), isTrue);
    expect((await repo.card(open))!.columnId, c1);
    expect((await repo.card(done))!.closedAt, isNotNull);
    final n = await repo.addCard(b, 'New');
    expect((await repo.card(n))!.columnId, c1, reason: 'new cards land where open cards go');
    await repo.moveCard(open, const Lane.todo());
    expect((await repo.card(open))!.columnId, c1, reason: 'asking for a deleted To-do lands there too');
    expect(await repo.deleteColumn(c1), isTrue, reason: 'Later is still left');
    expect((await repo.card(open))!.laterAt, isNotNull);
    expect(await repo.setLaneHidden(b, 'later', true), isFalse, reason: 'it is the last place for open cards');
    expect(await repo.setLaneHidden(b, 'todo', false), isTrue);
    expect(await repo.setLaneHidden(b, 'later', true), isTrue);
    expect((await repo.card(later))!.laterAt, isNull, reason: 'its cards came back to To-do');
    final x = await board(b);
    expect(laneLook(x, 'later').hidden, isTrue);
    expect(laneLook(x, 'later').name, 'Later', reason: 'hiding keeps its name for when it comes back');
    final sent = [for (final e in await repo.pendingOutbox()) if (e.name == 'board.lane') jsonDecode(e.args)];
    expect(sent.map((m) => '${m['lane']}:${m['hidden']}'), ['todo:true', 'todo:false', 'later:true']);
  });
}
