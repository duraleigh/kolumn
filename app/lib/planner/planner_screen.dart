import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart' show setEquals;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../card/card_screen.dart';
import '../data/database.dart';
import '../data/due.dart';
import '../data/lanes.dart';
import '../data/repository.dart';
import '../state/providers.dart';
import '../theme/tokens.dart';
import 'days.dart';
import 'planner_model.dart';
import 'planner_sheets.dart';
import 'todo_sheet.dart';
import '../ui/item_sheet.dart';

enum PlannerView { week, month, day }

/// Widths and sizes, in logical pixels.
abstract final class PlannerMetrics {
  static const double wide = 840;
  static const double rowPhone = 50;
  static const double rowWide = 38;
  static const Duration holdDelay = Duration(milliseconds: 350);
  static const Duration edgeFlip = Duration(milliseconds: 650);
}

/// The Planner: Tweek's paper-planner week (and month and day), drawn in
/// Kolumn's colors. Each day is ruled lines with one to-do per line; tap an
/// empty line to write one, tick the circle to finish it, hold and drag it to
/// another day.
class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({super.key});

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen> {
  PlannerView _view = PlannerView.week;
  late String _anchor = ref.read(plannerTodayProvider);
  bool _searching = false;
  final _search = TextEditingController();
  final _scroll = ScrollController();

  String? _adding;
  final _draft = TextEditingController();
  final _draftFocus = FocusNode();

  bool _dragging = false;
  int _scrollDir = 0;
  Timer? _scrollTimer;
  Timer? _flipTimer;

  // Late items stay in sight (his rule, 2026-11-13): each late row on screen
  // is tracked, and any not in view is pinned at the top.
  final _bodyKey = GlobalKey();
  final Map<String, GlobalKey> _lateKeys = {};
  Set<String> _lateInView = {};
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    // Something can go late while the screen is open: look again each minute.
    _tick = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
    _draftFocus.addListener(() {
      final slot = _adding;
      if (_draftFocus.hasFocus || slot == null) return;
      // Leaving the line saves what was typed, unless the writing just moved
      // to another line (the field there takes the focus a moment later).
      Future.delayed(const Duration(milliseconds: 180), () {
        if (mounted && !_draftFocus.hasFocus && _adding == slot) _commitDraft(keepGoing: false);
      });
    });
  }

  /// The rows of late items that are fully on screen right now.
  void _checkLate() {
    if (!mounted) return;
    final box = _bodyKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached || !box.hasSize) return;
    final top = box.localToGlobal(Offset.zero).dy;
    final bottom = top + box.size.height;
    final seen = <String>{};
    _lateKeys.forEach((id, k) {
      final rb = k.currentContext?.findRenderObject() as RenderBox?;
      if (rb == null || !rb.attached || !rb.hasSize) return;
      final y = rb.localToGlobal(Offset.zero).dy;
      if (y >= top - 0.5 && y + rb.size.height <= bottom + 0.5) seen.add(id);
    });
    if (!setEquals(seen, _lateInView)) setState(() => _lateInView = seen);
  }

  @override
  void dispose() {
    _tick?.cancel();
    _search.dispose();
    _scroll.dispose();
    _draft.dispose();
    _draftFocus.dispose();
    _scrollTimer?.cancel();
    _flipTimer?.cancel();
    super.dispose();
  }

  // ------------------------------------------------------------- moving through time

  void _step(int dir) {
    setState(() {
      switch (_view) {
        case PlannerView.week:
          _anchor = addDays(_anchor, 7 * dir);
        case PlannerView.day:
          _anchor = addDays(_anchor, dir);
        case PlannerView.month:
          final d = parseDay(_anchor);
          _anchor = dayKey(DateTime(d.year, d.month + dir, 1));
      }
    });
  }

  void _goToday() => setState(() => _anchor = ref.read(plannerTodayProvider));

  String _title(bool wide) {
    final a = parseDay(_view == PlannerView.week ? mondayOf(_anchor) : _anchor);
    switch (_view) {
      case PlannerView.day:
        // The day's name, bold, like the month in the other views (his ask, 2026-11-13).
        return weekdayLong[parseDay(_anchor).weekday - 1];
      case PlannerView.week:
      case PlannerView.month:
        return '${wide ? monthLong[a.month - 1] : monthShort[a.month - 1]} ${a.year}';
    }
  }

  // ------------------------------------------------------------- writing on a line

  void _startAdding(String slotKey) {
    if (_adding != null && _adding != slotKey) _commitDraft(keepGoing: false);
    setState(() {
      _adding = slotKey;
      _draft.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _draftFocus.requestFocus());
  }

  Future<void> _commitDraft({required bool keepGoing}) async {
    final slotKey = _adding;
    final text = _draft.text.trim();
    final plannerId = ref.read(currentPlannerIdProvider).value;
    if (!keepGoing) setState(() => _adding = null);
    _draft.clear();
    if (slotKey == null || text.isEmpty || plannerId == null) return;
    final slot = TodoSlot.fromKey(slotKey);
    if (slot == null) return;
    await ref.read(repositoryProvider).addTodo(plannerId, slot, text);
    if (keepGoing) _draftFocus.requestFocus();
  }

  // ------------------------------------------------------------- ticking, opening, moving

  Future<void> _toggle(PlannerEntry e) async {
    HapticFeedback.selectionClick();
    final repo = ref.read(repositoryProvider);
    if (e.isCard) {
      // Ticking a card finishes it: it goes to Done on its Kolumn.
      await repo.moveCard(e.card!.id, e.done ? const Lane.todo() : const Lane.done());
    } else {
      await repo.setTodoDone(e.todo!, !e.done, day: e.day);
    }
  }

  void _open(PlannerEntry e) {
    if (e.isCard) {
      showCardSheet(context, e.card!.id);
    } else {
      showTodoSheet(context, ref, todoId: e.todo!.id, day: e.day);
    }
  }

  /// His moving rules, the same for dragging and "Move to a different date":
  /// an unfinished to-do never to a past day nor past its due day; a finished
  /// one never to a future day; only unfinished ones to Someday. Cards keep
  /// to days. A drop anywhere else flies back.
  bool _canDrop(PlannerEntry e, String toKey) {
    if (ref.read(readOnlyProvider).value ?? false) return false;
    final to = TodoSlot.fromKey(toKey);
    if (to == null) return false;
    if (e.isCard) return to.day != null;
    final today = ref.read(plannerTodayProvider);
    final t = e.todo!;
    // One day of a repeating to-do is finished or not on its own.
    final probe = e.repeats ? t.copyWith(doneAt: Value(e.done ? 1 : null)) : t;
    return canMoveTodo(probe, to, today: today);
  }

  Future<void> _move(PlannerEntry e, String toKey) async {
    if (e.slotKey == toKey) return;
    if (!_canDrop(e, toKey)) return;
    final repo = ref.read(repositoryProvider);
    final to = TodoSlot.fromKey(toKey);
    if (to == null) return;
    HapticFeedback.mediumImpact();
    if (e.isCard) {
      if (to.day == null) return;
      final c = e.card!;
      if (c.dueAt != null && c.dueHasTime) {
        // Same time of day, on the new day.
        final t = DateTime.fromMillisecondsSinceEpoch(c.dueAt!);
        final d = parseDay(to.day!);
        await repo.setCardDueAt(c.id, DateTime(d.year, d.month, d.day, t.hour, t.minute).millisecondsSinceEpoch, hasTime: true);
      } else {
        await repo.setCardDue(c.id, to.day);
      }
      return;
    }
    final t = e.todo!;
    if (e.repeats && e.day != null) {
      // One day of a repeating to-do: that day moves on its own; the rest repeat as before.
      await repo.skipTodoDay(t, e.day!);
      final copy = await repo.addTodo(t.plannerId, to, t.title);
      if (t.note.isNotEmpty) await repo.updateTodo(copy, note: t.note);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Moved that day only. The other days still repeat.')));
      }
      return;
    }
    await repo.updateTodo(t.id, slot: to);
  }

  void _dragStart() {
    HapticFeedback.mediumImpact();
    setState(() => _dragging = true);
  }

  void _dragEnd() {
    _scrollTimer?.cancel();
    _flipTimer?.cancel();
    _scrollDir = 0;
    if (mounted) setState(() => _dragging = false);
  }

  /// Near the top or bottom while dragging, the page scrolls.
  void _dragUpdate(DragUpdateDetails d) {
    final h = MediaQuery.sizeOf(context).height;
    final dir = d.globalPosition.dy < 170 ? -1 : (d.globalPosition.dy > h - 150 ? 1 : 0);
    if (dir == _scrollDir) return;
    _scrollDir = dir;
    _scrollTimer?.cancel();
    if (dir == 0) return;
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!_scroll.hasClients) return;
      final p = _scroll.position;
      _scroll.jumpTo((p.pixels + 9 * _scrollDir).clamp(p.minScrollExtent, p.maxScrollExtent));
    });
  }

  /// Held at the left or right edge while dragging: the week (or day) turns.
  void _edgeEnter(int dir) {
    _flipTimer?.cancel();
    _flipTimer = Timer.periodic(PlannerMetrics.edgeFlip, (_) {
      HapticFeedback.selectionClick();
      _step(dir);
    });
  }

  void _edgeLeave() => _flipTimer?.cancel();

  // ------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    final plannerId = ref.watch(currentPlannerIdProvider).value;
    final planners = ref.watch(plannersProvider).value;
    final data = plannerId == null ? null : ref.watch(plannerDataProvider(plannerId));
    final wide = MediaQuery.sizeOf(context).width >= PlannerMetrics.wide;
    final readOnly = ref.watch(readOnlyProvider).value ?? false;

    if (data == null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: planners == null
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('No planner yet', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 14),
                      if (!readOnly)
                        FilledButton.icon(
                          onPressed: () async {
                            final repo = ref.read(repositoryProvider);
                            final id = await repo.ensureStarterPlanner();
                            await repo.setSetting('planner.current', id);
                          },
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Make my planner'),
                        ),
                    ],
                  ),
          ),
        ),
      );
    }

    final ctx = _Ctx(
      data: data,
      wide: wide,
      readOnly: readOnly,
      reminders: ref.watch(reminderMapProvider),
      boardOrder: [for (final b in ref.watch(boardsProvider).value ?? const <KBoard>[]) b.id],
      adding: _adding,
      draft: _draft,
      draftFocus: _draftFocus,
      onAdd: _startAdding,
      onSubmit: () => _commitDraft(keepGoing: true),
      onToggle: _toggle,
      onOpen: _open,
      onMove: _move,
      onDragStart: _dragStart,
      onDragEnd: _dragEnd,
      onDragUpdate: _dragUpdate,
      canDrop: _canDrop,
      lateKey: (id) => _lateKeys.putIfAbsent(id, () => GlobalKey()),
    );
    // Keys only for rows that are late now.
    _lateKeys.removeWhere((id, _) => !data.lateItems.any((e) => e.id == id));
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkLate());

    Widget body;
    if (_searching) {
      body = _SearchResults(ctx: ctx, query: _search.text);
    } else {
      switch (_view) {
        case PlannerView.week:
          body = wide ? _WideWeek(ctx: ctx, monday: mondayOf(_anchor), scroll: _scroll) : _PhoneWeek(ctx: ctx, monday: mondayOf(_anchor), scroll: _scroll);
        case PlannerView.day:
          body = _DayPage(ctx: ctx, day: _anchor, scroll: _scroll);
        case PlannerView.month:
          body = _Month(
            ctx: ctx,
            first: _anchor,
            onPick: (day) => setState(() {
              _anchor = day;
              _view = PlannerView.day;
            }),
          );
      }
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                _searching
                    ? _SearchBar(
                        controller: _search,
                        onChanged: (_) => setState(() {}),
                        onClose: () => setState(() {
                          _searching = false;
                          _search.clear();
                        }),
                      )
                    : _Header(
                        title: _title(wide),
                        sub: _view == PlannerView.day ? dayLabel(_anchor, today: ref.read(plannerTodayProvider)) : null,
                        wide: wide,
                        planner: data.planner,
                        onTitle: _goToday,
                        onPrev: () => _step(-1),
                        onNext: () => _step(1),
                        onSearch: () => setState(() => _searching = true),
                        prevLabel: _view == PlannerView.day ? 'Previous day' : (_view == PlannerView.month ? 'Previous month' : 'Previous week'),
                        nextLabel: _view == PlannerView.day ? 'Next day' : (_view == PlannerView.month ? 'Next month' : 'Next week'),
                      ),
                if (!_searching && _view != PlannerView.month)
                  _LateStack(ctx: ctx, items: [for (final e in data.lateItems) if (!_lateInView.contains(e.id)) e]),
                Expanded(
                  key: _bodyKey,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (_) {
                      WidgetsBinding.instance.addPostFrameCallback((_) => _checkLate());
                      return false;
                    },
                    // On a phone, swipe left or right for the next or previous
                    // month, week or day (his ask, 2026-11-13).
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onHorizontalDragEnd: wide || _searching || _dragging
                          ? null
                          : (d) {
                              final v = d.primaryVelocity ?? 0;
                              if (v.abs() < 250) return;
                              HapticFeedback.selectionClick();
                              _step(v < 0 ? 1 : -1);
                            },
                      child: RefreshIndicator(onRefresh: () => ref.read(syncServiceProvider).syncNow(), child: body),
                    ),
                  ),
                ),
              ],
            ),
            if (!_searching)
              Positioned(
                left: 0,
                right: 0,
                bottom: 14,
                child: Center(
                  child: _ViewSwitch(
                    view: _view,
                    onPick: (v) => setState(() {
                      if (v == PlannerView.month) {
                        final d = parseDay(_anchor);
                        _anchor = dayKey(DateTime(d.year, d.month, 1));
                      } else if (_view == PlannerView.month) {
                        final t = ref.read(plannerTodayProvider);
                        _anchor = t.substring(0, 7) == _anchor.substring(0, 7) ? t : _anchor;
                      }
                      _view = v;
                    }),
                  ),
                ),
              ),
            if (_dragging && _view != PlannerView.month) ...[
              _EdgeFlip(left: true, onEnter: () => _edgeEnter(-1), onLeave: _edgeLeave),
              _EdgeFlip(left: false, onEnter: () => _edgeEnter(1), onLeave: _edgeLeave),
            ],
          ],
        ),
      ),
    );
  }
}

/// What every piece of the Planner needs to draw itself and act.
class _Ctx {
  _Ctx({
    required this.data,
    required this.wide,
    required this.readOnly,
    required this.reminders,
    required this.boardOrder,
    required this.adding,
    required this.draft,
    required this.draftFocus,
    required this.onAdd,
    required this.onSubmit,
    required this.onToggle,
    required this.onOpen,
    required this.onMove,
    required this.onDragStart,
    required this.onDragEnd,
    required this.onDragUpdate,
    required this.canDrop,
    required this.lateKey,
  });

  final PlannerData data;
  final bool wide;
  final bool readOnly;
  final Map<String, int> reminders;
  final List<String> boardOrder;
  final String? adding;
  final TextEditingController draft;
  final FocusNode draftFocus;
  final void Function(String slotKey) onAdd;
  final VoidCallback onSubmit;
  final void Function(PlannerEntry) onToggle;
  final void Function(PlannerEntry) onOpen;
  final Future<void> Function(PlannerEntry, String) onMove;
  final VoidCallback onDragStart;
  final VoidCallback onDragEnd;
  final void Function(DragUpdateDetails) onDragUpdate;
  final bool Function(PlannerEntry, String) canDrop;
  final GlobalKey Function(String entryId) lateKey;

  double get row => wide ? PlannerMetrics.rowWide : PlannerMetrics.rowPhone;
  double get font => wide ? 14 : 16;
  String get today => data.today;

  Color boardColor(BuildContext context, String boardId) {
    final i = boardOrder.indexOf(boardId);
    final lc = LaneColors.at(i < 0 ? 0 : i % LaneColors.all.length);
    return Theme.of(context).brightness == Brightness.dark ? lc.dark : lc.light;
  }
}

// ------------------------------------------------------------------ header

class _Header extends ConsumerWidget {
  const _Header({
    required this.title,
    required this.sub,
    required this.wide,
    required this.planner,
    required this.onTitle,
    required this.onPrev,
    required this.onNext,
    required this.onSearch,
    required this.prevLabel,
    required this.nextLabel,
  });

  final String title;
  final String? sub;
  final bool wide;
  final KPlanner planner;
  final VoidCallback onTitle;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onSearch;
  final String prevLabel;
  final String nextLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    Widget round(IconData icon, String label, VoidCallback onTap) => Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Tooltip(
        message: label,
        child: Material(
          color: c.onSurface,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(width: 42, height: 42, child: Icon(icon, color: c.surface, size: 22)),
          ),
        ),
      ),
    );
    final plannerChip = Material(
      color: context.palette.chip,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: () => showPlannersSheet(context, ref),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: wide ? 40 : 34, maxWidth: wide ? 260 : 220),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_today_outlined, size: wide ? 16 : 14, color: c.onSurface),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    planner.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: wide ? 14 : 13, fontWeight: FontWeight.w600, color: c.onSurface),
                  ),
                ),
                Icon(Icons.expand_more_rounded, size: 18, color: c.onSurface),
              ],
            ),
          ),
        ),
      ),
    );
    final titleRow = Tooltip(
      message: 'Go to today',
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTitle,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: wide ? 40 : 34, fontWeight: FontWeight.w700, letterSpacing: -0.8, height: 1.1, color: c.onSurface),
              ),
            ),
            if (sub != null) ...[
              const SizedBox(width: 10),
              Flexible(
                child: Text(sub!, maxLines: 1, overflow: TextOverflow.fade, softWrap: false, style: TextStyle(fontSize: 17, color: c.onSurfaceVariant)),
              ),
            ],
          ],
        ),
      ),
    );
    if (!wide) {
      // A phone (his choice, option A): the planner and search on a small first
      // line; the big title alone on the second; no arrows (swipe instead).
      return Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 8, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Flexible(child: Align(alignment: Alignment.centerLeft, child: plannerChip)),
                const Spacer(),
                IconButton(tooltip: 'Search', onPressed: onSearch, icon: const Icon(Icons.search_rounded)),
              ],
            ),
            const SizedBox(height: 4),
            Padding(padding: const EdgeInsets.only(right: 10), child: titleRow),
          ],
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(wide ? 28 : 18, wide ? 22 : 14, wide ? 22 : 12, wide ? 14 : 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Tooltip(
              message: 'Go to today',
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: onTitle,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: wide ? 40 : 34, fontWeight: FontWeight.w700, letterSpacing: -0.8, height: 1.1, color: c.onSurface),
                      ),
                    ),
                    if (sub != null) ...[
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(sub!, maxLines: 1, overflow: TextOverflow.fade, softWrap: false, style: TextStyle(fontSize: 17, color: c.onSurfaceVariant)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Material(
            color: context.palette.chip,
            shape: const StadiumBorder(),
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: () => showPlannersSheet(context, ref),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: 40, maxWidth: wide ? 260 : 132),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 16, color: c.onSurface),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          planner.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.onSurface),
                        ),
                      ),
                      Icon(Icons.expand_more_rounded, size: 18, color: c.onSurface),
                    ],
                  ),
                ),
              ),
            ),
          ),
          IconButton(tooltip: 'Search', onPressed: onSearch, icon: const Icon(Icons.search_rounded)),
          round(Icons.chevron_left_rounded, prevLabel, onPrev),
          round(Icons.chevron_right_rounded, nextLabel, onNext),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged, required this.onClose});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(14, 12, 8, 8),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            autofocus: true,
            onChanged: onChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search this planner',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: context.palette.chip,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        TextButton(onPressed: onClose, child: const Text('Done')),
      ],
    ),
  );
}

class _ViewSwitch extends StatelessWidget {
  const _ViewSwitch({required this.view, required this.onPick});
  final PlannerView view;
  final ValueChanged<PlannerView> onPick;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget b(PlannerView v, IconData icon, String label) {
      final on = v == view;
      return Tooltip(
        message: label,
        child: Material(
          color: on ? c.onSurface : Colors.transparent,
          shape: const StadiumBorder(),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: () => onPick(v),
            child: SizedBox(width: 52, height: 40, child: Icon(icon, size: 20, color: on ? c.surface : c.onSurfaceVariant)),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: context.palette.card,
        borderRadius: BorderRadius.circular(999),
        boxShadow: context.palette.cardShadow,
        border: Border.all(color: c.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          b(PlannerView.month, Icons.grid_view_rounded, 'Month'),
          const SizedBox(width: 4),
          b(PlannerView.week, Icons.view_agenda_outlined, 'Week'),
          const SizedBox(width: 4),
          b(PlannerView.day, Icons.crop_square_rounded, 'Day'),
        ],
      ),
    );
  }
}

class _EdgeFlip extends StatelessWidget {
  const _EdgeFlip({required this.left, required this.onEnter, required this.onLeave});
  final bool left;
  final VoidCallback onEnter;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Positioned(
      left: left ? 0 : null,
      right: left ? null : 0,
      top: 120,
      bottom: 120,
      width: 30,
      child: DragTarget<PlannerEntry>(
        onWillAcceptWithDetails: (_) {
          onEnter();
          return false;
        },
        onLeave: (_) => onLeave(),
        builder: (context, _, _) => Center(
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: c.primaryContainer,
              borderRadius: left ? const BorderRadius.horizontal(right: Radius.circular(16)) : const BorderRadius.horizontal(left: Radius.circular(16)),
            ),
            alignment: Alignment.center,
            child: Icon(left ? Icons.chevron_left_rounded : Icons.chevron_right_rounded, size: 20, color: c.onPrimaryContainer),
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ a day (or Someday list)

class _DayHeading extends StatelessWidget {
  const _DayHeading({required this.day, required this.today, required this.wide});
  final String day;
  final String today;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isToday = day == today;
    final color = isToday ? c.primary : c.onSurface;
    return Container(
      padding: const EdgeInsets.only(bottom: 7, left: 2, right: 2),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: color, width: 2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Text(
              dayHeading(day),
              style: TextStyle(fontSize: wide ? 17 : 19, fontWeight: FontWeight.w700, letterSpacing: -0.3, color: color),
            ),
          ),
          Text(
            weekdayShort[parseDay(day).weekday - 1],
            style: TextStyle(fontSize: wide ? 15 : 17, color: (isToday ? c.primary : c.onSurfaceVariant).withValues(alpha: 0.75)),
          ),
        ],
      ),
    );
  }
}

/// The ruled lines of one day or Someday list, and the drop target around them.
class _Lines extends StatelessWidget {
  const _Lines({required this.ctx, required this.slotKey, required this.minLines, this.heading});

  final _Ctx ctx;
  final String slotKey;
  final int minLines;
  final Widget? heading;

  @override
  Widget build(BuildContext context) {
    final entries = ctx.data.entries(slotKey);
    final isSomeday = slotKey.startsWith('someday-');
    final c = context.colors;
    final line = BorderSide(color: c.outlineVariant.withValues(alpha: 0.7));
    final rows = <Widget>[for (final e in entries) _EntryRow(ctx: ctx, entry: e)];
    final adding = ctx.adding == slotKey;
    if (adding) {
      rows.add(
        Container(
          height: ctx.row,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: c.primary, width: 1.5)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 2),
          alignment: Alignment.centerLeft,
          child: TextField(
            controller: ctx.draft,
            focusNode: ctx.draftFocus,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
            onEditingComplete: () {},
            onSubmitted: (_) => ctx.onSubmit(),
            style: TextStyle(fontSize: ctx.font, color: c.onSurface),
            decoration: const InputDecoration(isCollapsed: true, border: InputBorder.none, hintText: 'New to-do'),
          ),
        ),
      );
    }
    final empty = (minLines - rows.length).clamp(1, 99);
    for (var i = 0; i < empty; i++) {
      rows.add(
        Semantics(
          button: true,
          label: 'Add a to-do',
          child: InkWell(
            onTap: ctx.readOnly ? null : () => ctx.onAdd(slotKey),
            mouseCursor: ctx.readOnly ? SystemMouseCursors.basic : SystemMouseCursors.text,
            child: Container(
              height: ctx.row,
              decoration: BoxDecoration(border: Border(bottom: line)),
            ),
          ),
        ),
      );
    }
    return DragTarget<PlannerEntry>(
      onWillAcceptWithDetails: (d) => !ctx.readOnly && !(d.data.isCard && isSomeday) && ctx.canDrop(d.data, slotKey),
      onAcceptWithDetails: (d) => ctx.onMove(d.data, slotKey),
      builder: (context, candidates, _) {
        final over = candidates.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          decoration: BoxDecoration(
            color: over ? context.palette.chip : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: over ? c.primary : Colors.transparent, width: 2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [?heading, ...rows]),
        );
      },
    );
  }
}

/// The words of a line, with "LATE:" in front when it is late (bold while
/// still late; plain once finished late).
TextSpan _titleSpan(PlannerEntry e, TextStyle style) {
  if (!e.state.showsLate) return TextSpan(text: e.title, style: style);
  return TextSpan(
    style: style,
    children: [
      TextSpan(text: 'LATE: ', style: TextStyle(fontWeight: e.late ? FontWeight.w800 : style.fontWeight)),
      TextSpan(text: e.title),
    ],
  );
}

class _EntryRow extends StatefulWidget {
  const _EntryRow({required this.ctx, required this.entry});
  final _Ctx ctx;
  final PlannerEntry entry;

  @override
  State<_EntryRow> createState() => _EntryRowState();
}

class _EntryRowState extends State<_EntryRow> with SingleTickerProviderStateMixin {
  Offset? _origin;

  /// A drop on a day it may not go to: the lifted row flies back to where it
  /// came from (his ask, 2026-11-13), since a drag does not do that by itself.
  void _flyBack(Offset from, Widget ghost) {
    final to = _origin;
    if (to == null || !mounted) return;
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => TweenAnimationBuilder<Offset>(
        tween: Tween(begin: from, end: to),
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
        onEnd: () => entry.remove(),
        builder: (_, o, child) => Positioned(left: o.dx, top: o.dy, child: IgnorePointer(child: child!)),
        child: ghost,
      ),
    );
    overlay.insert(entry);
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final ctx = widget.ctx;
    final c = context.colors;
    final p = context.palette;
    final e = widget.entry;
    final late = e.late;
    final fg = late ? p.lateRowText : (e.done ? c.onSurfaceVariant : (e.state == DueState.dueToday ? p.dueToday : c.onSurface));
    final bell = ctx.reminders.containsKey(e.isCard ? e.card!.id : e.todo!.id);
    final icon = ctx.wide ? 13.0 : 15.0;
    Widget row(bool ghost) => Container(
      height: ctx.row,
      decoration: ghost
          ? BoxDecoration(
              color: late ? p.lateRow : p.card,
              borderRadius: BorderRadius.circular(14),
              boxShadow: p.liftShadow,
              border: Border.all(color: c.primary, width: 2),
            )
          : BoxDecoration(
              // Late: the whole row is red, with white words (his rule).
              color: late ? p.lateRow : null,
              border: Border(bottom: BorderSide(color: c.outlineVariant.withValues(alpha: 0.7))),
            ),
      padding: EdgeInsets.symmetric(horizontal: ghost || late ? 10 : 2),
      child: Row(
        children: [
          if (e.isCard) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: late ? p.lateRowText : ctx.boardColor(context, e.card!.boardId), borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 7),
          ],
          if (e.repeats) ...[Icon(Icons.repeat_rounded, size: icon, color: fg), const SizedBox(width: 5)],
          if (bell) ...[Icon(Icons.notifications_none_rounded, size: icon, color: fg), const SizedBox(width: 5)],
          Expanded(
            child: Text.rich(
              _titleSpan(
                e,
                TextStyle(
                  fontSize: ctx.font,
                  color: fg,
                  fontWeight: e.isCard || e.state == DueState.dueToday ? FontWeight.w600 : FontWeight.w400,
                  decoration: e.done ? TextDecoration.lineThrough : null,
                  decorationColor: fg,
                ),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (!ghost)
            Semantics(
              button: true,
              label: e.done ? 'Mark not done' : 'Mark done',
              child: InkResponse(
                radius: 22,
                onTap: ctx.readOnly ? null : () => ctx.onToggle(e),
                child: SizedBox(
                  width: ctx.wide ? 30 : 44,
                  height: ctx.row,
                  child: Center(
                    child: Theme(
                      data: late ? Theme.of(context).copyWith(colorScheme: c.copyWith(onSurface: p.lateRowText)) : Theme.of(context),
                      child: CheckCircle(done: e.done, size: ctx.wide ? 18 : 22),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    Widget body = InkWell(onTap: () => ctx.onOpen(e), child: row(false));
    if (late) body = KeyedSubtree(key: ctx.lateKey(e.id), child: body);
    if (ctx.readOnly) return body;
    final width = ctx.wide ? 220.0 : 280.0;
    final ghost = Material(
      type: MaterialType.transparency,
      child: Transform.rotate(angle: -0.03, child: SizedBox(width: width, child: row(true))),
    );
    final placeholder = Opacity(opacity: 0.3, child: row(false));
    void started() {
      final rb = context.findRenderObject() as RenderBox?;
      _origin = rb?.localToGlobal(Offset.zero);
      ctx.onDragStart();
    }

    void ended(DraggableDetails d) {
      ctx.onDragEnd();
      if (!d.wasAccepted) _flyBack(d.offset, ghost);
    }

    if (ctx.wide) {
      return Draggable<PlannerEntry>(
        data: e,
        feedback: ghost,
        childWhenDragging: placeholder,
        onDragStarted: started,
        onDragEnd: ended,
        onDragUpdate: ctx.onDragUpdate,
        child: body,
      );
    }
    return LongPressDraggable<PlannerEntry>(
      data: e,
      delay: PlannerMetrics.holdDelay,
      feedback: ghost,
      childWhenDragging: placeholder,
      onDragStarted: started,
      onDragEnd: ended,
      onDragUpdate: ctx.onDragUpdate,
      child: body,
    );
  }
}

/// Late items whose own row is not in view, stacked in red at the top, so
/// they can never be scrolled out of sight (his rule, 2026-11-13). Tapping one
/// opens it.
class _LateStack extends StatelessWidget {
  const _LateStack({required this.ctx, required this.items});
  final _Ctx ctx;
  final List<PlannerEntry> items;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: items.isEmpty
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: EdgeInsets.fromLTRB(ctx.wide ? 26 : 16, 0, ctx.wide ? 26 : 16, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final e in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Material(
                        color: p.lateRow,
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => ctx.onOpen(e),
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 40),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text.rich(
                                    _titleSpan(e, TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: p.lateRowText)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(dayHeading(e.slotKey), style: TextStyle(fontSize: 13, color: p.lateRowText.withValues(alpha: 0.85))),
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
  }
}

// ------------------------------------------------------------------ week (phone)

class _PhoneWeek extends StatelessWidget {
  const _PhoneWeek({required this.ctx, required this.monday, required this.scroll});
  final _Ctx ctx;
  final String monday;
  final ScrollController scroll;

  @override
  Widget build(BuildContext context) {
    final days = [for (var i = 0; i < 7; i++) addDays(monday, i)];
    return ListView(
      controller: scroll,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
      children: [
        for (final d in days)
          Padding(
            padding: const EdgeInsets.only(top: 18),
            child: _Lines(
              ctx: ctx,
              slotKey: d,
              minLines: 2,
              heading: _DayHeading(day: d, today: ctx.today, wide: false),
            ),
          ),
        Padding(padding: const EdgeInsets.only(top: 30), child: _SomedayHeading(wide: false)),
        for (var n = 1; n <= 3; n++)
          Padding(
            padding: EdgeInsets.only(top: n == 1 ? 0 : 14),
            child: _Lines(ctx: ctx, slotKey: 'someday-$n', minLines: 2),
          ),
      ],
    );
  }
}

class _SomedayHeading extends StatelessWidget {
  const _SomedayHeading({required this.wide});
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.only(bottom: 7, left: 4),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.onSurface, width: 2)),
      ),
      child: Text(
        'Someday',
        style: TextStyle(fontSize: wide ? 20 : 19, fontWeight: FontWeight.w700, letterSpacing: -0.3, color: c.onSurface),
      ),
    );
  }
}

// ------------------------------------------------------------------ week (computer, tablet)

class _WideWeek extends StatelessWidget {
  const _WideWeek({required this.ctx, required this.monday, required this.scroll});
  final _Ctx ctx;
  final String monday;
  final ScrollController scroll;

  @override
  Widget build(BuildContext context) {
    final days = [for (var i = 0; i < 7; i++) addDays(monday, i)];
    Widget day(String d, int lines) => _Lines(
      ctx: ctx,
      slotKey: d,
      minLines: lines,
      heading: _DayHeading(day: d, today: ctx.today, wide: true),
    );
    return SingleChildScrollView(
      controller: scroll,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(26, 4, 26, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < 5; i++) ...[if (i > 0) const SizedBox(width: 20), Expanded(child: day(days[i], 11))],
              const SizedBox(width: 20),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [day(days[5], 4), const SizedBox(height: 24), day(days[6], 4)]),
              ),
            ],
          ),
          const SizedBox(height: 36),
          const _SomedayHeading(wide: true),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var n = 1; n <= 3; n++) ...[
                if (n > 1) const SizedBox(width: 20),
                Expanded(
                  child: _Lines(ctx: ctx, slotKey: 'someday-$n', minLines: 4),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ one day

class _DayPage extends StatelessWidget {
  const _DayPage({required this.ctx, required this.day, required this.scroll});
  final _Ctx ctx;
  final String day;
  final ScrollController scroll;

  @override
  Widget build(BuildContext context) => ListView(
    controller: scroll,
    physics: const AlwaysScrollableScrollPhysics(),
    padding: EdgeInsets.fromLTRB(ctx.wide ? 26 : 16, 4, ctx.wide ? 26 : 16, 110),
    children: [
      Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: _Lines(ctx: ctx, slotKey: day, minLines: 12),
        ),
      ),
    ],
  );
}

// ------------------------------------------------------------------ month

class _Month extends StatelessWidget {
  const _Month({required this.ctx, required this.first, required this.onPick});
  final _Ctx ctx;
  final String first;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final f = parseDay(first);
    final start = mondayOf(dayKey(DateTime(f.year, f.month, 1)));
    final last = dayKey(DateTime(f.year, f.month + 1, 0));
    final weeks = <List<String>>[];
    for (var d = start; d.compareTo(last) <= 0; d = addDays(d, 7)) {
      weeks.add([for (var i = 0; i < 7; i++) addDays(d, i)]);
    }
    final cellH = ctx.wide ? 118.0 : 92.0;
    final monthKey = dayKey(DateTime(f.year, f.month, 1)).substring(0, 7);
    final elsewhere = [for (final e in ctx.data.lateItems) if (e.slotKey.substring(0, 7) != monthKey) e];
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(ctx.wide ? 22 : 8, 0, ctx.wide ? 22 : 8, 110),
      children: [
        Row(
          children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    weekdayShort[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.onSurfaceVariant),
                  ),
                ),
              ),
          ],
        ),
        for (final w in weeks)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final d in w)
                Expanded(
                  child: _MonthCell(ctx: ctx, day: d, inMonth: parseDay(d).month == f.month, height: cellH, onTap: () => onPick(d)),
                ),
            ],
          ),
        // Late items from other months: red boxes under the calendar, so they
        // stay in sight here too (his rule, 2026-11-13).
        if (elsewhere.isNotEmpty) ...[
          const SizedBox(height: 14),
          _LateStack(ctx: ctx, items: elsewhere),
        ],
      ],
    );
  }
}

class _MonthCell extends StatelessWidget {
  const _MonthCell({required this.ctx, required this.day, required this.inMonth, required this.height, required this.onTap});
  final _Ctx ctx;
  final String day;
  final bool inMonth;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final p = context.palette;
    final items = ctx.data.entries(day);
    final isToday = day == ctx.today;
    final weekend = parseDay(day).weekday >= 6;
    final show = ctx.wide ? 4 : 3;
    // A late item's own day, in its own month: the whole square goes red.
    final late = inMonth && items.any((e) => e.late);
    return Semantics(
      button: true,
      label: '${dayLabel(day)}, ${items.length} ${items.length == 1 ? 'item' : 'items'}',
      child: InkWell(
        onTap: onTap,
        child: Opacity(
          opacity: inMonth ? 1 : 0.4,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: late ? p.lateRow : null,
              border: Border(top: BorderSide(color: c.outlineVariant.withValues(alpha: 0.7))),
            ),
            padding: const EdgeInsets.fromLTRB(2, 5, 2, 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: isToday ? c.primary : Colors.transparent),
                    child: Text(
                      '${parseDay(day).day}',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isToday ? c.onPrimary : (late ? p.lateRowText : (weekend ? c.onSurfaceVariant : c.onSurface))),
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                for (final e in items.take(show))
                  Container(
                    margin: const EdgeInsets.only(bottom: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: e.late ? Colors.transparent : (late ? p.card.withValues(alpha: 0.9) : (e.isCard ? c.primaryContainer : p.chip)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text.rich(
                      _titleSpan(
                        e,
                        TextStyle(
                          fontSize: 10,
                          height: 1.5,
                          color: e.late ? p.lateRowText : (e.done ? c.onSurfaceVariant : (e.state == DueState.dueToday ? p.dueToday : c.onSurface)),
                          decoration: e.done ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      maxLines: e.late ? 2 : 1,
                      overflow: TextOverflow.clip,
                      softWrap: e.late,
                    ),
                  ),
                if (items.length > show)
                  Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: Text('${items.length - show} more', style: TextStyle(fontSize: 10, color: late ? p.lateRowText : c.onSurfaceVariant)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ search

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.ctx, required this.query});
  final _Ctx ctx;
  final String query;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final found = ctx.data.search(query);
    if (query.trim().isEmpty) {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(28),
            child: Text(
              'Type to find a to-do or a card in this planner.',
              textAlign: TextAlign.center,
              style: TextStyle(color: c.onSurfaceVariant),
            ),
          ),
        ],
      );
    }
    if (found.isEmpty) {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(28),
            child: Text(
              'Nothing matches "$query".',
              textAlign: TextAlign.center,
              style: TextStyle(color: c.onSurfaceVariant),
            ),
          ),
        ],
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
      itemCount: found.length,
      itemBuilder: (context, i) {
        final e = found[i];
        final where = e.day == null ? 'Someday' : (e.repeats ? 'Repeats from ${dayLabel(e.day!)}' : friendlyDay(e.day!, today: ctx.today));
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          leading: CheckCircle(done: e.done),
          title: Text(
            e.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: e.late ? context.palette.dangerText : null, fontWeight: e.late ? FontWeight.w700 : null, decoration: e.done ? TextDecoration.lineThrough : null),
          ),
          subtitle: Text(e.isCard ? '$where · card #${e.card!.number}' : where),
          onTap: () => ctx.onOpen(e),
        );
      },
    );
  }
}
