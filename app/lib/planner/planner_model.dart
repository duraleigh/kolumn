import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../data/due.dart';
import '../data/repository.dart';
import '../state/providers.dart';
import 'days.dart';
import 'repeat.dart';

/// One line in the Planner: a to-do (for a repeating one, one day of it), or
/// a dated card from a Kolumn the planner shows.
class PlannerEntry {
  PlannerEntry.todo(KTodo this.todo, {required this.slotKey, this.day, required this.done, this.rule, this.state = DueState.none}) : card = null;

  PlannerEntry.card(KCard this.card, {required this.slotKey, required this.state}) : todo = null, day = slotKey, done = card.closedAt != null, rule = null;

  final KTodo? todo;
  final KCard? card;

  /// The day or Someday list it shows in ("2026-11-11" or "someday-1").
  final String slotKey;

  /// The day this line stands for (for a repeating to-do, which day).
  final String? day;
  final bool done;

  /// Where it stands against its due date: due today (yellow/amber), late
  /// (red, "LATE:"), finished late ("LATE:", not bold)…
  final DueState state;
  final RepeatRule? rule;

  /// Past its due moment and not finished: a red row, pinned in sight.
  bool get late => state == DueState.late;
  bool get isCard => card != null;
  bool get repeats => rule != null;
  String get id => isCard ? 'card:${card!.id}' : 'todo:${todo!.id}@$slotKey';
  String get title => isCard ? card!.title : todo!.title;
}

/// Whether a Kolumn's card may show in a planner (2026-11-13): BOTH must
/// agree — the Kolumn allows the planner (and the card's kolumn has not been
/// narrowed to leave it out), and the planner has the Kolumn switched on.
bool kolumnAllowsPlanner(KBoard board, String plannerId, {String? lane, KColumn? column}) {
  final allowed = ((jsonDecode(board.plannerIds) as List?) ?? const []).cast<String>();
  if (!allowed.contains(plannerId)) return false;
  List? narrowed;
  if (column != null) {
    narrowed = column.plannerIds == null ? null : jsonDecode(column.plannerIds!) as List?;
  } else if (lane != null) {
    final looks = jsonDecode(board.lanes);
    final one = looks is Map ? looks[lane] : null;
    narrowed = one is Map && one['plannerIds'] is List ? one['plannerIds'] as List : null;
  }
  return narrowed == null || narrowed.contains(plannerId);
}

/// Everything one planner shows, worked out from what is on the phone.
class PlannerData {
  PlannerData({
    required this.planner,
    required this.todos,
    required this.marks,
    required this.cards,
    required this.today,
    this.boards = const [],
    this.columns = const [],
    int? now,
  }) : now = now ?? DateTime.now().millisecondsSinceEpoch;

  final KPlanner planner;
  final List<KTodo> todos;
  final Map<String, Map<String, String>> marks; // todoId -> day -> 'done' | 'skip'
  final List<KCard> cards;
  final String today;
  final List<KBoard> boards;
  final List<KColumn> columns;

  /// The moment "late" is measured against.
  final int now;

  /// The Kolumns this planner has switched on (its side of the agreement).
  late final Set<String> boardIds = ((jsonDecode(planner.boardIds) as List?) ?? const []).cast<String>().toSet();

  late final Map<String, KBoard> _boards = {for (final b in boards) b.id: b};
  late final Map<String, KColumn> _columns = {for (final c in columns) c.id: c};

  /// Whether a card's Kolumn (and its kolumn) let this planner show it.
  bool shows(KCard c) {
    if (!boardIds.contains(c.boardId)) return false;
    final b = _boards[c.boardId];
    if (b == null) return false;
    if (c.closedAt != null) return kolumnAllowsPlanner(b, planner.id, lane: 'done');
    if (c.laterAt != null) return kolumnAllowsPlanner(b, planner.id, lane: 'later');
    final col = c.columnId == null ? null : _columns[c.columnId];
    if (col != null) return kolumnAllowsPlanner(b, planner.id, column: col);
    return kolumnAllowsPlanner(b, planner.id, lane: 'todo');
  }

  DueState stateOfTodo(KTodo t) => t.repeat != null ? (t.doneAt != null ? DueState.done : DueState.none) : dueState(dueAt: t.dueAt, hasTime: t.dueHasTime, doneAt: t.doneAt, now: now);

  DueState stateOfCard(KCard c) => dueState(dueAt: c.dueAt, hasTime: c.dueHasTime, doneAt: c.closedAt, now: now);

  late final List<(KTodo, RepeatRule)> _repeating = [
    for (final t in todos)
      if (t.repeat != null && t.day != null)
        if (RepeatRule.fromJson(t.repeat) case final r?) (t, r),
  ];

  late final Map<String, List<KTodo>> _bySlot = () {
    final m = <String, List<KTodo>>{};
    for (final t in todos) {
      if (t.repeat != null && t.day != null) continue;
      m.putIfAbsent(TodoSlot.of(t).key, () => []).add(t);
    }
    return m;
  }();

  late final Map<String, List<KCard>> _cardsByDay = () {
    final m = <String, List<KCard>>{};
    for (final c in cards) {
      if (c.dueAt == null || c.deletedAt != null || c.status != 'published' || !shows(c)) continue;
      m.putIfAbsent(dueDay(c.dueAt!, hasTime: c.dueHasTime), () => []).add(c);
    }
    return m;
  }();

  /// The lines for a day or Someday list, in Tweek's order: by where they
  /// were put, with anything due that day on top (his rule, 2026-11-13);
  /// finished ones sunk to the bottom (switch), finished ones hidden (switch).
  List<PlannerEntry> entries(String slotKey) {
    final out = <PlannerEntry>[];
    final isDay = !slotKey.startsWith('someday-');
    final plain = [...?_bySlot[slotKey]]..sort((a, b) => a.position != b.position ? a.position.compareTo(b.position) : a.createdAt.compareTo(b.createdAt));
    for (final t in plain) {
      out.add(PlannerEntry.todo(t, slotKey: slotKey, day: t.day, done: t.doneAt != null, state: stateOfTodo(t)));
    }
    if (isDay) {
      final rep = <PlannerEntry>[];
      for (final (t, r) in _repeating) {
        if (!r.occursOn(t.day!, slotKey)) continue;
        final mark = marks[t.id]?[slotKey];
        if (mark == 'skip') continue;
        rep.add(PlannerEntry.todo(t, slotKey: slotKey, day: slotKey, done: mark == 'done', rule: r, state: mark == 'done' ? DueState.done : DueState.none));
      }
      rep.sort((a, b) => a.todo!.position.compareTo(b.todo!.position));
      out.insertAll(0, rep);
      final cs = [...?_cardsByDay[slotKey]]..sort((a, b) => a.number.compareTo(b.number));
      for (final c in cs) {
        out.add(PlannerEntry.card(c, slotKey: slotKey, state: stateOfCard(c)));
      }
    }
    // Due today, or late on its due day: to the top, in their order.
    bool urgent(PlannerEntry e) => !e.done && (e.state == DueState.dueToday || e.state == DueState.late);
    final ordered = [...out.where(urgent), ...out.where((e) => !urgent(e))];
    var shown = planner.hideDone ? ordered.where((e) => !e.done).toList() : ordered;
    if (planner.sinkDone) shown = [...shown.where((e) => !e.done), ...shown.where((e) => e.done)];
    return shown;
  }

  /// Everything late in this planner (to-dos and cards), oldest due first:
  /// these stay pinned in sight until finished or given a later due date.
  late final List<PlannerEntry> lateItems = () {
    final out = <PlannerEntry>[];
    for (final t in todos) {
      if (t.repeat != null || t.day == null) continue;
      final st = stateOfTodo(t);
      if (st == DueState.late) out.add(PlannerEntry.todo(t, slotKey: t.day!, day: t.day, done: false, state: st));
    }
    for (final e in _cardsByDay.entries) {
      for (final c in e.value) {
        final st = stateOfCard(c);
        if (st == DueState.late) out.add(PlannerEntry.card(c, slotKey: e.key, state: st));
      }
    }
    int due(PlannerEntry e) => e.isCard ? e.card!.dueAt! : e.todo!.dueAt!;
    out.sort((a, b) => due(a).compareTo(due(b)));
    return out;
  }();

  /// Searching: to-dos (title and note) and the planner's dated cards.
  List<PlannerEntry> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final out = <PlannerEntry>[];
    for (final t in todos) {
      if (t.title.toLowerCase().contains(q) || t.note.toLowerCase().contains(q)) {
        final slot = TodoSlot.of(t).key;
        out.add(PlannerEntry.todo(t, slotKey: slot, day: t.day, done: t.doneAt != null, rule: RepeatRule.fromJson(t.repeat), state: stateOfTodo(t)));
      }
    }
    for (final e in _cardsByDay.entries) {
      for (final c in e.value) {
        if (c.title.toLowerCase().contains(q)) out.add(PlannerEntry.card(c, slotKey: e.key, state: stateOfCard(c)));
      }
    }
    out.sort((a, b) => (a.day ?? '9999').compareTo(b.day ?? '9999'));
    return out;
  }
}

/// Where a to-do may be moved (his rules, 2026-11-13), by dragging or by
/// "Move to a different date": an unfinished one never to a past day, nor
/// past its due day; a finished one never to a future day; only unfinished
/// ones may go to a Someday list.
bool canMoveTodo(KTodo t, TodoSlot to, {required String today}) {
  final finished = t.doneAt != null;
  if (to.day == null) return !finished;
  if (finished) return to.day!.compareTo(today) <= 0;
  if (to.day!.compareTo(today) < 0) return false;
  if (t.dueAt != null && to.day!.compareTo(dueDay(t.dueAt!, hasTime: t.dueHasTime)) > 0) return false;
  return true;
}

// ---------------------------------------------------------------- providers

final plannersProvider = StreamProvider<List<KPlanner>>((ref) => ref.watch(repositoryProvider).watchPlanners());

final currentPlannerIdProvider = StreamProvider<String?>((ref) => ref.watch(repositoryProvider).watchSetting('planner.current'));

final plannerTodosProvider = StreamProvider.family<List<KTodo>, String>((ref, id) => ref.watch(repositoryProvider).watchTodos(id));

final todoMarksProvider = StreamProvider<List<KTodoMark>>((ref) => ref.watch(repositoryProvider).watchTodoMarks());

final todoProvider = StreamProvider.family<KTodo?, String>((ref, id) => ref.watch(repositoryProvider).watchTodo(id));

final todoStepsProvider = StreamProvider.family<List<KTodoStep>, String>((ref, id) => ref.watch(repositoryProvider).watchTodoSteps(id));

final todoFilesProvider = StreamProvider.family<List<KTodoFile>, String>((ref, id) => ref.watch(repositoryProvider).watchTodoFiles(id));

final plannerPeopleProvider = StreamProvider.family<List<KPlannerPerson>, String>((ref, id) => ref.watch(repositoryProvider).watchPlannerPeople(id));

final remindersProvider = StreamProvider<List<KReminder>>((ref) => ref.watch(repositoryProvider).watchReminders());

/// The reminder time for each item that has one.
final reminderMapProvider = Provider<Map<String, int>>((ref) {
  return {for (final r in ref.watch(remindersProvider).value ?? const <KReminder>[]) r.itemId: r.at!};
});

/// "Today" for the Planner; a test can pin it.
final plannerTodayProvider = Provider<String>((ref) => todayKey());

/// The clock "late" is measured against; a test can pin it.
final plannerNowProvider = Provider<int Function()>((ref) => () => DateTime.now().millisecondsSinceEpoch);

final plannerDataProvider = Provider.family<PlannerData?, String>((ref, id) {
  KPlanner? planner;
  for (final p in ref.watch(plannersProvider).value ?? const <KPlanner>[]) {
    if (p.id == id) planner = p;
  }
  if (planner == null) return null;
  final marks = <String, Map<String, String>>{};
  for (final m in ref.watch(todoMarksProvider).value ?? const <KTodoMark>[]) {
    marks.putIfAbsent(m.todoId, () => {})[m.day] = m.mark;
  }
  return PlannerData(
    planner: planner,
    todos: ref.watch(plannerTodosProvider(id)).value ?? const [],
    marks: marks,
    cards: ref.watch(allCardsProvider).value ?? const [],
    boards: ref.watch(boardsProvider).value ?? const [],
    columns: ref.watch(allColumnsProvider).value ?? const [],
    today: ref.watch(plannerTodayProvider),
    now: ref.watch(plannerNowProvider)(),
  );
});
