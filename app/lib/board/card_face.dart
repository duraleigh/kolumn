import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
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
    final meta = <Widget>[
      if (priority) _Pill(text: 'Priority', bg: c.primaryContainer, fg: c.onPrimaryContainer),
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
  const _Count({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: context.palette.chip, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: c.onSurfaceVariant),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
