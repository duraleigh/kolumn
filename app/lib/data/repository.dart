import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'database.dart';
import 'lanes.dart';

typedef Clock = int Function();

int _systemClock() => DateTime.now().toUtc().millisecondsSinceEpoch;

/// Every read and change Kolumn makes, in one place. Screens never touch the
/// tables directly. Each change also lands in the outbox for Phase 3's sync.
class KolumnRepository {
  KolumnRepository(this.db, {Clock? clock, Uuid? uuid}) : _now = clock ?? _systemClock, _uuid = uuid ?? const Uuid();

  final KolumnDb db;
  final Clock _now;
  final Uuid _uuid;

  String newId() => _uuid.v7();

  // ---------------------------------------------------------------- reading

  Stream<List<KBoard>> watchBoards() =>
      (db.select(db.kBoards)
            ..where((b) => b.deletedAt.isNull())
            ..orderBy([(b) => OrderingTerm.asc(b.createdAt)]))
          .watch();

  Stream<List<KColumn>> watchColumns(String boardId) =>
      (db.select(db.kColumns)
            ..where((c) => c.boardId.equals(boardId) & c.deletedAt.isNull())
            ..orderBy([(c) => OrderingTerm.asc(c.position)]))
          .watch();

  Stream<List<KCard>> watchCards(String boardId) => (db.select(db.kCards)..where((c) => c.boardId.equals(boardId) & c.deletedAt.isNull())).watch();

  Stream<KCard?> watchCard(String id) => (db.select(db.kCards)..where((c) => c.id.equals(id))).watchSingleOrNull();

  Future<KCard?> card(String id) => (db.select(db.kCards)..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<List<KColumn>> columns(String boardId) =>
      (db.select(db.kColumns)
            ..where((c) => c.boardId.equals(boardId) & c.deletedAt.isNull())
            ..orderBy([(c) => OrderingTerm.asc(c.position)]))
          .get();

  Stream<String?> watchSetting(String key) => (db.select(db.kSettings)..where((s) => s.key.equals(key))).watchSingleOrNull().map((row) => row?.value);

  Future<String?> setting(String key) async => (await (db.select(db.kSettings)..where((s) => s.key.equals(key))).getSingleOrNull())?.value;

  Future<void> setSetting(String key, String value) => db.into(db.kSettings).insertOnConflictUpdate(KSettingsCompanion.insert(key: key, value: value));

  // ---------------------------------------------------------------- outbox

  Future<void> _record(String name, Map<String, Object?> args) async {
    await db.into(db.kOutbox).insert(KOutboxCompanion.insert(mutationId: newId(), name: name, args: jsonEncode(args), clientTs: _now()));
  }

  // ---------------------------------------------------------------- boards

  Future<String> createBoard(String name) async {
    final id = newId();
    final now = _now();
    await db.transaction(() async {
      await db.into(db.kBoards).insert(KBoardsCompanion.insert(id: id, name: name.trim(), createdAt: now, updatedAt: now));
      await _record('board.create', {'id': id, 'name': name.trim()});
    });
    return id;
  }

  Future<void> renameBoard(String id, String name) => db.transaction(() async {
    await (db.update(db.kBoards)..where((b) => b.id.equals(id))).write(KBoardsCompanion(name: Value(name.trim()), updatedAt: Value(_now())));
    await _record('board.rename', {'id': id, 'name': name.trim()});
  });

  Future<void> deleteBoard(String id) => db.transaction(() async {
    final now = _now();
    await (db.update(db.kBoards)..where((b) => b.id.equals(id))).write(KBoardsCompanion(deletedAt: Value(now), updatedAt: Value(now)));
    await _record('board.delete', {'id': id});
  });

  // ---------------------------------------------------------------- columns

  Future<String> addColumn(String boardId, String name, int color) async {
    final id = newId();
    final now = _now();
    await db.transaction(() async {
      final existing = await columns(boardId);
      final pos = existing.isEmpty ? 1.0 : existing.last.position + 1.0;
      await db
          .into(db.kColumns)
          .insert(KColumnsCompanion.insert(id: id, boardId: boardId, name: name.trim(), color: Value(color), position: pos, createdAt: now, updatedAt: now));
      await _record('column.create', {'id': id, 'boardId': boardId, 'name': name.trim(), 'color': color, 'position': pos});
    });
    return id;
  }

  Future<void> updateColumn(String id, {String? name, int? color}) => db.transaction(() async {
    await (db.update(db.kColumns)..where((c) => c.id.equals(id))).write(
      KColumnsCompanion(
        name: name == null ? const Value.absent() : Value(name.trim()),
        color: color == null ? const Value.absent() : Value(color),
        updatedAt: Value(_now()),
      ),
    );
    await _record('column.update', {'id': id, 'name': name?.trim(), 'color': color});
  });

  /// Swaps a column with its neighbor. [direction] is -1 (left) or 1 (right).
  Future<void> moveColumn(String boardId, String id, int direction) => db.transaction(() async {
    final cols = await columns(boardId);
    final i = cols.indexWhere((c) => c.id == id);
    final j = i + direction;
    if (i < 0 || j < 0 || j >= cols.length) return;
    final a = cols[i], b = cols[j];
    final now = _now();
    await (db.update(db.kColumns)..where((c) => c.id.equals(a.id))).write(KColumnsCompanion(position: Value(b.position), updatedAt: Value(now)));
    await (db.update(db.kColumns)..where((c) => c.id.equals(b.id))).write(KColumnsCompanion(position: Value(a.position), updatedAt: Value(now)));
    await _record('column.move', {'id': a.id, 'position': b.position, 'swappedWith': b.id, 'otherPosition': a.position});
  });

  /// Deletes a column. Its open cards go back to To-do, as in Fizzy.
  Future<void> deleteColumn(String id) => db.transaction(() async {
    final now = _now();
    await (db.update(db.kColumns)..where((c) => c.id.equals(id))).write(KColumnsCompanion(deletedAt: Value(now), updatedAt: Value(now)));
    await (db.update(db.kCards)..where((c) => c.columnId.equals(id))).write(KCardsCompanion(columnId: const Value(null), updatedAt: Value(now)));
    await _record('column.delete', {'id': id});
  });

  // ---------------------------------------------------------------- cards

  Future<int> _nextNumber() async {
    final current = int.tryParse(await setting('cards.counter') ?? '') ?? 0;
    final next = current + 1;
    await setSetting('cards.counter', '$next');
    return next;
  }

  Future<String> addCard(String boardId, String title, {Lane lane = const Lane.todo(), bool priority = false}) async {
    final id = newId();
    await db.transaction(() async {
      final now = _now();
      final number = await _nextNumber();
      await db
          .into(db.kCards)
          .insert(
            KCardsCompanion.insert(
              id: id,
              boardId: boardId,
              number: number,
              title: title.trim().isEmpty ? 'Untitled' : title.trim(),
              columnId: Value(lane.kind == LaneKind.column ? lane.columnId : null),
              closedAt: Value(lane.kind == LaneKind.done ? now : null),
              laterAt: Value(lane.kind == LaneKind.later ? now : null),
              laterReason: Value(lane.kind == LaneKind.later ? 'manual' : null),
              priorityAt: Value(priority ? now : null),
              lastActiveAt: now,
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _record('card.create', {'id': id, 'boardId': boardId, 'number': number, 'title': title.trim(), 'lane': lane.key, 'priority': priority});
    });
    return id;
  }

  /// Moves a card. Mirrors Fizzy's rules: going to a column or To-do takes it
  /// out of Later and reopens it; going to Later reopens it and takes it off
  /// its column; going to Done closes it.
  Future<void> moveCard(String id, Lane to) => db.transaction(() async {
    final now = _now();
    final KCardsCompanion change;
    switch (to.kind) {
      case LaneKind.todo:
        change = KCardsCompanion(columnId: const Value(null), closedAt: const Value(null), laterAt: const Value(null), laterReason: const Value(null));
      case LaneKind.later:
        change = KCardsCompanion(columnId: const Value(null), closedAt: const Value(null), laterAt: Value(now), laterReason: const Value('manual'));
      case LaneKind.done:
        change = KCardsCompanion(closedAt: Value(now), laterAt: const Value(null), laterReason: const Value(null));
      case LaneKind.column:
        change = KCardsCompanion(columnId: Value(to.columnId), closedAt: const Value(null), laterAt: const Value(null), laterReason: const Value(null));
    }
    await (db.update(db.kCards)..where((c) => c.id.equals(id))).write(change.copyWith(lastActiveAt: Value(now), updatedAt: Value(now)));
    await _record('card.move', {'id': id, 'to': to.key});
  });

  Future<void> setPriority(String id, bool on) => db.transaction(() async {
    final now = _now();
    await (db.update(
      db.kCards,
    )..where((c) => c.id.equals(id))).write(KCardsCompanion(priorityAt: Value(on ? now : null), lastActiveAt: Value(now), updatedAt: Value(now)));
    await _record('card.priority', {'id': id, 'on': on});
  });

  Future<void> editCard(String id, {String? title, String? description}) => db.transaction(() async {
    final now = _now();
    await (db.update(db.kCards)..where((c) => c.id.equals(id))).write(
      KCardsCompanion(
        title: title == null ? const Value.absent() : Value(title.trim().isEmpty ? 'Untitled' : title.trim()),
        description: description == null ? const Value.absent() : Value(description),
        lastActiveAt: Value(now),
        updatedAt: Value(now),
      ),
    );
    await _record('card.edit', {'id': id, 'title': title?.trim(), 'description': description});
  });

  Future<void> deleteCard(String id) => db.transaction(() async {
    final now = _now();
    await (db.update(db.kCards)..where((c) => c.id.equals(id))).write(KCardsCompanion(deletedAt: Value(now), updatedAt: Value(now)));
    await _record('card.delete', {'id': id});
  });

  Future<void> restoreCard(String id) => db.transaction(() async {
    await (db.update(db.kCards)..where((c) => c.id.equals(id))).write(KCardsCompanion(deletedAt: const Value(null), updatedAt: Value(_now())));
    await _record('card.restore', {'id': id});
  });

  // ---------------------------------------------------------------- first run

  /// Makes a practice board on first launch, the way Fizzy starts every new
  /// account with a Playground board of cards that teach the basics.
  Future<String> ensureStarterBoard() async {
    final existing = await (db.select(db.kBoards)..where((b) => b.deletedAt.isNull())).get();
    if (existing.isNotEmpty) {
      final saved = await setting('board.current');
      if (saved != null && existing.any((b) => b.id == saved)) return saved;
      await setSetting('board.current', existing.first.id);
      return existing.first.id;
    }
    final board = await createBoard('Playground');
    final doing = await addColumn(board, 'In progress', 0);
    final waiting = await addColumn(board, 'Waiting on', 2);
    await addCard(board, 'Cards you\'re not ready for wait here in Later', lane: const Lane.later());
    await addCard(board, 'Finished cards land in Done', lane: const Lane.done());
    await addCard(board, 'Swipe sideways to see the other columns', lane: Lane.column(waiting));
    await addCard(board, 'Priority cards always sit at the top', lane: Lane.column(doing), priority: true);
    await addCard(board, 'Tap a card to open it, rename it, or make it Priority');
    await addCard(board, 'Tap a thin strip to open that column');
    await addCard(board, 'Hold a card, then drag it onto a column in the tray');
    await setSetting('board.current', board);
    return board;
  }
}
