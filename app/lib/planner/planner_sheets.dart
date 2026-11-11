import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../state/providers.dart';
import '../theme/tokens.dart';
import '../ui/bits.dart';
import '../ui/sheets.dart';
import 'planner_model.dart';

/// The list of planners: pick one, open its settings, or add one.
Future<void> showPlannersSheet(BuildContext context, WidgetRef ref) =>
    showModalBottomSheet<void>(context: context, isScrollControlled: true, showDragHandle: true, builder: (context) => const _PlannersSheet());

class _PlannersSheet extends ConsumerWidget {
  const _PlannersSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planners = ref.watch(plannersProvider).value ?? const <KPlanner>[];
    final current = ref.watch(currentPlannerIdProvider).value;
    final readOnly = ref.watch(readOnlyProvider).value ?? false;
    final repo = ref.read(repositoryProvider);
    final c = context.colors;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Planners', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Material(
              color: context.palette.chip,
              borderRadius: BorderRadius.circular(18),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (final p in planners)
                    _PlannerRow(
                      planner: p,
                      current: p.id == current,
                      onPick: () {
                        repo.setSetting('planner.current', p.id);
                        Navigator.pop(context);
                      },
                      onSettings: () {
                        final nav = Navigator.of(context)..pop();
                        showPlannerSettings(nav.context, ref, p.id);
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (!readOnly)
              FilledButton.icon(
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50), backgroundColor: c.onSurface, foregroundColor: c.surface),
                onPressed: () async {
                  final n = await askText(context, title: 'New planner', action: 'Create', hint: 'Planner name, like Family or Tour');
                  if (n == null || n.trim().isEmpty) return;
                  final id = await repo.createPlanner(n);
                  await repo.setSetting('planner.current', id);
                  if (context.mounted) Navigator.pop(context);
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add planner'),
              ),
            const SizedBox(height: 4),
            TextButton.icon(
              onPressed: () {
                final nav = Navigator.of(context)..pop();
                showSettingsSheet(nav.context, ref);
              },
              icon: const Icon(Icons.tune_rounded),
              label: const Text('App settings'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlannerRow extends ConsumerWidget {
  const _PlannerRow({required this.planner, required this.current, required this.onPick, required this.onSettings});
  final KPlanner planner;
  final bool current;
  final VoidCallback onPick;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = (ref.watch(plannerPeopleProvider(planner.id)).value ?? const []).length;
    return Row(
      children: [
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onPick,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(planner.name, style: const TextStyle(fontSize: 15))),
                  Text(n == 0 ? 'Just you' : '${n + 1} people', style: TextStyle(fontSize: 12, color: context.colors.onSurfaceVariant)),
                  if (current) ...[const SizedBox(width: 8), const Icon(Icons.check_rounded, size: 18)],
                ],
              ),
            ),
          ),
        ),
        IconButton(tooltip: 'Settings for ${planner.name}', onPressed: onSettings, icon: const Icon(Icons.settings_outlined, size: 20)),
      ],
    );
  }
}

/// One planner's settings: its name, who is in it, which Kolumns' dated cards
/// it shows, and Tweek's three switches.
Future<void> showPlannerSettings(BuildContext context, WidgetRef ref, String plannerId) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  useSafeArea: true,
  builder: (context) => _PlannerSettings(plannerId: plannerId),
);

class _PlannerSettings extends ConsumerWidget {
  const _PlannerSettings({required this.plannerId});
  final String plannerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    KPlanner? p;
    for (final x in ref.watch(plannersProvider).value ?? const <KPlanner>[]) {
      if (x.id == plannerId) p = x;
    }
    if (p == null) return const SizedBox(height: 120, child: Center(child: Text('This planner is gone.')));
    final planner = p;
    final repo = ref.read(repositoryProvider);
    final readOnly = ref.watch(readOnlyProvider).value ?? false;
    final people = ref.watch(plannerPeopleProvider(planner.id)).value ?? const <KPlannerPerson>[];
    final names = ref.watch(peopleNamesProvider);
    final team = ref.watch(peopleProvider).value ?? const <KPerson>[];
    final boards = ref.watch(boardsProvider).value ?? const <KBoard>[];
    final shown = ((jsonDecode(planner.boardIds) as List?) ?? const []).cast<String>().toSet();
    final me = ref.watch(meIdProvider).value;
    final manage = planner.canManage && !readOnly;
    final c = context.colors;
    final t = Theme.of(context).textTheme;

    Widget group(String title, List<Widget> rows) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 16, 6, 6),
          child: Text(
            title,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.onSurfaceVariant),
          ),
        ),
        Material(
          color: context.palette.chip,
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: Column(children: rows),
        ),
      ],
    );

    Map<int, String> roles() => {for (final x in people) x.userId: x.role};

    Future<void> personMenu(KPlannerPerson x) async {
      final choice = await showModalBottomSheet<String>(
        context: context,
        showDragHandle: true,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Can edit'),
                subtitle: const Text('Adds, changes and ticks to-dos'),
                trailing: x.role == 'edit' ? const Icon(Icons.check_rounded) : null,
                onTap: () => Navigator.pop(context, 'edit'),
              ),
              ListTile(
                title: const Text('Owner'),
                subtitle: const Text('Also renames, shares and deletes the planner'),
                trailing: x.role == 'owner' ? const Icon(Icons.check_rounded) : null,
                onTap: () => Navigator.pop(context, 'owner'),
              ),
              ListTile(
                leading: Icon(Icons.person_remove_outlined, color: c.error),
                title: Text('Take out of this planner', style: TextStyle(color: c.error)),
                onTap: () => Navigator.pop(context, 'remove'),
              ),
            ],
          ),
        ),
      );
      if (choice == null) return;
      final r = roles();
      if (choice == 'remove') {
        r.remove(x.userId);
      } else {
        r[x.userId] = choice;
      }
      await repo.setPlannerPeople(planner.id, r);
    }

    Future<void> addPeople() async {
      final inIt = {planner.creatorId, ...people.map((x) => x.userId)};
      final others = team.where((x) => !inIt.contains(x.id)).toList();
      if (others.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Everyone on the team is already in this planner.')));
        return;
      }
      final picked = await showModalBottomSheet<int>(
        context: context,
        showDragHandle: true,
        builder: (context) => SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final x in others)
                ListTile(
                  leading: PersonAvatar(id: x.id, name: x.name, size: 32),
                  title: Text(x.name),
                  onTap: () => Navigator.pop(context, x.id),
                ),
            ],
          ),
        ),
      );
      if (picked == null) return;
      await repo.setPlannerPeople(planner.id, {...roles(), picked: 'edit'});
    }

    final ownerId = planner.creatorId;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(planner.name, style: t.titleLarge)),
              if (manage)
                IconButton(
                  tooltip: 'Rename',
                  onPressed: () async {
                    final n = await askText(context, title: 'Rename planner', initial: planner.name, action: 'Save');
                    if (n != null && n.trim().isNotEmpty) await repo.updatePlanner(planner.id, name: n);
                  },
                  icon: const Icon(Icons.edit_outlined),
                ),
            ],
          ),
          group('People', [
            if (ownerId != null)
              ListTile(
                leading: PersonAvatar(id: ownerId, name: names[ownerId] ?? '?', size: 30),
                title: Text(ownerId == me ? 'You' : (names[ownerId] ?? 'Someone')),
                trailing: Text('Owner', style: TextStyle(color: c.onSurfaceVariant)),
              ),
            for (final x in people)
              ListTile(
                leading: PersonAvatar(id: x.userId, name: names[x.userId] ?? '?', size: 30),
                title: Text(x.userId == me ? 'You' : (names[x.userId] ?? 'Someone')),
                trailing: Text(x.role == 'owner' ? 'Owner' : 'Can edit', style: TextStyle(color: c.onSurfaceVariant)),
                onTap: manage ? () => personMenu(x) : null,
              ),
            if (manage)
              ListTile(
                title: Text(
                  'Add people',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: context.palette.accentText, fontWeight: FontWeight.w600),
                ),
                onTap: addPeople,
              ),
            if (people.isEmpty && !manage) const ListTile(title: Text('Only you')),
          ]),
          group('Cards from Kolumns', [
            if (boards.isEmpty) const ListTile(title: Text('No Kolumns yet')),
            for (final b in boards)
              SwitchListTile(
                title: Text(b.name),
                subtitle: const Text('Cards with a due day show on that day'),
                value: shown.contains(b.id),
                onChanged: readOnly ? null : (on) => repo.updatePlanner(planner.id, boardIds: on ? [...shown, b.id] : shown.where((x) => x != b.id).toList()),
              ),
          ]),
          group('To-dos', [
            SwitchListTile(
              title: const Text('Move unfinished to the next day'),
              subtitle: const Text('Late cards stay on their day, in red'),
              value: planner.rollOver,
              onChanged: readOnly ? null : (v) => repo.updatePlanner(planner.id, rollOver: v),
            ),
            SwitchListTile(
              title: const Text('Sink finished to the bottom'),
              value: planner.sinkDone,
              onChanged: readOnly ? null : (v) => repo.updatePlanner(planner.id, sinkDone: v),
            ),
            SwitchListTile(
              title: const Text('Hide finished'),
              value: planner.hideDone,
              onChanged: readOnly ? null : (v) => repo.updatePlanner(planner.id, hideDone: v),
            ),
          ]),
          if (manage) ...[
            const SizedBox(height: 18),
            TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: c.error),
              onPressed: () async {
                final all = ref.read(plannersProvider).value ?? const <KPlanner>[];
                if (all.length <= 1) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Make another planner first. Kolumn always keeps one.')));
                  return;
                }
                final ok = await confirm(
                  context,
                  title: 'Delete "${planner.name}"?',
                  body: 'Its to-dos go for everyone in it. Cards stay on their Kolumns.',
                  action: 'Delete planner',
                );
                if (!ok) return;
                await repo.deletePlanner(planner.id);
                final next = all.firstWhere((x) => x.id != planner.id);
                await repo.setSetting('planner.current', next.id);
                if (context.mounted) Navigator.pop(context);
              },
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Delete planner'),
            ),
          ],
        ],
      ),
    );
  }
}
