import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../card/card_screen.dart';
import '../data/database.dart';
import '../find/find_screen.dart';
import '../planner/days.dart';
import '../planner/planner_model.dart';
import '../state/providers.dart';
import '../theme/tokens.dart';
import '../ui/app_header.dart';
import '../ui/bits.dart';
import 'activity_model.dart';

/// Fizzy's home: what the team did, one day at a time, as Added, Updated
/// and Done. Works from what is on the phone, so it works offline too.
class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  String? _day;
  ActivityGroup _group = ActivityGroup.updated;
  bool _picked = false;
  Set<String> _boards = const {};

  @override
  Widget build(BuildContext context) {
    final today = ref.watch(plannerTodayProvider);
    final day = _day ?? today;
    final events = ref.watch(allEventsProvider).value ?? const <KEvent>[];
    final cards = {for (final c in ref.watch(allCardsProvider).value ?? const <KCard>[]) c.id: c};
    final boards = ref.watch(boardsProvider).value ?? const <KBoard>[];
    final names = ref.watch(peopleNamesProvider);
    final me = ref.watch(meIdProvider).value;
    final a = activityOn(day, events, cards, boards: _boards);
    // Open on the busiest group the first time, as Fizzy's columns all show at once.
    if (!_picked && a.events.isNotEmpty) {
      _group = ActivityGroup.values.reduce((x, y) => a.of(y).length > a.of(x).length ? y : x);
    }
    final shown = a.of(_group);
    final earlier = previousActiveDay(day, events, cards, boards: _boards);
    final c = context.colors;
    final p = context.palette;
    final t = Theme.of(context).textTheme;

    String dayTitle(String d) {
      final n = daysBetween(d, today);
      if (n == 0) return 'Today';
      if (n == 1) return 'Yesterday';
      if (n < 7) return weekdayLong[parseDay(d).weekday - 1];
      return dayLabel(d, today: today);
    }

    final boardLabel = _boards.isEmpty
        ? 'All Kolumns'
        : (_boards.length == 1 ? (boards.where((b) => b.id == _boards.first).firstOrNull?.name ?? '1 Kolumn') : '${_boards.length} Kolumns');

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppHeader(
              title: 'Activity',
              actions: [
                IconButton(
                  tooltip: 'Find cards',
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const FindScreen())),
                  icon: const Icon(Icons.search_rounded),
                ),
              ],
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref.read(syncServiceProvider).syncNow(),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ActionChip(
                        avatar: const Icon(Icons.view_kanban_outlined, size: 18),
                        label: Text(boardLabel),
                        onPressed: () async {
                          final picked = await _pickBoards(context, boards, _boards);
                          if (picked != null) setState(() => _boards = picked);
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _RoundButton(
                          icon: Icons.chevron_left_rounded,
                          label: 'Earlier day',
                          onTap: earlier == null
                              ? null
                              : () => setState(() {
                                  _day = earlier;
                                  _picked = false;
                                }),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(dayTitle(day), style: t.titleMedium!.copyWith(fontWeight: FontWeight.w600)),
                              Text(dayLabel(day, today: today), style: t.bodySmall),
                            ],
                          ),
                        ),
                        _RoundButton(
                          icon: Icons.chevron_right_rounded,
                          label: 'Later day',
                          onTap: day.compareTo(today) >= 0
                              ? null
                              : () => setState(() {
                                  _day = addDays(day, 1);
                                  _picked = false;
                                }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: p.lane, borderRadius: BorderRadius.circular(18)),
                      child: Row(
                        children: [
                          for (final g in ActivityGroup.values)
                            Expanded(
                              child: _GroupTab(
                                name: const {ActivityGroup.added: 'Added', ActivityGroup.updated: 'Updated', ActivityGroup.done: 'Done'}[g]!,
                                count: a.of(g).length,
                                on: g == _group,
                                onTap: () => setState(() {
                                  _group = g;
                                  _picked = true;
                                }),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (shown.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: Text(
                          a.events.isEmpty ? 'Nothing happened on this day.' : 'Nothing in this group on this day.',
                          textAlign: TextAlign.center,
                          style: t.bodyMedium!.copyWith(color: c.onSurfaceVariant),
                        ),
                      ),
                    for (final e in shown)
                      _EventCard(
                        event: e,
                        card: cards[e.cardId]!,
                        who: e.userId == me ? 'You' : (names[e.userId] ?? 'Someone'),
                        name: names[e.userId] ?? '?',
                        me: me,
                        boardName: boards.length > 1 ? boards.where((b) => b.id == cards[e.cardId]!.boardId).firstOrNull?.name : null,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<Set<String>?> _pickBoards(BuildContext context, List<KBoard> boards, Set<String> current) {
  var picked = {...current};
  return showModalBottomSheet<Set<String>>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => StatefulBuilder(
      builder: (context, set) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text('Show activity from', style: Theme.of(context).textTheme.titleLarge),
            ),
            CheckboxListTile(title: const Text('All Kolumns'), value: picked.isEmpty, onChanged: (_) => set(() => picked = {})),
            for (final b in boards)
              CheckboxListTile(
                title: Text(b.name),
                value: picked.contains(b.id),
                onChanged: (on) => set(() => on == true ? picked.add(b.id) : picked.remove(b.id)),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(onPressed: () => Navigator.pop(context, picked), child: const Text('Show')),
            ),
          ],
        ),
      ),
    ),
  );
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: label,
    child: Material(
      color: context.palette.lane,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: onTap == null ? context.colors.onSurfaceVariant.withValues(alpha: 0.35) : context.colors.onSurface),
        ),
      ),
    ),
  );
}

class _GroupTab extends StatelessWidget {
  const _GroupTab({required this.name, required this.count, required this.on, required this.onTap});
  final String name;
  final int count;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      selected: on,
      button: true,
      child: Material(
        color: on ? context.palette.card : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        elevation: on ? 1 : 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: SizedBox(
            height: 42,
            child: Center(
              child: Text.rich(
                TextSpan(
                  text: name,
                  children: [
                    TextSpan(
                      text: '  $count',
                      style: TextStyle(color: c.onSurfaceVariant, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                style: TextStyle(fontSize: 14, fontWeight: on ? FontWeight.w700 : FontWeight.w500, color: on ? c.onSurface : c.onSurfaceVariant),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event, required this.card, required this.who, required this.name, required this.me, this.boardName});
  final KEvent event;
  final KCard card;
  final String who;
  final String name;
  final int? me;
  final String? boardName;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    Map<String, dynamic> parts;
    try {
      parts = (jsonDecode(event.particulars) as Map).cast<String, dynamic>();
    } catch (_) {
      parts = const {};
    }
    final text = activityLine(event.action, parts, who: who, title: card.title, me: me);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: p.card,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => showCardSheet(context, card.id),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), boxShadow: p.cardShadow),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                event.userId == 0
                    ? CircleAvatar(radius: 16, backgroundColor: p.chip, child: Icon(Icons.hourglass_bottom_rounded, size: 16, color: context.colors.onSurfaceVariant))
                    : PersonAvatar(id: event.userId, name: name, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(text, style: const TextStyle(fontSize: 14, height: 1.4)),
                      const SizedBox(height: 3),
                      Text(
                        [clockTime(event.createdAt), ?boardName].join(' · '),
                        style: TextStyle(fontSize: 12, color: context.colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
