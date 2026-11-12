import 'dart:convert';

import 'package:drift/drift.dart';

import '../planner/days.dart';
import '../planner/repeat.dart';
import 'database.dart';
import 'lane_looks.dart';
import 'lanes.dart';
import 'repository.dart';

/// Exporting (Phase 7): a Kolumn, or everything, as files to keep or open
/// elsewhere. A JSON file holds everything (cards with their notes,
/// checklists, comments and history, and planners with their to-dos); a CSV
/// file lists the cards for a spreadsheet. Made from what is on the phone, so
/// it works offline. Photos and files are listed by name, not included.
class KolumnExport {
  KolumnExport(this.repo);
  final KolumnRepository repo;
  KolumnDb get db => repo.db;

  Future<Map<int, String>> _names() async => {for (final p in await db.select(db.kPeople).get()) p.id: p.name};

  String _when(int? ms) => ms == null ? '' : DateTime.fromMillisecondsSinceEpoch(ms).toIso8601String().substring(0, 16).replaceFirst('T', ' ');

  /// One Kolumn: its kolumns, left to right, and every card in each.
  Future<Map<String, Object?>> kolumn(String boardId) async {
    final b = (await (db.select(db.kBoards)..where((x) => x.id.equals(boardId))).getSingle());
    final cols = await repo.columns(boardId);
    final names = await _names();
    final live = cols.map((c) => c.id).toSet();
    final cards = await (db.select(db.kCards)..where((c) => c.boardId.equals(boardId) & c.deletedAt.isNull() & c.status.equals('published'))).get();
    final ids = cards.map((c) => c.id).toList();
    final steps = await (db.select(db.kSteps)..where((s) => s.cardId.isIn(ids) & s.deletedAt.isNull())).get();
    final comments = await (db.select(db.kComments)..where((s) => s.cardId.isIn(ids) & s.deletedAt.isNull())).get();
    final tags = await (db.select(db.kTags)..where((s) => s.cardId.isIn(ids) & s.deletedAt.isNull())).get();
    final assignees = await (db.select(db.kAssignees)..where((s) => s.cardId.isIn(ids) & s.deletedAt.isNull())).get();
    final files = await (db.select(db.kFiles)..where((s) => s.cardId.isIn(ids) & s.deletedAt.isNull())).get();
    final events = await (db.select(db.kEvents)..where((s) => s.cardId.isIn(ids))).get();

    String laneName(Lane l) => l.kind == LaneKind.column ? (cols.where((c) => c.id == l.columnId).firstOrNull?.name ?? '') : laneLook(b, kindKey(l.kind)).name;

    Map<String, Object?> card(KCard c) => {
      'number': c.synced ? c.number : null,
      'title': c.title,
      'notes': c.description,
      'priority': c.priorityAt != null,
      'dueDay': c.dueAt == null ? null : dueDayOf(c.dueAt!),
      'tags': [for (final t in tags.where((t) => t.cardId == c.id)) t.tag],
      'assignedTo': [for (final a in assignees.where((a) => a.cardId == c.id)) names[a.userId] ?? 'someone'],
      'addedBy': names[c.creatorId] ?? '',
      'added': _when(c.createdAt),
      'finished': _when(c.closedAt),
      'checklist': [
        for (final s in (steps.where((s) => s.cardId == c.id).toList()..sort((a, b) => a.position.compareTo(b.position)))) {'step': s.content, 'done': s.done},
      ],
      'comments': [
        for (final m in (comments.where((m) => m.cardId == c.id).toList()..sort((a, b) => a.createdAt.compareTo(b.createdAt))))
          {'by': names[m.userId] ?? 'someone', 'when': _when(m.createdAt), 'text': m.body},
      ],
      'files': [
        for (final f in files.where((f) => f.cardId == c.id && f.commentId == null)) {'name': f.filename, 'bytes': f.size},
      ],
      'history': [
        for (final e in (events.where((e) => e.cardId == c.id).toList()..sort((a, b) => a.createdAt.compareTo(b.createdAt))))
          {'what': e.action, 'by': e.userId == 0 ? 'Kolumn' : (names[e.userId] ?? 'someone'), 'when': _when(e.createdAt)},
      ],
    };

    final lanes = <Map<String, Object?>>[];
    final placed = <String>{};
    for (final (lane, _) in laneOrder(b, cols)) {
      final inIt = sortForLane(lane, cards.where((c) => Lane.of(c, live) == lane));
      placed.addAll(inIt.map((c) => c.id));
      lanes.add({'kolumn': laneName(lane), 'cards': [for (final c in inIt) card(c)]});
    }
    final elsewhere = cards.where((c) => !placed.contains(c.id)).toList();
    if (elsewhere.isNotEmpty) {
      lanes.add({'kolumn': '(in a deleted kolumn)', 'cards': [for (final c in elsewhere) card(c)]});
    }
    return {'name': b.name, 'kolumns': lanes};
  }

  /// One spreadsheet row per card.
  Future<String> kolumnCsv(String boardId) async {
    final k = await kolumn(boardId);
    final rows = <List<String>>[
      ['Kolumn', 'In', 'Number', 'Title', 'Priority', 'Due', 'Tags', 'Assigned to', 'Added by', 'Added', 'Finished', 'Checklist done', 'Notes'],
    ];
    for (final lane in (k['kolumns'] as List).cast<Map<String, Object?>>()) {
      for (final c in (lane['cards'] as List).cast<Map<String, Object?>>()) {
        final steps = (c['checklist'] as List).cast<Map>();
        rows.add([
          '${k['name']}',
          '${lane['kolumn']}',
          c['number'] == null ? '' : '${c['number']}',
          '${c['title']}',
          c['priority'] == true ? 'yes' : '',
          '${c['dueDay'] ?? ''}',
          (c['tags'] as List).join(', '),
          (c['assignedTo'] as List).join(', '),
          '${c['addedBy']}',
          '${c['added']}',
          '${c['finished']}',
          steps.isEmpty ? '' : '${steps.where((s) => s['done'] == true).length} of ${steps.length}',
          '${c['notes']}',
        ]);
      }
    }
    return rows.map((r) => r.map(_csv).join(',')).join('\r\n');
  }

  static String _csv(String v) => v.contains(RegExp(r'[",\r\n]')) || v.startsWith(RegExp(r'[=+\-@]')) ? '"${v.startsWith(RegExp(r'[=+\-@]')) ? "'" : ''}${v.replaceAll('"', '""')}"' : v;

  /// One planner and its to-dos.
  Future<Map<String, Object?>> planner(KPlanner p) async {
    final todos = await (db.select(db.kTodos)..where((t) => t.plannerId.equals(p.id) & t.deletedAt.isNull())).get();
    final ids = todos.map((t) => t.id).toList();
    final steps = await (db.select(db.kTodoSteps)..where((s) => s.todoId.isIn(ids) & s.deletedAt.isNull())).get();
    todos.sort((a, b) => (a.day ?? 'someday-${a.list}').compareTo(b.day ?? 'someday-${b.list}'));
    return {
      'name': p.name,
      'toDos': [
        for (final t in todos)
          {
            'title': t.title,
            'day': t.day,
            'someday': t.day == null ? t.list : null,
            'done': t.doneAt != null,
            'repeats': t.repeat == null || t.day == null ? null : RepeatRule.fromJson(t.repeat)?.describe(t.day!),
            'note': t.note,
            'checklist': [
              for (final s in steps.where((s) => s.todoId == t.id)) {'step': s.content, 'done': s.done, 'heading': s.heading},
            ],
          },
      ],
    };
  }

  /// Everything this person can see: every Kolumn and every planner.
  Future<Map<String, Object?>> everything() async {
    final boards = await (db.select(db.kBoards)..where((b) => b.deletedAt.isNull())).get();
    final planners = await (db.select(db.kPlanners)..where((p) => p.deletedAt.isNull())).get();
    return {
      'exported': _when(DateTime.now().millisecondsSinceEpoch),
      'kolumns': [for (final b in boards) await kolumn(b.id)],
      'planners': [for (final p in planners) await planner(p)],
    };
  }

  static String pretty(Object? v) => const JsonEncoder.withIndent('  ').convert(v);

  /// A file name that works everywhere: "Kolumn - Fall tour - 2026-11-12".
  static String fileName(String name) => 'Kolumn - ${name.replaceAll(RegExp(r'[^\w\s&-]'), '').trim()} - ${todayKey()}';
}
