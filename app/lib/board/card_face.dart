import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../data/due.dart';
import '../data/lane_looks.dart';
import '../data/tidy.dart';
import '../planner/planner_model.dart';
import '../state/providers.dart';
import '../theme/tokens.dart';
import '../ui/bits.dart';
import '../ui/item_sheet.dart';

/// How a card looks on the board, in the drag ghost, and in lists: its cover
/// picture, title, Priority, its due date, the people on it, and small counts.
/// Due today: the title in amber (yellow on dark); late: the card turns red
/// with white words and a bold "LATE:" in front, as in the Planner (his rule,
/// 2026-11-13). No tags (his ruling, 2026-11-13).
class CardFace extends ConsumerWidget {
  const CardFace({super.key, required this.card, this.lifted = false, this.onTap});

  final KCard card;
  final bool lifted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final c = context.colors;
    final t = Theme.of(context).textTheme;
    final x = ref.watch(cardExtrasProvider)[card.id];
    final priority = card.priorityAt != null;
    final done = card.closedAt != null;
    final shadows = lifted ? p.liftShadow : p.cardShadow;
    final today = ref.watch(plannerTodayProvider);
    final state = dueState(dueAt: card.dueAt, hasTime: card.dueHasTime, doneAt: card.closedAt, now: ref.watch(plannerNowProvider)());
    final late = state == DueState.late;
    final dueToday = state == DueState.dueToday;
    KBoard? board;
    for (final b in ref.watch(boardsProvider).value ?? const <KBoard>[]) {
      if (b.id == card.boardId) board = b;
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    final tidyLeft = tidyWarning(card, board, now) ? tidyDaysLeft(card, board, now) : null;
    final meta = <Widget>[
      if (priority) _Pill(text: 'Priority', bg: c.primaryContainer, fg: c.onPrimaryContainer),
      if (card.dueAt != null)
        _Count(
          icon: late ? Icons.error_outline_rounded : Icons.event_outlined,
          text: dueText(card.dueAt!, hasTime: card.dueHasTime, context: context, today: today),
          bg: late ? p.lateRowText.withValues(alpha: 0.18) : null,
          fg: late ? p.lateRowText : (dueToday ? p.dueToday : null),
        ),
      if (ref.watch(reminderMapProvider).containsKey(card.id)) const _Count(icon: Icons.notifications_none_rounded, text: ''),
      if (tidyLeft != null) _Count(icon: Icons.hourglass_bottom_rounded, text: tidyLeft <= 1 ? 'To ${laneLook(board, 'later').name} soon' : 'To ${laneLook(board, 'later').name} in ${tidyLeft}d'),
      if (x != null && x.steps > 0) _Count(icon: Icons.check_box_outlined, text: '${x.stepsDone}/${x.steps}'),
      if (x != null && x.comments > 0) _Count(icon: Icons.chat_bubble_outline_rounded, text: '${x.comments}'),
      if (x != null && x.files > 0) _Count(icon: Icons.attach_file_rounded, text: '${x.files}'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: late ? p.lateRow : p.card,
        borderRadius: BorderRadius.circular(KShapes.card),
        boxShadow: shadows,
        border: priority || lifted ? Border.all(color: c.primary, width: 2) : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (card.coverId != null) SizedBox(height: 110, child: HubPicture(fileId: card.coverId!)),
              Padding(
                padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (card.pinnedAt != null) ...[
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Semantics(label: 'Pinned to the top', child: Icon(Icons.push_pin_rounded, size: 16, color: late ? p.lateRowText : p.accentText)),
                          ),
                          const SizedBox(width: 5),
                        ],
                        if (priority) ...[
                          Padding(
                            padding: const EdgeInsets.only(top: 1),
                            child: Icon(Icons.star_rounded, size: 18, color: late ? p.lateRowText : p.accentText),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                if (state.showsLate) TextSpan(text: 'LATE: ', style: TextStyle(fontWeight: late ? FontWeight.w800 : null)),
                                TextSpan(text: card.title),
                              ],
                            ),
                            style: t.bodyLarge!.copyWith(
                              fontSize: 15,
                              height: 1.35,
                              fontWeight: late || dueToday ? FontWeight.w600 : null,
                              decoration: done ? TextDecoration.lineThrough : null,
                              color: late ? p.lateRowText : (done ? c.onSurfaceVariant : (dueToday ? p.dueToday : c.onSurface)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // No card number here (his ask, 2026-11-12); it shows at the top of the open card.
                    if (meta.isNotEmpty || (x != null && x.assignees.isNotEmpty)) ...[
                      const SizedBox(height: 9),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(child: Wrap(spacing: 5, runSpacing: 5, children: meta)),
                          if (x != null && x.assignees.isNotEmpty) ...[const SizedBox(width: 6), AvatarStack(ids: x.assignees)],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.bg, required this.fg});
  final String text;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
    child: Text(
      text,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
    ),
  );
}

class _Count extends StatelessWidget {
  const _Count({required this.icon, required this.text, this.bg, this.fg});
  final IconData icon;
  final String text;
  final Color? bg;
  final Color? fg;

  @override
  Widget build(BuildContext context) {
    final color = fg ?? context.colors.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: bg ?? context.palette.chip, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          if (text.isNotEmpty) ...[
            const SizedBox(width: 3),
            Text(
              text,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ],
      ),
    );
  }
}
