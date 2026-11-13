import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../board/board_screen.dart' show moveWithUndo;
import '../board/lane_info.dart';
import '../data/database.dart';
import '../data/due.dart';
import '../data/lane_looks.dart';
import '../data/lanes.dart';
import '../data/repository.dart';
import '../data/tidy.dart';
import '../planner/days.dart';
import '../planner/planner_model.dart';
import '../planner/todo_sheet.dart';
import '../state/providers.dart';
import '../theme/tokens.dart';
import '../ui/bits.dart';
import '../ui/item_sheet.dart';
import '../ui/sheets.dart';
import 'composer.dart';

/// Opens a card (his ask, 2026-11-13): the same pop-up as a Planner to-do,
/// sliding up from the bottom, made from the same pieces — plus a part that
/// slides up with its comments and activity (the pen button, or pull the top
/// edge up). Bottom bar: who's on it · Priority · the pen · reminder · ⋮.
Future<void> showCardSheet(BuildContext context, String cardId) => showItemSheet(context, (wide) => CardSheet(cardId: cardId, wide: wide));

class CardSheet extends ConsumerStatefulWidget {
  const CardSheet({super.key, required this.cardId, this.wide = false});
  final String cardId;
  final bool wide;

  @override
  ConsumerState<CardSheet> createState() => _CardSheetState();
}

class _CardSheetState extends ConsumerState<CardSheet> {
  final _title = TextEditingController();
  final _notes = TextEditingController();
  final _newStep = TextEditingController();
  bool _loaded = false;
  Timer? _save;
  late final KolumnRepository _repo = ref.read(repositoryProvider);

  @override
  void dispose() {
    _flush();
    _title.dispose();
    _notes.dispose();
    _newStep.dispose();
    super.dispose();
  }

  void _changed() {
    _save?.cancel();
    _save = Timer(const Duration(milliseconds: 700), _flush);
  }

  void _flush() {
    if (_save == null) return;
    _save?.cancel();
    _save = null;
    _repo.editCard(widget.cardId, title: _title.text, description: _notes.text);
  }

  Future<void> _openCard(String id) async {
    final c = await _repo.card(id);
    if (c == null || !mounted) return;
    await showCardSheet(context, id);
  }

  Future<void> _attach({required bool photo, ImageSource source = ImageSource.gallery}) async {
    String path;
    String name;
    if (photo) {
      final x = await ImagePicker().pickImage(source: source, maxWidth: 2400, maxHeight: 2400, imageQuality: 85);
      if (x == null) return;
      path = x.path;
      name = x.name;
    } else {
      final r = await FilePicker.pickFiles();
      if (r.isEmpty || r.first.path == null) return;
      path = r.first.path!;
      name = r.first.name;
    }
    final src = File(path);
    final size = await src.length();
    if (size > 25 * 1024 * 1024) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Files can be up to 25 MB.')));
      return;
    }
    // Keep our own copy until it has reached the hub.
    final dir = Directory('${(await getApplicationDocumentsDirectory()).path}/kolumn-uploads');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    final keep = await src.copy('${dir.path}/${DateTime.now().microsecondsSinceEpoch}-$name');
    final mime = mimeFor(name);
    final hasCover = (await _repo.card(widget.cardId))?.coverId != null;
    // The first picture on a card becomes its cover, as in Fizzy.
    await _repo.addFile(widget.cardId, localPath: keep.path, filename: name, mime: mime, size: size, cover: !hasCover && mime.startsWith('image/'));
  }

  Future<void> _openFile(KFile f) async {
    if (f.mime.startsWith('image/')) {
      await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => _PictureViewer(file: f)));
      return;
    }
    final bytes = await ref.read(fileBytesProvider((f.id, false)).future);
    if (bytes == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('That file can\'t be opened right now. Check your connection.')));
      return;
    }
    final dir = Directory('${(await getApplicationCacheDirectory()).path}/kolumn-open/${f.id}');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    final out = File('${dir.path}/${f.filename}');
    if (!out.existsSync()) await out.writeAsBytes(bytes, flush: true);
    await OpenFilex.open(out.path, type: f.mime);
  }

  Future<void> _fileMenu(KFile f, String? coverId) async {
    final c = context.colors;
    final isImage = f.mime.startsWith('image/');
    final pick = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isImage)
              ListTile(
                leading: const Icon(Icons.wallpaper_rounded),
                title: Text(coverId == f.id ? 'Stop using as cover' : 'Use as the card\'s cover'),
                onTap: () => Navigator.pop(context, 'cover'),
              ),
            ListTile(
              leading: Icon(Icons.delete_outline_rounded, color: c.error),
              title: const Text('Remove from card'),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (pick == 'cover') await _repo.setCover(widget.cardId, coverId == f.id ? null : f.id);
    if (pick == 'delete') await _repo.deleteFile(f);
  }

  Future<void> _stepMenu(KStep s) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.edit_outlined), title: const Text('Edit'), onTap: () => Navigator.pop(context, 'edit')),
            ListTile(
              leading: Icon(Icons.delete_outline_rounded, color: context.colors.error),
              title: Text('Delete', style: TextStyle(color: context.colors.error)),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || choice == null) return;
    if (choice == 'edit') {
      final n = await askText(context, title: 'Edit step', initial: s.content, action: 'Save');
      if (n != null && n.trim().isNotEmpty) await _repo.updateStep(s, content: n);
    } else {
      await _repo.deleteStep(s);
    }
  }

  Future<void> _pickDue(KCard card) async {
    final today = ref.read(plannerTodayProvider);
    final r = await pickDueMoment(
      context,
      title: 'Due date',
      current: card.dueAt,
      currentHasTime: card.dueHasTime,
      startDay: today,
      firstDay: today,
      removeLabel: card.dueAt == null ? null : 'Remove the due date',
    );
    if (r == null) return;
    await _repo.setCardDueAt(card.id, r.at, hasTime: r.hasTime);
  }

  Future<void> _remind(KCard card) async {
    final today = ref.read(plannerTodayProvider);
    final current = ref.read(reminderMapProvider)[card.id];
    final r = await pickReminder(context, current: current, day: card.dueAt == null ? today : _laterOf(dueDay(card.dueAt!, hasTime: card.dueHasTime), today));
    if (r != null) await _repo.setReminder(card.id, 'card', r.at);
  }

  static String _laterOf(String a, String b) => a.compareTo(b) > 0 ? a : b;

  /// ⋮: Follow · Pin to the top of its kolumn · Move to a different kolumn · Delete.
  Future<void> _more(KCard card, {required bool following, required List<LaneInfo> lanes, required Lane lane, required List<KBoard> boards}) async {
    final c = context.colors;
    final pinned = card.pinnedAt != null;
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(following ? Icons.notifications_off_outlined : Icons.notifications_active_outlined),
              title: Text(following ? 'Stop following' : 'Follow'),
              subtitle: Text(following ? 'You hear about changes to this card' : 'Hear about changes to this card'),
              onTap: () => Navigator.pop(context, 'follow'),
            ),
            ListTile(
              leading: Icon(pinned ? Icons.push_pin_rounded : Icons.push_pin_outlined),
              title: Text(pinned ? 'Unpin from the top' : 'Pin to the top of its kolumn'),
              subtitle: Text(pinned ? 'It goes back among the others' : 'It stays at the top until unpinned, for everyone'),
              onTap: () => Navigator.pop(context, 'pin'),
            ),
            ListTile(leading: const Icon(Icons.drive_file_move_outline), title: const Text('Move to a different kolumn'), onTap: () => Navigator.pop(context, 'move')),
            ListTile(
              leading: Icon(Icons.delete_outline_rounded, color: c.error),
              title: Text('Delete card', style: TextStyle(color: c.error)),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || choice == null) return;
    switch (choice) {
      case 'follow':
        await _repo.setWatching(card.id, !following);
      case 'pin':
        await _repo.setPinTop(card.id, !pinned);
      case 'move':
        final others = boards.where((b) => b.id != card.boardId).toList();
        final to = await _showMoveAnywhere(context, lanes: lanes, current: lane, boards: others, title: card.title);
        if (to == null || !mounted) return;
        if (to.lane != null) {
          await moveWithUndo(context, ref, card.id, to.lane!, lane, lanes);
        } else {
          _flush();
          await _repo.moveCardToBoard(card.id, to.board!.id);
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Moved to ${to.board!.name}, in ${laneLook(to.board, 'todo').name}')));
        }
      case 'delete':
        final messenger = ScaffoldMessenger.of(context);
        _save?.cancel();
        _save = null;
        await _repo.deleteCard(card.id);
        if (!mounted) return;
        Navigator.pop(context);
        messenger.showSnackBar(
          SnackBar(
            content: const Text('Card deleted'),
            action: SnackBarAction(label: 'Undo', onPressed: () => _repo.restoreCard(card.id)),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = ref.watch(cardProvider(widget.cardId)).value;
    if (card == null || card.deletedAt != null) {
      return const SizedBox(height: 200, child: Center(child: Text('This card is gone.')));
    }
    if (!_loaded) {
      _loaded = true;
      _title.text = card.title;
      _notes.text = card.description;
    }
    final boardId = card.boardId;
    final columns = ref.watch(columnsProvider(boardId)).value ?? const <KColumn>[];
    final cards = ref.watch(cardsProvider(boardId)).value ?? const <KCard>[];
    final boards = ref.watch(boardsProvider).value ?? const <KBoard>[];
    final readOnly = ref.watch(readOnlyProvider).value ?? false;
    final board = boards.where((b) => b.id == boardId).firstOrNull;
    final lanes = buildLanes(context, columns, cards, board: board);
    final lane = Lane.of(card, columns.map((c) => c.id).toSet());
    final info = lanes.firstWhere((l) => l.lane == lane, orElse: () => lanes.firstWhere((l) => l.isHome, orElse: () => lanes.first));
    final today = ref.watch(plannerTodayProvider);
    final now = ref.watch(plannerNowProvider)();
    final state = dueState(dueAt: card.dueAt, hasTime: card.dueHasTime, doneAt: card.closedAt, now: now);
    final priority = card.priorityAt != null;
    final following = ref.watch(watchProvider(card.id)).value?.watching ?? false;
    final reminder = ref.watch(reminderMapProvider)[card.id];
    final names = ref.watch(peopleNamesProvider);
    final people = ref.watch(peopleProvider).value ?? const <KPerson>[];
    final assigned = (ref.watch(allAssigneesProvider).value ?? const <KAssignee>[]).where((a) => a.cardId == card.id).map((a) => a.userId).toList();
    final steps = ref.watch(stepsProvider(card.id)).value ?? const <KStep>[];
    final files = (ref.watch(filesProvider(card.id)).value ?? const <KFile>[]).where((f) => f.commentId == null).toList();
    final left = tidyDaysLeft(card, board, now);
    final c = context.colors;

    return ItemSheetFrame(
      wide: widget.wide,
      main: [
        if (card.status == 'draft')
          _DraftBanner(
            onPost: () async {
              _flush();
              await _repo.publishCard(card.id);
            },
          ),
        if (card.coverId != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AspectRatio(aspectRatio: 16 / 9, child: HubPicture(fileId: card.coverId!)),
            ),
          ),
        // The title first, the due pill under it (his layout, 2026-11-13).
        TitleField(controller: _title, readOnly: readOnly, onChanged: _changed, hint: 'Card title'),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: DuePill(
              dueAt: card.dueAt,
              hasTime: card.dueHasTime,
              state: state,
              readOnly: readOnly,
              today: today,
              onPick: () => _pickDue(card),
              onClear: () => _repo.setCardDueAt(card.id, null),
            ),
          ),
        ),
        if (left != null && tidyWarning(card, board, now))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              left <= 1
                  ? 'Nobody has touched this card in a while. It moves to ${laneLook(board, 'later').name} tomorrow unless someone does.'
                  : 'Nobody has touched this card in a while. It moves to ${laneLook(board, 'later').name} in $left days unless someone does.',
              style: TextStyle(fontSize: 13, color: c.onSurfaceVariant),
            ),
          ),
        if (assigned.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              for (final id in assigned)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PersonAvatar(id: id, name: names[id] ?? '?', size: 24),
                    const SizedBox(width: 8),
                    Text(names[id] ?? 'Someone', style: TextStyle(fontSize: 14, color: c.onSurfaceVariant)),
                  ],
                ),
            ],
          ),
        ],
        const SizedBox(height: 10),
        NoteField(controller: _notes, readOnly: readOnly, onChanged: _changed, onOpenCard: _openCard),
        const SizedBox(height: 10),
        for (final s in steps)
          ChecklistRow(
            content: s.content,
            done: s.done,
            readOnly: readOnly,
            onToggle: () => _repo.updateStep(s, done: !s.done),
            onMenu: () => _stepMenu(s),
          ),
        if (!readOnly) AddStepField(controller: _newStep, onAdd: (v) => _repo.addStep(card.id, v)),
        if (!readOnly)
          AttachChips(
            onPhoto: () => _attach(photo: true),
            onCamera: () => _attach(photo: true, source: ImageSource.camera),
            onFile: () => _attach(photo: false),
          ),
        FileTiles(
          files: [for (final f in files) FileTileData(id: f.id, filename: f.filename, mime: f.mime, size: f.size, uploaded: f.uploaded, cover: card.coverId == f.id)],
          onOpen: (t) => _openFile(files.firstWhere((f) => f.id == t.id)),
          onHold: readOnly ? null : (t) => _fileMenu(files.firstWhere((f) => f.id == t.id), card.coverId),
        ),
      ],
      // Pulled up (or the pen): comments and activity, with a box to write in.
      more: (context) => [
        // The card's number shows only once the card is slid up (his ask, 2026-11-12).
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            [card.synced ? 'Card #${card.number}' : 'New card', info.name, if (card.pinnedAt != null) 'pinned to the top'].join(' · '),
            style: TextStyle(fontSize: 13, color: c.onSurfaceVariant),
          ),
        ),
        _Reactions(cardId: card.id, commentId: null, readOnly: readOnly),
        const SizedBox(height: 16),
        _CommentsSection(cardId: card.id, readOnly: readOnly, onOpenCard: _openCard),
        const SizedBox(height: 8),
        _Activity(cardId: card.id, createdAt: card.createdAt),
      ],
      composer: readOnly ? null : CommentComposer(cardId: card.id),
      bar: ItemBar(
        children: [
          BarIcon(
            icon: Icons.person_outline_rounded,
            label: 'Who\'s on it',
            on: assigned.isNotEmpty,
            onTap: readOnly
                ? null
                : () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    showDragHandle: true,
                    builder: (_) => _AssignSheet(cardId: card.id, people: people),
                  ),
          ),
          BarIcon(icon: priority ? Icons.star_rounded : Icons.star_outline_rounded, label: priority ? 'Priority (tap to remove)' : 'Make it Priority', on: priority, onTap: readOnly ? null : () => _repo.setPriority(card.id, !priority)),
          Builder(
            builder: (context) => BarCenter(icon: Icons.edit_note_rounded, label: 'Comments and activity', onTap: () => ItemSheetFrame.of(context)?.toggle()),
          ),
          BarIcon(icon: Icons.notifications_none_rounded, label: 'Reminder', on: reminder != null, onTap: () => _remind(card)),
          BarIcon(
            icon: Icons.more_horiz_rounded,
            label: 'More',
            onTap: readOnly ? null : () => _more(card, following: following, lanes: lanes, lane: lane, boards: boards),
          ),
        ],
      ),
    );
  }
}

/// Where "Move to a different kolumn" goes: one of this Kolumn's kolumns, or another Kolumn.
class _MoveTarget {
  const _MoveTarget.lane(Lane this.lane) : board = null;
  const _MoveTarget.board(KBoard this.board) : lane = null;
  final Lane? lane;
  final KBoard? board;
}

/// One list: this Kolumn's kolumns, then the other Kolumns (his answer, 2026-11-13).
Future<_MoveTarget?> _showMoveAnywhere(BuildContext context, {required List<LaneInfo> lanes, required Lane current, required List<KBoard> boards, required String title}) {
  return showModalBottomSheet<_MoveTarget>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      final c = context.colors;
      final t = Theme.of(context).textTheme;
      Widget row({required Widget lead, required String name, required String trail, required bool here, VoidCallback? onTap}) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Material(
          color: here ? c.primaryContainer : context.palette.lane,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KShapes.lg),
            side: here ? BorderSide(color: c.primary, width: 2) : BorderSide.none,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(KShapes.lg),
            onTap: here ? null : onTap,
            child: SizedBox(
              height: 52,
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  lead,
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(name, style: t.bodyLarge!.copyWith(fontWeight: FontWeight.w500, color: here ? c.onPrimaryContainer : null)),
                  ),
                  Text(trail, style: t.bodySmall),
                  const SizedBox(width: 14),
                ],
              ),
            ),
          ),
        ),
      );
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Move to a different kolumn', style: t.titleLarge),
              const SizedBox(height: 2),
              Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: t.bodySmall),
              const SizedBox(height: 12),
              for (final l in lanes)
                row(
                  lead: Container(width: 12, height: 12, decoration: BoxDecoration(color: l.color, shape: BoxShape.circle)),
                  name: l.name,
                  trail: l.lane == current ? 'here now' : '${l.cards.length}',
                  here: l.lane == current,
                  onTap: () => Navigator.pop(context, _MoveTarget.lane(l.lane)),
                ),
              if (boards.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
                  child: Text('Other Kolumns', style: t.titleSmall!.copyWith(fontWeight: FontWeight.w700)),
                ),
                for (final b in boards)
                  row(
                    lead: Icon(Icons.view_kanban_outlined, size: 18, color: c.onSurfaceVariant),
                    name: b.name,
                    trail: 'to ${laneLook(b, 'todo').name}',
                    here: false,
                    onTap: () => Navigator.pop(context, _MoveTarget.board(b)),
                  ),
              ],
            ],
          ),
        ),
      );
    },
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 2),
    child: Row(
      children: [
        Text(text, style: Theme.of(context).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w700, color: context.colors.onSurface)),
      ],
    ),
  );
}

class _DraftBanner extends StatelessWidget {
  const _DraftBanner({required this.onPost});
  final VoidCallback onPost;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
      decoration: BoxDecoration(color: c.tertiaryContainer, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Draft. Only you can see this card.',
              style: TextStyle(color: c.onTertiaryContainer, fontWeight: FontWeight.w600),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
            onPressed: onPost,
            child: const Text('Post it'),
          ),
        ],
      ),
    );
  }
}

class _AssignSheet extends ConsumerWidget {
  const _AssignSheet({required this.cardId, required this.people});
  final String cardId;
  final List<KPerson> people;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assigned = (ref.watch(allAssigneesProvider).value ?? const <KAssignee>[]).where((a) => a.cardId == cardId).map((a) => a.userId).toSet();
    final repo = ref.read(repositoryProvider);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Who\'s on it?', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (people.isEmpty) const Padding(padding: EdgeInsets.all(12), child: Text('The team list arrives with the next check.')),
            for (final p in people)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                secondary: PersonAvatar(id: p.id, name: p.name, size: 32),
                title: Text(p.name),
                value: assigned.contains(p.id),
                onChanged: (v) => repo.setAssigned(cardId, p.id, v == true),
              ),
            const SizedBox(height: 8),
            FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
          ],
        ),
      ),
    );
  }
}

class _PictureViewer extends StatelessWidget {
  const _PictureViewer({required this.file});
  final KFile file;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      title: Text(file.filename, style: const TextStyle(color: Colors.white, fontSize: 16)),
    ),
    body: InteractiveViewer(
      maxScale: 5,
      child: Center(
        child: HubPicture(fileId: file.id, thumb: false, fit: BoxFit.contain),
      ),
    ),
  );
}

// ------------------------------------------------------------------ reactions

class _Reactions extends ConsumerWidget {
  const _Reactions({required this.cardId, required this.commentId, required this.readOnly});
  final String cardId;
  final String? commentId;
  final bool readOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = (ref.watch(reactionsProvider(cardId)).value ?? const <KReaction>[]).where((r) => r.commentId == commentId).toList();
    final me = ref.watch(meIdProvider).value;
    final names = ref.watch(peopleNamesProvider);
    final repo = ref.read(repositoryProvider);
    final c = context.colors;
    final groups = <String, List<KReaction>>{};
    for (final r in all) {
      groups.putIfAbsent(r.emoji, () => []).add(r);
    }
    if (readOnly && groups.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final e in groups.entries)
          Tooltip(
            message: e.value.map((r) => r.userId == me ? 'You' : (names[r.userId] ?? 'Someone')).join(', '),
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: readOnly ? null : () => repo.toggleReaction(cardId, e.key, commentId: commentId),
              child: Container(
                constraints: const BoxConstraints(minHeight: 36),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: e.value.any((r) => r.userId == me) ? c.primaryContainer : context.palette.chip,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('${e.key} ${e.value.length}', style: TextStyle(fontSize: 15, color: c.onSurface)),
              ),
            ),
          ),
        if (!readOnly)
          Tooltip(
            message: 'Add a reaction',
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () async {
                final emoji = await pickReaction(context);
                if (emoji != null) await repo.toggleReaction(cardId, emoji, commentId: commentId);
              },
              child: Container(
                constraints: const BoxConstraints(minHeight: 36, minWidth: 44),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: context.palette.dash),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Icon(Icons.add_reaction_outlined, size: 18, color: c.onSurfaceVariant),
              ),
            ),
          ),
      ],
    );
  }
}

Future<String?> pickReaction(BuildContext context) => showModalBottomSheet<String>(
  context: context,
  builder: (context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final e in reactionChoices)
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.pop(context, e),
              child: SizedBox(
                width: 56,
                height: 56,
                child: Center(child: Text(e, style: const TextStyle(fontSize: 30))),
              ),
            ),
        ],
      ),
    ),
  ),
);

// ------------------------------------------------------------------ comments

class _CommentsSection extends ConsumerWidget {
  const _CommentsSection({required this.cardId, required this.readOnly, required this.onOpenCard});
  final String cardId;
  final bool readOnly;
  final void Function(String) onOpenCard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comments = ref.watch(commentsProvider(cardId)).value ?? const <KComment>[];
    final names = ref.watch(peopleNamesProvider);
    final me = ref.watch(meIdProvider).value;
    final repo = ref.read(repositoryProvider);
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(comments.isEmpty ? 'Comments' : 'Comments · ${comments.length}'),
        if (comments.isEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 4),
            child: Text(readOnly ? 'No comments yet.' : 'No comments yet. Type @ to mention someone, # to link a card.', style: t.bodySmall),
          ),
        for (final cm in comments)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PersonAvatar(id: cm.userId, name: names[cm.userId] ?? '?', size: 34),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(cm.userId == me ? 'You' : (names[cm.userId] ?? 'Someone'), style: t.labelLarge),
                          Text('  ·  ${shortWhen(cm.createdAt)}${cm.editedAt != null ? ' · edited' : ''}${cm.synced ? '' : ' · sending'}', style: t.bodySmall),
                        ],
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onLongPress: readOnly || cm.userId != me
                            ? null
                            : () async {
                                final pick = await showModalBottomSheet<String>(
                                  context: context,
                                  builder: (_) => SafeArea(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          leading: const Icon(Icons.edit_outlined),
                                          title: const Text('Edit comment'),
                                          onTap: () => Navigator.pop(context, 'edit'),
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.delete_outline_rounded),
                                          title: const Text('Delete comment'),
                                          onTap: () => Navigator.pop(context, 'delete'),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                                if (!context.mounted) return;
                                if (pick == 'edit') {
                                  final n = await askText(context, title: 'Edit comment', initial: cm.body, action: 'Save');
                                  if (n != null) await repo.editComment(cm.id, n);
                                } else if (pick == 'delete') {
                                  final ok = await confirm(context, title: 'Delete this comment?', body: 'It\'s removed for everyone.', action: 'Delete');
                                  if (ok) await repo.deleteComment(cm.id);
                                }
                              },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                          decoration: BoxDecoration(
                            color: p.card,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(18),
                              bottomLeft: Radius.circular(18),
                              bottomRight: Radius.circular(18),
                            ),
                            boxShadow: p.cardShadow,
                          ),
                          child: FormattedText(cm.body, style: t.bodyMedium!.copyWith(fontSize: 15, height: 1.4), onOpenCard: onOpenCard),
                        ),
                      ),
                      const SizedBox(height: 6),
                      _Reactions(cardId: cardId, commentId: cm.id, readOnly: readOnly),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ------------------------------------------------------------------ activity

/// What happened to the card, newest last.
class _Activity extends ConsumerWidget {
  const _Activity({required this.cardId, required this.createdAt});
  final String cardId;
  final int createdAt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(eventsProvider(cardId)).value ?? const <KEvent>[];
    final names = ref.watch(peopleNamesProvider);
    final me = ref.watch(meIdProvider).value;
    final t = Theme.of(context).textTheme;
    final lines = <String>[
      for (final e in events)
        '${historyLine(e.action, (jsonDecode(e.particulars) as Map).cast<String, dynamic>(), e.userId == me ? 'You' : (names[e.userId] ?? 'Someone'))} · ${shortWhen(e.createdAt)}',
    ];
    if (lines.isEmpty) lines.add('Added ${shortWhen(createdAt)}');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle('Activity · ${lines.length}'),
        for (final l in lines.reversed.take(40))
          Padding(
            padding: const EdgeInsets.only(bottom: 6, left: 2),
            child: Text(l, style: t.bodySmall),
          ),
      ],
    );
  }
}
