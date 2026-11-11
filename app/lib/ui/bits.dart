import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/providers.dart';
import '../theme/tokens.dart';

// ------------------------------------------------------------------ avatars

const _tones = [
  (Color(0xFFDFE0FF), Color(0xFF0B1A7A)),
  (Color(0xFFBFEFD0), Color(0xFF003920)),
  (Color(0xFFF0DBFF), Color(0xFF3A0A5C)),
  (Color(0xFFFFDBD1), Color(0xFF5A1600)),
  (Color(0xFFBEEFF4), Color(0xFF00373B)),
  (Color(0xFFFFE59A), Color(0xFF3F2E00)),
  (Color(0xFFFFD8E6), Color(0xFF5C0F33)),
  (Color(0xFFE3E1E9), Color(0xFF1B1B21)),
];

String initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
}

/// A person's initials in a tonal circle (the same tones as ConvoMail's).
class PersonAvatar extends StatelessWidget {
  const PersonAvatar({super.key, required this.id, required this.name, this.size = 24});
  final int id;
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _tones[id.abs() % _tones.length];
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: dark ? fg.withValues(alpha: 0.9) : bg,
        shape: BoxShape.circle,
        border: Border.all(color: context.palette.card, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        initials(name),
        style: TextStyle(fontSize: size * 0.4, fontWeight: FontWeight.w700, color: dark ? bg : fg),
      ),
    );
  }
}

class AvatarStack extends ConsumerWidget {
  const AvatarStack({super.key, required this.ids, this.size = 22});
  final List<int> ids;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final names = ref.watch(peopleNamesProvider);
    final shown = ids.take(3).toList();
    return SizedBox(
      width: shown.isEmpty ? 0 : size + (shown.length - 1) * size * 0.65,
      height: size,
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            Positioned(
              left: i * size * 0.65,
              child: PersonAvatar(id: shown[i], name: names[shown[i]] ?? '?', size: size),
            ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ pictures

/// A picture attached to a card, from the phone's copy or fetched from the hub.
class HubPicture extends ConsumerWidget {
  const HubPicture({super.key, required this.fileId, this.thumb = true, this.fit = BoxFit.cover});
  final String fileId;
  final bool thumb;
  final BoxFit fit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bytes = ref.watch(fileBytesProvider((fileId, thumb)));
    return bytes.when(
      data: (b) => b == null
          ? Container(
              color: context.palette.chip,
              alignment: Alignment.center,
              child: Icon(Icons.image_not_supported_outlined, color: context.colors.onSurfaceVariant),
            )
          : Image.memory(b, fit: fit, gaplessPlayback: true),
      loading: () => Container(color: context.palette.chip),
      error: (_, _) => Container(color: context.palette.chip),
    );
  }
}

// ------------------------------------------------------------------ formatted text

/// Mentions are written `@[Name](12)` and card links `#[Title](card:ID)`;
/// both read as "@Name" / "#Title" on screen.
final markupPattern = RegExp(r'@\[([^\]]{1,80})\]\((\d{1,10})\)|#\[([^\]]{1,120})\]\(card:([0-9a-fA-F-]{8,36})\)');

/// Notes and comments, lightly formatted: **bold**, _italic_, "- " bullets,
/// @mentions and #card links (tappable).
class FormattedText extends StatelessWidget {
  const FormattedText(this.text, {super.key, this.style, this.onOpenCard});
  final String text;
  final TextStyle? style;
  final void Function(String cardId)? onOpenCard;

  @override
  Widget build(BuildContext context) {
    final base = style ?? Theme.of(context).textTheme.bodyLarge!;
    final accent = context.palette.accentText;
    final lines = text.split('\n');
    final children = <Widget>[];
    for (final line in lines) {
      final bullet = RegExp(r'^\s*[-*•]\s+').firstMatch(line);
      final body = bullet == null ? line : line.substring(bullet.end);
      final rich = Text.rich(TextSpan(style: base, children: _inline(body, base, accent)));
      children.add(
        bullet == null
            ? rich
            : Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('•  ', style: base),
                    Expanded(child: rich),
                  ],
                ),
              ),
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }

  List<InlineSpan> _inline(String s, TextStyle base, Color accent) {
    final spans = <InlineSpan>[];
    final token = RegExp(r'\*\*(.+?)\*\*|(?<![\w*])_(.+?)_(?!\w)|' + markupPattern.pattern);
    var at = 0;
    for (final m in token.allMatches(s)) {
      if (m.start > at) spans.add(TextSpan(text: s.substring(at, m.start)));
      if (m.group(1) != null) {
        spans.add(
          TextSpan(
            text: m.group(1),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        );
      } else if (m.group(2) != null) {
        spans.add(
          TextSpan(
            text: m.group(2),
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
        );
      } else if (m.group(3) != null) {
        spans.add(
          TextSpan(
            text: '@${m.group(3)}',
            style: TextStyle(color: accent, fontWeight: FontWeight.w600),
          ),
        );
      } else if (m.group(5) != null) {
        final id = m.group(6)!;
        spans.add(
          TextSpan(
            text: '#${m.group(5)}',
            style: TextStyle(color: accent, fontWeight: FontWeight.w600, decoration: TextDecoration.underline),
            recognizer: onOpenCard == null ? null : (TapGestureRecognizer()..onTap = () => onOpenCard!(id)),
          ),
        );
      }
      at = m.end;
    }
    if (at < s.length) spans.add(TextSpan(text: s.substring(at)));
    return spans;
  }
}

/// Plain words for a card's history line.
String historyLine(String action, Map<String, dynamic> p, String who) {
  String lane(String to) {
    if (to == 'todo') return 'To-do';
    if (to == 'later') return 'Later';
    if (to == 'done') return 'Done';
    return (p['column'] as String?)?.isNotEmpty == true ? p['column'] as String : 'a column';
  }

  switch (action) {
    case 'card_published':
      return '$who added this card';
    case 'card_moved':
      return '$who moved this to ${lane(p['to'] as String? ?? 'todo')}';
    case 'card_priority':
      return '$who made this Priority';
    case 'card_unpriority':
      return '$who took Priority off';
    case 'card_renamed':
      return '$who renamed this (was "${p['from'] ?? ''}")';
    case 'card_assigned':
      return '$who assigned ${p['name'] ?? 'someone'}';
    case 'card_unassigned':
      return '$who unassigned ${p['name'] ?? 'someone'}';
    case 'comment_created':
      return '$who commented';
    case 'card_board_changed':
      return '$who moved this from ${p['from'] ?? 'another board'} to ${p['to'] ?? 'this board'}';
    default:
      return '$who changed this';
  }
}

String shortWhen(int ms) {
  final d = DateTime.fromMillisecondsSinceEpoch(ms).toLocal();
  final now = DateTime.now();
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final t = '$h:${d.minute.toString().padLeft(2, '0')} ${d.hour < 12 ? 'am' : 'pm'}';
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(d.year, d.month, d.day);
  if (day == today) return 'Today $t';
  if (day == today.subtract(const Duration(days: 1))) return 'Yesterday $t';
  return '${months[d.month - 1]} ${d.day}, $t';
}

String sizeText(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).round()} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

String mimeFor(String filename) {
  final ext = filename.split('.').last.toLowerCase();
  const map = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'gif': 'image/gif',
    'webp': 'image/webp',
    'heic': 'image/heic',
    'pdf': 'application/pdf',
    'txt': 'text/plain',
    'csv': 'text/csv',
    'doc': 'application/msword',
    'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'mp3': 'audio/mpeg',
    'm4a': 'audio/mp4',
    'mp4': 'video/mp4',
    'mov': 'video/quicktime',
    'zip': 'application/zip',
  };
  return map[ext] ?? 'application/octet-stream';
}

const reactionChoices = ['👍', '❤️', '🎉', '😂', '👀', '🙏', '🔥', '✅'];
