import 'dart:convert';

import 'database.dart';
import 'lanes.dart';

/// The name and color of Later, To-do or Done on one Kolumn. Every Kolumn
/// can rename and recolor these three (his ruling, 2026-11-11: a Kolumn is
/// not always a to-do list); these are the usual ones.
class LaneLook {
  const LaneLook(this.name, this.color, {this.custom = false, this.pos = 0, this.hidden = false});
  final String name;

  /// An index into LaneColors.all.
  final int color;
  final bool custom;

  /// Where it sits among the Kolumn's kolumns (the same scale as theirs).
  final double pos;

  /// Deleted from this Kolumn (it can be brought back).
  final bool hidden;
}

const _usual = {'later': LaneLook('Later', 7, pos: -2), 'todo': LaneLook('To-do', 0, pos: -1), 'done': LaneLook('Done', 7, pos: 1000000)};

String kindKey(LaneKind k) => switch (k) {
  LaneKind.later => 'later',
  LaneKind.done => 'done',
  _ => 'todo',
};

/// This Kolumn's look for one of the three; the usual one when it has none.
LaneLook laneLook(KBoard? board, String kind) {
  final usual = _usual[kind] ?? _usual['todo']!;
  if (board == null) return usual;
  Map<String, dynamic>? all;
  try {
    all = (jsonDecode(board.lanes) as Map?)?.cast<String, dynamic>();
  } catch (_) {
    all = null;
  }
  final one = all?[kind];
  if (one is! Map) return usual;
  final name = one['name'];
  final color = one['color'];
  final pos = one['pos'];
  return LaneLook(
    name is String && name.trim().isNotEmpty ? name.trim() : usual.name,
    color is num ? color.toInt().clamp(0, 7) : usual.color,
    custom: name is String || color is num,
    pos: pos is num ? pos.toDouble() : usual.pos,
    hidden: one['hidden'] == true,
  );
}

Lane laneOfKind(String kind) => switch (kind) {
  'later' => const Lane.later(),
  'done' => const Lane.done(),
  _ => const Lane.todo(),
};

/// A Kolumn's kolumns, left to right, with where each sits: Later, To-do and
/// Done (unless deleted) among its own, by position. They move and delete
/// like any other (his ruling, 2026-11-11).
List<(Lane, double)> laneOrder(KBoard? board, List<KColumn> columns) {
  final out = <(Lane, double)>[
    for (final k in const ['later', 'todo', 'done'])
      if (!laneLook(board, k).hidden) (laneOfKind(k), laneLook(board, k).pos),
    for (final c in columns)
      if (c.deletedAt == null) (Lane.column(c.id), c.position),
  ];
  out.sort((a, b) => a.$2.compareTo(b.$2));
  return out;
}

/// Where open cards go when the kolumn they belong in is not there, and where
/// new cards land: To-do if the Kolumn shows it, else its left-most ordinary
/// kolumn, else Later. Null when there is nowhere (only Done is left). The
/// hub uses the same rule.
Lane? homeLane(KBoard? board, List<KColumn> columns, {Lane? exclude}) {
  final order = laneOrder(board, columns).map((e) => e.$1).where((l) => l != exclude).toList();
  if (order.contains(const Lane.todo())) return const Lane.todo();
  for (final laterOk in const [false, true]) {
    for (final l in order) {
      if (l.kind != LaneKind.done && (laterOk || l.kind != LaneKind.later)) return l;
    }
  }
  return null;
}

/// The usual name, for history lines and alerts made before a Kolumn had its own.
String usualLaneName(String kind) => (_usual[kind] ?? _usual['todo']!).name;
