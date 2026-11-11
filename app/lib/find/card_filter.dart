import '../data/database.dart';
import '../data/tidy.dart';
import '../planner/days.dart';

/// Which cards to show, as Fizzy's filters do: words to look for, Kolumns,
/// where the card is (open, Later, Done, Priority, moving to Later soon),
/// who it is assigned to, who added it, tags, when it was added or finished,
/// and the order. Saved views keep one of these under a name.
class CardFilter {
  const CardFilter({
    this.terms = '',
    this.boards = const {},
    this.status = 'open',
    this.assignees = const {},
    this.creators = const {},
    this.tags = const {},
    this.added,
    this.done,
    this.sort = 'latest',
  });

  final String terms;
  final Set<String> boards;

  /// 'open', 'later', 'done', 'priority', 'soon' (moving to Later soon), 'all'.
  final String status;

  /// User ids as text, plus 'me' and 'none' (nobody assigned).
  final Set<String> assignees;
  final Set<int> creators;
  final Set<String> tags;

  /// A time window: 'today', 'yesterday', 'thisweek', 'lastweek',
  /// 'thismonth', 'lastmonth', 'thisyear'.
  final String? added;
  final String? done;

  /// 'latest' (most recent activity), 'newest', 'oldest'.
  final String sort;

  static const statuses = {'open': 'Open', 'priority': 'Priority', 'soon': 'To Later soon', 'later': 'Later', 'done': 'Done', 'all': 'Everything'};
  static const windows = {
    'today': 'Today',
    'yesterday': 'Yesterday',
    'thisweek': 'This week',
    'lastweek': 'Last week',
    'thismonth': 'This month',
    'lastmonth': 'Last month',
    'thisyear': 'This year',
  };
  static const sorts = {'latest': 'Latest activity', 'newest': 'Newest first', 'oldest': 'Oldest first'};

  bool get isPlain => boards.isEmpty && status == 'open' && assignees.isEmpty && creators.isEmpty && tags.isEmpty && added == null && done == null && sort == 'latest';

  CardFilter copyWith({
    String? terms,
    Set<String>? boards,
    String? status,
    Set<String>? assignees,
    Set<int>? creators,
    Set<String>? tags,
    String? added,
    bool clearAdded = false,
    String? done,
    bool clearDone = false,
    String? sort,
  }) => CardFilter(
    terms: terms ?? this.terms,
    boards: boards ?? this.boards,
    status: status ?? this.status,
    assignees: assignees ?? this.assignees,
    creators: creators ?? this.creators,
    tags: tags ?? this.tags,
    added: clearAdded ? null : (added ?? this.added),
    done: clearDone ? null : (done ?? this.done),
    sort: sort ?? this.sort,
  );

  Map<String, Object?> toJson() => {
    if (terms.trim().isNotEmpty) 'terms': terms.trim(),
    if (boards.isNotEmpty) 'boards': boards.toList()..sort(),
    'status': status,
    if (assignees.isNotEmpty) 'assignees': assignees.toList()..sort(),
    if (creators.isNotEmpty) 'creators': creators.toList()..sort(),
    if (tags.isNotEmpty) 'tags': tags.toList()..sort(),
    'added': ?added,
    'done': ?done,
    'sort': sort,
  };

  static CardFilter fromJson(Map<String, dynamic> j) => CardFilter(
    terms: j['terms'] as String? ?? '',
    boards: ((j['boards'] as List?) ?? const []).cast<String>().toSet(),
    status: statuses.containsKey(j['status']) ? j['status'] as String : 'open',
    assignees: ((j['assignees'] as List?) ?? const []).map((e) => '$e').toSet(),
    creators: ((j['creators'] as List?) ?? const []).map((e) => (e as num).toInt()).toSet(),
    tags: ((j['tags'] as List?) ?? const []).cast<String>().toSet(),
    added: windows.containsKey(j['added']) ? j['added'] as String : null,
    done: windows.containsKey(j['done']) ? j['done'] as String : null,
    sort: sorts.containsKey(j['sort']) ? j['sort'] as String : 'latest',
  );

  /// Start (inclusive) and end (exclusive) of a window, in the phone's local time.
  static (DateTime, DateTime)? window(String? key, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    switch (key) {
      case 'today':
        return (today, today.add(const Duration(days: 1)));
      case 'yesterday':
        return (DateTime(today.year, today.month, today.day - 1), today);
      case 'thisweek':
        final mon = parseDay(mondayOf(dayKey(today)));
        return (mon, DateTime(mon.year, mon.month, mon.day + 7));
      case 'lastweek':
        final mon = parseDay(mondayOf(dayKey(today)));
        return (DateTime(mon.year, mon.month, mon.day - 7), mon);
      case 'thismonth':
        return (DateTime(today.year, today.month, 1), DateTime(today.year, today.month + 1, 1));
      case 'lastmonth':
        return (DateTime(today.year, today.month - 1, 1), DateTime(today.year, today.month, 1));
      case 'thisyear':
        return (DateTime(today.year, 1, 1), DateTime(today.year + 1, 1, 1));
    }
    return null;
  }
}

/// What a card can be found by, besides its own fields.
class CardText {
  CardText({this.comments = const [], this.steps = const [], this.tags = const [], this.assignees = const []});
  final List<String> comments;
  final List<String> steps;
  final List<String> tags;
  final List<int> assignees;
}

/// A card that matched, and where the words were found.
class FoundCard {
  FoundCard(this.card, this.where, this.snippet);
  final KCard card;

  /// 'title', 'notes', 'comment', 'step', 'tag', 'number', or '' when there were no words.
  final String where;
  final String snippet;
}

/// Runs a filter over the cards on the phone. Drafts are only their maker's.
List<FoundCard> applyFilter(
  CardFilter f, {
  required List<KCard> cards,
  required Map<String, CardText> text,
  required Map<String, KBoard> boards,
  required int? me,
  required DateTime now,
}) {
  final nowMs = now.millisecondsSinceEpoch;
  final q = f.terms.trim().toLowerCase();
  final addedWin = CardFilter.window(f.added, now);
  final doneWin = CardFilter.window(f.done, now);
  bool inWin((DateTime, DateTime)? w, int? ms) =>
      w == null || (ms != null && !DateTime.fromMillisecondsSinceEpoch(ms).isBefore(w.$1) && DateTime.fromMillisecondsSinceEpoch(ms).isBefore(w.$2));
  final out = <FoundCard>[];
  for (final c in cards) {
    if (c.deletedAt != null || !boards.containsKey(c.boardId)) continue;
    // A draft is only its maker's; one not yet sent was made on this phone.
    if (c.status == 'draft' && c.creatorId != null && c.creatorId != me) continue;
    if (f.boards.isNotEmpty && !f.boards.contains(c.boardId)) continue;
    final open = c.closedAt == null && c.laterAt == null;
    switch (f.status) {
      case 'open':
        if (!open) continue;
      case 'later':
        if (c.laterAt == null || c.closedAt != null) continue;
      case 'done':
        if (c.closedAt == null) continue;
      case 'priority':
        if (c.priorityAt == null || c.closedAt != null) continue;
      case 'soon':
        if (!tidyWarning(c, boards[c.boardId], nowMs)) continue;
    }
    final t = text[c.id] ?? CardText();
    if (f.assignees.isNotEmpty) {
      final ok = f.assignees.any((a) {
        if (a == 'none') return t.assignees.isEmpty;
        if (a == 'me') return me != null && t.assignees.contains(me);
        return t.assignees.contains(int.tryParse(a));
      });
      if (!ok) continue;
    }
    if (f.creators.isNotEmpty && !f.creators.contains(c.creatorId)) continue;
    if (f.tags.isNotEmpty && !f.tags.any(t.tags.contains)) continue;
    if (!inWin(addedWin, c.createdAt)) continue;
    if (!inWin(doneWin, c.closedAt)) continue;

    var where = '';
    var snippet = '';
    if (q.isNotEmpty) {
      String? hit(String s) => s.toLowerCase().contains(q) ? s : null;
      final num = q.startsWith('#') ? q.substring(1) : q;
      if (hit(c.title) != null) {
        where = 'title';
      } else if (c.synced && '${c.number}' == num) {
        where = 'number';
      } else if (hit(c.description) != null) {
        where = 'notes';
        snippet = _around(c.description, q);
      } else if (t.comments.map(hit).nonNulls.firstOrNull case final s?) {
        where = 'comment';
        snippet = _around(s, q);
      } else if (t.steps.map(hit).nonNulls.firstOrNull case final s?) {
        where = 'step';
        snippet = s;
      } else if (t.tags.any((x) => x.contains(q.replaceFirst('#', '')))) {
        where = 'tag';
        snippet = '#${t.tags.firstWhere((x) => x.contains(q.replaceFirst('#', '')))}';
      } else {
        continue;
      }
    }
    out.add(FoundCard(c, where, snippet));
  }
  int rank(FoundCard x) => const {'title': 0, 'number': 0, 'tag': 1, 'notes': 2, 'step': 2, 'comment': 3, '': 0}[x.where] ?? 4;
  out.sort((a, b) {
    if (q.isNotEmpty && rank(a) != rank(b)) return rank(a).compareTo(rank(b));
    switch (f.sort) {
      case 'newest':
        return b.card.createdAt.compareTo(a.card.createdAt);
      case 'oldest':
        return a.card.createdAt.compareTo(b.card.createdAt);
      default:
        return b.card.lastActiveAt.compareTo(a.card.lastActiveAt);
    }
  });
  return out;
}

/// A short piece of [text] around the first [q], plain words only.
String _around(String text, String q) {
  final flat = text.replaceAllMapped(RegExp(r'@\[([^\]]{1,80})\]\(\d{1,10}\)'), (m) => '@${m[1]}').replaceAll(RegExp(r'\s+'), ' ');
  final i = flat.toLowerCase().indexOf(q);
  if (i < 0) return flat.length > 90 ? '${flat.substring(0, 90)}…' : flat;
  final start = (i - 30).clamp(0, flat.length);
  final end = (i + q.length + 50).clamp(0, flat.length);
  return '${start > 0 ? '…' : ''}${flat.substring(start, end)}${end < flat.length ? '…' : ''}';
}
