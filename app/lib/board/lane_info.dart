import 'package:flutter/material.dart';

import '../data/database.dart';
import '../data/lane_looks.dart';
import '../data/lanes.dart';
import '../theme/tokens.dart';

/// Everything the board needs to draw one lane: its place, name, color and
/// its cards in display order.
class LaneInfo {
  const LaneInfo({required this.lane, required this.name, required this.color, required this.cards, this.column});

  final Lane lane;
  final String name;
  final Color color;
  final List<KCard> cards;
  final KColumn? column;

  bool get isCustom => lane.kind == LaneKind.column;
  bool get isTodoLane => lane.kind == LaneKind.todo;
}

/// Lanes in Fizzy's left-to-right order: Later, To-do, the board's own
/// columns, then Done. Later, To-do and Done take this Kolumn's own names and
/// colors when it has chosen some.
List<LaneInfo> buildLanes(BuildContext context, List<KColumn> columns, List<KCard> cards, {KBoard? board}) {
  final b = Theme.of(context).brightness;
  final primary = Theme.of(context).colorScheme.primary;
  final live = columns.map((c) => c.id).toSet();
  final byLane = <Lane, List<KCard>>{};
  for (final c in cards) {
    if (c.status == 'draft') continue; // Drafts live in their own list, not on the board.
    byLane.putIfAbsent(Lane.of(c, live), () => []).add(c);
  }
  List<KCard> of(Lane l) => sortForLane(l, byLane[l] ?? const []);
  final later = laneLook(board, 'later'), todo = laneLook(board, 'todo'), done = laneLook(board, 'done');
  // The usual To-do color follows the theme's own accent exactly.
  final todoColor = !todo.custom || todo.color == 0 ? (b == Brightness.dark ? const Color(0xFFA78BFA) : primary) : LaneColors.at(todo.color).of(b);
  return [
    LaneInfo(lane: const Lane.later(), name: later.name, color: LaneColors.at(later.color).of(b), cards: of(const Lane.later())),
    LaneInfo(lane: const Lane.todo(), name: todo.name, color: todoColor, cards: of(const Lane.todo())),
    for (final col in columns)
      LaneInfo(lane: Lane.column(col.id), name: col.name, color: LaneColors.at(col.color).of(b), cards: of(Lane.column(col.id)), column: col),
    LaneInfo(lane: const Lane.done(), name: done.name, color: LaneColors.at(done.color).of(b), cards: of(const Lane.done())),
  ];
}

String laneName(List<LaneInfo> lanes, Lane lane) => lanes.firstWhere((l) => l.lane == lane, orElse: () => lanes[1]).name;
