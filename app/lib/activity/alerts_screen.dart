import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../card/card_screen.dart';
import '../data/database.dart';
import '../planner/days.dart';
import '../state/providers.dart';
import '../theme/tokens.dart';
import '../ui/app_header.dart';
import '../ui/bits.dart';
import 'activity_model.dart';

/// The bell: what concerns this person, newest first, one line per card.
/// Opening one marks it read.
class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(notificationsProvider).value ?? const <KNotification>[];
    final cards = {for (final c in ref.watch(allCardsProvider).value ?? const <KCard>[]) c.id: c};
    final alerts = all.where((n) => cards[n.cardId]?.deletedAt == null && cards.containsKey(n.cardId)).toList();
    final unread = alerts.where((n) => n.readAt == null).length;
    final names = ref.watch(peopleNamesProvider);
    final me = ref.watch(meIdProvider).value;
    final repo = ref.read(repositoryProvider);
    final c = context.colors;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppHeader(
              title: 'Alerts',
              actions: [
                IconButton(
                  tooltip: 'Which Kolumns tell me everything',
                  onPressed: () => showFollowSheet(context, ref),
                  icon: const Icon(Icons.notifications_active_outlined),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 8, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(unread == 0 ? 'All caught up' : '$unread new', style: t.bodyMedium!.copyWith(color: c.onSurfaceVariant)),
                  ),
                  if (unread > 0) TextButton(onPressed: repo.readAllAlerts, child: const Text('Mark all read')),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref.read(syncServiceProvider).syncNow(),
                child: alerts.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(32, 40, 32, 0),
                            child: Text(
                              'Nothing yet. You\'ll be told here when someone assigns you a card, mentions you, comments on a card you follow, or changes a Kolumn you follow.',
                              textAlign: TextAlign.center,
                              style: t.bodyMedium!.copyWith(color: c.onSurfaceVariant),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
                        itemCount: alerts.length,
                        itemBuilder: (context, i) {
                          final n = alerts[i];
                          final card = cards[n.cardId]!;
                          return _AlertRow(
                            text: alertLine(n, who: n.creatorId == me ? 'You' : (names[n.creatorId] ?? 'Someone'), title: card.title, me: me),
                            when: _when(n.updatedAt),
                            more: n.unreadCount > 1 ? '${n.unreadCount} updates' : null,
                            avatarId: n.creatorId,
                            avatarName: names[n.creatorId] ?? '?',
                            unread: n.readAt == null,
                            onTap: () {
                              if (n.readAt == null) repo.setAlertRead(n.cardId, true);
                              Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => CardScreen(cardId: card.id, boardId: card.boardId)));
                            },
                            onLongPress: () => repo.setAlertRead(n.cardId, n.readAt == null),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _when(int ms) {
  final d = DateTime.fromMillisecondsSinceEpoch(ms);
  final today = todayKey();
  final day = dayKey(d);
  if (day == today) return 'Today ${clockTime(ms)}';
  if (daysBetween(day, today) == 1) return 'Yesterday ${clockTime(ms)}';
  return dayLabel(day, today: today);
}

class _AlertRow extends StatelessWidget {
  const _AlertRow({
    required this.text,
    required this.when,
    required this.more,
    required this.avatarId,
    required this.avatarName,
    required this.unread,
    required this.onTap,
    required this.onLongPress,
  });
  final String text;
  final String when;
  final String? more;
  final int avatarId;
  final String avatarName;
  final bool unread;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Semantics(
        label: unread ? 'New' : null,
        child: Material(
          color: unread ? p.card : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          elevation: unread ? 1 : 0,
          shadowColor: c.primary.withValues(alpha: 0.2),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            onLongPress: onLongPress,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PersonAvatar(id: avatarId, name: avatarName, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(text, style: TextStyle(fontSize: 14, height: 1.4, fontWeight: unread ? FontWeight.w600 : FontWeight.w400)),
                        const SizedBox(height: 3),
                        Text([when, ?more].join(' · '), style: TextStyle(fontSize: 12, color: c.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  if (unread)
                    Padding(
                      padding: const EdgeInsets.only(left: 8, top: 6),
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(color: c.primary, shape: BoxShape.circle),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Which Kolumns tell this person about everything (Fizzy's "watching").
/// A card you are assigned, mentioned on or follow still alerts you either way.
Future<void> showFollowSheet(BuildContext context, WidgetRef ref) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (context) => Consumer(
    builder: (context, ref, _) {
      final boards = ref.watch(boardsProvider).value ?? const <KBoard>[];
      final follows = ref.watch(followsProvider);
      final repo = ref.read(repositoryProvider);
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                child: Text('Tell me about everything on…', style: Theme.of(context).textTheme.titleLarge),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  'You always hear about cards you\'re assigned to, mentioned on, or follow.',
                  style: TextStyle(color: context.colors.onSurfaceVariant),
                ),
              ),
              for (final b in boards)
                SwitchListTile(title: Text(b.name), value: follows[b.id] ?? false, onChanged: (on) => repo.setBoardFollow(b.id, on)),
            ],
          ),
        ),
      );
    },
  ),
);
