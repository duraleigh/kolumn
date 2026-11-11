import 'package:flutter/material.dart';

import '../data/database.dart';
import '../theme/tokens.dart';

/// How a card looks on the board, in the drag ghost, and in lists.
class CardFace extends StatelessWidget {
  const CardFace({super.key, required this.card, this.lifted = false, this.onTap});

  final KCard card;
  final bool lifted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final c = context.colors;
    final priority = card.priorityAt != null;
    final done = card.closedAt != null;
    final shadows = lifted ? p.liftShadow : p.cardShadow;
    return Container(
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(KShapes.card),
        boxShadow: shadows,
        border: priority ? Border.all(color: c.primary, width: 2) : (lifted ? Border.all(color: c.primary, width: 2) : null),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(KShapes.card),
          onTap: onTap,
          child: Padding(
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
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
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
                  children: [
                    if (priority) _Pill(text: 'Priority', bg: c.primaryContainer, fg: c.onPrimaryContainer),
                    const Spacer(),
                    Text(card.synced ? '#${card.number}' : 'New', style: Theme.of(context).textTheme.labelMedium),
                  ],
                ),
              ],
            ),
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
