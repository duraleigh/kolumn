import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../planner/days.dart';
import '../planner/repeat.dart';
import 'database.dart';
import 'lane_looks.dart';
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
      final me = int.tryParse(await setting('me.id') ?? '');
      await db
          .into(db.kBoards)
          .insert(
            KBoardsCompanion.insert(
              id: id,
              name: name.trim(),
              creatorId: Value(me),
              members: Value(jsonEncode(me == null ? const <int>[] : [me])),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _record('board.create', {'id': id, 'name': name.trim()});
    });
    return id;
  }

  Future<void> renameBoard(String id, String name) => db.transaction(() async {
    await (db.update(db.kBoards)..where((b) => b.id.equals(id))).write(KBoardsCompanion(name: Value(name.trim()), updatedAt: Value(_now())));
    await _record('board.rename', {'id': id, 'name': name.trim()});
  });

  /// Renames or recolors Later, To-do or Done on one Kolumn ([kind] is
  /// 'later', 'todo' or 'done'). An empty name goes back to the usual one.
  Future<void> setLaneLook(String boardId, String kind, {required String name, required int color}) => db.transaction(() async {
    await _patchLane(boardId, kind, (one) {
      if (name.trim().isEmpty) {
        one.remove('name');
      } else {
        one['name'] = name.trim();
      }
      one['color'] = color;
    });
    await _record('board.lane', {'id': boardId, 'lane': kind, 'name': name.trim().isEmpty ? null : name.trim(), 'color': color});
  });

  Future<KBoard?> _board(String id) => (db.select(db.kBoards)..where((x) => x.id.equals(id))).getSingleOrNull();

  /// Changes one of Later, To-do and Done in a Kolumn's stored choices, keeping the rest.
  Future<void> _patchLane(String boardId, String kind, void Function(Map<String, dynamic>) change) async {
    final b = await _board(boardId);
    if (b == null) return;
    final all = (jsonDecode(b.lanes) as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    final one = ((all[kind] as Map?) ?? const {}).cast<String, dynamic>().map(MapEntry.new);
    change(one);
    if (one.isEmpty) {
      all.remove(kind);
    } else {
      all[kind] = one;
    }
    await (db.update(db.kBoards)..where((x) => x.id.equals(boardId))).write(KBoardsCompanion(lanes: Value(jsonEncode(all)), updatedAt: Value(_now())));
  }

  /// Where a card asked to go really goes: To-do or Later deleted on this
  /// Kolumn send it where open cards go instead (the hub does the same).
  Future<Lane> _resolve(String boardId, Lane to) async {
    if (to.kind != LaneKind.todo && to.kind != LaneKind.later) return to;
    final b = await _board(boardId);
    if (!laneLook(b, kindKey(to.kind)).hidden) return to;
    return homeLane(b, await columns(boardId)) ?? to;
  }

  KCardsCompanion _laneChange(Lane to, int now) => switch (to.kind) {
    LaneKind.todo => const KCardsCompanion(columnId: Value(null), closedAt: Value(null), laterAt: Value(null), laterReason: Value(null)),
    LaneKind.later => KCardsCompanion(columnId: const Value(null), closedAt: const Value(null), laterAt: Value(now), laterReason: const Value('manual')),
    LaneKind.done => KCardsCompanion(closedAt: Value(now), laterAt: const Value(null), laterReason: const Value(null)),
    LaneKind.column => KCardsCompanion(columnId: Value(to.columnId), closedAt: const Value(null), laterAt: const Value(null), laterReason: const Value(null)),
  };

  /// Moves any kolumn — Later, To-do and Done included — one place left
  /// (-1) or right (1) on its Kolumn.
  Future<void> moveLane(String boardId, Lane lane, int direction) => db.transaction(() async {
    final order = laneOrder(await _board(boardId), await columns(boardId));
    final i = order.indexWhere((e) => e.$1 == lane);
    final j = i + direction;
    if (i < 0 || j < 0 || j >= order.length) return;
    final (a, pa) = order[i];
    final (b, pb) = order[j];
    // Two places at the same spot would not swap; nudge them apart.
    final na = pb == pa ? pb + direction * 0.5 : pb;
    final nb = pa;
    final now = _now();
    if (a.kind == LaneKind.column && b.kind == LaneKind.column) {
      await (db.update(db.kColumns)..where((c) => c.id.equals(a.columnId!))).write(KColumnsCompanion(position: Value(na), updatedAt: Value(now)));
      await (db.update(db.kColumns)..where((c) => c.id.equals(b.columnId!))).write(KColumnsCompanion(position: Value(nb), updatedAt: Value(now)));
      await _record('column.move', {'id': a.columnId, 'position': na, 'swappedWith': b.columnId, 'otherPosition': nb});
      return;
    }
    for (final (l, p) in [(a, na), (b, nb)]) {
      if (l.kind == LaneKind.column) {
        await (db.update(db.kColumns)..where((c) => c.id.equals(l.columnId!))).write(KColumnsCompanion(position: Value(p), updatedAt: Value(now)));
        await _record('column.move', {'id': l.columnId, 'position': p});
      } else {
        await _patchLane(boardId, kindKey(l.kind), (one) => one['pos'] = p);
        await _record('board.lane', {'id': boardId, 'lane': kindKey(l.kind), 'pos': p});
      }
    }
  });

  /// Deletes (hides) Later, To-do or Done on one Kolumn, or brings it back.
  /// Open cards in a deleted To-do or Later go where open cards go; finished
  /// cards in a deleted Done stay finished, out of sight. False when it is the
  /// last place left for open cards.
  Future<bool> setLaneHidden(String boardId, String kind, bool hidden) => db.transaction(() async {
    final b = await _board(boardId);
    final cols = await columns(boardId);
    if (hidden && kind != 'done' && homeLane(b, cols, exclude: laneOfKind(kind)) == null) return false;
    await _patchLane(boardId, kind, (one) => hidden ? one['hidden'] = true : one.remove('hidden'));
    await _record('board.lane', {'id': boardId, 'lane': kind, 'hidden': hidden});
    if (hidden && kind != 'done') {
      final target = homeLane(await _board(boardId), cols);
      if (target != null) {
        final live = cols.map((c) => c.id).toSet();
        final now = _now();
        for (final c in await (db.select(db.kCards)..where((c) => c.boardId.equals(boardId) & c.deletedAt.isNull() & c.closedAt.isNull())).get()) {
          final inIt = kind == 'later' ? c.laterAt != null : (c.laterAt == null && (c.columnId == null || !live.contains(c.columnId)));
          if (inIt) await (db.update(db.kCards)..where((x) => x.id.equals(c.id))).write(_laneChange(target, now).copyWith(updatedAt: Value(now)));
        }
      }
    }
    return true;
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

  /// Swaps a column with its neighbor column. [direction] is -1 (left) or 1
  /// (right). (The board's menu uses [moveLane], which also passes Later,
  /// To-do and Done.)
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

  /// Deletes a column. Its open cards go back to To-do (or, when this Kolumn
  /// deleted To-do, where open cards go), as in Fizzy. False when it is the
  /// last place left for open cards.
  Future<bool> deleteColumn(String id) => db.transaction(() async {
    final now = _now();
    final col = await (db.select(db.kColumns)..where((c) => c.id.equals(id))).getSingleOrNull();
    if (col == null) return false;
    final target = homeLane(await _board(col.boardId), await columns(col.boardId), exclude: Lane.column(id));
    if (target == null) return false;
    await (db.update(db.kColumns)..where((c) => c.id.equals(id))).write(KColumnsCompanion(deletedAt: Value(now), updatedAt: Value(now)));
    for (final c in await (db.select(db.kCards)..where((c) => c.columnId.equals(id))).get()) {
      final open = c.closedAt == null && c.laterAt == null;
      await (db.update(db.kCards)..where((x) => x.id.equals(c.id))).write(
        open
            ? _laneChange(target, now).copyWith(updatedAt: Value(now))
            : KCardsCompanion(columnId: Value(target.kind == LaneKind.column ? target.columnId : null), updatedAt: Value(now)),
      );
    }
    await _record('column.delete', {'id': id});
    return true;
  });

  // ---------------------------------------------------------------- cards

  Future<int> _nextNumber() async {
    final current = int.tryParse(await setting('cards.counter') ?? '') ?? 0;
    final next = current + 1;
    await setSetting('cards.counter', '$next');
    return next;
  }

  Future<String> addCard(String boardId, String title, {Lane lane = const Lane.todo(), bool priority = false, bool draft = false}) async {
    final id = newId();
    await db.transaction(() async {
      final now = _now();
      final number = await _nextNumber();
      // New cards land in To-do, or where open cards go when this Kolumn deleted it.
      lane = await _resolve(boardId, lane);
      final pos = draft ? null : await _topPosition(boardId, lane);
      await db
          .into(db.kCards)
          .insert(
            KCardsCompanion.insert(
              id: id,
              boardId: boardId,
              number: number,
              title: title.trim().isEmpty ? 'Untitled' : title.trim(),
              columnId: Value(lane.kind == LaneKind.column ? lane.columnId : null),
              position: Value(pos),
              closedAt: Value(lane.kind == LaneKind.done ? now : null),
              laterAt: Value(lane.kind == LaneKind.later ? now : null),
              laterReason: Value(lane.kind == LaneKind.later ? 'manual' : null),
              priorityAt: Value(priority ? now : null),
              lastActiveAt: now,
              status: Value(draft ? 'draft' : 'published'),
              creatorId: Value(await meId()),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _record('card.create', {
        'id': id,
        'boardId': boardId,
        'number': number,
        'title': title.trim(),
        'lane': lane.key,
        'priority': priority,
        'draft': draft,
        'position': ?pos,
      });
    });
    return id;
  }

  /// Moves a card. Mirrors Fizzy's rules: going to a column or To-do takes it
  /// out of Later and reopens it; going to Later reopens it and takes it off
  /// its column; going to Done closes it.
  /// The cards in one kolumn, in the order they show.
  Future<List<KCard>> _laneCards(String boardId, Lane lane, {String? except}) async {
    final cols = await columns(boardId);
    final live = cols.map((c) => c.id).toSet();
    final all = await (db.select(db.kCards)..where((c) => c.boardId.equals(boardId) & c.deletedAt.isNull() & c.status.equals('published'))).get();
    return sortForLane(lane, all.where((c) => c.id != except && Lane.of(c, live) == lane));
  }

  /// Where a card goes when it joins a kolumn: on top. Null while nobody has
  /// put that kolumn in order (then the automatic order puts it on top anyway).
  Future<double?> _topPosition(String boardId, Lane lane, {String? except}) async {
    final placed = (await _laneCards(boardId, lane, except: except)).map((c) => c.position).nonNulls.toList();
    if (placed.isEmpty) return null;
    return placed.reduce((a, b) => a < b ? a : b) - 1024;
  }

  /// Moves a card. Mirrors Fizzy's rules: going to a column or To-do takes it
  /// out of Later and reopens it; going to Later reopens it and takes it off
  /// its column; going to Done closes it. It lands on top, or at [index] in
  /// the kolumn's order when dropped in a particular spot.
  Future<void> moveCard(String id, Lane to, {int? index}) => db.transaction(() async {
    final now = _now();
    final c = await card(id);
    if (c == null) return;
    to = await _resolve(c.boardId, to);
    final pos = await _topPosition(c.boardId, to, except: id);
    await (db.update(db.kCards)..where((c) => c.id.equals(id))).write(
      _laneChange(to, now).copyWith(lastActiveAt: Value(now), updatedAt: Value(now), position: Value(pos)),
    );
    await _record('card.move', {'id': id, 'to': to.key, 'position': pos});
    if (index != null) await _place(c.boardId, to, id, index);
  });

  /// Drags a card to [index] in its kolumn's order (his ask, 2026-11-12). The
  /// whole kolumn takes its order from then on; only cards whose place
  /// changed are sent.
  Future<void> reorderCard(String id, int index) => db.transaction(() async {
    final c = await card(id);
    if (c == null) return;
    final live = (await columns(c.boardId)).map((x) => x.id).toSet();
    await _place(c.boardId, Lane.of(c, live), id, index);
  });

  Future<void> _place(String boardId, Lane lane, String id, int index) async {
    final others = await _laneCards(boardId, lane, except: id);
    final me = await card(id);
    if (me == null) return;
    final order = [...others]..insert(index.clamp(0, others.length), me);
    for (var i = 0; i < order.length; i++) {
      final want = (i + 1) * 1024.0;
      if (order[i].position == want) continue;
      await (db.update(db.kCards)..where((x) => x.id.equals(order[i].id))).write(KCardsCompanion(position: Value(want)));
      await _record('card.position', {'id': order[i].id, 'position': want});
    }
  }

  Future<void> setPriority(String id, bool on) => db.transaction(() async {
    final now = _now();
    await (db.update(
      db.kCards,
    )..where((c) => c.id.equals(id))).write(KCardsCompanion(priorityAt: Value(on ? now : null), lastActiveAt: Value(now), updatedAt: Value(now)));
    await _record('card.priority', {'id': id, 'on': on});
  });

  Future<void> editCard(String id, {String? title, String? description}) => db.transaction(() async {
    final now = _now();
    final before = await card(id);
    await (db.update(db.kCards)..where((c) => c.id.equals(id))).write(
      KCardsCompanion(
        title: title == null ? const Value.absent() : Value(title.trim().isEmpty ? 'Untitled' : title.trim()),
        description: description == null ? const Value.absent() : Value(description),
        lastActiveAt: Value(now),
        updatedAt: Value(now),
      ),
    );
    await _record('card.edit', {'id': id, 'title': title?.trim(), 'description': description, 'baseRev': before?.rev ?? 0});
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

  // ---------------------------------------------------------------- everything on a card (Phase 4)

  int? _me;

  /// Who "I" am on this phone, as the hub last said.
  Future<int?> meId() async => _me ??= int.tryParse(await setting('me.id') ?? '');

  Future<void> _touch(String cardId, {bool activity = true}) async {
    final now = _now();
    await (db.update(
      db.kCards,
    )..where((c) => c.id.equals(cardId))).write(KCardsCompanion(updatedAt: Value(now), lastActiveAt: activity ? Value(now) : const Value.absent()));
  }

  Future<String> addStep(String cardId, String content) async {
    final id = newId();
    await db.transaction(() async {
      final existing = await (db.select(db.kSteps)..where((s) => s.cardId.equals(cardId))).get();
      final pos = existing.isEmpty ? 1.0 : existing.map((e) => e.position).reduce((a, b) => a > b ? a : b) + 1;
      await db.into(db.kSteps).insert(KStepsCompanion.insert(id: id, cardId: cardId, content: content.trim(), position: Value(pos), createdAt: _now()));
      await _touch(cardId);
      await _record('step.create', {'id': id, 'cardId': cardId, 'content': content.trim(), 'position': pos});
    });
    return id;
  }

  Future<void> updateStep(KStep step, {String? content, bool? done}) => db.transaction(() async {
    await (db.update(db.kSteps)..where((s) => s.id.equals(step.id))).write(
      KStepsCompanion(content: content == null ? const Value.absent() : Value(content.trim()), done: done == null ? const Value.absent() : Value(done)),
    );
    await _touch(step.cardId);
    await _record('step.update', {'id': step.id, 'content': ?content?.trim(), 'done': ?done});
  });

  Future<void> deleteStep(KStep step) => db.transaction(() async {
    await (db.update(db.kSteps)..where((s) => s.id.equals(step.id))).write(KStepsCompanion(deletedAt: Value(_now())));
    await _record('step.delete', {'id': step.id});
  });

  Future<String> addComment(String cardId, String body) async {
    final id = newId();
    await db.transaction(() async {
      await db.into(db.kComments).insert(KCommentsCompanion.insert(id: id, cardId: cardId, userId: await meId() ?? 0, body: body.trim(), createdAt: _now()));
      await _touch(cardId);
      await _setWatch(cardId, true, record: false);
      await _record('comment.create', {'id': id, 'cardId': cardId, 'body': body.trim()});
    });
    return id;
  }

  Future<void> editComment(String id, String body) => db.transaction(() async {
    await (db.update(db.kComments)..where((c) => c.id.equals(id))).write(KCommentsCompanion(body: Value(body.trim()), editedAt: Value(_now())));
    await _record('comment.edit', {'id': id, 'body': body.trim()});
  });

  Future<void> deleteComment(String id) => db.transaction(() async {
    await (db.update(db.kComments)..where((c) => c.id.equals(id))).write(KCommentsCompanion(deletedAt: Value(_now())));
    await _record('comment.delete', {'id': id});
  });

  /// Tapping a reaction: adds mine, or takes mine back if it is already there.
  Future<void> toggleReaction(String cardId, String emoji, {String? commentId}) => db.transaction(() async {
    final me = await meId() ?? 0;
    final mine =
        await (db.select(db.kReactions)..where(
              (r) =>
                  r.cardId.equals(cardId) &
                  r.userId.equals(me) &
                  r.emoji.equals(emoji) &
                  r.deletedAt.isNull() &
                  (commentId == null ? r.commentId.isNull() : r.commentId.equals(commentId)),
            ))
            .get();
    if (mine.isNotEmpty) {
      for (final r in mine) {
        await (db.update(db.kReactions)..where((x) => x.id.equals(r.id))).write(KReactionsCompanion(deletedAt: Value(_now())));
        await _record('reaction.remove', {'id': r.id});
      }
      return;
    }
    final id = newId();
    await db
        .into(db.kReactions)
        .insert(KReactionsCompanion.insert(id: id, cardId: cardId, commentId: Value(commentId), userId: me, emoji: emoji, createdAt: _now()));
    await _record('reaction.add', {'id': id, 'cardId': cardId, 'commentId': commentId, 'emoji': emoji});
  });

  static String cleanTag(String t) => t.trim().replaceAll(RegExp(r'^#+'), '').replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

  Future<void> setTag(String cardId, String tag, bool on) => db.transaction(() async {
    final t = cleanTag(tag);
    if (t.isEmpty) return;
    await db.into(db.kTags).insertOnConflictUpdate(KTagsCompanion.insert(cardId: cardId, tag: t, deletedAt: Value(on ? null : _now())));
    await _touch(cardId);
    await _record(on ? 'tag.add' : 'tag.remove', {'id': cardId, 'tag': t});
  });

  Future<void> setAssigned(String cardId, int userId, bool on) => db.transaction(() async {
    await db.into(db.kAssignees).insertOnConflictUpdate(KAssigneesCompanion.insert(cardId: cardId, userId: userId, deletedAt: Value(on ? null : _now())));
    await _touch(cardId);
    if (on && userId == await meId()) await _setWatch(cardId, true, record: false);
    await _record(on ? 'assign.add' : 'assign.remove', {'id': cardId, 'userId': userId});
  });

  Future<void> _setWatch(String cardId, bool on, {bool record = true}) async {
    await db.into(db.kWatches).insertOnConflictUpdate(KWatchesCompanion.insert(cardId: cardId, watching: on));
    if (record) await _record('watch.set', {'id': cardId, 'on': on});
  }

  Future<void> setWatching(String cardId, bool on) => db.transaction(() => _setWatch(cardId, on));

  Future<void> setPinned(String cardId, bool on) => db.transaction(() async {
    await db.into(db.kPins).insertOnConflictUpdate(KPinsCompanion.insert(cardId: cardId, pinnedAt: _now(), deletedAt: Value(on ? null : _now())));
    await _record('pin.set', {'id': cardId, 'on': on});
  });

  Future<void> publishCard(String cardId) => db.transaction(() async {
    await (db.update(db.kCards)..where((c) => c.id.equals(cardId))).write(const KCardsCompanion(status: Value('published')));
    await _touch(cardId);
    await _record('card.publish', {'id': cardId});
  });

  /// Moves a card to another board; it lands in To-do there, as in Fizzy.
  Future<void> moveCardToBoard(String cardId, String boardId) => db.transaction(() async {
    await (db.update(db.kCards)..where((c) => c.id.equals(cardId))).write(KCardsCompanion(boardId: Value(boardId), columnId: const Value(null)));
    await _touch(cardId);
    await _record('card.board', {'id': cardId, 'boardId': boardId});
  });

  Future<void> setCover(String cardId, String? fileId) => db.transaction(() async {
    await (db.update(db.kCards)..where((c) => c.id.equals(cardId))).write(KCardsCompanion(coverId: Value(fileId)));
    await _record('card.cover', {'id': cardId, 'fileId': fileId});
  });

  /// Attaches a file kept at [localPath]. It goes to the hub with the next
  /// sync (or when back online), and shows here at once from the phone's copy.
  Future<String> addFile(
    String cardId, {
    required String localPath,
    required String filename,
    required String mime,
    required int size,
    bool cover = false,
  }) async {
    final id = newId();
    await db.transaction(() async {
      await db
          .into(db.kFiles)
          .insert(
            KFilesCompanion.insert(
              id: id,
              cardId: cardId,
              userId: Value(await meId() ?? 0),
              filename: filename,
              mime: Value(mime),
              size: Value(size),
              createdAt: _now(),
              localPath: Value(localPath),
            ),
          );
      if (cover) {
        await (db.update(db.kCards)..where((c) => c.id.equals(cardId))).write(KCardsCompanion(coverId: Value(id)));
      }
      await _touch(cardId);
      await _record('file.upload', {'id': id, 'cardId': cardId, 'filename': filename, 'cover': cover, 'path': localPath});
    });
    return id;
  }

  Future<void> deleteFile(KFile f) => db.transaction(() async {
    await (db.update(db.kFiles)..where((x) => x.id.equals(f.id))).write(KFilesCompanion(deletedAt: Value(_now())));
    await (db.update(db.kCards)..where((c) => c.id.equals(f.cardId) & c.coverId.equals(f.id))).write(const KCardsCompanion(coverId: Value(null)));
    await _record('file.delete', {'id': f.id});
  });

  Future<void> markFileUploaded(String id) => (db.update(db.kFiles)..where((f) => f.id.equals(id))).write(const KFilesCompanion(uploaded: Value(true)));

  Future<void> setFileLocalPath(String id, String path) => (db.update(db.kFiles)..where((f) => f.id.equals(id))).write(KFilesCompanion(localPath: Value(path)));

  Stream<List<KStep>> watchSteps(String cardId) =>
      (db.select(db.kSteps)
            ..where((s) => s.cardId.equals(cardId) & s.deletedAt.isNull())
            ..orderBy([(s) => OrderingTerm.asc(s.position), (s) => OrderingTerm.asc(s.createdAt)]))
          .watch();
  Stream<List<KComment>> watchComments(String cardId) =>
      (db.select(db.kComments)
            ..where((c) => c.cardId.equals(cardId) & c.deletedAt.isNull())
            ..orderBy([(c) => OrderingTerm.asc(c.createdAt)]))
          .watch();
  Stream<List<KReaction>> watchReactions(String cardId) => (db.select(db.kReactions)..where((r) => r.cardId.equals(cardId) & r.deletedAt.isNull())).watch();
  Stream<List<KTag>> watchTags() => (db.select(db.kTags)..where((t) => t.deletedAt.isNull())).watch();
  Stream<List<KAssignee>> watchAssignees() => (db.select(db.kAssignees)..where((a) => a.deletedAt.isNull())).watch();
  Stream<List<KStep>> watchAllSteps() => (db.select(db.kSteps)..where((s) => s.deletedAt.isNull())).watch();
  Stream<List<KComment>> watchAllComments() => (db.select(db.kComments)..where((c) => c.deletedAt.isNull())).watch();
  Stream<List<KFile>> watchAllFiles() => (db.select(db.kFiles)..where((f) => f.deletedAt.isNull())).watch();
  Stream<List<KFile>> watchFiles(String cardId) =>
      (db.select(db.kFiles)
            ..where((f) => f.cardId.equals(cardId) & f.deletedAt.isNull())
            ..orderBy([(f) => OrderingTerm.asc(f.createdAt)]))
          .watch();
  Stream<KWatch?> watchWatch(String cardId) => (db.select(db.kWatches)..where((w) => w.cardId.equals(cardId))).watchSingleOrNull();
  Stream<List<KPin>> watchPins() =>
      (db.select(db.kPins)
            ..where((p) => p.deletedAt.isNull())
            ..orderBy([(p) => OrderingTerm.desc(p.pinnedAt)]))
          .watch();
  Stream<List<KEvent>> watchEvents(String cardId) =>
      (db.select(db.kEvents)
            ..where((e) => e.cardId.equals(cardId))
            ..orderBy([(e) => OrderingTerm.desc(e.createdAt)]))
          .watch();
  Stream<List<KCard>> watchAllCards() => (db.select(db.kCards)..where((c) => c.deletedAt.isNull())).watch();
  Future<KFile?> file(String id) => (db.select(db.kFiles)..where((f) => f.id.equals(id))).getSingleOrNull();

  Future<void> _applyDetails(Map<String, dynamic> body, Set<String> pending) async {
    int? i(Object? v) => v == null ? null : (v as num).toInt();
    List<Map<String, dynamic>> list(String k) => ((body[k] as List?) ?? const []).cast<Map<String, dynamic>>();
    for (final s in list('steps')) {
      if (pending.contains(s['id'])) continue;
      await db
          .into(db.kSteps)
          .insertOnConflictUpdate(
            KStepsCompanion.insert(
              id: s['id'] as String,
              cardId: s['cardId'] as String,
              content: s['content'] as String? ?? '',
              done: Value(s['done'] == true),
              position: Value((s['position'] as num?)?.toDouble() ?? 0),
              createdAt: i(s['createdAt']) ?? 0,
              deletedAt: Value(i(s['deletedAt'])),
            ),
          );
    }
    for (final c in list('comments')) {
      if (pending.contains(c['id'])) continue;
      await db
          .into(db.kComments)
          .insertOnConflictUpdate(
            KCommentsCompanion.insert(
              id: c['id'] as String,
              cardId: c['cardId'] as String,
              userId: i(c['userId']) ?? 0,
              body: c['body'] as String? ?? '',
              createdAt: i(c['createdAt']) ?? 0,
              editedAt: Value(i(c['editedAt'])),
              deletedAt: Value(i(c['deletedAt'])),
              synced: const Value(true),
            ),
          );
    }
    for (final r in list('reactions')) {
      if (pending.contains(r['id'])) continue;
      await db
          .into(db.kReactions)
          .insertOnConflictUpdate(
            KReactionsCompanion.insert(
              id: r['id'] as String,
              cardId: r['cardId'] as String,
              commentId: Value(r['commentId'] as String?),
              userId: i(r['userId']) ?? 0,
              emoji: r['emoji'] as String? ?? '',
              createdAt: i(r['createdAt']) ?? 0,
              deletedAt: Value(i(r['deletedAt'])),
            ),
          );
    }
    for (final t in list('tags')) {
      if (pending.contains(t['cardId'])) continue;
      await db
          .into(db.kTags)
          .insertOnConflictUpdate(KTagsCompanion.insert(cardId: t['cardId'] as String, tag: t['tag'] as String, deletedAt: Value(i(t['deletedAt']))));
    }
    for (final a in list('assignees')) {
      if (pending.contains(a['cardId'])) continue;
      await db
          .into(db.kAssignees)
          .insertOnConflictUpdate(KAssigneesCompanion.insert(cardId: a['cardId'] as String, userId: i(a['userId']) ?? 0, deletedAt: Value(i(a['deletedAt']))));
    }
    for (final w in list('watches')) {
      if (pending.contains(w['cardId'])) continue;
      await db.into(db.kWatches).insertOnConflictUpdate(KWatchesCompanion.insert(cardId: w['cardId'] as String, watching: w['watching'] == true));
    }
    for (final p in list('pins')) {
      if (pending.contains(p['cardId'])) continue;
      await db
          .into(db.kPins)
          .insertOnConflictUpdate(KPinsCompanion.insert(cardId: p['cardId'] as String, pinnedAt: i(p['pinnedAt']) ?? 0, deletedAt: Value(i(p['deletedAt']))));
    }
    for (final f in list('files')) {
      if (pending.contains(f['id'])) continue;
      final existing = await file(f['id'] as String);
      await db
          .into(db.kFiles)
          .insertOnConflictUpdate(
            KFilesCompanion.insert(
              id: f['id'] as String,
              cardId: f['cardId'] as String,
              commentId: Value(f['commentId'] as String?),
              userId: Value(i(f['userId']) ?? 0),
              filename: f['filename'] as String? ?? 'file',
              mime: Value(f['mime'] as String? ?? 'application/octet-stream'),
              size: Value(i(f['size']) ?? 0),
              width: Value(i(f['width'])),
              height: Value(i(f['height'])),
              hasThumb: Value(f['hasThumb'] == true),
              createdAt: i(f['createdAt']) ?? 0,
              deletedAt: Value(i(f['deletedAt'])),
              localPath: Value(existing?.localPath),
              uploaded: const Value(true),
            ),
          );
    }
    for (final e in list('events')) {
      await db
          .into(db.kEvents)
          .insertOnConflictUpdate(
            KEventsCompanion.insert(
              id: Value(i(e['id'])!),
              cardId: e['cardId'] as String,
              userId: i(e['userId']) ?? 0,
              action: e['action'] as String? ?? '',
              particulars: Value(jsonEncode(e['particulars'] ?? const {})),
              createdAt: i(e['createdAt']) ?? 0,
            ),
          );
    }
  }

  // ---------------------------------------------------------------- time (Phase 5)

  /// A card's due DAY (no times), or null to clear it.
  Future<void> setCardDue(String cardId, String? day) => db.transaction(() async {
    final now = _now();
    await (db.update(db.kCards)..where((c) => c.id.equals(cardId))).write(
      KCardsCompanion(dueAt: Value(day == null ? null : dueMsOf(day)), dueHasTime: const Value(false), lastActiveAt: Value(now), updatedAt: Value(now)),
    );
    await _record('card.due', {'id': cardId, 'day': day});
  });

  /// How long a Kolumn's cards may sit untouched before they move to Later on
  /// their own. Null means the usual 30 days.
  Future<void> setTidyDays(String boardId, int? days) => db.transaction(() async {
    await (db.update(db.kBoards)..where((b) => b.id.equals(boardId))).write(KBoardsCompanion(tidyDays: Value(days), updatedAt: Value(_now())));
    await _record('board.tidy', {'id': boardId, 'days': days});
  });

  // ---------------------------------------------------------------- the Planner (Phase 5)

  Stream<List<KPlanner>> watchPlanners() =>
      (db.select(db.kPlanners)
            ..where((p) => p.deletedAt.isNull())
            ..orderBy([(p) => OrderingTerm.asc(p.createdAt)]))
          .watch();

  Stream<List<KPlannerPerson>> watchPlannerPeople(String plannerId) =>
      (db.select(db.kPlannerPeople)..where((p) => p.plannerId.equals(plannerId) & p.deletedAt.isNull())).watch();

  Stream<List<KTodo>> watchTodos(String plannerId) => (db.select(db.kTodos)..where((t) => t.plannerId.equals(plannerId) & t.deletedAt.isNull())).watch();

  Stream<List<KTodo>> watchAllTodos() => (db.select(db.kTodos)..where((t) => t.deletedAt.isNull())).watch();

  Stream<KTodo?> watchTodo(String id) => (db.select(db.kTodos)..where((t) => t.id.equals(id))).watchSingleOrNull();

  Future<KTodo?> todo(String id) => (db.select(db.kTodos)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<List<KTodoMark>> watchTodoMarks() => (db.select(db.kTodoMarks)..where((m) => m.deletedAt.isNull())).watch();

  Stream<List<KTodoStep>> watchTodoSteps(String todoId) =>
      (db.select(db.kTodoSteps)
            ..where((s) => s.todoId.equals(todoId) & s.deletedAt.isNull())
            ..orderBy([(s) => OrderingTerm.asc(s.position), (s) => OrderingTerm.asc(s.createdAt)]))
          .watch();

  Stream<List<KTodoStep>> watchAllTodoSteps() => (db.select(db.kTodoSteps)..where((s) => s.deletedAt.isNull())).watch();

  Stream<List<KTodoFile>> watchTodoFiles(String todoId) =>
      (db.select(db.kTodoFiles)
            ..where((f) => f.todoId.equals(todoId) & f.deletedAt.isNull())
            ..orderBy([(f) => OrderingTerm.asc(f.createdAt)]))
          .watch();

  Stream<List<KTodoFile>> watchAllTodoFiles() => (db.select(db.kTodoFiles)..where((f) => f.deletedAt.isNull())).watch();

  Stream<List<KReminder>> watchReminders() => (db.select(db.kReminders)..where((r) => r.at.isNotNull())).watch();

  Future<KTodoFile?> todoFile(String id) => (db.select(db.kTodoFiles)..where((f) => f.id.equals(id))).getSingleOrNull();

  Future<String> createPlanner(String name, {List<String> boardIds = const []}) async {
    final id = newId();
    final now = _now();
    await db.transaction(() async {
      await db
          .into(db.kPlanners)
          .insert(
            KPlannersCompanion.insert(
              id: id,
              name: name.trim().isEmpty ? 'My planner' : name.trim(),
              creatorId: Value(await meId()),
              boardIds: Value(jsonEncode(boardIds)),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _record('planner.create', {'id': id, 'name': name.trim(), 'boardIds': boardIds});
    });
    return id;
  }

  Future<void> updatePlanner(String id, {String? name, bool? rollOver, bool? sinkDone, bool? hideDone, List<String>? boardIds}) => db.transaction(() async {
    await (db.update(db.kPlanners)..where((p) => p.id.equals(id))).write(
      KPlannersCompanion(
        name: name == null ? const Value.absent() : Value(name.trim()),
        rollOver: Value.absentIfNull(rollOver),
        sinkDone: Value.absentIfNull(sinkDone),
        hideDone: Value.absentIfNull(hideDone),
        boardIds: boardIds == null ? const Value.absent() : Value(jsonEncode(boardIds)),
        updatedAt: Value(_now()),
      ),
    );
    await _record('planner.update', {
      'id': id,
      'name': ?name?.trim(),
      'rollOver': ?rollOver,
      'sinkDone': ?sinkDone,
      'hideDone': ?hideDone,
      'boardIds': ?boardIds,
    });
  });

  Future<void> deletePlanner(String id) => db.transaction(() async {
    final now = _now();
    await (db.update(db.kPlanners)..where((p) => p.id.equals(id))).write(KPlannersCompanion(deletedAt: Value(now), updatedAt: Value(now)));
    await _record('planner.delete', {'id': id});
  });

  /// Who a planner is shared with, and as what: 'owner' or 'edit'.
  Future<void> setPlannerPeople(String id, Map<int, String> people) => db.transaction(() async {
    await (db.update(db.kPlannerPeople)..where((p) => p.plannerId.equals(id))).write(KPlannerPeopleCompanion(deletedAt: Value(_now())));
    for (final e in people.entries) {
      await db
          .into(db.kPlannerPeople)
          .insertOnConflictUpdate(KPlannerPeopleCompanion.insert(plannerId: id, userId: e.key, role: Value(e.value), deletedAt: const Value(null)));
    }
    await _record('planner.people', {
      'id': id,
      'people': [
        for (final e in people.entries) {'userId': e.key, 'role': e.value},
      ],
    });
  });

  Future<double> _nextTodoPosition(String plannerId, TodoSlot slot) async {
    final q = db.select(db.kTodos)..where((t) => t.plannerId.equals(plannerId) & t.deletedAt.isNull());
    if (slot.day != null) {
      q.where((t) => t.day.equals(slot.day!));
    } else {
      q.where((t) => t.day.isNull() & t.list.equals(slot.list!));
    }
    final rows = await q.get();
    return rows.isEmpty ? 1.0 : rows.map((r) => r.position).reduce((a, b) => a > b ? a : b) + 1;
  }

  Future<String> addTodo(String plannerId, TodoSlot slot, String title) async {
    final id = newId();
    await db.transaction(() async {
      final now = _now();
      final pos = await _nextTodoPosition(plannerId, slot);
      await db
          .into(db.kTodos)
          .insert(
            KTodosCompanion.insert(
              id: id,
              plannerId: plannerId,
              day: Value(slot.day),
              list: Value(slot.list),
              title: title.trim(),
              position: Value(pos),
              creatorId: Value(await meId()),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _record('todo.create', {'id': id, 'plannerId': plannerId, 'day': slot.day, 'list': slot.list, 'title': title.trim(), 'position': pos});
    });
    return id;
  }

  /// Changes only what is given. [slot] moves it to another day or a Someday
  /// list (to the end there unless [position] says where).
  Future<void> updateTodo(
    String id, {
    String? title,
    String? note,
    TodoSlot? slot,
    double? position,
    RepeatRule? repeat,
    bool clearRepeat = false,
    int? assigneeId,
    bool clearAssignee = false,
    String? plannerId,
  }) => db.transaction(() async {
    final before = await todo(id);
    if (before == null) return;
    final pos = position ?? (slot != null || plannerId != null ? await _nextTodoPosition(plannerId ?? before.plannerId, slot ?? TodoSlot.of(before)) : null);
    await (db.update(db.kTodos)..where((t) => t.id.equals(id))).write(
      KTodosCompanion(
        title: title == null || title.trim().isEmpty ? const Value.absent() : Value(title.trim()),
        note: Value.absentIfNull(note),
        day: slot == null ? const Value.absent() : Value(slot.day),
        list: slot == null ? const Value.absent() : Value(slot.list),
        position: Value.absentIfNull(pos),
        repeat: clearRepeat ? const Value(null) : (repeat == null ? const Value.absent() : Value(repeat.encode())),
        assigneeId: clearAssignee || plannerId != null ? const Value(null) : Value.absentIfNull(assigneeId),
        plannerId: Value.absentIfNull(plannerId),
        updatedAt: Value(_now()),
      ),
    );
    await _record('todo.update', {
      'id': id,
      if (title != null && title.trim().isNotEmpty) 'title': title.trim(),
      'note': ?note,
      if (slot != null) ...{'day': slot.day, 'list': slot.list},
      'position': ?pos,
      if (clearRepeat) 'repeat': null else if (repeat != null) 'repeat': repeat.toJson(),
      if (clearAssignee) 'assigneeId': null else 'assigneeId': ?assigneeId,
      'plannerId': ?plannerId,
    });
  });

  /// Ticks a to-do, or takes the tick back. For a repeating to-do, [day] says
  /// which day's tick.
  Future<void> setTodoDone(KTodo t, bool done, {String? day}) => db.transaction(() async {
    if (t.repeat != null) {
      if (day == null) return;
      await db
          .into(db.kTodoMarks)
          .insertOnConflictUpdate(KTodoMarksCompanion.insert(todoId: t.id, day: day, mark: 'done', deletedAt: Value(done ? null : _now())));
      await _record('todo.done', {'id': t.id, 'on': done, 'day': day});
      return;
    }
    await (db.update(db.kTodos)..where((x) => x.id.equals(t.id))).write(KTodosCompanion(doneAt: Value(done ? _now() : null), updatedAt: Value(_now())));
    await _record('todo.done', {'id': t.id, 'on': done});
  });

  /// Deletes one day of a repeating to-do; the other days stay.
  Future<void> skipTodoDay(KTodo t, String day) => db.transaction(() async {
    await db.into(db.kTodoMarks).insertOnConflictUpdate(KTodoMarksCompanion.insert(todoId: t.id, day: day, mark: 'skip', deletedAt: const Value(null)));
    await _record('todo.skip', {'id': t.id, 'day': day});
  });

  Future<void> deleteTodo(String id) => db.transaction(() async {
    final now = _now();
    await (db.update(db.kTodos)..where((t) => t.id.equals(id))).write(KTodosCompanion(deletedAt: Value(now), updatedAt: Value(now)));
    await _record('todo.delete', {'id': id});
  });

  /// Moves every unfinished, non-repeating to-do from an earlier day to
  /// [today], in planners with that switch on (Tweek's "move unfinished to
  /// the next day"). Cards never move. Returns how many moved.
  Future<int> rollOver(String today) async {
    final planners = await (db.select(db.kPlanners)..where((p) => p.deletedAt.isNull() & p.rollOver.equals(true))).get();
    if (planners.isEmpty) return 0;
    final late =
        await (db.select(db.kTodos)..where(
              (t) =>
                  t.plannerId.isIn(planners.map((p) => p.id).toList()) &
                  t.deletedAt.isNull() &
                  t.doneAt.isNull() &
                  t.repeat.isNull() &
                  t.day.isNotNull() &
                  t.day.isSmallerThanValue(today),
            ))
            .get();
    for (final t in late) {
      await updateTodo(t.id, slot: TodoSlot.day(today));
    }
    return late.length;
  }

  Future<String> addTodoStep(String todoId, String content, {bool heading = false}) async {
    final id = newId();
    await db.transaction(() async {
      final existing = await (db.select(db.kTodoSteps)..where((s) => s.todoId.equals(todoId))).get();
      final pos = existing.isEmpty ? 1.0 : existing.map((e) => e.position).reduce((a, b) => a > b ? a : b) + 1;
      await db
          .into(db.kTodoSteps)
          .insert(
            KTodoStepsCompanion.insert(id: id, todoId: todoId, content: content.trim(), heading: Value(heading), position: Value(pos), createdAt: _now()),
          );
      await _record('todostep.create', {'id': id, 'todoId': todoId, 'content': content.trim(), 'heading': heading, 'position': pos});
    });
    return id;
  }

  Future<void> updateTodoStep(KTodoStep s, {String? content, bool? done, bool? star, bool? heading, int? indent}) => db.transaction(() async {
    await (db.update(db.kTodoSteps)..where((x) => x.id.equals(s.id))).write(
      KTodoStepsCompanion(
        content: content == null || content.trim().isEmpty ? const Value.absent() : Value(content.trim()),
        done: Value.absentIfNull(done),
        star: Value.absentIfNull(star),
        heading: Value.absentIfNull(heading),
        indent: Value.absentIfNull(indent),
      ),
    );
    await _record('todostep.update', {'id': s.id, 'content': ?content?.trim(), 'done': ?done, 'star': ?star, 'heading': ?heading, 'indent': ?indent});
  });

  Future<void> deleteTodoStep(KTodoStep s) => db.transaction(() async {
    await (db.update(db.kTodoSteps)..where((x) => x.id.equals(s.id))).write(KTodoStepsCompanion(deletedAt: Value(_now())));
    await _record('todostep.delete', {'id': s.id});
  });

  Future<String> addTodoFile(String todoId, {required String localPath, required String filename, required String mime, required int size}) async {
    final id = newId();
    await db.transaction(() async {
      await db
          .into(db.kTodoFiles)
          .insert(
            KTodoFilesCompanion.insert(
              id: id,
              todoId: todoId,
              userId: Value(await meId() ?? 0),
              filename: filename,
              mime: Value(mime),
              size: Value(size),
              createdAt: _now(),
              localPath: Value(localPath),
            ),
          );
      await _record('todofile.upload', {'id': id, 'todoId': todoId, 'filename': filename, 'path': localPath});
    });
    return id;
  }

  Future<void> deleteTodoFile(KTodoFile f) => db.transaction(() async {
    await (db.update(db.kTodoFiles)..where((x) => x.id.equals(f.id))).write(KTodoFilesCompanion(deletedAt: Value(_now())));
    await _record('todofile.delete', {'id': f.id});
  });

  Future<void> markTodoFileUploaded(String id) =>
      (db.update(db.kTodoFiles)..where((f) => f.id.equals(id))).write(const KTodoFilesCompanion(uploaded: Value(true)));

  Future<void> setTodoFileLocalPath(String id, String path) =>
      (db.update(db.kTodoFiles)..where((f) => f.id.equals(id))).write(KTodoFilesCompanion(localPath: Value(path)));

  /// A reminder for this person only, on a to-do or a card; null clears it.
  Future<void> setReminder(String itemId, String kind, int? at) => db.transaction(() async {
    await db.into(db.kReminders).insertOnConflictUpdate(KRemindersCompanion.insert(itemId: itemId, kind: kind, at: Value(at)));
    await _record('reminder.set', {'id': itemId, 'kind': kind, 'at': at});
  });

  /// Everyone's first planner. It shows the dated cards of every Kolumn they
  /// can see; the planner's settings change that.
  Future<String> ensureStarterPlanner() async {
    final existing = await (db.select(db.kPlanners)..where((p) => p.deletedAt.isNull())).get();
    if (existing.isNotEmpty) return existing.first.id;
    final boards = await (db.select(db.kBoards)..where((b) => b.deletedAt.isNull())).get();
    final id = await createPlanner('My planner', boardIds: boards.map((b) => b.id).toList());
    await setSetting('planner.current', id);
    return id;
  }

  Future<void> _applyPlanner(Map<String, dynamic> body, Set<String> pending, {required bool replaceAll}) async {
    if (body['plannerIds'] == null) return; // A hub from before the Planner.
    int? i(Object? v) => v == null ? null : (v as num).toInt();
    List<Map<String, dynamic>> list(String k) => ((body[k] as List?) ?? const []).cast<Map<String, dynamic>>();
    final visible = (body['plannerIds'] as List).cast<String>().toSet();

    // Planners this person is no longer in leave the phone, with their to-dos.
    for (final p in await db.select(db.kPlanners).get()) {
      if (!visible.contains(p.id) && !pending.contains(p.id)) {
        final todoIds = (await (db.select(db.kTodos)..where((t) => t.plannerId.equals(p.id))).get()).map((t) => t.id).toList();
        await (db.delete(db.kTodoSteps)..where((x) => x.todoId.isIn(todoIds))).go();
        await (db.delete(db.kTodoFiles)..where((x) => x.todoId.isIn(todoIds))).go();
        await (db.delete(db.kTodoMarks)..where((x) => x.todoId.isIn(todoIds))).go();
        await (db.delete(db.kTodos)..where((x) => x.plannerId.equals(p.id))).go();
        await (db.delete(db.kPlannerPeople)..where((x) => x.plannerId.equals(p.id))).go();
        await (db.delete(db.kPlanners)..where((x) => x.id.equals(p.id))).go();
      }
    }

    for (final p in list('planners')) {
      if (pending.contains(p['id'])) continue;
      await db
          .into(db.kPlanners)
          .insertOnConflictUpdate(
            KPlannersCompanion.insert(
              id: p['id'] as String,
              name: p['name'] as String? ?? '',
              creatorId: Value(i(p['creatorId'])),
              rollOver: Value(p['rollOver'] != false),
              sinkDone: Value(p['sinkDone'] != false),
              hideDone: Value(p['hideDone'] == true),
              boardIds: Value(jsonEncode(p['boardIds'] ?? const [])),
              canManage: Value(p['canManage'] == true),
              createdAt: i(p['createdAt']) ?? 0,
              updatedAt: i(p['updatedAt']) ?? 0,
              deletedAt: Value(i(p['deletedAt'])),
            ),
          );
    }
    for (final p in list('plannerPeople')) {
      if (pending.contains(p['plannerId'])) continue;
      await db
          .into(db.kPlannerPeople)
          .insertOnConflictUpdate(
            KPlannerPeopleCompanion.insert(
              plannerId: p['plannerId'] as String,
              userId: i(p['userId']) ?? 0,
              role: Value(p['role'] as String? ?? 'edit'),
              deletedAt: Value(i(p['deletedAt'])),
            ),
          );
    }
    final serverTodos = <String>{};
    for (final t in list('todos')) {
      final id = t['id'] as String;
      serverTodos.add(id);
      if (pending.contains(id)) continue;
      final rule = t['repeat'];
      await db
          .into(db.kTodos)
          .insertOnConflictUpdate(
            KTodosCompanion.insert(
              id: id,
              plannerId: t['plannerId'] as String,
              day: Value(t['day'] as String?),
              list: Value(i(t['list'])),
              title: t['title'] as String? ?? '',
              note: Value(t['note'] as String? ?? ''),
              doneAt: Value(i(t['doneAt'])),
              position: Value((t['position'] as num?)?.toDouble() ?? 0),
              repeat: Value(rule == null ? null : jsonEncode(rule)),
              assigneeId: Value(i(t['assigneeId'])),
              creatorId: Value(i(t['creatorId'])),
              createdAt: i(t['createdAt']) ?? 0,
              updatedAt: i(t['updatedAt']) ?? 0,
              deletedAt: Value(i(t['deletedAt'])),
            ),
          );
    }
    final serverMarks = <String>{};
    for (final m in list('todoMarks')) {
      serverMarks.add('${m['todoId']}|${m['day']}');
      if (pending.contains(m['todoId'])) continue;
      await db
          .into(db.kTodoMarks)
          .insertOnConflictUpdate(
            KTodoMarksCompanion.insert(
              todoId: m['todoId'] as String,
              day: m['day'] as String,
              mark: m['mark'] as String? ?? 'done',
              deletedAt: Value(i(m['deletedAt'])),
            ),
          );
    }
    final serverSteps = <String>{};
    for (final s in list('todoSteps')) {
      serverSteps.add(s['id'] as String);
      if (pending.contains(s['id'])) continue;
      await db
          .into(db.kTodoSteps)
          .insertOnConflictUpdate(
            KTodoStepsCompanion.insert(
              id: s['id'] as String,
              todoId: s['todoId'] as String,
              content: s['content'] as String? ?? '',
              done: Value(s['done'] == true),
              heading: Value(s['heading'] == true),
              indent: Value(i(s['indent']) ?? 0),
              star: Value(s['star'] == true),
              position: Value((s['position'] as num?)?.toDouble() ?? 0),
              createdAt: i(s['createdAt']) ?? 0,
              deletedAt: Value(i(s['deletedAt'])),
            ),
          );
    }
    final serverFiles = <String>{};
    for (final f in list('todoFiles')) {
      serverFiles.add(f['id'] as String);
      if (pending.contains(f['id'])) continue;
      final existing = await todoFile(f['id'] as String);
      await db
          .into(db.kTodoFiles)
          .insertOnConflictUpdate(
            KTodoFilesCompanion.insert(
              id: f['id'] as String,
              todoId: f['todoId'] as String,
              userId: Value(i(f['userId']) ?? 0),
              filename: f['filename'] as String? ?? 'file',
              mime: Value(f['mime'] as String? ?? 'application/octet-stream'),
              size: Value(i(f['size']) ?? 0),
              width: Value(i(f['width'])),
              height: Value(i(f['height'])),
              hasThumb: Value(f['hasThumb'] == true),
              createdAt: i(f['createdAt']) ?? 0,
              deletedAt: Value(i(f['deletedAt'])),
              localPath: Value(existing?.localPath),
              uploaded: const Value(true),
            ),
          );
    }
    for (final r in list('reminders')) {
      if (pending.contains(r['itemId'])) continue;
      await db
          .into(db.kReminders)
          .insertOnConflictUpdate(KRemindersCompanion.insert(itemId: r['itemId'] as String, kind: r['kind'] as String? ?? 'todo', at: Value(i(r['at']))));
    }

    if (replaceAll) {
      // A full refresh: anything the hub no longer has goes, unless waiting to be sent.
      for (final t in await db.select(db.kTodos).get()) {
        if (!serverTodos.contains(t.id) && !pending.contains(t.id)) await (db.delete(db.kTodos)..where((x) => x.id.equals(t.id))).go();
      }
      for (final s in await db.select(db.kTodoSteps).get()) {
        if (!serverSteps.contains(s.id) && !pending.contains(s.id) && !pending.contains(s.todoId)) {
          await (db.delete(db.kTodoSteps)..where((x) => x.id.equals(s.id))).go();
        }
      }
      for (final f in await db.select(db.kTodoFiles).get()) {
        if (!serverFiles.contains(f.id) && !pending.contains(f.id)) await (db.delete(db.kTodoFiles)..where((x) => x.id.equals(f.id))).go();
      }
      for (final m in await db.select(db.kTodoMarks).get()) {
        if (!serverMarks.contains('${m.todoId}|${m.day}') && !pending.contains(m.todoId)) {
          await (db.delete(db.kTodoMarks)..where((x) => x.todoId.equals(m.todoId) & x.day.equals(m.day))).go();
        }
      }
    }

    await setSetting('sync.plannerIds', jsonEncode(visible.toList()));
    final current = await setting('planner.current');
    final planners = await (db.select(db.kPlanners)..where((p) => p.deletedAt.isNull())).get();
    if (planners.isNotEmpty && (current == null || !planners.any((p) => p.id == current))) {
      await setSetting('planner.current', planners.first.id);
    }
  }

  /// Planners this phone holds that the hub also knows.
  Future<List<String>> knownPlannerIds() async {
    final raw = await setting('sync.plannerIds');
    final server = raw == null ? <String>{} : (jsonDecode(raw) as List).cast<String>().toSet();
    final local = (await db.select(db.kPlanners).get()).map((p) => p.id).toSet();
    return local.intersection(server).toList();
  }

  // ---------------------------------------------------------------- alerts, following, saved views (Phase 6)

  Stream<List<KNotification>> watchNotifications() =>
      (db.select(db.kNotifications)..orderBy([(n) => OrderingTerm.desc(n.updatedAt)])).watch();

  Stream<List<KBoardWatch>> watchBoardWatches() => db.select(db.kBoardWatches).watch();

  Stream<List<KView>> watchViews() =>
      (db.select(db.kViews)
            ..where((v) => v.deletedAt.isNull())
            ..orderBy([(v) => OrderingTerm.asc(v.createdAt)]))
          .watch();

  Stream<List<KEvent>> watchAllEvents() => (db.select(db.kEvents)..orderBy([(e) => OrderingTerm.desc(e.createdAt)])).watch();

  Stream<List<KColumn>> watchAllColumns() => (db.select(db.kColumns)..where((c) => c.deletedAt.isNull())).watch();

  /// Opening an alert marks it read; "Mark unread" puts it back.
  Future<void> setAlertRead(String cardId, bool read) => db.transaction(() async {
    await (db.update(db.kNotifications)..where((n) => n.cardId.equals(cardId))).write(
      KNotificationsCompanion(readAt: Value(read ? _now() : null), unreadCount: Value(read ? 0 : 1)),
    );
    await _record(read ? 'notification.read' : 'notification.unread', {'id': cardId});
  });

  Future<void> readAllAlerts() => db.transaction(() async {
    await (db.update(db.kNotifications)..where((n) => n.readAt.isNull())).write(KNotificationsCompanion(readAt: Value(_now()), unreadCount: const Value(0)));
    await _record('notification.readall', {'id': newId()});
  });

  /// Following a Kolumn: alerts about everything that happens on it.
  Future<void> setBoardFollow(String boardId, bool on) => db.transaction(() async {
    await db.into(db.kBoardWatches).insertOnConflictUpdate(KBoardWatchesCompanion.insert(boardId: boardId, watching: on));
    await _record('board.watch', {'id': boardId, 'on': on});
  });

  /// A saved view: a name and its filters. Saving again with the same id renames or changes it.
  Future<String> saveView(String name, Map<String, Object?> params, {String? id}) async {
    final vid = id ?? newId();
    await db.transaction(() async {
      await db
          .into(db.kViews)
          .insertOnConflictUpdate(KViewsCompanion.insert(id: vid, name: name.trim(), params: Value(jsonEncode(params)), createdAt: _now(), deletedAt: const Value(null)));
      await _record('view.save', {'id': vid, 'name': name.trim(), 'params': params});
    });
    return vid;
  }

  Future<void> deleteView(String id) => db.transaction(() async {
    await (db.update(db.kViews)..where((v) => v.id.equals(id))).write(KViewsCompanion(deletedAt: Value(_now())));
    await _record('view.delete', {'id': id});
  });

  Future<void> _applyAlerts(Map<String, dynamic> body, Set<String> pending, Set<String> visibleBoards, {required bool replaceAll}) async {
    if (body['notifications'] == null) return; // A hub from before Phase 6.
    int? i(Object? v) => v == null ? null : (v as num).toInt();
    List<Map<String, dynamic>> list(String k) => ((body[k] as List?) ?? const []).cast<Map<String, dynamic>>();
    if (replaceAll) await db.delete(db.kNotifications).go();
    for (final n in list('notifications')) {
      if (pending.contains(n['cardId'])) continue;
      await db
          .into(db.kNotifications)
          .insertOnConflictUpdate(
            KNotificationsCompanion.insert(
              cardId: n['cardId'] as String,
              boardId: n['boardId'] as String,
              creatorId: Value(i(n['creatorId']) ?? 0),
              action: n['action'] as String? ?? '',
              particulars: Value(jsonEncode(n['particulars'] ?? const {})),
              unreadCount: Value(i(n['unreadCount']) ?? 0),
              readAt: Value(i(n['readAt'])),
              updatedAt: i(n['updatedAt']) ?? 0,
            ),
          );
    }
    // Alerts about Kolumns this person can no longer see go.
    await (db.delete(db.kNotifications)..where((n) => n.boardId.isNotIn(visibleBoards.toList()))).go();
    for (final w in list('boardWatches')) {
      if (pending.contains(w['boardId'])) continue;
      await db.into(db.kBoardWatches).insertOnConflictUpdate(KBoardWatchesCompanion.insert(boardId: w['boardId'] as String, watching: w['watching'] == true));
    }
    for (final v in list('views')) {
      if (pending.contains(v['id'])) continue;
      await db
          .into(db.kViews)
          .insertOnConflictUpdate(
            KViewsCompanion.insert(
              id: v['id'] as String,
              name: v['name'] as String? ?? '',
              params: Value(jsonEncode(v['params'] ?? const {})),
              createdAt: i(v['createdAt']) ?? 0,
              deletedAt: Value(i(v['deletedAt'])),
            ),
          );
    }
  }

  // ---------------------------------------------------------------- sharing

  /// Who sees a board: everyone with To-Dos ([allAccess]), or only [members]
  /// (its maker is always one; the hub adds them back if left out).
  Future<void> setBoardAccess(String id, {required bool allAccess, required List<int> members}) => db.transaction(() async {
    await (db.update(
      db.kBoards,
    )..where((b) => b.id.equals(id))).write(KBoardsCompanion(allAccess: Value(allAccess), members: Value(jsonEncode(members)), updatedAt: Value(_now())));
    await _record('board.access', {'id': id, 'allAccess': allAccess, 'members': members});
  });

  Stream<List<KPerson>> watchPeople() => (db.select(db.kPeople)..orderBy([(p) => OrderingTerm.asc(p.name)])).watch();

  // ---------------------------------------------------------------- sync plumbing

  Future<List<KOutboxEntry>> pendingOutbox({int limit = 200}) =>
      (db.select(db.kOutbox)
            ..orderBy([(o) => OrderingTerm.asc(o.id)])
            ..limit(limit))
          .get();

  Stream<int> watchPendingCount() {
    final count = db.kOutbox.id.count();
    return (db.selectOnly(db.kOutbox)..addColumns([count])).map((r) => r.read(count) ?? 0).watchSingle();
  }

  Future<int> pendingCount() async => (await db.select(db.kOutbox).get()).length;

  Future<void> removeOutbox(Iterable<String> mutationIds) => (db.delete(db.kOutbox)..where((o) => o.mutationId.isIn(mutationIds.toList()))).go();

  Future<Set<String>> _pendingIds() async {
    final ids = <String>{};
    for (final e in await db.select(db.kOutbox).get()) {
      final a = jsonDecode(e.args);
      if (a is Map) {
        for (final k in const ['id', 'swappedWith', 'commentId', 'todoId', 'plannerId']) {
          final v = a[k];
          if (v is String) ids.add(v);
        }
      }
    }
    return ids;
  }

  /// Takes in what the hub sent. The hub is the authority, except for rows
  /// this phone has changed and not yet sent: those keep their local state
  /// until the change goes out and comes back.
  ///
  /// With [replaceAll] (a full refresh), columns and cards the hub does not
  /// have are dropped, unless still waiting to be sent.
  Future<void> applyPull(Map<String, dynamic> body, {bool replaceAll = false}) => db.transaction(() async {
    final pending = await _pendingIds();
    final visible = ((body['boardIds'] as List?) ?? const []).cast<String>().toSet();

    int? i(Object? v) => v == null ? null : (v as num).toInt();

    // Boards the person can no longer see go, with everything on them.
    for (final b in await db.select(db.kBoards).get()) {
      if (!visible.contains(b.id) && !pending.contains(b.id)) {
        await (db.delete(db.kCards)..where((c) => c.boardId.equals(b.id))).go();
        await (db.delete(db.kColumns)..where((c) => c.boardId.equals(b.id))).go();
        await (db.delete(db.kBoards)..where((x) => x.id.equals(b.id))).go();
      }
    }

    final serverCards = <String>{};
    final serverColumns = <String>{};

    for (final raw in (body['boards'] as List? ?? const [])) {
      final b = raw as Map<String, dynamic>;
      final id = b['id'] as String;
      if (pending.contains(id)) continue;
      await db
          .into(db.kBoards)
          .insertOnConflictUpdate(
            KBoardsCompanion.insert(
              id: id,
              name: b['name'] as String? ?? '',
              tidyDays: Value(i(b['tidyDays'])),
              lanes: Value(jsonEncode(b['lanes'] is Map ? b['lanes'] : const {})),
              allAccess: Value(b['allAccess'] == true),
              creatorId: Value(i(b['creatorId'])),
              members: Value(jsonEncode(b['members'] ?? const [])),
              canManage: Value(b['canManage'] == true),
              createdAt: i(b['createdAt']) ?? 0,
              updatedAt: i(b['updatedAt']) ?? 0,
              deletedAt: Value(i(b['deletedAt'])),
            ),
          );
    }

    for (final raw in (body['columns'] as List? ?? const [])) {
      final c = raw as Map<String, dynamic>;
      final id = c['id'] as String;
      serverColumns.add(id);
      if (pending.contains(id)) continue;
      await db
          .into(db.kColumns)
          .insertOnConflictUpdate(
            KColumnsCompanion.insert(
              id: id,
              boardId: c['boardId'] as String,
              name: c['name'] as String? ?? '',
              color: Value(i(c['color']) ?? 0),
              position: (c['position'] as num?)?.toDouble() ?? 0,
              createdAt: i(c['createdAt']) ?? 0,
              updatedAt: i(c['updatedAt']) ?? 0,
              deletedAt: Value(i(c['deletedAt'])),
            ),
          );
    }

    for (final raw in (body['cards'] as List? ?? const [])) {
      final c = raw as Map<String, dynamic>;
      final id = c['id'] as String;
      serverCards.add(id);
      if (pending.contains(id)) continue;
      await db
          .into(db.kCards)
          .insertOnConflictUpdate(
            KCardsCompanion.insert(
              id: id,
              boardId: c['boardId'] as String,
              number: i(c['number']) ?? 0,
              title: c['title'] as String? ?? '',
              description: Value(c['description'] as String? ?? ''),
              columnId: Value(c['columnId'] as String?),
              position: Value((c['position'] as num?)?.toDouble()),
              closedAt: Value(i(c['closedAt'])),
              laterAt: Value(i(c['laterAt'])),
              laterReason: Value(c['laterReason'] as String?),
              priorityAt: Value(i(c['priorityAt'])),
              dueAt: Value(i(c['dueAt'])),
              dueHasTime: Value(c['dueHasTime'] == true),
              lastActiveAt: i(c['lastActiveAt']) ?? 0,
              rev: Value(i(c['rev']) ?? 0),
              synced: const Value(true),
              status: Value(c['status'] as String? ?? 'published'),
              coverId: Value(c['coverId'] as String?),
              creatorId: Value(i(c['creatorId'])),
              createdAt: i(c['createdAt']) ?? 0,
              updatedAt: i(c['updatedAt']) ?? 0,
              deletedAt: Value(i(c['deletedAt'])),
            ),
          );
    }

    if (replaceAll) {
      for (final c in await db.select(db.kCards).get()) {
        if (!serverCards.contains(c.id) && !pending.contains(c.id)) {
          await (db.delete(db.kCards)..where((x) => x.id.equals(c.id))).go();
        }
      }
      for (final c in await db.select(db.kColumns).get()) {
        if (!serverColumns.contains(c.id) && !pending.contains(c.id)) {
          await (db.delete(db.kColumns)..where((x) => x.id.equals(c.id))).go();
        }
      }
    }

    await _applyDetails(body, pending);
    await _applyPlanner(body, pending, replaceAll: replaceAll);
    await _applyAlerts(body, pending, visible, replaceAll: replaceAll);

    await db.delete(db.kPeople).go();
    for (final raw in (body['people'] as List?) ?? const []) {
      final p = raw as Map<String, dynamic>;
      await db.into(db.kPeople).insert(KPeopleCompanion.insert(id: Value(i(p['id'])!), name: p['name'] as String? ?? ''));
    }

    final me = body['me'] as Map<String, dynamic>?;
    if (me != null) {
      await setSetting('me.id', '${me['id']}');
      _me = (me['id'] as num?)?.toInt();
      await setSetting('me.name', '${me['name'] ?? ''}');
      await setSetting('me.level', '${me['level'] ?? 'write'}');
      await setSetting('me.manager', me['manager'] == true ? '1' : '0');
    }
    await setSetting('sync.cursor', '${i(body['cursor']) ?? 0}');
    await setSetting('sync.boardIds', jsonEncode(visible.toList()));

    // Keep the chosen board pointing at one that still exists.
    final current = await setting('board.current');
    final boards = await (db.select(db.kBoards)..where((b) => b.deletedAt.isNull())).get();
    if (boards.isNotEmpty && (current == null || !boards.any((b) => b.id == current))) {
      await setSetting('board.current', boards.first.id);
    }
  });

  /// Boards this phone already holds that the hub also knows, for "what changed since".
  Future<List<String>> knownBoardIds() async {
    final raw = await setting('sync.boardIds');
    final server = raw == null ? <String>{} : (jsonDecode(raw) as List).cast<String>().toSet();
    final local = (await db.select(db.kBoards).get()).map((b) => b.id).toSet();
    return local.intersection(server).toList();
  }

  /// Signing out: everything shared leaves this phone, unsent changes included.
  Future<void> forgetSharedData() => db.transaction(() async {
    await db.delete(db.kCards).go();
    await db.delete(db.kColumns).go();
    await db.delete(db.kBoards).go();
    await db.delete(db.kPeople).go();
    await db.delete(db.kOutbox).go();
    for (final t in <TableInfo>[
      db.kSteps,
      db.kComments,
      db.kReactions,
      db.kTags,
      db.kAssignees,
      db.kWatches,
      db.kPins,
      db.kFiles,
      db.kEvents,
      db.kPlanners,
      db.kPlannerPeople,
      db.kTodos,
      db.kTodoMarks,
      db.kTodoSteps,
      db.kTodoFiles,
      db.kReminders,
      db.kNotifications,
      db.kBoardWatches,
      db.kViews,
    ]) {
      await db.delete(t).go();
    }
    _me = null;
    for (final k in const [
      'sync.cursor',
      'sync.boardIds',
      'sync.plannerIds',
      'board.current',
      'planner.current',
      'me.id',
      'me.name',
      'me.level',
      'me.manager',
      'sync.last',
      'alerts.shown',
    ]) {
      await (db.delete(db.kSettings)..where((s) => s.key.equals(k))).go();
    }
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
    await addCard(board, 'Swipe sideways to see the other kolumns', lane: Lane.column(waiting));
    await addCard(board, 'Priority cards always sit at the top', lane: Lane.column(doing), priority: true);
    await addCard(board, 'Tap a card to open it, rename it, or make it Priority');
    await addCard(board, 'Tap a thin strip to open that kolumn');
    await addCard(board, 'Hold a card, then drag it onto a kolumn in the tray');
    await setSetting('board.current', board);
    return board;
  }
}

/// Where a to-do sits: a [day], or Someday list [list] (1-3).
class TodoSlot {
  const TodoSlot.day(String this.day) : list = null;
  const TodoSlot.someday(int this.list) : day = null;
  final String? day;
  final int? list;

  static TodoSlot of(KTodo t) => t.day != null ? TodoSlot.day(t.day!) : TodoSlot.someday(t.list ?? 1);

  String get key => day ?? 'someday-$list';

  static TodoSlot? fromKey(String key) {
    if (key.startsWith('someday-')) return TodoSlot.someday(int.tryParse(key.substring(8)) ?? 1);
    return RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(key) ? TodoSlot.day(key) : null;
  }

  @override
  bool operator ==(Object other) => other is TodoSlot && other.day == day && other.list == list;

  @override
  int get hashCode => Object.hash(day, list);
}
