import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../board/board_screen.dart' show moveWithUndo;
import '../board/lane_info.dart';
import '../data/database.dart';
import '../data/lanes.dart';
import '../data/repository.dart';
import '../state/providers.dart';
import '../theme/tokens.dart';
import '../ui/sheets.dart';

/// One card, opened. Phase 2 covers its title, notes, Priority, its column
/// and deleting it; steps, comments, people and dates come in later phases.
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
  bool _loaded = false;
  Timer? _save;
  late final KolumnRepository _repo;

  @override
  void initState() {
    super.initState();
    _repo = ref.read(repositoryProvider);
  }

  @override
  void dispose() {
    _flush();
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _changed() {
    _save?.cancel();
    _save = Timer(const Duration(milliseconds: 600), _flush);
  }

  void _flush() {
    if (_save == null) return;
    _save?.cancel();
    _save = null;
    _repo.editCard(widget.cardId, title: _title.text, description: _notes.text);
  }

  @override
  Widget build(BuildContext context) {
    final card = ref.watch(cardProvider(widget.cardId)).value;
    final columns = ref.watch(columnsProvider(widget.boardId)).value ?? const <KColumn>[];
    final cards = ref.watch(cardsProvider(widget.boardId)).value ?? const <KCard>[];
    final boards = ref.watch(boardsProvider).value ?? const <KBoard>[];
    if (card == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (!_loaded) {
      _loaded = true;
      _title.text = card.title;
      _notes.text = card.description;
    }
    final lanes = buildLanes(context, columns, cards);
    final lane = Lane.of(card, columns.map((c) => c.id).toSet());
    final info = lanes.firstWhere((l) => l.lane == lane, orElse: () => lanes[1]);
    final boardName = boards.where((b) => b.id == widget.boardId).map((b) => b.name).firstOrNull ?? '';
    final c = context.colors;
    final p = context.palette;
    final priority = card.priorityAt != null;
    final readOnly = ref.watch(readOnlyProvider).value ?? false;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('${card.synced ? '#${card.number}' : 'New card'} · $boardName', style: t.bodyMedium!.copyWith(color: c.onSurfaceVariant)),
        actions: readOnly
            ? null
            : [
                IconButton(
                  tooltip: priority ? 'Remove Priority' : 'Make Priority',
                  isSelected: priority,
                  style: IconButton.styleFrom(backgroundColor: priority ? c.primaryContainer : null),
                  onPressed: () => ref.read(repositoryProvider).setPriority(card.id, !priority),
                  icon: Icon(priority ? Icons.star_rounded : Icons.star_outline_rounded, color: priority ? c.onPrimaryContainer : null),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Card options',
                  onSelected: (v) async {
                    if (v != 'delete') return;
                    final repo = ref.read(repositoryProvider);
                    final messenger = ScaffoldMessenger.of(context);
                    _save?.cancel();
                    _save = null;
                    await repo.deleteCard(card.id);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    messenger.showSnackBar(
                      SnackBar(
                        content: const Text('Card deleted'),
                        action: SnackBarAction(label: 'Undo', onPressed: () => repo.restoreCard(card.id)),
                      ),
                    );
                  },
                  itemBuilder: (_) => const [PopupMenuItem(value: 'delete', child: Text('Delete card'))],
                ),
              ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 40),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Material(
              color: p.lane,
              shape: const StadiumBorder(),
              elevation: 0,
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
          const SizedBox(height: 18),
          Container(
            decoration: BoxDecoration(color: p.card, borderRadius: BorderRadius.circular(20), boxShadow: p.cardShadow),
            padding: const EdgeInsets.all(6),
            child: TextField(
              controller: _notes,
              readOnly: readOnly,
              onChanged: (_) => _changed(),
              minLines: 4,
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(filled: false, hintText: 'Add notes…', border: InputBorder.none, enabledBorder: InputBorder.none),
            ),
          ),
          const SizedBox(height: 18),
          Text('Added ${_date(card.createdAt)} · Last changed ${_date(card.lastActiveAt)}', style: t.bodySmall),
          const SizedBox(height: 6),
          Text('Checklists, comments, people and due dates come in the next phases.', style: t.bodySmall),
        ],
      ),
    );
  }

  static String _date(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms).toLocal();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    return '${months[d.month - 1]} ${d.day}, $h:$m ${d.hour < 12 ? 'am' : 'pm'}';
  }
}
