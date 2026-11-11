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
import '../data/lanes.dart';
import '../data/repository.dart';
import '../state/providers.dart';
import '../theme/tokens.dart';
import '../ui/bits.dart';
import '../ui/sheets.dart';
import 'composer.dart';

/// One card, opened: everything on it.
class CardScreen extends ConsumerStatefulWidget {
  const CardScreen({super.key, required this.cardId, required this.boardId});
  final String cardId;
  final String boardId;

  @override
  ConsumerState<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends ConsumerState<CardScreen> {
  final _title = TextEditingController();
  final _notes = TextEditingController();
  final _notesFocus = FocusNode();
  final _newStep = TextEditingController();
  bool _loaded = false;
  bool _editingNotes = false;
  Timer? _save;
  late final KolumnRepository _repo;

  @override
  void initState() {
    super.initState();
    _repo = ref.read(repositoryProvider);
    _notesFocus.addListener(() {
      if (!_notesFocus.hasFocus && _editingNotes) setState(() => _editingNotes = false);
    });
  }

  @override
  void dispose() {
    _flush();
    _title.dispose();
    _notes.dispose();
    _notesFocus.dispose();
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
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CardScreen(cardId: id, boardId: c.boardId),
      ),
    );
  }

  void _wrapSelection(String mark) {
    final sel = _notes.selection;
    final text = _notes.text;
    final start = sel.isValid ? sel.start : text.length;
    final end = sel.isValid ? sel.end : text.length;
    final picked = text.substring(start, end);
    final next = text.replaceRange(start, end, '$mark$picked$mark');
    _notes.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: start + mark.length + picked.length + (picked.isEmpty ? 0 : mark.length)),
    );
    _changed();
  }

  void _bulletLine() {
    final sel = _notes.selection;
    final text = _notes.text;
    final at = sel.isValid ? sel.start : text.length;
    final lineStart = at == 0 ? 0 : text.lastIndexOf('\n', at - 1) + 1;
    final next = text.replaceRange(lineStart, lineStart, '- ');
    _notes.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: at + 2),
    );
    _changed();
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

  @override
  Widget build(BuildContext context) {
    final card = ref.watch(cardProvider(widget.cardId)).value;
    final boardId = card?.boardId ?? widget.boardId;
    final columns = ref.watch(columnsProvider(boardId)).value ?? const <KColumn>[];
    final cards = ref.watch(cardsProvider(boardId)).value ?? const <KCard>[];
    final boards = ref.watch(boardsProvider).value ?? const <KBoard>[];
    if (card == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (!_loaded) {
      _loaded = true;
      _title.text = card.title;
      _notes.text = card.description;
    }
    final readOnly = ref.watch(readOnlyProvider).value ?? false;
    final lanes = buildLanes(context, columns, cards);
    final lane = Lane.of(card, columns.map((c) => c.id).toSet());
    final info = lanes.firstWhere((l) => l.lane == lane, orElse: () => lanes[1]);
    final boardName = boards.where((b) => b.id == card.boardId).map((b) => b.name).firstOrNull ?? '';
    final c = context.colors;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final priority = card.priorityAt != null;
    final pinned = (ref.watch(pinsProvider).value ?? const <KPin>[]).any((x) => x.cardId == card.id);
    final draft = card.status == 'draft';

    return Scaffold(
      appBar: AppBar(
        title: Text('${card.synced ? '#${card.number}' : 'New card'} · $boardName', style: t.bodyMedium!.copyWith(color: c.onSurfaceVariant)),
        actions: [
          IconButton(
            tooltip: pinned ? 'Unpin' : 'Pin to my shortcuts',
            onPressed: () => _repo.setPinned(card.id, !pinned),
            icon: Icon(pinned ? Icons.push_pin_rounded : Icons.push_pin_outlined, color: pinned ? p.accentText : null),
          ),
          if (!readOnly) ...[
            IconButton(
              tooltip: priority ? 'Remove Priority' : 'Make Priority',
              style: IconButton.styleFrom(backgroundColor: priority ? c.primaryContainer : null),
              onPressed: () => _repo.setPriority(card.id, !priority),
              icon: Icon(priority ? Icons.star_rounded : Icons.star_outline_rounded, color: priority ? c.onPrimaryContainer : null),
            ),
            PopupMenuButton<String>(
              tooltip: 'Card options',
              onSelected: (v) async {
                if (v == 'board') {
                  final others = boards.where((b) => b.id != card.boardId).toList();
                  final to = await pickBoard(context, others);
                  if (to == null) return;
                  _flush();
                  await _repo.moveCardToBoard(card.id, to.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Moved to ${to.name}, in To-do')));
                  }
                } else if (v == 'delete') {
                  final messenger = ScaffoldMessenger.of(context);
                  _save?.cancel();
                  _save = null;
                  await _repo.deleteCard(card.id);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  messenger.showSnackBar(
                    SnackBar(
                      content: const Text('Card deleted'),
                      action: SnackBarAction(label: 'Undo', onPressed: () => _repo.restoreCard(card.id)),
                    ),
                  );
                }
              },
              itemBuilder: (_) => [
                if (boards.length > 1) const PopupMenuItem(value: 'board', child: Text('Move to another board')),
                const PopupMenuItem(value: 'delete', child: Text('Delete card')),
              ],
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
              children: [
                if (draft)
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
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: HubPicture(fileId: card.coverId!),
                      ),
                    ),
                  ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Material(
                    color: p.lane,
                    shape: const StadiumBorder(),
                    child: InkWell(
                      customBorder: const StadiumBorder(),
                      onTap: readOnly
                          ? null
                          : () async {
                              final to = await showMoveSheet(context, lanes: lanes, current: lane, title: card.title);
                              if (to != null && context.mounted) await moveWithUndo(context, ref, card.id, to, lane, lanes);
                            },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(color: info.color, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 8),
                            Text(info.name, style: t.labelLarge),
                            const SizedBox(width: 4),
                            Icon(Icons.expand_more_rounded, size: 18, color: c.onSurfaceVariant),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _title,
                  readOnly: readOnly,
                  onChanged: (_) => _changed(),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  style: t.headlineSmall,
                  decoration: const InputDecoration(
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: 'Card title',
                  ),
                ),
                if (priority)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: c.primaryContainer, borderRadius: BorderRadius.circular(999)),
                        child: Text(
                          'Priority',
                          style: TextStyle(color: c.onPrimaryContainer, fontWeight: FontWeight.w600, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 14),
                _MetaBlock(cardId: card.id, readOnly: readOnly),
                const SizedBox(height: 18),
                _SectionTitle(
                  'Notes',
                  trailing: readOnly || _editingNotes
                      ? null
                      : TextButton(
                          onPressed: () => setState(() {
                            _editingNotes = true;
                            _notesFocus.requestFocus();
                          }),
                          child: const Text('Edit'),
                        ),
                ),
                _notesBox(readOnly),
                const SizedBox(height: 18),
                _StepsSection(cardId: card.id, readOnly: readOnly, controller: _newStep),
                const SizedBox(height: 18),
                _FilesSection(
                  cardId: card.id,
                  coverId: card.coverId,
                  readOnly: readOnly,
                  onAddPhoto: (cam) => _attach(photo: true, source: cam ? ImageSource.camera : ImageSource.gallery),
                  onAddFile: () => _attach(photo: false),
                  onOpen: _openFile,
                ),
                const SizedBox(height: 18),
                const _SectionTitle('Reactions'),
                _Reactions(cardId: card.id, commentId: null, readOnly: readOnly),
                const SizedBox(height: 18),
                _CommentsSection(cardId: card.id, readOnly: readOnly, onOpenCard: _openCard),
                const SizedBox(height: 18),
                _History(cardId: card.id, createdAt: card.createdAt),
              ],
            ),
          ),
          if (!readOnly) CommentComposer(cardId: card.id),
        ],
      ),
    );
  }

  Widget _notesBox(bool readOnly) {
    final p = context.palette;
    if (_editingNotes && !readOnly) {
      return Container(
        decoration: BoxDecoration(color: p.card, borderRadius: BorderRadius.circular(20), boxShadow: p.cardShadow),
        padding: const EdgeInsets.fromLTRB(6, 2, 6, 6),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(tooltip: 'Bold', onPressed: () => _wrapSelection('**'), icon: const Icon(Icons.format_bold_rounded)),
                IconButton(tooltip: 'Italic', onPressed: () => _wrapSelection('_'), icon: const Icon(Icons.format_italic_rounded)),
                IconButton(tooltip: 'Bullet', onPressed: _bulletLine, icon: const Icon(Icons.format_list_bulleted_rounded)),
                const Spacer(),
                TextButton(onPressed: () => _notesFocus.unfocus(), child: const Text('Done')),
              ],
            ),
            TextField(
              controller: _notes,
              focusNode: _notesFocus,
              onChanged: (_) => _changed(),
              minLines: 4,
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(filled: false, hintText: 'Add notes…', border: InputBorder.none, enabledBorder: InputBorder.none),
            ),
          ],
        ),
      );
    }
    final text = _notes.text.trim();
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: readOnly
          ? null
          : () => setState(() {
              _editingNotes = true;
              _notesFocus.requestFocus();
            }),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(color: p.card, borderRadius: BorderRadius.circular(20), boxShadow: p.cardShadow),
        padding: const EdgeInsets.all(16),
        child: text.isEmpty
            ? Text(readOnly ? 'No notes.' : 'Tap to add notes…', style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: context.colors.onSurfaceVariant))
            : FormattedText(text, onOpenCard: _openCard),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6, left: 2),
    child: Row(
      children: [
        Text(text, style: Theme.of(context).textTheme.titleSmall!.copyWith(color: context.colors.onSurfaceVariant)),
        const Spacer(),
        ?trailing,
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

// ------------------------------------------------------------------ people, tags, following

class _MetaBlock extends ConsumerWidget {
  const _MetaBlock({required this.cardId, required this.readOnly});
  final String cardId;
  final bool readOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final c = context.colors;
    final t = Theme.of(context).textTheme;
    final repo = ref.read(repositoryProvider);
    final names = ref.watch(peopleNamesProvider);
    final people = ref.watch(peopleProvider).value ?? const <KPerson>[];
    final assigned = (ref.watch(allAssigneesProvider).value ?? const <KAssignee>[]).where((a) => a.cardId == cardId).map((a) => a.userId).toList();
    final allTags = ref.watch(allTagsProvider).value ?? const <KTag>[];
    final tags = allTags.where((x) => x.cardId == cardId).map((x) => x.tag).toList()..sort();
    final watching = ref.watch(watchProvider(cardId)).value?.watching ?? false;

    Widget row(IconData icon, String label, Widget value, {VoidCallback? onTap, bool last = false}) => InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 52),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          border: last ? null : Border(bottom: BorderSide(color: c.outlineVariant.withValues(alpha: 0.5))),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: c.onSurfaceVariant),
            const SizedBox(width: 12),
            SizedBox(
              width: 80,
              child: Text(label, style: t.bodyMedium!.copyWith(color: c.onSurfaceVariant)),
            ),
            Expanded(child: value),
          ],
        ),
      ),
    );

    return Container(
      decoration: BoxDecoration(color: p.card, borderRadius: BorderRadius.circular(20), boxShadow: p.cardShadow),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: Column(
        children: [
          row(
            Icons.person_outline_rounded,
            'Assigned',
            assigned.isEmpty
                ? Text(readOnly ? 'Nobody' : 'Tap to assign', style: t.bodyMedium!.copyWith(color: c.onSurfaceVariant))
                : Wrap(
                    spacing: 10,
                    runSpacing: 6,
                    children: [
                      for (final id in assigned)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PersonAvatar(id: id, name: names[id] ?? '?', size: 24),
                            const SizedBox(width: 6),
                            Text(names[id] ?? 'Someone', style: t.bodyMedium),
                          ],
                        ),
                    ],
                  ),
            onTap: readOnly
                ? null
                : () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => _AssignSheet(cardId: cardId, people: people),
                  ),
          ),
          row(
            Icons.sell_outlined,
            'Tags',
            Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final tag in tags)
                  InputChip(label: Text(tag), visualDensity: VisualDensity.compact, onDeleted: readOnly ? null : () => repo.setTag(cardId, tag, false)),
                if (!readOnly)
                  ActionChip(
                    avatar: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Tag'),
                    visualDensity: VisualDensity.compact,
                    onPressed: () async {
                      final known = ({for (final x in allTags) x.tag}..removeAll(tags)).toList()..sort();
                      final tag = await pickTag(context, known);
                      if (tag != null) await repo.setTag(cardId, tag, true);
                    },
                  ),
                if (readOnly && tags.isEmpty) Text('None', style: t.bodyMedium!.copyWith(color: c.onSurfaceVariant)),
              ],
            ),
          ),
          row(
            Icons.visibility_outlined,
            'Following',
            Row(
              children: [
                Expanded(child: Text(watching ? 'You\'ll hear about changes' : 'Not following', style: t.bodyMedium)),
                Switch(value: watching, onChanged: (v) => repo.setWatching(cardId, v)),
              ],
            ),
            last: true,
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

// ------------------------------------------------------------------ steps

class _StepsSection extends ConsumerWidget {
  const _StepsSection({required this.cardId, required this.readOnly, required this.controller});
  final String cardId;
  final bool readOnly;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final steps = ref.watch(stepsProvider(cardId)).value ?? const <KStep>[];
    final repo = ref.read(repositoryProvider);
    final p = context.palette;
    final c = context.colors;
    final done = steps.where((s) => s.done).length;
    if (readOnly && steps.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(steps.isEmpty ? 'Steps' : 'Steps · $done of ${steps.length}'),
        Container(
          decoration: BoxDecoration(color: p.card, borderRadius: BorderRadius.circular(20), boxShadow: p.cardShadow),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Column(
            children: [
              for (final s in steps)
                Dismissible(
                  key: ValueKey(s.id),
                  direction: readOnly ? DismissDirection.none : DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(Icons.delete_outline_rounded, color: c.error),
                  ),
                  onDismissed: (_) => repo.deleteStep(s),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: readOnly ? null : () => repo.updateStep(s, done: !s.done),
                    onLongPress: readOnly
                        ? null
                        : () async {
                            final n = await askText(context, title: 'Edit step', initial: s.content, action: 'Save');
                            if (n != null) await repo.updateStep(s, content: n);
                          },
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 48),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: s.done ? c.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: s.done ? c.primary : p.dash, width: 2),
                            ),
                            child: s.done ? Icon(Icons.check_rounded, size: 16, color: c.onPrimary) : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              s.content,
                              style: TextStyle(
                                fontSize: 15,
                                decoration: s.done ? TextDecoration.lineThrough : null,
                                color: s.done ? c.onSurfaceVariant : c.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (!readOnly)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 4, 4),
                  child: Row(
                    children: [
                      Icon(Icons.add_rounded, color: p.accentText),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: controller,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(filled: false, hintText: 'Add a step', border: InputBorder.none, enabledBorder: InputBorder.none),
                          onSubmitted: (v) async {
                            if (v.trim().isEmpty) return;
                            await repo.addStep(cardId, v);
                            controller.clear();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (!readOnly && steps.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text('Tap to tick · hold to edit · swipe left to remove', style: Theme.of(context).textTheme.bodySmall),
          ),
      ],
    );
  }
}

// ------------------------------------------------------------------ files

class _FilesSection extends ConsumerWidget {
  const _FilesSection({
    required this.cardId,
    required this.coverId,
    required this.readOnly,
    required this.onAddPhoto,
    required this.onAddFile,
    required this.onOpen,
  });
  final String cardId;
  final String? coverId;
  final bool readOnly;
  final void Function(bool camera) onAddPhoto;
  final VoidCallback onAddFile;
  final void Function(KFile) onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final files = (ref.watch(filesProvider(cardId)).value ?? const <KFile>[]).where((f) => f.commentId == null).toList();
    final repo = ref.read(repositoryProvider);
    final p = context.palette;
    final c = context.colors;
    if (readOnly && files.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(files.isEmpty ? 'Photos and files' : 'Photos and files · ${files.length}'),
        if (files.isNotEmpty)
          LayoutBuilder(
            builder: (context, box) {
              final w = (box.maxWidth - 16) / 3;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final f in files)
                    GestureDetector(
                      onTap: () => onOpen(f),
                      onLongPress: readOnly
                          ? null
                          : () async {
                              final isImage = f.mime.startsWith('image/');
                              final pick = await showModalBottomSheet<String>(
                                context: context,
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
                              if (pick == 'cover') await repo.setCover(cardId, coverId == f.id ? null : f.id);
                              if (pick == 'delete') await repo.deleteFile(f);
                            },
                      child: SizedBox(
                        width: w,
                        height: w,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (f.mime.startsWith('image/'))
                                HubPicture(fileId: f.id)
                              else
                                Container(
                                  color: p.lane,
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.description_outlined, color: p.accentText, size: 30),
                                      const SizedBox(height: 6),
                                      Text(
                                        f.filename,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      Text(sizeText(f.size), style: Theme.of(context).textTheme.bodySmall),
                                    ],
                                  ),
                                ),
                              if (!f.uploaded)
                                Positioned(
                                  right: 6,
                                  top: 6,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(color: c.inverseSurface, shape: BoxShape.circle),
                                    child: Icon(Icons.cloud_upload_outlined, size: 14, color: c.onInverseSurface),
                                  ),
                                ),
                              if (coverId == f.id)
                                Positioned(
                                  left: 6,
                                  bottom: 6,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(color: c.inverseSurface, borderRadius: BorderRadius.circular(999)),
                                    child: Text('Cover', style: TextStyle(fontSize: 11, color: c.onInverseSurface)),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        if (!readOnly) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ActionChip(avatar: const Icon(Icons.photo_outlined, size: 18), label: const Text('Photo'), onPressed: () => onAddPhoto(false)),
              ActionChip(avatar: const Icon(Icons.photo_camera_outlined, size: 18), label: const Text('Camera'), onPressed: () => onAddPhoto(true)),
              ActionChip(avatar: const Icon(Icons.attach_file_rounded, size: 18), label: const Text('File'), onPressed: onAddFile),
            ],
          ),
        ],
      ],
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

// ------------------------------------------------------------------ history

class _History extends ConsumerWidget {
  const _History({required this.cardId, required this.createdAt});
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('History'),
        for (final l in lines.take(30))
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 4),
            child: Text(l, style: t.bodySmall),
          ),
      ],
    );
  }
}
