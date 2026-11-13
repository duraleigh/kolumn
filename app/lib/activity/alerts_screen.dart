import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../card/card_screen.dart';
import '../planner/todo_sheet.dart';
import '../data/database.dart';
import '../planner/days.dart';
import '../state/providers.dart';
import '../theme/tokens.dart';
import '../ui/app_header.dart';
import '../ui/bits.dart';
import 'activity_model.dart';

/// The bell: what concerns this person, newest first, one line per card or
/// to-do, and (since 0.8) their reminders once they go off. Opening one marks
/// it read.
class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(notificationsProvider).value ?? const <KNotification>[];
    final cards = {for (final c in ref.watch(allCardsProvider).value ?? const <KCard>[]) c.id: c};
    final todos = {for (final t in ref.watch(allTodosProvider).value ?? const <KTodo>[]) t.id: t};
    String? titleOf(KNotification n) => n.kind == 'todo'
        ? (todos[n.cardId]?.deletedAt == null ? todos[n.cardId]?.title : null)
        : (cards[n.cardId]?.deletedAt == null ? cards[n.cardId]?.title : null);
    final reminders = ref.watch(passedRemindersProvider);
    // One list, newest first: alerts, and reminders that went off.
    final rows = <(int, Object)>[
      for (final n in all)
        if (titleOf(n) != null) (n.updatedAt, n),
      for (final r in reminders) (r.at, r),
    ]..sort((a, b) => b.$1.compareTo(a.$1));
    final unread = all.where((n) => n.readAt == null && titleOf(n) != null).length + reminders.where((r) => !r.read).length;
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
                  if (unread > 0)
                    TextButton(
                      onPressed: () async {
                        await repo.readAllAlerts();
                        await repo.readReminders([for (final r in reminders) if (!r.read) (r.itemId, r.at)]);
                      },
                      child: const Text('Mark all read'),
                    ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref.read(syncServiceProvider).syncNow(),
                child: rows.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(32, 40, 32, 0),
                            child: Text(
                              'Nothing yet. You\'ll be told here when someone assigns you a card or a to-do, mentions you, comments on a card you follow, changes a Kolumn you follow, or a to-do you follow is finished, changes its due date or goes late. Your reminders show here too.',
                              textAlign: TextAlign.center,
                              style: t.bodyMedium!.copyWith(color: c.onSurfaceVariant),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
                        itemCount: rows.length,
                        itemBuilder: (context, i) {
                          final row = rows[i].$2;
                          if (row is PassedReminder) {
                            return _AlertRow(
                              text: 'Reminder: ${row.title}',
                              when: _when(row.at),
                              more: row.todo ? 'Planner' : null,
                              icon: Icons.notifications_active_outlined,
                              unread: !row.read,
                              onTap: () {
                                if (!row.read) repo.setReminderRead(row.itemId, row.at, true);
                                row.todo ? showTodoSheet(context, ref, todoId: row.itemId) : showCardSheet(context, row.itemId);
                              },
                              onLongPress: () => repo.setReminderRead(row.itemId, row.at, !row.read),
                            );
                          }
                          final n = row as KNotification;
                          return _AlertRow(
                            text: alertLine(n, who: n.creatorId == 0 ? 'Kolumn' : (n.creatorId == me ? 'You' : (names[n.creatorId] ?? 'Someone')), title: titleOf(n)!, me: me),
                            when: _when(n.updatedAt),
                            more: [if (n.unreadCount > 1) '${n.unreadCount} updates', if (n.kind == 'todo') 'Planner'].join(' · ').ifEmptyNull,
                            avatarId: n.creatorId,
                            avatarName: names[n.creatorId] ?? '?',
                            icon: n.creatorId == 0 ? Icons.error_outline_rounded : null,
                            unread: n.readAt == null,
                            onTap: () {
                              if (n.readAt == null) repo.setAlertRead(n.cardId, true);
                              n.kind == 'todo' ? showTodoSheet(context, ref, todoId: n.cardId) : showCardSheet(context, n.cardId);
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

extension on String {
  String? get ifEmptyNull => isEmpty ? null : this;
}

class _AlertRow extends StatelessWidget {
  const _AlertRow({
    required this.text,
    required this.when,
    required this.more,
    this.avatarId = 0,
    this.avatarName = '',
    this.icon,
    required this.unread,
    required this.onTap,
    required this.onLongPress,
  });
  final String text;
  final String when;
  final String? more;
  final int avatarId;
  final String avatarName;

  /// Shown instead of a face: a reminder, or something Kolumn noticed itself.
  final IconData? icon;
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
                  icon != null
                      ? CircleAvatar(radius: 16, backgroundColor: p.chip, child: Icon(icon, size: 17, color: c.onSurface))
                      : PersonAvatar(id: avatarId, name: avatarName, size: 32),
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
