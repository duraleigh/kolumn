import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../activity/activity_model.dart';
import '../data/database.dart';
import '../data/repository.dart';
import '../planner/days.dart';
import '../planner/repeat.dart';

/// One reminder to show: when, and what it says.
class DueReminder {
  const DueReminder(this.key, this.at, this.title, this.body);
  final String key;
  final DateTime at;
  final String title;
  final String body;

  int get notificationId => key.hashCode & 0x7fffffff;
}

/// Works out which reminders this phone should show, from this person's own
/// reminders: a card's (unless it is finished), a to-do's (unless it is
/// ticked), and for a repeating to-do the same time on each of its coming
/// days (up to [perRepeat] of them).
List<DueReminder> upcomingReminders({
  required List<KReminder> reminders,
  required Map<String, KTodo> todos,
  required Map<String, KCard> cards,
  required Map<String, Map<String, String>> marks,
  required DateTime now,
  int perRepeat = 14,
  int max = 60,
}) {
  final out = <DueReminder>[];
  for (final r in reminders) {
    final at = r.at;
    if (at == null) continue;
    final when = DateTime.fromMillisecondsSinceEpoch(at);
    if (r.kind == 'card') {
      final c = cards[r.itemId];
      if (c == null || c.deletedAt != null || c.closedAt != null || !when.isAfter(now)) continue;
      out.add(DueReminder('card:${c.id}', when, c.title, c.dueAt == null ? 'Card #${c.number}' : 'Due ${friendlyDay(dueDayOf(c.dueAt!), today: dayKey(now))}'));
      continue;
    }
    final t = todos[r.itemId];
    if (t == null || t.deletedAt != null) continue;
    final rule = RepeatRule.fromJson(t.repeat);
    if (rule == null || t.day == null) {
      if (t.doneAt != null || !when.isAfter(now)) continue;
      out.add(DueReminder('todo:${t.id}', when, t.title, 'Reminder'));
      continue;
    }
    // A repeating to-do: the same time of day, on each day it comes up from the reminder's day on.
    final from = [dayKey(now), dayKey(when), t.day!].reduce((a, b) => a.compareTo(b) > 0 ? a : b);
    var n = 0;
    for (final d in rule.daysBetweenIncl(t.day!, from, addDays(from, 400))) {
      final mark = marks[t.id]?[d];
      if (mark != null) continue; // ticked or deleted that day
      final p = parseDay(d);
      final at2 = DateTime(p.year, p.month, p.day, when.hour, when.minute);
      if (!at2.isAfter(now)) continue;
      out.add(DueReminder('todo:${t.id}@$d', at2, t.title, rule.describe(t.day!)));
      if (++n >= perRepeat) break;
    }
  }
  out.sort((a, b) => a.at.compareTo(b.at));
  return out.take(max).toList();
}

/// Puts this person's reminders on the phone as notifications that appear at
/// the chosen time, even with Kolumn closed. Re-done whenever reminders,
/// to-dos or cards change.
class ReminderService {
  ReminderService(this.repo);
  final KolumnRepository repo;

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;
  bool _asked = false;
  Timer? _debounce;
  final _subs = <StreamSubscription<Object?>>[];
  List<KReminder> _reminders = const [];
  List<KTodo> _todos = const [];
  List<KCard> _cards = const [];
  List<KTodoMark> _marks = const [];
  String _lastPlan = '';

  static const _alertsChannel = AndroidNotificationDetails(
    'kolumn_alerts',
    'Alerts',
    channelDescription: 'When someone assigns you, mentions you, or changes something you follow',
    importance: Importance.high,
    priority: Priority.high,
    icon: 'ic_stat_kolumn',
  );

  static const _channel = AndroidNotificationDetails(
    'kolumn_reminders',
    'Reminders',
    channelDescription: 'The reminders you set on to-dos and cards',
    importance: Importance.high,
    priority: Priority.high,
    icon: 'ic_stat_kolumn',
  );

  Future<void> _init() async {
    try {
      tzdata.initializeTimeZones();
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
      await _plugin.initialize(settings: const InitializationSettings(android: AndroidInitializationSettings('ic_stat_kolumn')));
      _ready = true;
    } catch (_) {
      _ready = false; // Not on a phone (tests), or the phone refused: Kolumn works without reminders.
    }
  }

  /// For the check every 15 minutes while Kolumn is closed: set the
  /// reminders and pop up new alerts once, then stop.
  Future<void> runOnce() async {
    await _init();
    if (!_ready) return;
    _reminders = await repo.watchReminders().first;
    _todos = await repo.watchAllTodos().first;
    _cards = await repo.watchAllCards().first;
    _marks = await repo.watchTodoMarks().first;
    await _reschedule();
    await _alerts(await repo.watchNotifications().first);
  }

  Future<void> start() async {
    await _init();
    if (!_ready) return;
    _subs
      ..add(repo.watchReminders().listen((v) => _changed(() => _reminders = v)))
      ..add(repo.watchAllTodos().listen((v) => _changed(() => _todos = v)))
      ..add(repo.watchAllCards().listen((v) => _changed(() => _cards = v)))
      ..add(repo.watchTodoMarks().listen((v) => _changed(() => _marks = v)))
      ..add(repo.watchNotifications().listen(_alerts));
  }

  /// New alerts that arrive while Kolumn is not on screen pop up on the
  /// phone. Each is shown once; the first fetch after signing in shows none.
  Future<void> _alerts(List<KNotification> list) async {
    if (!_ready) return;
    final unread = list.where((n) => n.readAt == null).toList();
    final newest = list.isEmpty ? 0 : list.map((n) => n.updatedAt).reduce((a, b) => a > b ? a : b);
    final raw = await repo.setting('alerts.shown');
    if (raw == null) {
      if (list.isNotEmpty) await repo.setSetting('alerts.shown', '$newest');
      return;
    }
    final shown = int.tryParse(raw) ?? 0;
    final fresh = unread.where((n) => n.updatedAt > shown).toList();
    if (newest > shown) await repo.setSetting('alerts.shown', '$newest');
    if (fresh.isEmpty || WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) return;
    final me = await repo.meId();
    final names = {for (final p in await repo.watchPeople().first) p.id: p.name};
    for (final n in fresh.take(5)) {
      final card = await repo.card(n.cardId);
      if (card == null) continue;
      try {
        await _plugin.show(
          id: 'alert:${n.cardId}'.hashCode & 0x7fffffff,
          title: card.title,
          body: alertLine(n, who: names[n.creatorId] ?? 'Someone', title: card.title, me: me),
          notificationDetails: const NotificationDetails(android: _alertsChannel),
        );
      } catch (_) {
        // A pop-up that cannot show is skipped; the alert is still in the app.
      }
    }
  }

  void _changed(void Function() set) {
    set();
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 1), _reschedule);
  }

  Future<void> _reschedule() async {
    if (!_ready) return;
    final marks = <String, Map<String, String>>{};
    for (final m in _marks) {
      marks.putIfAbsent(m.todoId, () => {})[m.day] = m.mark;
    }
    final plan = upcomingReminders(
      reminders: _reminders,
      todos: {for (final t in _todos) t.id: t},
      cards: {for (final c in _cards) c.id: c},
      marks: marks,
      now: DateTime.now(),
    );
    final sig = plan.map((r) => '${r.key}|${r.at.millisecondsSinceEpoch}|${r.title}').join(',');
    if (sig == _lastPlan) return;
    _lastPlan = sig;
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (plan.isNotEmpty && !_asked) {
      _asked = true;
      await android?.requestNotificationsPermission();
    }
    await _plugin.cancelAllPendingNotifications();
    for (final r in plan) {
      try {
        await _plugin.zonedSchedule(
          id: r.notificationId,
          scheduledDate: tz.TZDateTime.from(r.at, tz.local),
          notificationDetails: const NotificationDetails(android: _channel),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          title: r.title,
          body: r.body,
        );
      } catch (_) {
        // One that cannot be set (the phone said no to exact times) is skipped.
      }
    }
  }

  void dispose() {
    _debounce?.cancel();
    for (final s in _subs) {
      s.cancel();
    }
  }
}
