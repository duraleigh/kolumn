import 'database.dart';
import 'lane_looks.dart';

/// Kolumn's tidy-up (Fizzy's auto-postpone): a card nobody touches for its
/// Kolumn's tidy-up time moves to Later on its own. A card with a due day
/// never moves. The choices, in days; null means the usual 30.
const tidyChoices = [3, 7, 11, 30, 90, 365];
const tidyDefault = 30;

const _day = 86400000;

/// Whole days left before the tidy-up moves this card, or null when it never
/// will (a draft, finished, already in Later, or it has a due day).
int? tidyDaysLeft(KCard card, KBoard? board, int nowMs) {
  if (card.status != 'published' || card.closedAt != null || card.laterAt != null || card.dueAt != null || card.deletedAt != null) return null;
  if (laneLook(board, 'later').hidden) return null; // This Kolumn deleted Later: nothing moves on its own.
  final period = board?.tidyDays ?? tidyDefault;
  final left = (card.lastActiveAt + period * _day - nowMs) / _day;
  return left <= 0 ? 0 : left.ceil();
}

/// True near the end: the last quarter of the tidy-up time (at least a day).
bool tidyWarning(KCard card, KBoard? board, int nowMs) {
  final left = tidyDaysLeft(card, board, nowMs);
  if (left == null) return false;
  final period = board?.tidyDays ?? tidyDefault;
  return left <= (period / 4).ceil();
}

String tidyChoiceLabel(int? days) {
  final d = days ?? tidyDefault;
  if (d == 365) return 'A year';
  return '$d days';
}
