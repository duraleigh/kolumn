import 'dart:convert';

import 'days.dart';

enum RepeatUnit { day, week, month, year }

/// How a to-do repeats, as Tweek's repeat wheel sets it: every N days, weeks,
/// months or years; on chosen weekdays; monthly on the same date or the same
/// weekday ("the second Wednesday"); optionally until a day.
class RepeatRule {
  const RepeatRule({this.every = 1, this.unit = RepeatUnit.day, this.weekdays = const [], this.monthlyByWeekday = false, this.until});

  final int every;
  final RepeatUnit unit;

  /// Monday = 1 … Sunday = 7. Empty means "the start day's weekday".
  final List<int> weekdays;
  final bool monthlyByWeekday;
  final String? until;

  RepeatRule copyWith({int? every, RepeatUnit? unit, List<int>? weekdays, bool? monthlyByWeekday, String? until, bool clearUntil = false}) => RepeatRule(
    every: every ?? this.every,
    unit: unit ?? this.unit,
    weekdays: weekdays ?? this.weekdays,
    monthlyByWeekday: monthlyByWeekday ?? this.monthlyByWeekday,
    until: clearUntil ? null : (until ?? this.until),
  );

  Map<String, Object?> toJson() => {
    'every': every,
    'unit': unit.name,
    if (unit == RepeatUnit.week && weekdays.isNotEmpty) 'weekdays': weekdays,
    if (unit == RepeatUnit.month) 'monthly': monthlyByWeekday ? 'weekday' : 'date',
    'until': ?until,
  };

  static RepeatRule? fromJson(Object? raw) {
    Object? j = raw;
    if (j is String) {
      try {
        j = jsonDecode(j);
      } catch (_) {
        return null;
      }
    }
    if (j is! Map) return null;
    final m = j;
    final unit = RepeatUnit.values.where((u) => u.name == m['unit']).firstOrNull;
    if (unit == null) return null;
    return RepeatRule(
      every: ((m['every'] as num?)?.toInt() ?? 1).clamp(1, 99),
      unit: unit,
      weekdays: ((m['weekdays'] as List?) ?? const []).map((e) => (e as num).toInt()).where((d) => d >= 1 && d <= 7).toList()..sort(),
      monthlyByWeekday: m['monthly'] == 'weekday',
      until: m['until'] as String?,
    );
  }

  String encode() => jsonEncode(toJson());

  /// Does a to-do that starts on [start] come up on [day]?
  bool occursOn(String start, String day) {
    if (day.compareTo(start) < 0) return false;
    if (until != null && day.compareTo(until!) > 0) return false;
    final s = parseDay(start), d = parseDay(day);
    switch (unit) {
      case RepeatUnit.day:
        return daysBetween(start, day) % every == 0;
      case RepeatUnit.week:
        final days = weekdays.isEmpty ? [s.weekday] : weekdays;
        if (!days.contains(d.weekday)) return false;
        final weeks = daysBetween(mondayOf(start), mondayOf(day)) ~/ 7;
        return weeks % every == 0;
      case RepeatUnit.month:
        final months = (d.year - s.year) * 12 + d.month - s.month;
        if (months % every != 0) return false;
        if (!monthlyByWeekday) {
          // The 31st comes up on the last day of shorter months.
          return d.day == (s.day > daysInMonth(d.year, d.month) ? daysInMonth(d.year, d.month) : s.day);
        }
        if (d.weekday != s.weekday) return false;
        final nth = (s.day - 1) ~/ 7 + 1;
        if (nth >= 5) return d.day + 7 > daysInMonth(d.year, d.month); // "the last Friday"
        return (d.day - 1) ~/ 7 + 1 == nth;
      case RepeatUnit.year:
        if ((d.year - s.year) % every != 0 || d.month != s.month) return false;
        return d.day == (s.day > daysInMonth(d.year, d.month) ? daysInMonth(d.year, d.month) : s.day);
    }
  }

  /// The days it comes up from [from] to [to], both included.
  List<String> daysBetweenIncl(String start, String from, String to) {
    final out = <String>[];
    var d = from.compareTo(start) < 0 ? start : from;
    var guard = 0;
    while (d.compareTo(to) <= 0 && guard++ < 4000) {
      if (occursOn(start, d)) out.add(d);
      d = addDays(d, 1);
    }
    return out;
  }

  /// Plain words: "Every day", "Every 2 weeks on Mon, Wed", "Every month on
  /// the second Wednesday", "Every year on 11 Nov", plus "until …".
  String describe(String start) {
    final s = parseDay(start);
    String unitWord(String one) => every == 1 ? one : '$every ${one}s';
    String text;
    switch (unit) {
      case RepeatUnit.day:
        text = every == 1 ? 'Every day' : 'Every $every days';
      case RepeatUnit.week:
        final days = (weekdays.isEmpty ? [s.weekday] : weekdays).map((d) => weekdayShort[d - 1]).join(', ');
        text = 'Every ${unitWord('week')} on $days';
      case RepeatUnit.month:
        if (monthlyByWeekday) {
          final nth = (s.day - 1) ~/ 7 + 1;
          const names = ['first', 'second', 'third', 'fourth', 'last'];
          text = 'Every ${unitWord('month')} on the ${names[(nth - 1).clamp(0, 4)]} ${weekdayLong[s.weekday - 1]}';
        } else {
          text = 'Every ${unitWord('month')} on the ${ordinal(s.day)}';
        }
      case RepeatUnit.year:
        text = 'Every ${unitWord('year')} on ${s.day} ${monthShort[s.month - 1]}';
    }
    return until == null ? text : '$text, until ${dayLabel(until!)}';
  }
}
