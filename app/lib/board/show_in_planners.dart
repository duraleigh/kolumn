import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../planner/planner_model.dart';
import '../state/providers.dart';
import '../theme/tokens.dart';

/// Which planners may show a Kolumn's cards (his ruling, 2026-11-13). The
/// Kolumn decides — None, or Only these (from planners its maker is in) — and
/// each kolumn inside follows it unless narrowed. A planner must also have the
/// Kolumn switched on: both must agree. Only its maker or a HUB Admin changes it.

List<String> _list(String? json) => json == null ? const [] : ((jsonDecode(json) as List?) ?? const []).cast<String>();

/// A Kolumn's own choice, as a short line: "None", or "Tour planner, Family".
String plannersLabel(KBoard b, List<KPlanner> planners) {
  final ids = _list(b.plannerIds);
  if (ids.isEmpty) return 'None';
  final names = [for (final p in planners) if (ids.contains(p.id)) p.name];
  final hidden = ids.length - names.length;
  return [...names, if (hidden > 0) '$hidden more'].join(', ');
}

Future<void> showKolumnPlanners(BuildContext context, WidgetRef ref, String boardId) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  useSafeArea: true,
  builder: (context) => _KolumnPlanners(boardId: boardId),
);

class _KolumnPlanners extends ConsumerStatefulWidget {
  const _KolumnPlanners({required this.boardId});
  final String boardId;

  @override
  ConsumerState<_KolumnPlanners> createState() => _KolumnPlannersState();
}

class _KolumnPlannersState extends ConsumerState<_KolumnPlanners> {
  Map<String, Set<int>>? _members;
  bool? _onlyThese;

  @override
  void initState() {
    super.initState();
    ref.read(repositoryProvider).plannerMembers().then((m) {
      if (mounted) setState(() => _members = m);
    });
  }

  @override
  Widget build(BuildContext context) {
    final b = (ref.watch(boardsProvider).value ?? const <KBoard>[]).where((x) => x.id == widget.boardId).firstOrNull;
    if (b == null) return const SizedBox(height: 120);
    final repo = ref.read(repositoryProvider);
    final planners = ref.watch(plannersProvider).value ?? const <KPlanner>[];
    final chosen = _list(b.plannerIds);
    final only = _onlyThese ?? chosen.isNotEmpty;
    // Planners stay private: only those its maker is in can be picked.
    final eligible = [for (final p in planners) if (_members?[p.id]?.contains(b.creatorId) ?? false) p];
    final c = context.colors;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Show in planners', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Which planners may show ${b.name}\'s cards with a due date. A planner must also switch it on in its own settings.',
            style: TextStyle(color: c.onSurfaceVariant),
          ),
          const SizedBox(height: 14),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('None'), icon: Icon(Icons.block_rounded)),
              ButtonSegment(value: true, label: Text('Only these'), icon: Icon(Icons.checklist_rounded)),
            ],
            selected: {only},
            onSelectionChanged: (v) async {
              setState(() => _onlyThese = v.first);
              if (!v.first) await repo.setBoardPlanners(b.id, const []);
            },
          ),
          const SizedBox(height: 10),
          if (only) ...[
            if (_members == null) const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
            if (_members != null && eligible.isEmpty)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text('Its maker isn\'t in any planner yet.', style: TextStyle(color: c.onSurfaceVariant)),
              ),
            for (final p in eligible)
              CheckboxListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                secondary: const Icon(Icons.calendar_today_outlined),
                title: Text(p.name),
                value: chosen.contains(p.id),
                onChanged: (on) => repo.setBoardPlanners(b.id, on == true ? [...chosen, p.id] : chosen.where((x) => x != p.id).toList()),
              ),
          ],
          const SizedBox(height: 8),
          Text(
            'Each kolumn follows this, unless narrowed in its own ••• menu.',
            style: TextStyle(fontSize: 13, color: c.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// One kolumn's choice: as its Kolumn allows, or narrowed to some of those planners (or none).
/// [lane] is 'later', 'todo', 'done', or a kolumn's id.
Future<void> showLanePlanners(BuildContext context, WidgetRef ref, {required String boardId, required String lane, required String laneName}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  useSafeArea: true,
  builder: (context) => Consumer(
    builder: (context, ref, _) {
      final b = (ref.watch(boardsProvider).value ?? const <KBoard>[]).where((x) => x.id == boardId).firstOrNull;
      if (b == null) return const SizedBox(height: 120);
      final repo = ref.read(repositoryProvider);
      final planners = ref.watch(plannersProvider).value ?? const <KPlanner>[];
      final allowed = _list(b.plannerIds);
      List<String>? narrowed;
      if (const ['later', 'todo', 'done'].contains(lane)) {
        final looks = jsonDecode(b.lanes);
        final one = looks is Map ? looks[lane] : null;
        narrowed = one is Map && one['plannerIds'] is List ? (one['plannerIds'] as List).cast<String>() : null;
      } else {
        final col = (ref.watch(allColumnsProvider).value ?? const <KColumn>[]).where((x) => x.id == lane).firstOrNull;
        narrowed = col?.plannerIds == null ? null : _list(col!.plannerIds);
      }
      final c = context.colors;
      final named = {for (final p in planners) p.id: p.name};
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Show "$laneName" in planners', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text('Cards in this kolumn can only show in planners ${b.name} allows.', style: TextStyle(color: c.onSurfaceVariant)),
            const SizedBox(height: 12),
            if (allowed.isEmpty)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: context.palette.chip, borderRadius: BorderRadius.circular(16)),
                child: Text('${b.name} shows in no planners, so this kolumn doesn\'t either. Choose planners in the Kolumn\'s settings first.'),
              )
            else ...[
              RadioGroup<bool>(
                groupValue: narrowed != null,
                onChanged: (v) => repo.setLanePlanners(boardId, lane, v == true ? [...allowed] : null),
                child: const Column(
                  children: [
                    RadioListTile<bool>(value: false, title: Text('As the Kolumn allows')),
                    RadioListTile<bool>(value: true, title: Text('Only some of those (or none)')),
                  ],
                ),
              ),
              if (narrowed != null)
                for (final id in allowed)
                  CheckboxListTile(
                    contentPadding: const EdgeInsets.only(left: 24, right: 4),
                    title: Text(named[id] ?? 'A planner you\'re not in'),
                    value: narrowed.contains(id),
                    onChanged: (on) => repo.setLanePlanners(boardId, lane, on == true ? [...narrowed!, id] : narrowed!.where((x) => x != id).toList()),
                  ),
            ],
          ],
        ),
      );
    },
  ),
);
