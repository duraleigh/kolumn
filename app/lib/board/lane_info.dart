import 'package:flutter/material.dart';

import '../data/database.dart';
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
}

/// Lanes in Fizzy's left-to-right order: Later, To-do, the board's own
/// columns, then Done.
List<LaneInfo> buildLanes(BuildContext context, List<KColumn> columns, List<KCard> cards) {
  final b = Theme.of(context).brightness;
  final primary = Theme.of(context).colorScheme.primary;
  final live = columns.map((c) => c.id).toSet();
  final byLane = <Lane, List<KCard>>{};
  for (final c in cards) {
    byLane.putIfAbsent(Lane.of(c, live), () => []).add(c);
  }
  List<KCard> of(Lane l) => sortForLane(l, byLane[l] ?? const []);
  final todoColor = b == Brightness.dark ? const Color(0xFFA78BFA) : primary;
  return [
    LaneInfo(lane: const Lane.later(), name: 'Later', color: LaneColors.quiet.of(b), cards: of(const Lane.later())),
    LaneInfo(lane: const Lane.todo(), name: 'To-do', color: todoColor, cards: of(const Lane.todo())),
    for (final col in columns)
      LaneInfo(lane: Lane.column(col.id), name: col.name, color: LaneColors.at(col.color).of(b), cards: of(Lane.column(col.id)), column: col),
    LaneInfo(lane: const Lane.done(), name: 'Done', color: LaneColors.quiet.of(b), cards: of(const Lane.done())),
  ];
}

String laneName(List<LaneInfo> lanes, Lane lane) => lanes.firstWhere((l) => l.lane == lane, orElse: () => lanes[1]).name;
