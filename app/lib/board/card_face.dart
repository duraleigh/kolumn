import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../data/lane_looks.dart';
import '../data/tidy.dart';
import '../planner/days.dart';
import '../planner/planner_model.dart';
import '../state/providers.dart';
import '../theme/tokens.dart';
import '../ui/bits.dart';

/// How a card looks on the board, in the drag ghost, and in lists: its cover
/// picture, title, Priority, tags, the people on it, and small counts.
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
    final dueDay = card.dueAt == null ? null : dueDayOf(card.dueAt!);
    final late = dueDay != null && !done && dueDay.compareTo(today) < 0;
    KBoard? board;
    for (final b in ref.watch(boardsProvider).value ?? const <KBoard>[]) {
      if (b.id == card.boardId) board = b;
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    final tidyLeft = tidyWarning(card, board, now) ? tidyDaysLeft(card, board, now) : null;
    final meta = <Widget>[
      if (priority) _Pill(text: 'Priority', bg: c.primaryContainer, fg: c.onPrimaryContainer),
      if (dueDay != null)
        _Count(
          icon: Icons.event_outlined,
          text: late ? 'Late · ${dayHeading(dueDay)}' : friendlyDay(dueDay, today: today),
          bg: late ? p.dangerBg : null,
          fg: late ? p.dangerText : null,
        ),
      if (ref.watch(reminderMapProvider).containsKey(card.id)) const _Count(icon: Icons.notifications_none_rounded, text: ''),
      if (tidyLeft != null) _Count(icon: Icons.hourglass_bottom_rounded, text: tidyLeft <= 1 ? 'To ${laneLook(board, 'later').name} soon' : 'To ${laneLook(board, 'later').name} in ${tidyLeft}d'),
      if (x != null && x.steps > 0) _Count(icon: Icons.check_box_outlined, text: '${x.stepsDone}/${x.steps}'),
      if (x != null && x.comments > 0) _Count(icon: Icons.chat_bubble_outline_rounded, text: '${x.comments}'),
      if (x != null && x.files > 0) _Count(icon: Icons.attach_file_rounded, text: '${x.files}'),
      for (final tag in (x?.tags ?? const <String>[]).take(3)) _Pill(text: tag, bg: p.chip, fg: c.onSurfaceVariant),
    ];
    return Container(
      decoration: BoxDecoration(
        color: p.card,
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
                        if (priority) ...[
                          Padding(
                            padding: const EdgeInsets.only(top: 1),
                            child: Icon(Icons.star_rounded, size: 18, color: p.accentText),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Expanded(
                          child: Text(
                            card.title,
                            style: t.bodyLarge!.copyWith(
                              fontSize: 15,
                              height: 1.35,
                              decoration: done ? TextDecoration.lineThrough : null,
                              color: done ? c.onSurfaceVariant : c.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 9),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(child: Wrap(spacing: 5, runSpacing: 5, children: meta)),
                        if (x != null && x.assignees.isNotEmpty) ...[const SizedBox(width: 6), AvatarStack(ids: x.assignees)],
                        const SizedBox(width: 6),
                        Text(card.synced ? '#${card.number}' : 'New', style: t.labelMedium),
                      ],
                    ),
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
