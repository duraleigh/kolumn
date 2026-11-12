import 'package:flutter/material.dart';

import '../data/database.dart';
import '../data/lane_looks.dart';
import '../data/lanes.dart';
import '../theme/tokens.dart';

/// Everything the board needs to draw one lane: its place, name, color and
/// its cards in display order.
class LaneInfo {
  const LaneInfo({required this.lane, required this.name, required this.color, required this.cards, this.column, this.isHome = false});

  final Lane lane;
  final String name;
  final Color color;
  final List<KCard> cards;
  final KColumn? column;

  /// Where new cards land (To-do, unless this Kolumn deleted it).
  final bool isHome;

  bool get isCustom => lane.kind == LaneKind.column;

  LaneInfo withHome() => LaneInfo(lane: lane, name: name, color: color, cards: cards, column: column, isHome: true);
}

/// A Kolumn's kolumns, left to right: by default Fizzy's order (Later, To-do,
/// its own, Done), but Later, To-do and Done can be renamed, recolored, moved
/// and deleted like any other.
List<LaneInfo> buildLanes(BuildContext context, List<KColumn> columns, List<KCard> cards, {KBoard? board}) {
  final b = Theme.of(context).brightness;
  final primary = Theme.of(context).colorScheme.primary;
  final live = columns.where((c) => c.deletedAt == null).map((c) => c.id).toSet();
  final home = homeLane(board, columns);
  final shown = laneOrder(board, columns).map((e) => e.$1).toSet();
  final byLane = <Lane, List<KCard>>{};
  for (final c in cards) {
    if (c.status == 'draft') continue; // Drafts live in their own list, not on the board.
    var lane = Lane.of(c, live);
    if (!shown.contains(lane)) {
      // A deleted Done keeps its finished cards out of sight; anything else
      // (waiting for the hub to move it) shows where open cards go.
      if (lane.kind == LaneKind.done || home == null) continue;
      lane = home;
    }
    byLane.putIfAbsent(lane, () => []).add(c);
  }
  List<KCard> of(Lane l) => sortForLane(l, byLane[l] ?? const []);
  final byId = {for (final c in columns) c.id: c};
  final out = <LaneInfo>[];
  for (final (lane, _) in laneOrder(board, columns)) {
    if (lane.kind == LaneKind.column) {
      final col = byId[lane.columnId]!;
      out.add(LaneInfo(lane: lane, name: col.name, color: LaneColors.at(col.color).of(b), cards: of(lane), column: col));
      continue;
    }
    final look = laneLook(board, kindKey(lane.kind));
    // The usual To-do color follows the theme's own accent exactly.
    final color = lane.kind == LaneKind.todo && look.color == 0 ? (b == Brightness.dark ? const Color(0xFFA78BFA) : primary) : LaneColors.at(look.color).of(b);
    out.add(LaneInfo(lane: lane, name: look.name, color: color, cards: of(lane), isHome: lane == home));
  }
  for (var i = 0; i < out.length; i++) {
    if (out[i].lane == home && !out[i].isHome) out[i] = out[i].withHome();
  }
  return out;
}

String laneName(List<LaneInfo> lanes, Lane lane) => lanes.firstWhere((l) => l.lane == lane, orElse: () => lanes.firstWhere((l) => l.isHome, orElse: () => lanes.first)).name;
