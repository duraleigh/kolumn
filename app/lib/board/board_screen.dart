import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../card/card_screen.dart';
import '../data/database.dart';
import '../data/lane_looks.dart';
import '../data/lanes.dart';
import '../find/find_screen.dart';
import '../state/providers.dart';
import '../sync/sync_service.dart';
import '../theme/tokens.dart';
import '../ui/sheets.dart';
import 'card_face.dart';
import 'lane_info.dart';

/// Widths of the board's pieces, in logical pixels.
abstract final class BoardMetrics {
  static const double strip = 44;
  static const double gap = 8;
  static const double pad = 10;
  static const double wideBreakpoint = 640;
  static const double minOpenWide = 280;
  static const double trayTargetMin = 92;
  static const double edgeZone = 32;
  static const Duration holdDelay = Duration(milliseconds: 350);
  static const Duration edgeFlip = Duration(milliseconds: 650);
}

class BoardScreen extends ConsumerWidget {
  const BoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardId = ref.watch(currentBoardIdProvider).value;
    final boards = ref.watch(boardsProvider).value ?? const <KBoard>[];
    KBoard? board;
    for (final b in boards) {
      if (b.id == boardId) board = b;
    }
    if (board == null) {
      return const _NoBoardYet();
    }
    return BoardView(key: ValueKey(board.id), board: board);
  }
}

/// Before the first boards arrive, or when someone can see none.
class _NoBoardYet extends ConsumerWidget {
  const _NoBoardYet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncStatusProvider).value;
    final readOnly = ref.watch(readOnlyProvider).value ?? false;
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    final checking = status == null || status.state == SyncState.checking;
    final noAccess = status?.state == SyncState.noAccess;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (checking) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text('Getting your Kolumns…', style: t.titleMedium),
                ] else if (noAccess) ...[
                  Icon(Icons.lock_outline_rounded, size: 40, color: c.onSurfaceVariant),
                  const SizedBox(height: 12),
                  Text('To-Dos isn\'t part of your hub access yet', textAlign: TextAlign.center, style: t.titleMedium),
                  const SizedBox(height: 6),
                  Text(
                    'A HUB Admin can add it in the hub under Team, People.',
                    textAlign: TextAlign.center,
                    style: t.bodyMedium!.copyWith(color: c.onSurfaceVariant),
                  ),
                ] else ...[
                  Text('No Kolumns yet', style: t.titleLarge),
                  const SizedBox(height: 6),
                  Text(
                    status.state == SyncState.offline ? 'Kolumn can\'t reach the hub right now.' : 'Nobody has shared a Kolumn with you yet.',
                    textAlign: TextAlign.center,
                    style: t.bodyMedium!.copyWith(color: c.onSurfaceVariant),
                  ),
                  const SizedBox(height: 18),
                  if (!readOnly)
                    FilledButton.icon(
                      onPressed: () async {
                        final n = await askText(context, title: 'New Kolumn', action: 'Create', hint: 'Kolumn name');
                        if (n == null) return;
                        final repo = ref.read(repositoryProvider);
                        final id = await repo.createBoard(n);
                        await repo.setSetting('board.current', id);
                      },
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('New Kolumn'),
                    ),
                ],
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () => ref.read(syncServiceProvider).syncNow(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Check again'),
                ),
                TextButton(onPressed: () => showSettingsSheet(context, ref), child: const Text('Settings and sign out')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BoardView extends ConsumerStatefulWidget {
  const BoardView({super.key, required this.board});
  final KBoard board;

  @override
  ConsumerState<BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends ConsumerState<BoardView> {
  final _row = ScrollController();
  final _trayKey = GlobalKey();
  Lane _open = const Lane.todo();
  Lane? _open2;
  bool _restored = false;

  String? _dragId;
  Lane? _dragFrom;
  Timer? _edgeTimer;
  int _edgeSide = 0;
  List<LaneInfo> _lanes = const [];
  bool _narrow = true;
  double _openW = 300;

  @override
  void dispose() {
    _edgeTimer?.cancel();
    _row.dispose();
    super.dispose();
  }

  String get _boardId => widget.board.id;

  void _restore(Lane? saved) {
    if (_restored) return;
    _restored = true;
    if (saved != null && saved != const Lane.todo()) {
      _open = saved;
      _open2 = saved;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _centerOpen(animate: false));
  }

  void _setOpen(Lane lane) {
    final repo = ref.read(repositoryProvider);
    setState(() {
      if (_narrow) {
        _open = lane;
      } else if (lane != const Lane.todo()) {
        _open2 = lane;
      }
    });
    repo.setSetting('open.$_boardId', lane.key);
    WidgetsBinding.instance.addPostFrameCallback((_) => _centerOpen());
  }

  void _fold() {
    setState(() => _open2 = null);
    ref.read(repositoryProvider).setSetting('open.$_boardId', 'todo');
  }

  bool _isOpen(Lane lane) => _narrow ? lane == _open : (lane == const Lane.todo() || lane == _open2);

  double _widthOf(Lane lane) => _isOpen(lane) ? _openW : BoardMetrics.strip;

  void _centerOpen({bool animate = true}) {
    if (!mounted || !_row.hasClients) return;
    if (!_narrow) {
      // On a wide screen everything fits; only nudge if a lane is off-screen.
      if (_row.position.maxScrollExtent <= 0) return;
    }
    final target = _narrow ? _open : (_open2 ?? const Lane.todo());
    var x = BoardMetrics.pad;
    for (final l in _lanes) {
      if (l.lane == target) break;
      x += _widthOf(l.lane) + BoardMetrics.gap;
    }
    final view = _row.position.viewportDimension;
    final dest = (x - (view - _widthOf(target)) / 2).clamp(0.0, _row.position.maxScrollExtent);
    if (animate) {
      _row.animateTo(dest, duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
    } else {
      _row.jumpTo(dest);
    }
  }

  // ------------------------------------------------------------- dragging

  void _dragStarted(KCard card) {
    final live = _lanes.where((l) => l.isCustom).map((l) => l.lane.columnId!).toSet();
    setState(() {
      _dragId = card.id;
      _dragFrom = Lane.of(card, live);
    });
    ref.read(repositoryProvider).setSetting('hint.drag', 'done');
  }

  void _dragUpdate(DragUpdateDetails d) {
    if (!_narrow) return;
    final size = MediaQuery.sizeOf(context);
    final trayBox = _trayKey.currentContext?.findRenderObject() as RenderBox?;
    final trayTop = trayBox == null ? size.height : trayBox.localToGlobal(Offset.zero).dy;
    var side = 0;
    if (d.globalPosition.dy < trayTop) {
      if (d.globalPosition.dx < BoardMetrics.edgeZone) side = -1;
      if (d.globalPosition.dx > size.width - BoardMetrics.edgeZone) side = 1;
    }
    if (side == _edgeSide) return;
    _edgeTimer?.cancel();
    setState(() => _edgeSide = side);
    if (side != 0) {
      _edgeTimer = Timer.periodic(BoardMetrics.edgeFlip, (_) => _flip(side));
    }
  }

  void _flip(int side) {
    final i = _lanes.indexWhere((l) => l.lane == _open);
    final j = (i + side).clamp(0, _lanes.length - 1);
    if (i < 0 || j == i) return;
    HapticFeedback.selectionClick();
    _setOpen(_lanes[j].lane);
  }

  void _dragEnded() {
    _edgeTimer?.cancel();
    if (!mounted) return;
    setState(() {
      _dragId = null;
      _dragFrom = null;
      _edgeSide = 0;
    });
  }

  Future<void> _drop(String cardId, Lane to) async {
    final from = _dragFrom;
    _dragEnded();
    if (from == to) return;
    await moveWithUndo(context, ref, cardId, to, from, _lanes);
  }

  // ------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    final columns = ref.watch(columnsProvider(_boardId)).value ?? const <KColumn>[];
    final cards = ref.watch(cardsProvider(_boardId)).value ?? const <KCard>[];
    final saved = ref.watch(openLaneProvider(_boardId));
    if (saved.hasValue) _restore(saved.value);
    final hintDone = ref.watch(_hintProvider).value ?? true;
    _lanes = buildLanes(context, columns, cards, board: widget.board);
    if (!_lanes.any((l) => l.lane == _open)) _open = const Lane.todo();
    if (_open2 != null && !_lanes.any((l) => l.lane == _open2)) _open2 = null;
    final dragging = _dragId != null;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                _TopBar(board: widget.board, lanes: _lanes),
                Expanded(child: LayoutBuilder(builder: (context, box) => _buildRow(context, box))),
              ],
            ),
            if (!hintDone && !dragging) const Positioned(left: 0, right: 0, bottom: 24, child: Center(child: _HintPill())),
            if (dragging && _narrow) ...[_EdgeTab(left: true, active: _edgeSide == -1), _EdgeTab(left: false, active: _edgeSide == 1)],
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                ignoring: !dragging,
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 260),
                  curve: dragging ? Curves.easeOutBack : Curves.easeInCubic,
                  offset: dragging ? Offset.zero : const Offset(0, 1.15),
                  child: DropTray(key: _trayKey, lanes: _lanes, from: _dragFrom, onDrop: _drop),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, BoxConstraints box) {
    _narrow = box.maxWidth < BoardMetrics.wideBreakpoint;
    final strips = _lanes.where((l) => !_isOpen(l.lane)).length;
    final opens = _lanes.length - strips;
    if (_narrow) {
      _openW = math.max(240, box.maxWidth - 2 * (BoardMetrics.strip + BoardMetrics.gap) - 2 * BoardMetrics.pad + 8);
    } else {
      final free = box.maxWidth - 2 * BoardMetrics.pad - _lanes.length * BoardMetrics.gap - (strips + 1) * BoardMetrics.strip;
      _openW = math.max(BoardMetrics.minOpenWide, free / math.max(1, opens));
    }
    final children = <Widget>[];
    for (final info in _lanes) {
      if (children.isNotEmpty) children.add(const SizedBox(width: BoardMetrics.gap));
      final open = _isOpen(info.lane);
      children.add(
        AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          width: open ? _openW : BoardMetrics.strip,
          child: open
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(KShapes.lane),
                  child: OverflowBox(
                    alignment: Alignment.topLeft,
                    minWidth: _openW,
                    maxWidth: _openW,
                    child: OpenLane(
                      info: info,
                      canFold: !_narrow && info.lane != const Lane.todo(),
                      onFold: _fold,
                      boardId: _boardId,
                      dragId: _dragId,
                      from: _dragFrom,
                      onDrop: _drop,
                      onDragStarted: _dragStarted,
                      onDragUpdate: _dragUpdate,
                      onDragEnded: _dragEnded,
                      laneCount: _lanes.length,
                      laneIndex: _lanes.indexOf(info),
                      lanes: _lanes,
                    ),
                  ),
                )
              : LaneStrip(info: info, from: _dragFrom, onTap: () => _setOpen(info.lane), onDrop: _drop),
        ),
      );
    }
    children.add(const SizedBox(width: BoardMetrics.gap));
    if (!(ref.watch(readOnlyProvider).value ?? false)) children.add(_AddColumnStrip(boardId: _boardId));
    return SingleChildScrollView(
      controller: _row,
      scrollDirection: Axis.horizontal,
      physics: _dragId != null ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(BoardMetrics.pad, 4, BoardMetrics.pad, 14),
      child: SizedBox(
        height: box.maxHeight - 18,
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
      ),
    );
  }
}

final _hintProvider = StreamProvider<bool>((ref) => ref.watch(repositoryProvider).watchSetting('hint.drag').map((v) => v == 'done'));

/// Moves a card and offers Undo. Used by the tray, the strips, the open
/// columns and the Move to list.
Future<void> moveWithUndo(BuildContext context, WidgetRef ref, String cardId, Lane to, Lane? from, List<LaneInfo> lanes) async {
  final repo = ref.read(repositoryProvider);
  await repo.moveCard(cardId, to);
  HapticFeedback.lightImpact();
  if (!context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text('Moved to ${laneName(lanes, to)}'),
      duration: const Duration(seconds: 4),
      action: from == null ? null : SnackBarAction(label: 'Undo', onPressed: () => repo.moveCard(cardId, from)),
    ),
  );
}

// ------------------------------------------------------------------ top bar

class _TopBar extends ConsumerWidget {
  const _TopBar({required this.board, required this.lanes});
  final KBoard board;
  final List<LaneInfo> lanes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 6, 8),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: c.primary,
              borderRadius: BorderRadius.circular(11),
              boxShadow: [BoxShadow(color: c.primary.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            alignment: Alignment.center,
            child: Text(
              'K',
              style: TextStyle(color: c.onPrimary, fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => showBoardsSheet(context, ref),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(board.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleLarge),
                        ),
                        Icon(Icons.expand_more_rounded, color: c.onSurfaceVariant),
                      ],
                    ),
                    Text(_statusLine(ref), maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Find cards',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const FindScreen())),
            icon: const Icon(Icons.search_rounded),
          ),
          _PinsButton(),
          _RefreshButton(),
          IconButton(tooltip: 'Settings', onPressed: () => showSettingsSheet(context, ref), icon: const Icon(Icons.tune_rounded)),
        ],
      ),
    );
  }
}

String _statusLine(WidgetRef ref) {
  final s = ref.watch(syncStatusProvider).value;
  final pending = ref.watch(pendingCountProvider).value ?? 0;
  final readOnly = ref.watch(readOnlyProvider).value ?? false;
  final view = readOnly ? 'View only · ' : '';
  String ago(DateTime? t) {
    if (t == null) return '';
    final m = DateTime.now().difference(t).inMinutes;
    return m < 1 ? 'just now' : (m == 1 ? '1 min ago' : '$m min ago');
  }

  switch (s?.state) {
    case SyncState.checking:
      return '${view}Checking for changes…';
    case SyncState.offline:
      return pending > 0
          ? '${view}Offline · $pending ${pending == 1 ? 'change' : 'changes'} waiting to send'
          : '${view}Offline · showing what\'s on this phone';
    case SyncState.noAccess:
      return 'To-Dos isn\'t part of your hub access';
    case SyncState.upToDate:
      return pending > 0 ? '${view}Sending $pending ${pending == 1 ? 'change' : 'changes'}…' : '${view}Up to date · ${ago(s?.lastSynced)}';
    default:
      return view.isEmpty ? 'Saved on this phone' : 'View only';
  }
}

class _PinsButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = (ref.watch(pinsProvider).value ?? const <KPin>[]).length;
    return IconButton(
      tooltip: 'Pinned cards',
      onPressed: () => showPinsSheet(
        context,
        (card) => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => CardScreen(cardId: card.id, boardId: card.boardId),
          ),
        ),
      ),
      icon: Badge(isLabelVisible: n > 0, label: Text('$n'), child: const Icon(Icons.push_pin_outlined)),
    );
  }
}

class _RefreshButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checking = ref.watch(syncStatusProvider).value?.state == SyncState.checking;
    return IconButton(
      tooltip: 'Check for changes now',
      onPressed: checking ? null : () => ref.read(syncServiceProvider).syncNow(),
      icon: AnimatedRotation(turns: checking ? 1 : 0, duration: const Duration(milliseconds: 900), child: const Icon(Icons.refresh_rounded)),
    );
  }
}

// ------------------------------------------------------------------ strips

class LaneStrip extends StatelessWidget {
  const LaneStrip({super.key, required this.info, required this.from, required this.onTap, required this.onDrop});
  final LaneInfo info;
  final Lane? from;
  final VoidCallback onTap;
  final void Function(String cardId, Lane to) onDrop;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final count = info.cards.length;
    return DragTarget<String>(
      onWillAcceptWithDetails: (_) => from != info.lane,
      onAcceptWithDetails: (d) => onDrop(d.data, info.lane),
      builder: (context, candidates, _) {
        final over = candidates.isNotEmpty;
        final fg = over ? Colors.white : info.color;
        return AnimatedScale(
          scale: over ? 1.06 : 1,
          duration: const Duration(milliseconds: 140),
          child: Semantics(
            button: true,
            label: 'Open ${info.name}, $count ${count == 1 ? 'card' : 'cards'}',
            child: Material(
              color: over ? info.color : p.lane,
              borderRadius: BorderRadius.circular(18),
              elevation: over ? 6 : 0,
              shadowColor: info.color.withValues(alpha: 0.5),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    children: [
                      Text(
                        '$count',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: fg),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: 4,
                        height: math.min(count, 15) * 5.0 + 6,
                        decoration: BoxDecoration(color: fg.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(2)),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: RotatedBox(
                          quarterTurns: 1,
                          child: Text(
                            info.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelLarge!.copyWith(color: over ? Colors.white : null, fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AddColumnStrip extends ConsumerWidget {
  const _AddColumnStrip({required this.boardId});
  final String boardId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    return SizedBox(
      width: BoardMetrics.strip,
      child: Align(
        alignment: Alignment.topCenter,
        child: Tooltip(
          message: 'Add a kolumn',
          child: Material(
            color: p.lane,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => showColumnEditor(context, ref, boardId: boardId),
              child: SizedBox(
                width: BoardMetrics.strip,
                height: 52,
                child: Icon(Icons.add_rounded, color: context.colors.primary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ open lane

class OpenLane extends ConsumerWidget {
  const OpenLane({
    super.key,
    required this.info,
    required this.canFold,
    required this.onFold,
    required this.boardId,
    required this.dragId,
    required this.from,
    required this.onDrop,
    required this.onDragStarted,
    required this.onDragUpdate,
    required this.onDragEnded,
    required this.laneCount,
    required this.laneIndex,
    required this.lanes,
  });

  final LaneInfo info;
  final bool canFold;
  final VoidCallback onFold;
  final String boardId;
  final String? dragId;
  final Lane? from;
  final void Function(String cardId, Lane to) onDrop;
  final void Function(KCard) onDragStarted;
  final void Function(DragUpdateDetails) onDragUpdate;
  final VoidCallback onDragEnded;
  final int laneCount;
  final int laneIndex;
  final List<LaneInfo> lanes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final isTodo = info.lane == const Lane.todo();
    final readOnly = ref.watch(readOnlyProvider).value ?? false;
    return DragTarget<String>(
      onWillAcceptWithDetails: (_) => from != info.lane,
      onAcceptWithDetails: (d) => onDrop(d.data, info.lane),
      builder: (context, candidates, _) {
        final over = candidates.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            color: isTodo || !info.isCustom ? p.todoLane : Color.alphaBlend(info.color.withValues(alpha: 0.07), p.lane),
            borderRadius: BorderRadius.circular(KShapes.lane),
            border: Border.all(color: over ? info.color : Colors.transparent, width: 3),
            boxShadow: over ? [BoxShadow(color: info.color.withValues(alpha: 0.25), blurRadius: 24, offset: const Offset(0, 10))] : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _LaneHeader(info: info, canFold: canFold, onFold: onFold, boardId: boardId, laneIndex: laneIndex, laneCount: laneCount),
              if (isTodo && !readOnly)
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: _AddCardButton(onTap: () => showNewCardSheet(context, ref, boardId)),
                ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => ref.read(syncServiceProvider).syncNow(),
                  child: info.cards.isEmpty
                      ? ListView(
                          padding: const EdgeInsets.all(24),
                          children: [
                            Text(
                              readOnly ? 'Nothing here.' : (isTodo ? 'Nothing to do yet. Add a card.' : 'Nothing here. Drag a card in.'),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: context.colors.onSurfaceVariant),
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(10, 2, 10, 120),
                          itemCount: info.cards.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, i) => DraggableCard(
                            card: info.cards[i],
                            enabled: !readOnly,
                            dragging: dragId == info.cards[i].id,
                            onDragStarted: onDragStarted,
                            onDragUpdate: onDragUpdate,
                            onDragEnded: onDragEnded,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => CardScreen(cardId: info.cards[i].id, boardId: boardId),
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LaneHeader extends ConsumerWidget {
  const _LaneHeader({required this.info, required this.canFold, required this.onFold, required this.boardId, required this.laneIndex, required this.laneCount});
  final LaneInfo info;
  final bool canFold;
  final VoidCallback onFold;
  final String boardId;
  final int laneIndex;
  final int laneCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final col = info.column;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 4, 6),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: info.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(info.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.titleMedium),
          ),
          const SizedBox(width: 6),
          Text('${info.cards.length}', style: t.bodyMedium!.copyWith(color: context.colors.onSurfaceVariant)),
          const Spacer(),
          if (info.isTodoLane) _DraftsChip(boardId: boardId),
          if (canFold) IconButton(tooltip: 'Fold this kolumn', onPressed: onFold, icon: const Icon(Icons.unfold_less_rounded, size: 20)),
          if (col == null && !(ref.watch(readOnlyProvider).value ?? false))
            IconButton(
              tooltip: 'Rename or recolor this kolumn',
              onPressed: () => showColumnEditor(context, ref, boardId: boardId, builtIn: info.lane.kind, builtInName: info.name),
              icon: const Icon(Icons.more_horiz_rounded),
            )
          else if (col != null && !(ref.watch(readOnlyProvider).value ?? false))
            PopupMenuButton<String>(
              tooltip: 'Options for this kolumn',
              icon: const Icon(Icons.more_horiz_rounded),
              onSelected: (v) async {
                final repo = ref.read(repositoryProvider);
                switch (v) {
                  case 'edit':
                    await showColumnEditor(context, ref, boardId: boardId, column: col);
                  case 'left':
                    await repo.moveColumn(boardId, col.id, -1);
                  case 'right':
                    await repo.moveColumn(boardId, col.id, 1);
                  case 'delete':
                    final ok = await confirm(
                      context,
                      title: 'Delete "${col.name}"?',
                      body: 'Its ${info.cards.length == 1 ? 'card goes' : 'cards go'} back to ${laneLook(ref.read(boardsProvider).value?.where((b) => b.id == boardId).firstOrNull, 'todo').name}. Nothing else is deleted.',
                      action: 'Delete kolumn',
                    );
                    if (ok) await repo.deleteColumn(col.id);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Rename or recolor')),
                const PopupMenuItem(value: 'left', child: Text('Move left')),
                const PopupMenuItem(value: 'right', child: Text('Move right')),
                const PopupMenuItem(value: 'delete', child: Text('Delete kolumn')),
              ],
            )
          else
            const SizedBox(width: 8, height: 44),
        ],
      ),
    );
  }
}

class _DraftsChip extends ConsumerWidget {
  const _DraftsChip({required this.boardId});
  final String boardId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(meIdProvider).value;
    final n = (ref.watch(cardsProvider(boardId)).value ?? const <KCard>[])
        .where((c) => c.status == 'draft' && (me == null || c.creatorId == null || c.creatorId == me))
        .length;
    if (n == 0) return const SizedBox.shrink();
    return TextButton.icon(
      onPressed: () => showDraftsSheet(
        context,
        boardId,
        (card) => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => CardScreen(cardId: card.id, boardId: card.boardId),
          ),
        ),
      ),
      icon: const Icon(Icons.edit_note_rounded, size: 18),
      label: Text('Drafts $n'),
    );
  }
}

class _AddCardButton extends StatelessWidget {
  const _AddCardButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KShapes.lg),
        side: BorderSide(color: p.dash, width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(KShapes.lg),
        onTap: onTap,
        child: SizedBox(
          height: 46,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_rounded, size: 20, color: p.accentText),
              const SizedBox(width: 6),
              Text(
                'Add a card',
                style: TextStyle(color: p.accentText, fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A card you can hold and drag. Holding for [BoardMetrics.holdDelay] lifts
/// it (with a buzz) and brings up the drop tray; moving your finger before
/// then scrolls the list instead.
class DraggableCard extends StatelessWidget {
  const DraggableCard({
    super.key,
    required this.card,
    this.enabled = true,
    required this.dragging,
    required this.onDragStarted,
    required this.onDragUpdate,
    required this.onDragEnded,
    required this.onTap,
  });

  final KCard card;
  final bool enabled;
  final bool dragging;
  final void Function(KCard) onDragStarted;
  final void Function(DragUpdateDetails) onDragUpdate;
  final VoidCallback onDragEnded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    if (!enabled) return CardFace(card: card, onTap: onTap);
    return LayoutBuilder(
      builder: (context, box) {
        return LongPressDraggable<String>(
          data: card.id,
          delay: BoardMetrics.holdDelay,
          hapticFeedbackOnStart: true,
          onDragStarted: () => onDragStarted(card),
          onDragUpdate: onDragUpdate,
          onDragEnd: (_) => onDragEnded(),
          onDraggableCanceled: (_, _) => onDragEnded(),
          feedback: Material(
            type: MaterialType.transparency,
            child: SizedBox(
              width: box.maxWidth,
              child: Transform.rotate(
                angle: -0.05,
                child: Transform.scale(scale: 1.04, child: CardFace(card: card, lifted: true)),
              ),
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.45,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(KShapes.card),
                border: Border.all(color: p.dash, width: 2),
              ),
              child: Opacity(opacity: 0.4, child: CardFace(card: card)),
            ),
          ),
          child: CardFace(card: card, onTap: onTap),
        );
      },
    );
  }
}

// ------------------------------------------------------------------ the tray

/// The drop tray: one big target per lane, wrapping onto as many rows as the
/// phone's width needs. Every target is at least 60 tall.
class DropTray extends StatelessWidget {
  const DropTray({super.key, required this.lanes, required this.from, required this.onDrop});
  final List<LaneInfo> lanes;
  final Lane? from;
  final void Function(String cardId, Lane to) onDrop;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(KShapes.sheet)),
        boxShadow: p.trayShadow,
      ),
      padding: EdgeInsets.fromLTRB(16, 10, 16, 16 + MediaQuery.paddingOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: p.dash, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text('Drop on a kolumn', style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: context.colors.onSurfaceVariant)),
          ),
          LayoutBuilder(
            builder: (context, box) {
              const gap = 8.0;
              final perRow = math.max(2, ((box.maxWidth + gap) / (BoardMetrics.trayTargetMin + gap)).floor());
              final w = (box.maxWidth - (perRow - 1) * gap) / perRow;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final l in lanes)
                    SizedBox(
                      width: w,
                      child: _TrayTarget(info: l, here: from == l.lane, onDrop: onDrop),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TrayTarget extends StatelessWidget {
  const _TrayTarget({required this.info, required this.here, required this.onDrop});
  final LaneInfo info;
  final bool here;
  final void Function(String cardId, Lane to) onDrop;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final rest = dark ? Colors.white.withValues(alpha: 0.05) : Color.alphaBlend(info.color.withValues(alpha: 0.10), Colors.white);
    final count = info.cards.length;
    return DragTarget<String>(
      onWillAcceptWithDetails: (_) => !here,
      onAcceptWithDetails: (d) => onDrop(d.data, info.lane),
      builder: (context, candidates, _) {
        final over = candidates.isNotEmpty;
        final sub = here ? 'here now' : (over ? 'release to drop' : '$count ${count == 1 ? 'card' : 'cards'}');
        return AnimatedScale(
          scale: over ? 1.07 : 1,
          duration: const Duration(milliseconds: 120),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            constraints: const BoxConstraints(minHeight: 60),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(
              color: over ? info.color : (here ? Colors.transparent : rest),
              borderRadius: BorderRadius.circular(KShapes.card),
              border: Border.all(color: here ? p.dash : (over ? info.color : Colors.transparent), width: 2),
              boxShadow: over ? [BoxShadow(color: info.color.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 8))] : null,
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  info.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, height: 1.15, color: over ? Colors.white : context.colors.onSurface),
                ),
                const SizedBox(height: 3),
                Text(sub, style: TextStyle(fontSize: 12, color: over ? Colors.white.withValues(alpha: 0.9) : context.colors.onSurfaceVariant)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EdgeTab extends StatelessWidget {
  const _EdgeTab({required this.left, required this.active});
  final bool left;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Positioned(
      left: left ? 0 : null,
      right: left ? null : 0,
      top: MediaQuery.sizeOf(context).height * 0.32,
      child: IgnorePointer(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: active ? 1 : 0.7,
          child: Container(
            width: 26,
            height: 120,
            decoration: BoxDecoration(
              color: c.primaryContainer,
              borderRadius: BorderRadius.horizontal(
                left: left ? Radius.zero : const Radius.circular(16),
                right: left ? const Radius.circular(16) : Radius.zero,
              ),
            ),
            child: Icon(left ? Icons.chevron_left_rounded : Icons.chevron_right_rounded, color: c.onPrimaryContainer),
          ),
        ),
      ),
    );
  }
}

class _HintPill extends StatelessWidget {
  const _HintPill();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return IgnorePointer(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: c.inverseSurface,
          borderRadius: BorderRadius.circular(999),
          boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 6))],
        ),
        child: Text('Hold a card to move it', style: TextStyle(color: c.onInverseSurface, fontSize: 14)),
      ),
    );
  }
}
