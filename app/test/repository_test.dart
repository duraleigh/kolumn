import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kolumn/data/database.dart';
import 'package:kolumn/data/lanes.dart';
import 'package:kolumn/data/repository.dart';

void main() {
  late KolumnDb db;
  late KolumnRepository repo;
  var now = 1000;

  setUp(() {
    now = 1000;
    db = KolumnDb.forTesting(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
    repo = KolumnRepository(db, clock: () => now += 10);
  });

  tearDown(() => db.close());

  Future<Set<String>> liveCols(String board) async => (await repo.columns(board)).map((c) => c.id).toSet();

  test('first launch makes one practice board, and only once', () async {
    final a = await repo.ensureStarterBoard();
    final b = await repo.ensureStarterBoard();
    expect(a, b);
    final boards = await db.select(db.kBoards).get();
    expect(boards, hasLength(1));
    expect(boards.single.name, 'Playground');
    expect(await repo.columns(a), hasLength(2));
    expect(await db.select(db.kCards).get(), hasLength(7));
  });

  test('card numbers count up across the account', () async {
    final board = await repo.createBoard('Tour');
    final c1 = await repo.addCard(board, 'One');
    final c2 = await repo.addCard(board, 'Two');
    expect((await repo.card(c1))!.number, 1);
    expect((await repo.card(c2))!.number, 2);
  });

  test('moves follow Fizzy: To-do, a column, Later, Done and back', () async {
    final board = await repo.createBoard('Tour');
    final col = await repo.addColumn(board, 'In progress', 0);
    final id = await repo.addCard(board, 'Book the van');
    final cols = await liveCols(board);
    expect(Lane.of((await repo.card(id))!, cols), const Lane.todo());

    await repo.moveCard(id, Lane.column(col));
    expect(Lane.of((await repo.card(id))!, cols), Lane.column(col));

    await repo.moveCard(id, const Lane.later());
    var c = (await repo.card(id))!;
    expect(Lane.of(c, cols), const Lane.later());
    expect(c.columnId, isNull, reason: 'Later takes a card off its column');

    await repo.moveCard(id, const Lane.done());
    c = (await repo.card(id))!;
    expect(Lane.of(c, cols), const Lane.done());
    expect(c.laterAt, isNull, reason: 'Done takes a card out of Later');

    await repo.moveCard(id, Lane.column(col));
    c = (await repo.card(id))!;
    expect(Lane.of(c, cols), Lane.column(col), reason: 'moving out of Done reopens the card');
    expect(c.closedAt, isNull);
  });

  test('every move counts as activity', () async {
    final board = await repo.createBoard('Tour');
    final id = await repo.addCard(board, 'A');
    final before = (await repo.card(id))!.lastActiveAt;
    await repo.moveCard(id, const Lane.later());
    expect((await repo.card(id))!.lastActiveAt, greaterThan(before));
  });

  test('deleting a column sends its cards back to To-do', () async {
    final board = await repo.createBoard('Tour');
    final col = await repo.addColumn(board, 'Waiting on', 2);
    final id = await repo.addCard(board, 'Permit', lane: Lane.column(col));
    await repo.deleteColumn(col);
    expect(await repo.columns(board), isEmpty);
    expect(Lane.of((await repo.card(id))!, await liveCols(board)), const Lane.todo());
  });

  test('columns swap places when moved left and right', () async {
    final board = await repo.createBoard('Tour');
    final a = await repo.addColumn(board, 'A', 0);
    final b = await repo.addColumn(board, 'B', 1);
    await repo.moveColumn(board, b, -1);
    expect((await repo.columns(board)).map((c) => c.id), [b, a]);
    await repo.moveColumn(board, b, -1);
    expect((await repo.columns(board)).map((c) => c.id), [b, a], reason: 'the leftmost column cannot go further left');
  });

  test('order inside a lane: Priority first, then most recently active', () async {
    final board = await repo.createBoard('Tour');
    final old = await repo.addCard(board, 'Old');
    final prio = await repo.addCard(board, 'Priority one');
    final fresh = await repo.addCard(board, 'Fresh');
    await repo.setPriority(prio, true);
    await repo.editCard(fresh, title: 'Fresh, edited');
    final cards = await db.select(db.kCards).get();
    final order = sortForLane(const Lane.todo(), cards).map((c) => c.id).toList();
    expect(order, [prio, fresh, old]);
  });

  test('deleted cards disappear and can be restored', () async {
    final board = await repo.createBoard('Tour');
    final id = await repo.addCard(board, 'Gone soon');
    await repo.deleteCard(id);
    expect(await repo.watchCards(board).first, isEmpty);
    await repo.restoreCard(id);
    expect(await repo.watchCards(board).first, hasLength(1));
  });

  test('every change is written down for the coming sync', () async {
    final board = await repo.createBoard('Tour');
    final id = await repo.addCard(board, 'Merch');
    await repo.moveCard(id, const Lane.done());
    final names = (await db.select(db.kOutbox).get()).map((e) => e.name).toList();
    expect(names, ['board.create', 'card.create', 'card.move']);
    final ids = (await db.select(db.kOutbox).get()).map((e) => e.mutationId).toSet();
    expect(ids, hasLength(3), reason: 'each change has its own id so it is never applied twice');
  });
}
