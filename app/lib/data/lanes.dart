import 'database.dart';

/// Where a card sits on a board. Fizzy's places, with Kolumn's names:
/// To-do (Fizzy's "Maybe?"), Later ("Not Now"), Done, or one of the board's
/// own columns.
enum LaneKind { later, todo, column, done }

class Lane {
  const Lane._(this.kind, this.columnId);

  const Lane.todo() : this._(LaneKind.todo, null);
  const Lane.later() : this._(LaneKind.later, null);
  const Lane.done() : this._(LaneKind.done, null);
  const Lane.column(String id) : this._(LaneKind.column, id);

  final LaneKind kind;
  final String? columnId;

  /// A stable text key, used for remembering the open column.
  String get key => kind == LaneKind.column ? 'col:$columnId' : kind.name;

  static Lane fromKey(String key) {
    if (key.startsWith('col:')) return Lane.column(key.substring(4));
    switch (key) {
      case 'later':
        return const Lane.later();
      case 'done':
        return const Lane.done();
      default:
        return const Lane.todo();
    }
  }

  /// The lane a card is in. A card whose column was deleted counts as To-do,
  /// as in Fizzy, where deleting a column sends its cards back to triage.
  static Lane of(KCard c, Set<String> liveColumnIds) {
    if (c.closedAt != null) return const Lane.done();
    if (c.laterAt != null) return const Lane.later();
    final col = c.columnId;
    if (col != null && liveColumnIds.contains(col)) return Lane.column(col);
    return const Lane.todo();
  }

  @override
  bool operator ==(Object other) => other is Lane && other.kind == kind && other.columnId == columnId;

  @override
  int get hashCode => Object.hash(kind, columnId);

  @override
  String toString() => key;
}

/// Kolumn's card order inside a lane: Priority cards first, then the most
/// recently active. Later is newest-shelved first; Done is newest-finished
/// first.
///
/// Once someone drags cards into an order (his ask, 2026-11-12), that order
/// wins: cards with a place sit by it, and any card without one yet (just
/// arrived, or from an older app) sits above them in the automatic order.
List<KCard> sortForLane(Lane lane, Iterable<KCard> cards) {
  final all = cards.toList();
  final placed = all.where((c) => c.position != null).toList()..sort((a, b) => a.position!.compareTo(b.position!));
  final list = all.where((c) => c.position == null).toList();
  _autoSort(lane, list);
  return [...list, ...placed];
}

void _autoSort(Lane lane, List<KCard> list) {
  int byDesc(int? a, int? b) => (b ?? 0).compareTo(a ?? 0);
  switch (lane.kind) {
    case LaneKind.done:
      list.sort((a, b) => byDesc(a.closedAt, b.closedAt));
    case LaneKind.later:
      list.sort((a, b) => byDesc(a.laterAt, b.laterAt));
    case LaneKind.todo:
    case LaneKind.column:
      list.sort((a, b) {
        final pa = a.priorityAt != null ? 1 : 0;
        final pb = b.priorityAt != null ? 1 : 0;
        if (pa != pb) return pb - pa;
        final byActive = byDesc(a.lastActiveAt, b.lastActiveAt);
        return byActive != 0 ? byActive : a.id.compareTo(b.id);
      });
  }
}
