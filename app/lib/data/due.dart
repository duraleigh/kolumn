import '../planner/days.dart';

/// Where something with a due date stands (his rules, 2026-11-13), the same
/// for Kolumn cards and Planner to-dos:
/// - [upcoming]: due on a later day;
/// - [dueToday]: due today and not yet past its moment — shown yellow (dark)
///   or deep amber (light), at the top of the day;
/// - [late]: past its moment and not finished — a red row, white words,
///   a bold "LATE:" in front;
/// - [lateDone]: finished after its moment — normal finished look, but keeps
///   "LATE:" (not bold).
enum DueState { none, upcoming, dueToday, late, done, lateDone }

DueState dueState({required int? dueAt, required bool hasTime, required int? doneAt, required int now}) {
  if (dueAt == null) return doneAt == null ? DueState.none : DueState.done;
  final moment = dueMoment(dueAt, hasTime: hasTime);
  if (doneAt != null) return doneAt > moment ? DueState.lateDone : DueState.done;
  if (now > moment) return DueState.late;
  return dueDay(dueAt, hasTime: hasTime) == todayKey(DateTime.fromMillisecondsSinceEpoch(now)) ? DueState.dueToday : DueState.upcoming;
}

extension DueStateLook on DueState {
  bool get isLate => this == DueState.late;

  /// "LATE:" goes in front of the title (bold only while still late).
  bool get showsLate => this == DueState.late || this == DueState.lateDone;
}
