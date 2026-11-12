import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../board/kolumn_settings.dart';
import '../board/lane_info.dart';
import '../home_shell.dart' show startScreenProvider, startScreens;
import '../data/database.dart';
import '../data/lane_looks.dart';
import '../data/tidy.dart';
import '../data/lanes.dart';
import '../state/providers.dart';
import '../theme/tokens.dart';

Future<bool> confirm(BuildContext context, {required String title, required String body, required String action}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: context.colors.error, foregroundColor: context.colors.onError, minimumSize: const Size(0, 44)),
          onPressed: () => Navigator.pop(context, true),
          child: Text(action),
        ),
      ],
    ),
  );
  return ok ?? false;
}

Future<String?> askText(BuildContext context, {required String title, String initial = '', required String action, String hint = ''}) {
  final ctl = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: ctl,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(hintText: hint),
        onSubmitted: (v) => Navigator.pop(context, v.trim().isEmpty ? null : v),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
          onPressed: () => Navigator.pop(context, ctl.text.trim().isEmpty ? null : ctl.text),
          child: Text(action),
        ),
      ],
    ),
  );
}

// ------------------------------------------------------------------ new card

/// Adds cards to one kolumn: the one in the middle of the screen when the +
/// button was tapped (his ask, 2026-11-12).
Future<void> showNewCardSheet(BuildContext context, WidgetRef ref, String boardId, {Lane lane = const Lane.todo(), String? laneName}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _NewCardSheet(boardId: boardId, lane: lane, laneName: laneName),
  );
}

class _NewCardSheet extends ConsumerStatefulWidget {
  const _NewCardSheet({required this.boardId, required this.lane, this.laneName});
  final String boardId;
  final Lane lane;
  final String? laneName;

  @override
  ConsumerState<_NewCardSheet> createState() => _NewCardSheetState();
}

class _NewCardSheetState extends ConsumerState<_NewCardSheet> {
  final _ctl = TextEditingController();
  int _added = 0;

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  Future<void> _add({required bool another, bool draft = false}) async {
    final t = _ctl.text.trim();
    if (t.isEmpty) return;
    await ref.read(repositoryProvider).addCard(widget.boardId, t, lane: widget.lane, draft: draft);
    if (!mounted) return;
    if (another) {
      _ctl.clear();
      setState(() => _added++);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'New card in ${widget.laneName ?? laneLook(ref.watch(boardsProvider).value?.where((b) => b.id == widget.boardId).firstOrNull, 'todo').name}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (_added > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('$_added added', style: Theme.of(context).textTheme.bodySmall),
            ),
          const SizedBox(height: 14),
          TextField(
            controller: _ctl,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'What needs doing?'),
            onSubmitted: (_) => _add(another: true),
          ),
          const SizedBox(height: 14),
          FilledButton(onPressed: () => _add(another: false), child: const Text('Add card')),
          const SizedBox(height: 6),
          TextButton(onPressed: () => _add(another: true), child: const Text('Add and start another')),
          TextButton(onPressed: () => _add(another: false, draft: true), child: const Text('Save as a draft (only you see it)')),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ move to

/// The "Move to…" list: the no-drag way to move a card, for one-handed use.
Future<Lane?> showMoveSheet(BuildContext context, {required List<LaneInfo> lanes, required Lane current, required String title}) {
  return showModalBottomSheet<Lane>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      final c = context.colors;
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Move to…', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 2),
              Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
              for (final l in lanes)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Material(
                    color: l.lane == current ? c.primaryContainer : context.palette.lane,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(KShapes.lg),
                      side: l.lane == current ? BorderSide(color: c.primary, width: 2) : BorderSide.none,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(KShapes.lg),
                      onTap: l.lane == current ? null : () => Navigator.pop(context, l.lane),
                      child: SizedBox(
                        height: 52,
                        child: Row(
                          children: [
                            const SizedBox(width: 14),
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(color: l.color, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l.name,
                                style: Theme.of(context).textTheme.bodyLarge!
                                    .copyWith(fontWeight: FontWeight.w500, color: l.lane == current ? c.onPrimaryContainer : null),
                              ),
                            ),
                            Text(l.lane == current ? 'here now' : '${l.cards.length}', style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(width: 14),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

// ------------------------------------------------------------------ columns

/// Adds a kolumn, or renames and recolors one. With [builtIn], it is Later,
/// To-do or Done on this Kolumn, which every Kolumn can rename and recolor too.
Future<void> showColumnEditor(BuildContext context, WidgetRef ref, {required String boardId, KColumn? column, LaneKind? builtIn, String? builtInName}) {
  return showDialog<void>(
    context: context,
    builder: (context) => _ColumnEditor(boardId: boardId, column: column, builtIn: builtIn),
  );
}

class _ColumnEditor extends ConsumerStatefulWidget {
  const _ColumnEditor({required this.boardId, this.column, this.builtIn});
  final String boardId;
  final KColumn? column;
  final LaneKind? builtIn;

  @override
  ConsumerState<_ColumnEditor> createState() => _ColumnEditorState();
}

class _ColumnEditorState extends ConsumerState<_ColumnEditor> {
  KBoard? get _board => ref.read(boardsProvider).value?.where((b) => b.id == widget.boardId).firstOrNull;
  String? get _kind => widget.builtIn == null ? null : kindKey(widget.builtIn!);
  late final LaneLook? _look = _kind == null ? null : laneLook(_board, _kind!);
  late final TextEditingController _name = TextEditingController(text: _look?.name ?? widget.column?.name ?? '');
  late int _color = _look?.color ?? widget.column?.color ?? 0;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final n = _name.text.trim();
    if (n.isEmpty) {
      setState(() => _error = 'Give the kolumn a name');
      return;
    }
    final repo = ref.read(repositoryProvider);
    if (_kind != null) {
      await repo.setLaneLook(widget.boardId, _kind!, name: n == usualLaneName(_kind!) ? '' : n, color: _color);
    } else if (widget.column == null) {
      await repo.addColumn(widget.boardId, n, _color);
    } else {
      await repo.updateColumn(widget.column!.id, name: n, color: _color);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    return AlertDialog(
      title: Text(_kind != null ? 'Rename or recolor' : (widget.column == null ? 'New kolumn' : 'Edit kolumn')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _name,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(hintText: 'Kolumn name', errorText: _error),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 16),
          Text('Color', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < LaneColors.all.length; i++)
                Semantics(
                  button: true,
                  selected: i == _color,
                  label: LaneColors.all[i].name,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => setState(() => _color = i),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: LaneColors.all[i].of(b),
                        shape: BoxShape.circle,
                        border: i == _color ? Border.all(color: context.colors.onSurface, width: 3) : null,
                      ),
                      child: i == _color ? const Icon(Icons.check_rounded, color: Colors.white) : null,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      actions: [
        if (_kind != null && (_look?.custom ?? false))
          TextButton(
            onPressed: () => setState(() {
              _name.text = usualLaneName(_kind!);
              _color = laneLook(null, _kind!).color;
            }),
            child: Text('Back to "${usualLaneName(_kind!)}"'),
          ),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
          onPressed: _save,
          child: Text(widget.column == null && _kind == null ? 'Add kolumn' : 'Save'),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------------ boards

Future<void> showBoardsSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (context) => const _BoardsSheet());
}

class _BoardsSheet extends ConsumerWidget {
  const _BoardsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boards = ref.watch(boardsProvider).value ?? const <KBoard>[];
    final current = ref.watch(currentBoardIdProvider).value;
    final repo = ref.read(repositoryProvider);
    final readOnly = ref.watch(readOnlyProvider).value ?? false;
    final c = context.colors;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Kolumns', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            for (final b in boards)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Material(
                  color: b.id == current ? c.primaryContainer : context.palette.lane,
                  borderRadius: BorderRadius.circular(KShapes.lg),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(KShapes.lg),
                    onTap: () async {
                      await repo.setSetting('board.current', b.id);
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: SizedBox(
                      height: 56,
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Icon(Icons.view_kanban_outlined, color: b.id == current ? c.onPrimaryContainer : c.onSurfaceVariant),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              b.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyLarge!
                                  .copyWith(fontWeight: FontWeight.w600, color: b.id == current ? c.onPrimaryContainer : null),
                            ),
                          ),
                          if (!b.allAccess)
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Tooltip(
                                message: 'Only chosen people',
                                child: Icon(Icons.lock_outline_rounded, size: 18, color: c.onSurfaceVariant),
                              ),
                            ),
                          IconButton(
                            tooltip: 'Kolumn settings',
                            icon: const Icon(Icons.more_horiz_rounded),
                            onPressed: () => showKolumnSettings(context, ref, b.id),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            if (!readOnly)
              FilledButton.icon(
                onPressed: () async {
                  final n = await askText(context, title: 'New Kolumn', action: 'Create', hint: 'Kolumn name');
                  if (n == null) return;
                  final id = await repo.createBoard(n);
                  await repo.setSetting('board.current', id);
                  if (context.mounted) Navigator.pop(context);
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('New Kolumn'),
              ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ settings

Future<void> showSettingsSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(context: context, isScrollControlled: true, useSafeArea: true, builder: (context) => const _SettingsSheet());
}

class _SettingsSheet extends ConsumerWidget {
  const _SettingsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider).value ?? ThemeMode.system;
    final repo = ref.read(repositoryProvider);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Settings', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Text('Look', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<ThemeMode>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: ThemeMode.system, label: Text('Match phone')),
                ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
              ],
              selected: {mode},
              onSelectionChanged: (s) {
                final m = s.first;
                repo.setSetting('theme', m == ThemeMode.light ? 'light' : (m == ThemeMode.dark ? 'dark' : 'system'));
              },
            ),
            const SizedBox(height: 20),
            Text('Opens on', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: 'kolumns', label: Text('Kolumns')),
                ButtonSegment(value: 'activity', label: Text('Activity')),
                ButtonSegment(value: 'planner', label: Text('Planner')),
              ],
              selected: {startScreens.contains(ref.watch(startScreenProvider).value) ? ref.watch(startScreenProvider).value! : 'kolumns'},
              onSelectionChanged: (s) => repo.setSetting('home.start', s.first),
            ),
            const SizedBox(height: 4),
            Text('The screen you see first each time Kolumn opens.', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 20),
            Text('Account', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text('Signed in as ${ref.watch(meNameProvider).value ?? 'you'} with your hub login.', style: Theme.of(context).textTheme.bodyMedium),
                ),
                TextButton(
                  onPressed: () async {
                    final pending = ref.read(pendingCountProvider).value ?? 0;
                    final ok = await confirm(
                      context,
                      title: 'Sign out of Kolumn?',
                      body: pending > 0
                          ? '$pending ${pending == 1 ? 'change hasn\'t' : 'changes haven\'t'} reached the hub yet and will be lost. Your Kolumns and planners stay safe in the hub.'
                          : 'Your Kolumns and planners stay safe in the hub. Sign in again any time to see them.',
                      action: 'Sign out',
                    );
                    if (!ok) return;
                    if (context.mounted) Navigator.pop(context);
                    await ref.read(syncServiceProvider).signOut();
                  },
                  child: const Text('Sign out'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () => exportEverything(context, ref),
              icon: const Icon(Icons.ios_share_rounded),
              label: const Text('Export everything'),
            ),
            const SizedBox(height: 14),
            Text(
              'Kolumn 0.7, test version. Kolumns and planners are shared through the hub and saved on this phone, so they work without a connection.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ board sharing

/// Who can see a board: everyone with To-Dos, or only the people ticked.
/// Its maker is always included.
Future<void> showBoardAccessSheet(BuildContext context, WidgetRef ref, KBoard board) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _BoardAccessSheet(board: board),
  );
}

class _BoardAccessSheet extends ConsumerStatefulWidget {
  const _BoardAccessSheet({required this.board});
  final KBoard board;

  @override
  ConsumerState<_BoardAccessSheet> createState() => _BoardAccessSheetState();
}

class _BoardAccessSheetState extends ConsumerState<_BoardAccessSheet> {
  late bool _all = widget.board.allAccess;
  late final Set<int> _members = {...(jsonDecode(widget.board.members) as List).map((e) => (e as num).toInt())};

  @override
  Widget build(BuildContext context) {
    final people = ref.watch(peopleProvider).value ?? const <KPerson>[];
    final maker = widget.board.creatorId;
    final t = Theme.of(context).textTheme;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Who can see "${widget.board.name}"', style: t.titleLarge),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Everyone with To-Dos'),
              subtitle: Text(_all ? 'Anyone the hub lets use To-Dos sees this Kolumn.' : 'Only the people ticked below see it.'),
              value: _all,
              onChanged: (v) => setState(() => _all = v),
            ),
            if (!_all) ...[
              const Divider(),
              for (final p in people)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(p.name),
                  subtitle: p.id == maker ? const Text('Made this Kolumn, always included') : null,
                  value: p.id == maker || _members.contains(p.id),
                  onChanged: p.id == maker ? null : (v) => setState(() => v == true ? _members.add(p.id) : _members.remove(p.id)),
                ),
            ],
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () async {
                final members = {..._members, ?maker}.toList();
                await ref.read(repositoryProvider).setBoardAccess(widget.board.id, allAccess: _all, members: members);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ pickers (Phase 4)

/// Choose another board (for moving a card).
Future<KBoard?> pickBoard(BuildContext context, List<KBoard> boards) => showModalBottomSheet<KBoard>(
  context: context,
  isScrollControlled: true,
  builder: (context) => SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Move to which Kolumn?', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text('The card, its steps, comments and files go with it, into To-do.', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          for (final b in boards)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Material(
                color: context.palette.lane,
                borderRadius: BorderRadius.circular(KShapes.lg),
                child: ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(KShapes.lg)),
                  leading: const Icon(Icons.view_kanban_outlined),
                  title: Text(b.name),
                  trailing: b.allAccess ? null : const Icon(Icons.lock_outline_rounded, size: 18),
                  onTap: () => Navigator.pop(context, b),
                ),
              ),
            ),
        ],
      ),
    ),
  ),
);

/// Choose or type a tag.
Future<String?> pickTag(BuildContext context, List<String> known) {
  final ctl = TextEditingController();
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: StatefulBuilder(
        builder: (context, setState) {
          final q = ctl.text.trim().toLowerCase().replaceAll(RegExp(r'^#+'), '');
          final matches = known.where((t) => q.isEmpty || t.contains(q)).take(20).toList();
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Add a tag', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              TextField(
                controller: ctl,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'venue, travel, merch…'),
                onChanged: (_) => setState(() {}),
                onSubmitted: (v) => Navigator.pop(context, v.trim().isEmpty ? null : v),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final t in matches) ActionChip(label: Text(t), onPressed: () => Navigator.pop(context, t)),
                  if (q.isNotEmpty && !known.contains(q))
                    ActionChip(avatar: const Icon(Icons.add_rounded, size: 18), label: Text('New tag "$q"'), onPressed: () => Navigator.pop(context, q)),
                ],
              ),
            ],
          );
        },
      ),
    ),
  );
}

/// My pinned cards, from any board.
Future<void> showPinsSheet(BuildContext context, void Function(KCard) open) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (context) => Consumer(
    builder: (context, ref, _) {
      final pins = ref.watch(pinsProvider).value ?? const <KPin>[];
      final cards = {for (final c in ref.watch(allCardsProvider).value ?? const <KCard>[]) c.id: c};
      final boards = {for (final b in ref.watch(boardsProvider).value ?? const <KBoard>[]) b.id: b.name};
      final list = [for (final p in pins) ?cards[p.cardId]];
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Pinned', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text('Your own shortcuts. Pin a card from its screen.', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
              if (list.isEmpty) const Padding(padding: EdgeInsets.all(16), child: Text('Nothing pinned yet.')),
              for (final c in list)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Material(
                    color: context.palette.lane,
                    borderRadius: BorderRadius.circular(KShapes.lg),
                    child: ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(KShapes.lg)),
                      leading: const Icon(Icons.push_pin_rounded),
                      title: Text(c.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                      subtitle: Text(boards[c.boardId] ?? ''),
                      onTap: () {
                        Navigator.pop(context);
                        open(c);
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  ),
);

/// My drafts on a board.
Future<void> showDraftsSheet(BuildContext context, String boardId, void Function(KCard) open) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (context) => Consumer(
    builder: (context, ref, _) {
      final me = ref.watch(meIdProvider).value;
      final drafts = (ref.watch(cardsProvider(boardId)).value ?? const <KCard>[])
          .where((c) => c.status == 'draft' && (me == null || c.creatorId == null || c.creatorId == me))
          .toList();
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Your drafts', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text('Only you can see these until you post them.', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
              if (drafts.isEmpty) const Padding(padding: EdgeInsets.all(16), child: Text('No drafts.')),
              for (final c in drafts)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Material(
                    color: context.palette.lane,
                    borderRadius: BorderRadius.circular(KShapes.lg),
                    child: ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(KShapes.lg)),
                      leading: const Icon(Icons.edit_note_rounded),
                      title: Text(c.title),
                      onTap: () {
                        Navigator.pop(context);
                        open(c);
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  ),
);

/// How long a Kolumn's untouched cards wait before moving to Later on their
/// own. Cards with a due day never move.
Future<void> pickTidyDays(BuildContext context, WidgetRef ref, KBoard b) async {
  final current = b.tidyDays ?? tidyDefault;
  final picked = await showModalBottomSheet<int>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
            child: Text('Tidy-up time for "${b.name}"', style: Theme.of(context).textTheme.titleLarge),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              'A card nobody touches for this long moves to ${laneLook(b, 'later').name} on its own. Cards with a due day never move.',
              style: TextStyle(color: context.colors.onSurfaceVariant),
            ),
          ),
          for (final d in tidyChoices)
            ListTile(
              title: Text(tidyChoiceLabel(d) + (d == tidyDefault ? ' (usual)' : '')),
              trailing: d == current ? const Icon(Icons.check_rounded) : null,
              onTap: () => Navigator.pop(context, d),
            ),
        ],
      ),
    ),
  );
  if (picked == null || picked == current) return;
  await ref.read(repositoryProvider).setTidyDays(b.id, picked == tidyDefault ? null : picked);
}
