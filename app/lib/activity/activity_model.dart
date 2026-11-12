import 'dart:convert';

import '../data/database.dart';
import '../planner/days.dart';

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

/// One line of the Activity feed, in plain words, naming the card.
String activityLine(String action, Map<String, dynamic> p, {required String who, required String title, required int? me}) {
  String person(Object? id, Object? name) => (id as num?)?.toInt() == me && me != null ? 'you' : ((name as String?)?.isNotEmpty == true ? name! : 'someone');
  switch (action) {
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
      return p['day'] is String ? '$who set $title due ${dayLabel(p['day'] as String)}' : '$who set a due day on $title';
    case 'card_due_cleared':
      return '$who took the due day off $title';
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
  return activityLine(n.action, p, who: who, title: title, me: me);
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
