import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../data/repository.dart';
import '../state/providers.dart';
import 'days.dart';
import 'repeat.dart';

/// One line in the Planner: a to-do (for a repeating one, one day of it), or
/// a dated card from a Kolumn the planner shows.
class PlannerEntry {
  PlannerEntry.todo(KTodo this.todo, {required this.slotKey, this.day, required this.done, this.rule}) : card = null, late = false;

  PlannerEntry.card(KCard this.card, {required this.slotKey, required this.late}) : todo = null, day = slotKey, done = card.closedAt != null, rule = null;

  final KTodo? todo;
  final KCard? card;

  /// The day or Someday list it shows in ("2026-11-11" or "someday-1").
  final String slotKey;

  /// The day this line stands for (for a repeating to-do, which day).
  final String? day;
  final bool done;

  /// A card past its due day and not finished: shown red, never moved.
  final bool late;
  final RepeatRule? rule;

  bool get isCard => card != null;
  bool get repeats => rule != null;
  String get id => isCard ? 'card:${card!.id}' : 'todo:${todo!.id}@$slotKey';
  String get title => isCard ? card!.title : todo!.title;
}

/// Everything one planner shows, worked out from what is on the phone.
class PlannerData {
  PlannerData({required this.planner, required this.todos, required this.marks, required this.cards, required this.today});

  final KPlanner planner;
  final List<KTodo> todos;
  final Map<String, Map<String, String>> marks; // todoId -> day -> 'done' | 'skip'
  final List<KCard> cards;
  final String today;

  late final Set<String> boardIds = ((jsonDecode(planner.boardIds) as List?) ?? const []).cast<String>().toSet();

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
      if (c.dueAt == null || c.deletedAt != null || c.status != 'published' || !boardIds.contains(c.boardId)) continue;
      m.putIfAbsent(dueDayOf(c.dueAt!), () => []).add(c);
    }
    return m;
  }();

  /// The lines for a day or Someday list, in Tweek's order: by where they
  /// were put, finished ones sunk to the bottom (switch), finished ones
  /// hidden (switch).
  List<PlannerEntry> entries(String slotKey) {
    final out = <PlannerEntry>[];
    final isDay = !slotKey.startsWith('someday-');
    final plain = [...?_bySlot[slotKey]]..sort((a, b) => a.position != b.position ? a.position.compareTo(b.position) : a.createdAt.compareTo(b.createdAt));
    for (final t in plain) {
      out.add(PlannerEntry.todo(t, slotKey: slotKey, day: t.day, done: t.doneAt != null));
    }
    if (isDay) {
      final rep = <PlannerEntry>[];
      for (final (t, r) in _repeating) {
        if (!r.occursOn(t.day!, slotKey)) continue;
        final mark = marks[t.id]?[slotKey];
        if (mark == 'skip') continue;
        rep.add(PlannerEntry.todo(t, slotKey: slotKey, day: slotKey, done: mark == 'done', rule: r));
      }
      rep.sort((a, b) => a.todo!.position.compareTo(b.todo!.position));
      out.insertAll(0, rep);
      final cs = [...?_cardsByDay[slotKey]]..sort((a, b) => a.number.compareTo(b.number));
      for (final c in cs) {
        out.add(PlannerEntry.card(c, slotKey: slotKey, late: c.closedAt == null && slotKey.compareTo(today) < 0));
      }
    }
    var shown = planner.hideDone ? out.where((e) => !e.done).toList() : out;
    if (planner.sinkDone) shown = [...shown.where((e) => !e.done), ...shown.where((e) => e.done)];
    return shown;
  }

  /// Searching: to-dos (title and note) and the planner's dated cards.
  List<PlannerEntry> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final out = <PlannerEntry>[];
    for (final t in todos) {
      if (t.title.toLowerCase().contains(q) || t.note.toLowerCase().contains(q)) {
        final slot = TodoSlot.of(t).key;
        out.add(PlannerEntry.todo(t, slotKey: slot, day: t.day, done: t.doneAt != null, rule: RepeatRule.fromJson(t.repeat)));
      }
    }
    for (final e in _cardsByDay.entries) {
      for (final c in e.value) {
        if (c.title.toLowerCase().contains(q)) out.add(PlannerEntry.card(c, slotKey: e.key, late: c.closedAt == null && e.key.compareTo(today) < 0));
      }
    }
    out.sort((a, b) => (a.day ?? '9999').compareTo(b.day ?? '9999'));
    return out;
  }
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
    today: ref.watch(plannerTodayProvider),
  );
});
