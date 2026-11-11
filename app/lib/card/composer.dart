import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../state/providers.dart';
import '../theme/tokens.dart';
import '../ui/bits.dart';

/// The comment box. Typing "@" offers the team, "#" offers cards; a pick
/// shows as "@Name" or "#Title" while writing and is sent as a proper
/// mention or card link.
class CommentComposer extends ConsumerStatefulWidget {
  const CommentComposer({super.key, required this.cardId});
  final String cardId;

  @override
  ConsumerState<CommentComposer> createState() => _CommentComposerState();
}

class _CommentComposerState extends ConsumerState<CommentComposer> {
  final _ctl = TextEditingController();
  final _focus = FocusNode();

  /// What each picked "@Name" / "#Title" stands for when sent.
  final _picked = <String, String>{};
  String? _trigger;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _ctl.addListener(_scan);
  }

  @override
  void dispose() {
    _ctl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _scan() {
    final sel = _ctl.selection;
    final text = _ctl.text;
    final at = sel.isValid ? sel.start : text.length;
    final before = text.substring(0, at);
    final m = RegExp(r'(?:^|\s)([@#])([^\s@#]{0,30})$').firstMatch(before);
    final trig = m?.group(1);
    final q = m?.group(2) ?? '';
    if (trig != _trigger || q != _query) {
      setState(() {
        _trigger = trig;
        _query = q;
      });
    }
  }

  void _insert(String display, String markup) {
    final sel = _ctl.selection;
    final text = _ctl.text;
    final at = sel.isValid ? sel.start : text.length;
    final start = at - (_query.length + 1);
    final next = '${text.substring(0, start)}$display ${text.substring(at)}';
    _picked[display] = markup;
    _ctl.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: start + display.length + 1),
    );
  }

  Future<void> _send() async {
    var body = _ctl.text.trim();
    if (body.isEmpty) return;
    final keys = _picked.keys.toList()..sort((a, b) => b.length.compareTo(a.length));
    for (final k in keys) {
      body = body.replaceAll(k, _picked[k]!);
    }
    await ref.read(repositoryProvider).addComment(widget.cardId, body);
    _ctl.clear();
    _picked.clear();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final c = context.colors;
    final suggestions = <Widget>[];
    if (_trigger == '@') {
      final people = ref.watch(peopleProvider).value ?? const <KPerson>[];
      for (final person in people.where((x) => x.name.toLowerCase().contains(_query.toLowerCase())).take(8)) {
        final display = '@${person.name}';
        suggestions.add(
          ActionChip(
            avatar: PersonAvatar(id: person.id, name: person.name, size: 22),
            label: Text(person.name),
            onPressed: () => _insert(display, '@[${person.name}](${person.id})'),
          ),
        );
      }
    } else if (_trigger == '#') {
      final cards = (ref.watch(allCardsProvider).value ?? const <KCard>[]).where((x) => x.id != widget.cardId && x.status == 'published').toList()
        ..sort((a, b) => b.lastActiveAt.compareTo(a.lastActiveAt));
      final q = _query.toLowerCase();
      for (final card in cards.where((x) => x.title.toLowerCase().contains(q) || '${x.number}'.startsWith(q)).take(8)) {
        final title = card.title.length > 40 ? '${card.title.substring(0, 40)}…' : card.title;
        suggestions.add(
          ActionChip(label: Text('#${card.number} $title'), onPressed: () => _insert('#$title', '#[${card.title.replaceAll(']', '')}](card:${card.id})')),
        );
      }
    }

    return Container(
      decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, boxShadow: p.trayShadow),
      padding: EdgeInsets.fromLTRB(12, 8, 12, 10 + MediaQuery.paddingOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (suggestions.isNotEmpty)
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: suggestions.length,
                separatorBuilder: (_, _) => const SizedBox(width: 6),
                itemBuilder: (_, i) => suggestions[i],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctl,
                  focusNode: _focus,
                  minLines: 1,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(hintText: 'Write a comment… (@ mentions, # links)'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                tooltip: 'Send',
                style: IconButton.styleFrom(backgroundColor: c.primary, foregroundColor: c.onPrimary, minimumSize: const Size(48, 48)),
                onPressed: _send,
                icon: const Icon(Icons.send_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
