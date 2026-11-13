import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../card/card_screen.dart';
import '../data/database.dart';
import '../data/lane_looks.dart';
import '../data/lanes.dart';
import '../state/providers.dart';
import '../theme/tokens.dart';
import '../ui/sheets.dart';
import 'card_filter.dart';

/// Finding cards across every Kolumn, from what is on the phone (so it works
/// with no signal): words in titles, notes, comments and checklists,
/// narrowed by filters, and kept as saved views.
class FindScreen extends ConsumerStatefulWidget {
  const FindScreen({super.key, this.initial = const CardFilter()});
  final CardFilter initial;

  @override
  ConsumerState<FindScreen> createState() => _FindScreenState();
}

class _FindScreenState extends ConsumerState<FindScreen> {
  late CardFilter _f = widget.initial;
  late final _q = TextEditingController(text: widget.initial.terms);
  String? _viewId;

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  void _set(CardFilter f) => setState(() => _f = f);

  Future<T?> _choose<T>(String title, List<(T, String)> options, T current) => showModalBottomSheet<T>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
            for (final (v, label) in options)
              ListTile(title: Text(label), trailing: v == current ? const Icon(Icons.check_rounded) : null, onTap: () => Navigator.pop(context, v)),
          ],
        ),
      ),
    ),
  );

  Future<Set<T>?> _chooseMany<T>(String title, List<(T, String)> options, Set<T> current) {
    var picked = {...current};
    return showModalBottomSheet<Set<T>>(
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
                child: Text(title, style: Theme.of(context).textTheme.titleLarge),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    if (options.isEmpty) const ListTile(title: Text('Nothing to choose yet')),
                    for (final (v, label) in options)
                      CheckboxListTile(
                        title: Text(label),
                        value: picked.contains(v),
                        onChanged: (on) => set(() => on == true ? picked.add(v) : picked.remove(v)),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context, <T>{}), child: const Text('Any')),
                    const Spacer(),
                    FilledButton(onPressed: () => Navigator.pop(context, picked), child: const Text('Show')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveView() async {
    final views = ref.read(viewsProvider).value ?? const <KView>[];
    final current = views.where((v) => v.id == _viewId).firstOrNull;
    final name = await askText(context, title: current == null ? 'Save this view' : 'Save view', initial: current?.name ?? '', action: 'Save', hint: 'Name, like "My Priority cards"');
    if (name == null || name.trim().isEmpty) return;
    final id = await ref.read(repositoryProvider).saveView(name, _f.toJson(), id: current?.id);
    setState(() => _viewId = id);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved "${name.trim()}"')));
  }

  Future<void> _viewMenu(KView v) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.edit_outlined), title: const Text('Rename'), onTap: () => Navigator.pop(context, 'rename')),
            ListTile(
              leading: Icon(Icons.delete_outline_rounded, color: context.colors.error),
              title: Text('Delete "${v.name}"', style: TextStyle(color: context.colors.error)),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || choice == null) return;
    final repo = ref.read(repositoryProvider);
    if (choice == 'delete') {
      await repo.deleteView(v.id);
      if (_viewId == v.id) setState(() => _viewId = null);
    } else {
      final n = await askText(context, title: 'Rename view', initial: v.name, action: 'Save');
      if (n != null && n.trim().isNotEmpty) await repo.saveView(n, (jsonDecode(v.params) as Map).cast<String, Object?>(), id: v.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cards = ref.watch(allCardsProvider).value ?? const <KCard>[];
    final boardList = ref.watch(boardsProvider).value ?? const <KBoard>[];
    final boards = {for (final b in boardList) b.id: b};
    final columns = {for (final c in ref.watch(allColumnsProvider).value ?? const <KColumn>[]) c.id: c};
    final people = ref.watch(peopleProvider).value ?? const <KPerson>[];
    final views = ref.watch(viewsProvider).value ?? const <KView>[];
    final me = ref.watch(meIdProvider).value;
    final text = <String, CardText>{};
    CardText of(String id) => text.putIfAbsent(id, () => CardText(comments: [], steps: [], tags: [], assignees: []));
    for (final x in ref.watch(allCommentsProvider).value ?? const <KComment>[]) {
      of(x.cardId).comments.add(x.body);
    }
    for (final x in ref.watch(allStepsProvider).value ?? const <KStep>[]) {
      of(x.cardId).steps.add(x.content);
    }
    // Tags are shown and searched nowhere now (his ruling, 2026-11-13).
    for (final x in ref.watch(allAssigneesProvider).value ?? const <KAssignee>[]) {
      of(x.cardId).assignees.add(x.userId);
    }
    final found = applyFilter(_f, cards: cards, text: text, boards: boards, me: me, now: DateTime.now());
    final c = context.colors;
    final p = context.palette;
    final names = {for (final x in people) x.id: x.name};

    String many(Set<String> s, String any, String Function(String) one) => s.isEmpty ? any : (s.length == 1 ? one(s.first) : '${s.length} chosen');

    Widget chip(String label, bool on, VoidCallback onTap) => Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(label: Text(label), selected: on, showCheckmark: false, onSelected: (_) => onTap()),
    );

    final chips = <Widget>[
      chip(CardFilter.statuses[_f.status]!, _f.status != 'open', () async {
        final v = await _choose('Show', [for (final e in CardFilter.statuses.entries) (e.key, e.value)], _f.status);
        if (v != null) _set(_f.copyWith(status: v));
      }),
      chip(many(_f.boards, 'All Kolumns', (id) => boards[id]?.name ?? '1 Kolumn'), _f.boards.isNotEmpty, () async {
        final v = await _chooseMany('Kolumns', [for (final b in boardList) (b.id, b.name)], _f.boards);
        if (v != null) _set(_f.copyWith(boards: v));
      }),
      chip(
        many(_f.assignees, 'Assigned to anyone', (a) => a == 'me' ? 'Assigned to me' : (a == 'none' ? 'Nobody assigned' : 'Assigned to ${names[int.tryParse(a)] ?? '?'}')),
        _f.assignees.isNotEmpty,
        () async {
          final v = await _chooseMany('Assigned to', [
            ('me', 'Me'),
            ('none', 'Nobody'),
            for (final x in people.where((x) => x.id != me)) ('${x.id}', x.name),
          ], _f.assignees);
          if (v != null) _set(_f.copyWith(assignees: v));
        },
      ),
      chip(
        _f.creators.isEmpty ? 'Added by anyone' : (_f.creators.length == 1 ? 'Added by ${_f.creators.first == me ? 'me' : names[_f.creators.first] ?? '?'}' : 'Added by ${_f.creators.length}'),
        _f.creators.isNotEmpty,
        () async {
          final v = await _chooseMany('Added by', [for (final x in people) (x.id, x.id == me ? 'Me' : x.name)], _f.creators);
          if (v != null) _set(_f.copyWith(creators: v));
        },
      ),
      chip(_f.added == null ? 'Added any time' : 'Added ${CardFilter.windows[_f.added]!.toLowerCase()}', _f.added != null, () async {
        final v = await _choose<String>('Added', [('', 'Any time'), for (final e in CardFilter.windows.entries) (e.key, e.value)], _f.added ?? '');
        if (v != null) _set(v.isEmpty ? _f.copyWith(clearAdded: true) : _f.copyWith(added: v));
      }),
      if (_f.status == 'done' || _f.status == 'all')
        chip(_f.done == null ? 'Done any time' : 'Done ${CardFilter.windows[_f.done]!.toLowerCase()}', _f.done != null, () async {
          final v = await _choose<String>('Done', [('', 'Any time'), for (final e in CardFilter.windows.entries) (e.key, e.value)], _f.done ?? '');
          if (v != null) _set(v.isEmpty ? _f.copyWith(clearDone: true) : _f.copyWith(done: v));
        }),
      chip(CardFilter.sorts[_f.sort]!, _f.sort != 'latest', () async {
        final v = await _choose('Order', [for (final e in CardFilter.sorts.entries) (e.key, e.value)], _f.sort);
        if (v != null) _set(_f.copyWith(sort: v));
      }),
    ];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _q,
          autofocus: widget.initial.isPlain && widget.initial.terms.isEmpty,
          onChanged: (v) => _set(_f.copyWith(terms: v)),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search cards and comments',
            filled: true,
            fillColor: p.card,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: c.outlineVariant)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: c.outlineVariant)),
            suffixIcon: _q.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear',
                    onPressed: () {
                      _q.clear();
                      _set(_f.copyWith(terms: ''));
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
          ),
        ),
        actions: [
          if (!_f.isPlain || _f.terms.trim().isNotEmpty) IconButton(tooltip: 'Save this view', onPressed: _saveView, icon: const Icon(Icons.bookmark_add_outlined)),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (views.isNotEmpty)
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(14, 6, 6, 4),
                children: [
                  for (final v in views)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onLongPress: () => _viewMenu(v),
                        child: ChoiceChip(
                          avatar: const Icon(Icons.bookmark_rounded, size: 16),
                          label: Text(v.name),
                          selected: v.id == _viewId,
                          onSelected: (_) {
                            final f = CardFilter.fromJson((jsonDecode(v.params) as Map).cast<String, dynamic>());
                            _q.text = f.terms;
                            setState(() {
                              _f = f;
                              _viewId = v.id;
                            });
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          SizedBox(
            height: 50,
            child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.fromLTRB(14, 6, 6, 6), children: chips),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${found.length} ${found.length == 1 ? 'card' : 'cards'}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                if (!_f.isPlain)
                  TextButton(
                    onPressed: () => setState(() {
                      _f = CardFilter(terms: _f.terms);
                      _viewId = null;
                    }),
                    child: const Text('Clear filters'),
                  ),
              ],
            ),
          ),
          Expanded(
            child: found.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      _f.terms.trim().isEmpty ? 'No cards match these filters.' : 'Nothing matches "${_f.terms.trim()}".',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: c.onSurfaceVariant),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
                    itemCount: found.length,
                    itemBuilder: (context, i) {
                      final f = found[i];
                      final card = f.card;
                      final lane = Lane.of(card, columns.keys.toSet());
                      final (laneName, laneColor) = switch (lane.kind) {
                        LaneKind.todo => (laneLook(boards[card.boardId], 'todo').name, LaneColors.at(laneLook(boards[card.boardId], 'todo').color).of(Theme.of(context).brightness)),
                        LaneKind.later => (laneLook(boards[card.boardId], 'later').name, LaneColors.at(laneLook(boards[card.boardId], 'later').color).of(Theme.of(context).brightness)),
                        LaneKind.done => (laneLook(boards[card.boardId], 'done').name, LaneColors.at(laneLook(boards[card.boardId], 'done').color).of(Theme.of(context).brightness)),
                        LaneKind.column => (
                          columns[lane.columnId]?.name ?? 'a kolumn',
                          Theme.of(context).brightness == Brightness.dark
                              ? LaneColors.at(columns[lane.columnId]?.color ?? 0).dark
                              : LaneColors.at(columns[lane.columnId]?.color ?? 0).light,
                        ),
                      };
                      final where = {'comment': 'In a comment', 'notes': 'In the notes', 'step': 'In the checklist', 'tag': 'Tag'}[f.where];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          color: p.card,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => showCardSheet(context, card.id),
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Container(
                                    width: 5,
                                    margin: const EdgeInsets.fromLTRB(8, 10, 0, 10),
                                    decoration: BoxDecoration(color: laneColor, borderRadius: BorderRadius.circular(3)),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            card.title,
                                            style: TextStyle(
                                              fontSize: 15,
                                              decoration: card.closedAt != null ? TextDecoration.lineThrough : null,
                                              color: card.closedAt != null ? c.onSurfaceVariant : c.onSurface,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            [
                                              if (card.synced) '#${card.number}',
                                              if (boardList.length > 1) boards[card.boardId]?.name ?? '',
                                              laneName,
                                              if (card.status == 'draft') 'Draft',
                                            ].join(' · '),
                                            style: TextStyle(fontSize: 12, color: c.onSurfaceVariant),
                                          ),
                                          if (where != null && f.snippet.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              '$where: ${f.snippet}',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: 13, color: c.onSurfaceVariant, fontStyle: FontStyle.italic),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
