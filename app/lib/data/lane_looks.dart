import 'dart:convert';

import 'database.dart';
import 'lanes.dart';

/// The name and color of Later, To-do or Done on one Kolumn. Every Kolumn
/// can rename and recolor these three (his ruling, 2026-11-11: a Kolumn is
/// not always a to-do list); these are the usual ones.
class LaneLook {
  const LaneLook(this.name, this.color, {this.custom = false});
  final String name;

  /// An index into LaneColors.all.
  final int color;
  final bool custom;
}

const _usual = {'later': LaneLook('Later', 7), 'todo': LaneLook('To-do', 0), 'done': LaneLook('Done', 7)};

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
  return LaneLook(
    name is String && name.trim().isNotEmpty ? name.trim() : usual.name,
    color is num ? color.toInt().clamp(0, 7) : usual.color,
    custom: true,
  );
}

/// The usual name, for history lines and alerts made before a Kolumn had its own.
String usualLaneName(String kind) => (_usual[kind] ?? _usual['todo']!).name;
