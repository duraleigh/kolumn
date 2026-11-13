import 'dart:convert';

import '../data/database.dart';
import '../planner/days.dart';
import '../planner/repeat.dart';

/// Fizzy's Activity: each day's history in three groups.
enum ActivityGroup { added, updated, done }

ActivityGroup groupOf(KEvent e) {
  if (e.action == 'card_published') return ActivityGroup.added;
  if (e.action == 'card_moved' && _p(e)['to'] == 'done') return ActivityGroup.done;
  return ActivityGroup.updated;
}

Map<String, dynamic> _p(KEvent e) {
  try {
    final v = jsonDecode(e.particulars);
    return v is Map<String, dynamic> ? v : const {};
  } catch (_) {
    return const {};
  }
}

String _lane(Map<String, dynamic> p) {
  // The name the kolumn had when the card moved (the hub keeps it), else the usual one.
  final named = p['column'] as String?;
  if (named != null && named.isNotEmpty) return named;
  switch (p['to']) {
    case 'todo':
      return 'To-do';
    case 'later':
      return 'Later';
    case 'done':
      return 'Done';
  }
  return 'another kolumn';
}

String _due(Map<String, dynamic> p) {
  final at = (p['dueAt'] as num?)?.toInt();
  if (at != null) return dayLabel(dueDay(at, hasTime: p['hasTime'] == true));
  if (p['day'] is String) return dayLabel(p['day'] as String);
  return '';
}

/// One line of the Activity feed, in plain words, naming the card or to-do.
String activityLine(String action, Map<String, dynamic> p, {required String who, required String title, required int? me, Map<int, String> names = const {}}) {
  String person(Object? id, Object? name) {
    final n = (id as num?)?.toInt();
    if (n == me && me != null) return 'you';
    if ((name as String?)?.isNotEmpty == true) return name!;
    return names[n] ?? 'someone';
  }

  switch (action) {
    // ---- Planner to-dos (2026-11-13)
    case 'todo_created':
      return '$who added $title';
    case 'todo_done':
      return p['late'] == true ? '$who finished $title, late' : '$who finished $title';
    case 'todo_reopened':
      return '$who marked $title not done';
    case 'todo_due_set':
      return '$who set $title due ${_due(p)}';
    case 'todo_due_changed':
      return '$who changed $title to be due ${_due(p)}';
    case 'todo_due_cleared':
      return '$who took the due date off $title';
    case 'todo_late':
      return '$title missed its due date';
    case 'todo_assigned':
      return '$who gave $title to ${person(p['userId'], null)}';
    case 'todo_moved':
      return p['to'] is String ? '$who moved $title to ${dayLabel(p['to'] as String)}' : '$who moved $title';
    // ---- Kolumn cards
    case 'card_published':
      return '$who added $title';
    case 'card_moved':
      return '$who moved $title to ${_lane(p)}';
    case 'card_priority':
      return '$who made $title Priority';
    case 'card_unpriority':
      return '$who took Priority off $title';
    case 'card_renamed':
      return '$who renamed "${p['from'] ?? ''}" to $title';
    case 'card_assigned':
      return '$who assigned ${person(p['userId'], p['name'])} to $title';
    case 'card_unassigned':
      return '$who took ${person(p['userId'], p['name'])} off $title';
    case 'comment_created':
      return '$who commented on $title';
    case 'card_board_changed':
      return '$who moved $title to ${p['to'] ?? 'another Kolumn'}';
    case 'card_due_set':
      return _due(p).isNotEmpty ? '$who set $title due ${_due(p)}' : '$who set a due date on $title';
    case 'card_due_cleared':
      return '$who took the due date off $title';
    case 'card_pinned':
      return '$who pinned $title to the top';
    case 'card_unpinned':
      return '$who unpinned $title from the top';
    case 'card_auto_later':
      return '$title moved to Later on its own after ${p['days'] ?? 30} days untouched';
    case 'mentioned':
      return '$who mentioned you on $title';
    default:
      return '$who changed $title';
  }
}

/// An alert in plain words: what happened, from the point of view of the
/// person reading it.
String alertLine(KNotification n, {required String who, required String title, required int? me}) {
  Map<String, dynamic> p;
  try {
    p = (jsonDecode(n.particulars) as Map).cast<String, dynamic>();
  } catch (_) {
    p = const {};
  }
  if (n.action == 'card_assigned' && (p['userId'] as num?)?.toInt() == me) return '$who assigned you to $title';
  if (n.action == 'todo_assigned' && (p['userId'] as num?)?.toInt() == me) return '$who gave you $title';
  return activityLine(n.action, p, who: who, title: title, me: me);
}

// ---------------------------------------------------------------- one feed for cards and to-dos

/// A line of Activity: something that happened to a card or, since 0.8, a
/// Planner to-do (seen only by people in that planner, as the hub sends them).
class ActivityItem {
  ActivityItem({
    required this.todo,
    required this.itemId,
    required this.sourceId,
    required this.userId,
    required this.action,
    required this.particulars,
    required this.createdAt,
    required this.title,
  });

  factory ActivityItem.card(KEvent e, KCard c) =>
      ActivityItem(todo: false, itemId: c.id, sourceId: c.boardId, userId: e.userId, action: e.action, particulars: _p(e), createdAt: e.createdAt, title: c.title);

  factory ActivityItem.todo(KTodoEvent e, KTodo t) =>
      ActivityItem(todo: true, itemId: t.id, sourceId: t.plannerId, userId: e.userId, action: e.action, particulars: _json(e.particulars), createdAt: e.createdAt, title: t.title);

  final bool todo;
  final String itemId;

  /// The Kolumn (for a card) or planner (for a to-do) it belongs to.
  final String sourceId;
  final int userId;
  final String action;
  final Map<String, dynamic> particulars;
  final int createdAt;
  final String title;

  ActivityGroup get group {
    switch (action) {
      case 'card_published':
      case 'todo_created':
        return ActivityGroup.added;
      case 'todo_done':
        return ActivityGroup.done;
      case 'card_moved':
        return particulars['to'] == 'done' ? ActivityGroup.done : ActivityGroup.updated;
    }
    return ActivityGroup.updated;
  }
}

Map<String, dynamic> _json(String s) {
  try {
    final v = jsonDecode(s);
    return v is Map<String, dynamic> ? v : const {};
  } catch (_) {
    return const {};
  }
}

/// Every Activity line on the phone, cards and to-dos, newest first. [only]
/// keeps the Kolumns and planners chosen (empty: everything).
List<ActivityItem> activityItems({
  required List<KEvent> events,
  required Map<String, KCard> cards,
  List<KTodoEvent> todoEvents = const [],
  Map<String, KTodo> todos = const {},
  Set<String> only = const {},
}) {
  final out = <ActivityItem>[];
  for (final e in events) {
    final c = cards[e.cardId];
    if (c == null || c.deletedAt != null || c.status != 'published') continue;
    if (only.isNotEmpty && !only.contains(c.boardId)) continue;
    out.add(ActivityItem.card(e, c));
  }
  for (final e in todoEvents) {
    final t = todos[e.todoId];
    if (t == null || t.deletedAt != null) continue;
    if (only.isNotEmpty && !only.contains(t.plannerId)) continue;
    out.add(ActivityItem.todo(e, t));
  }
  out.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return out;
}

/// One day of Activity, in the three groups.
class ActivityItemsDay {
  ActivityItemsDay(this.day, this.items);
  final String day;
  final List<ActivityItem> items;

  List<ActivityItem> of(ActivityGroup g) => items.where((e) => e.group == g).toList();
}

ActivityItemsDay itemsOn(String day, List<ActivityItem> all) =>
    ActivityItemsDay(day, [for (final e in all) if (dayKey(DateTime.fromMillisecondsSinceEpoch(e.createdAt)) == day) e]);

/// The most recent day before [day] with any activity (quiet days are skipped), or null.
String? previousItemsDay(String day, List<ActivityItem> all) {
  String? best;
  for (final e in all) {
    final d = dayKey(DateTime.fromMillisecondsSinceEpoch(e.createdAt));
    if (d.compareTo(day) < 0 && (best == null || d.compareTo(best) > 0)) best = d;
  }
  return best;
}

// ---------------------------------------------------------------- reminders in Alerts

/// A reminder that has gone off (his ask, 2026-11-13: reminders show in
/// Alerts too, for cards and to-dos). Kept on this phone only.
class PassedReminder {
  const PassedReminder({required this.itemId, required this.todo, required this.at, required this.title, required this.read});
  final String itemId;
  final bool todo;
  final int at;
  final String title;
  final bool read;
}

/// This person's reminders whose time has come, newest first, from the last
/// 30 days. A repeating to-do's reminder counts once, at its latest passed day.
List<PassedReminder> passedReminders({
  required List<KReminder> reminders,
  required Map<String, KCard> cards,
  required Map<String, KTodo> todos,
  required Set<(String, int)> read,
  required DateTime now,
}) {
  final out = <PassedReminder>[];
  final since = now.subtract(const Duration(days: 30)).millisecondsSinceEpoch;
  for (final r in reminders) {
    final set = r.at;
    if (set == null) continue;
    var at = set;
    String? title;
    if (r.kind == 'card') {
      final c = cards[r.itemId];
      if (c == null || c.deletedAt != null) continue;
      title = c.title;
    } else {
      final t = todos[r.itemId];
      if (t == null || t.deletedAt != null) continue;
      title = t.title;
      final rule = RepeatRule.fromJson(t.repeat);
      if (rule != null && t.day != null) {
        final w = DateTime.fromMillisecondsSinceEpoch(at);
        final today = dayKey(now);
        final days = rule.daysBetweenIncl(t.day!, addDays(today, -30), today).toList();
        for (final d in days.reversed) {
          final p = parseDay(d);
          final m = DateTime(p.year, p.month, p.day, w.hour, w.minute).millisecondsSinceEpoch;
          if (m <= now.millisecondsSinceEpoch && m >= set) {
            at = m;
            break;
          }
        }
      }
    }
    if (at > now.millisecondsSinceEpoch || at < since) continue;
    out.add(PassedReminder(itemId: r.itemId, todo: r.kind != 'card', at: at, title: title, read: read.contains((r.itemId, at))));
  }
  out.sort((a, b) => b.at.compareTo(a.at));
  return out;
}

/// One day of Activity: its events, newest first, in the three groups.
class ActivityDay {
  ActivityDay(this.day, this.events);
  final String day;
  final List<KEvent> events;

  List<KEvent> of(ActivityGroup g) => events.where((e) => groupOf(e) == g).toList();
}

/// The events of [day] (the phone's local day), on cards that still exist,
/// optionally only on the Kolumns in [boards].
ActivityDay activityOn(String day, List<KEvent> all, Map<String, KCard> cards, {Set<String>? boards}) {
  final out = <KEvent>[];
  for (final e in all) {
    final c = cards[e.cardId];
    if (c == null || c.deletedAt != null || c.status != 'published') continue;
    if (boards != null && boards.isNotEmpty && !boards.contains(c.boardId)) continue;
    if (dayKey(DateTime.fromMillisecondsSinceEpoch(e.createdAt)) != day) continue;
    out.add(e);
  }
  out.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return ActivityDay(day, out);
}

/// The most recent day before [day] that had any activity (Fizzy jumps over
/// quiet days), or null.
String? previousActiveDay(String day, List<KEvent> all, Map<String, KCard> cards, {Set<String>? boards}) {
  String? best;
  for (final e in all) {
    final c = cards[e.cardId];
    if (c == null || c.deletedAt != null || c.status != 'published') continue;
    if (boards != null && boards.isNotEmpty && !boards.contains(c.boardId)) continue;
    final d = dayKey(DateTime.fromMillisecondsSinceEpoch(e.createdAt));
    if (d.compareTo(day) < 0 && (best == null || d.compareTo(best) > 0)) best = d;
  }
  return best;
}
