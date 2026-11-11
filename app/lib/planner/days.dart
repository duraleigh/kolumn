/// Calendar days as Kolumn's Planner stores them: "2026-11-11", the phone's
/// own local date. No times, no time zones.
library;

String dayKey(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Midnight local of a day key. Built from parts, so it never drifts a day.
DateTime parseDay(String key) {
  final p = key.split('-');
  return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
}

String todayKey([DateTime? now]) => dayKey(now ?? DateTime.now());

/// Day arithmetic by calendar date (never by 24-hour steps, which drift
/// across daylight-saving changes).
String addDays(String key, int n) {
  final d = parseDay(key);
  return dayKey(DateTime(d.year, d.month, d.day + n));
}

/// Whole calendar days from [a] to [b].
int daysBetween(String a, String b) {
  final x = parseDay(a), y = parseDay(b);
  return DateTime.utc(y.year, y.month, y.day).difference(DateTime.utc(x.year, x.month, x.day)).inDays;
}

/// Weeks start on Monday, as in Tweek.
String mondayOf(String key) => addDays(key, -(parseDay(key).weekday - 1));

int daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

const weekdayShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const weekdayLong = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
const monthShort = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const monthLong = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

/// "11 Nov", Tweek's day heading.
String dayHeading(String key) {
  final d = parseDay(key);
  return '${d.day} ${monthShort[d.month - 1]}';
}

/// "Wed, 11 Nov" (adds the year when it is not this year).
String dayLabel(String key, {String? today}) {
  final d = parseDay(key);
  final t = parseDay(today ?? todayKey());
  final base = '${weekdayShort[d.weekday - 1]}, ${d.day} ${monthShort[d.month - 1]}';
  return d.year == t.year ? base : '$base ${d.year}';
}

/// "Today", "Tomorrow", "Yesterday", or [dayLabel].
String friendlyDay(String key, {String? today}) {
  final t = today ?? todayKey();
  final n = daysBetween(t, key);
  if (n == 0) return 'Today';
  if (n == 1) return 'Tomorrow';
  if (n == -1) return 'Yesterday';
  return dayLabel(key, today: t);
}

/// A card's due moment (noon UTC of the day, as the hub keeps it) to its day.
String dueDayOf(int dueAtMs) {
  final u = DateTime.fromMillisecondsSinceEpoch(dueAtMs, isUtc: true);
  return dayKey(DateTime(u.year, u.month, u.day));
}

/// A day to the moment the hub keeps for it: noon UTC.
int dueMsOf(String key) {
  final d = parseDay(key);
  return DateTime.utc(d.year, d.month, d.day, 12).millisecondsSinceEpoch;
}

String ordinal(int n) {
  if (n % 100 >= 11 && n % 100 <= 13) return '${n}th';
  switch (n % 10) {
    case 1:
      return '${n}st';
    case 2:
      return '${n}nd';
    case 3:
      return '${n}rd';
    default:
      return '${n}th';
  }
}
