import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../board/lane_info.dart';
import '../data/database.dart';
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

Future<void> showNewCardSheet(BuildContext context, WidgetRef ref, String boardId) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _NewCardSheet(boardId: boardId),
  );
}

class _NewCardSheet extends ConsumerStatefulWidget {
  const _NewCardSheet({required this.boardId});
  final String boardId;

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

  Future<void> _add({required bool another}) async {
    final t = _ctl.text.trim();
    if (t.isEmpty) return;
    await ref.read(repositoryProvider).addCard(widget.boardId, t);
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
          Text('New card in To-do', style: Theme.of(context).textTheme.titleLarge),
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

Future<void> showColumnEditor(BuildContext context, WidgetRef ref, {required String boardId, KColumn? column}) {
  return showDialog<void>(
    context: context,
    builder: (context) => _ColumnEditor(boardId: boardId, column: column),
  );
}

class _ColumnEditor extends ConsumerStatefulWidget {
  const _ColumnEditor({required this.boardId, this.column});
  final String boardId;
  final KColumn? column;

  @override
  ConsumerState<_ColumnEditor> createState() => _ColumnEditorState();
}

class _ColumnEditorState extends ConsumerState<_ColumnEditor> {
  late final TextEditingController _name = TextEditingController(text: widget.column?.name ?? '');
  late int _color = widget.column?.color ?? 0;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final n = _name.text.trim();
    if (n.isEmpty) {
      setState(() => _error = 'Give the column a name');
      return;
    }
    final repo = ref.read(repositoryProvider);
    if (widget.column == null) {
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
      title: Text(widget.column == null ? 'New column' : 'Edit column'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _name,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(hintText: 'Column name', errorText: _error),
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
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
          onPressed: _save,
          child: Text(widget.column == null ? 'Add column' : 'Save'),
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
            Text('Boards', style: Theme.of(context).textTheme.titleLarge),
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
                          if (!readOnly && b.canManage)
                            PopupMenuButton<String>(
                              tooltip: 'Board options',
                              icon: const Icon(Icons.more_horiz_rounded),
                              onSelected: (v) async {
                                if (v == 'access') {
                                  await showBoardAccessSheet(context, ref, b);
                                } else if (v == 'rename') {
                                  final n = await askText(context, title: 'Rename board', initial: b.name, action: 'Save');
                                  if (n != null) await repo.renameBoard(b.id, n);
                                } else if (v == 'delete') {
                                  if (boards.length < 2) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(content: Text('Make another board first. Kolumn always keeps one.')));
                                    }
                                    return;
                                  }
                                  if (!context.mounted) return;
                                  final ok = await confirm(
                                    context,
                                    title: 'Delete "${b.name}"?',
                                    body: 'The board and all its cards are removed for everyone who can see it.',
                                    action: 'Delete board',
                                  );
                                  if (!ok) return;
                                  await repo.deleteBoard(b.id);
                                  if (b.id == current) {
                                    final next = boards.firstWhere((x) => x.id != b.id);
                                    await repo.setSetting('board.current', next.id);
                                  }
                                }
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(value: 'access', child: Text('Who can see it')),
                                PopupMenuItem(value: 'rename', child: Text('Rename')),
                                PopupMenuItem(value: 'delete', child: Text('Delete board')),
                              ],
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
                  final n = await askText(context, title: 'New board', action: 'Create', hint: 'Board name');
                  if (n == null) return;
                  final id = await repo.createBoard(n);
                  await repo.setSetting('board.current', id);
                  if (context.mounted) Navigator.pop(context);
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('New board'),
              ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ settings

Future<void> showSettingsSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(context: context, builder: (context) => const _SettingsSheet());
}

class _SettingsSheet extends ConsumerWidget {
  const _SettingsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider).value ?? ThemeMode.system;
    final repo = ref.read(repositoryProvider);
    return SafeArea(
      child: Padding(
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
                          ? '$pending ${pending == 1 ? 'change hasn\'t' : 'changes haven\'t'} reached the hub yet and will be lost. Your boards stay safe in the hub.'
                          : 'Your boards stay safe in the hub. Sign in again any time to see them.',
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
            Text(
              'Kolumn 0.3, test version. Boards are shared through the hub and saved on this phone, so they work without a connection.',
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
              subtitle: Text(_all ? 'Anyone the hub lets use To-Dos sees this board.' : 'Only the people ticked below see it.'),
              value: _all,
              onChanged: (v) => setState(() => _all = v),
            ),
            if (!_all) ...[
              const Divider(),
              for (final p in people)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(p.name),
                  subtitle: p.id == maker ? const Text('Made this board, always included') : null,
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
