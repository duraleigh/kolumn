import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/database.dart';
import '../data/export.dart';
import '../data/tidy.dart';
import '../state/providers.dart';
import '../sync/hub_client.dart';
import '../theme/tokens.dart';
import '../ui/sheets.dart';

/// Everything about one Kolumn in one place (Phase 7): its name, who can see
/// it, its view-only link, its tidy-up time, alerts, exporting, deleting.
/// Anyone can follow and export; the rest is for its maker or a HUB Admin.
Future<void> showKolumnSettings(BuildContext context, WidgetRef ref, String boardId) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  useSafeArea: true,
  builder: (context) => _KolumnSettings(boardId: boardId),
);

class _KolumnSettings extends ConsumerWidget {
  const _KolumnSettings({required this.boardId});
  final String boardId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boards = ref.watch(boardsProvider).value ?? const <KBoard>[];
    final b = boards.where((x) => x.id == boardId).firstOrNull;
    if (b == null) return const SizedBox(height: 120, child: Center(child: Text('This Kolumn is gone.')));
    final repo = ref.read(repositoryProvider);
    final readOnly = ref.watch(readOnlyProvider).value ?? false;
    final manage = b.canManage && !readOnly;
    final follows = ref.watch(followsProvider)[b.id] ?? false;
    final people = (ref.watch(peopleProvider).value ?? const <KPerson>[]).length;
    final c = context.colors;

    Widget group(List<Widget> rows) => Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: context.palette.chip,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: Column(children: rows),
      ),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 14),
            child: Text(b.name, style: Theme.of(context).textTheme.titleLarge),
          ),
          if (manage)
            group([
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Rename'),
                onTap: () async {
                  final n = await askText(context, title: 'Rename Kolumn', initial: b.name, action: 'Save');
                  if (n != null && n.trim().isNotEmpty) await repo.renameBoard(b.id, n);
                },
              ),
              ListTile(
                leading: Icon(b.allAccess ? Icons.groups_outlined : Icons.lock_outline_rounded),
                title: const Text('Who can see it'),
                subtitle: Text(b.allAccess ? 'Everyone with To-Dos ($people)' : 'Only chosen people'),
                onTap: () => showBoardAccessSheet(context, ref, b),
              ),
              ListTile(
                leading: const Icon(Icons.link_rounded),
                title: const Text('View-only link'),
                subtitle: Text(b.shareKey == null ? 'Off' : 'On: anyone with the link sees the cards'),
                onTap: () => showShareSheet(context, ref, b.id),
              ),
              ListTile(
                leading: const Icon(Icons.hourglass_bottom_rounded),
                title: const Text('Tidy-up time'),
                subtitle: Text(tidyChoiceLabel(b.tidyDays)),
                onTap: () => pickTidyDays(context, ref, b),
              ),
            ]),
          group([
            SwitchListTile(
              secondary: const Icon(Icons.notifications_active_outlined),
              title: const Text('Tell me about everything'),
              subtitle: const Text('Alerts for every change on this Kolumn'),
              value: follows,
              onChanged: readOnly ? null : (on) => repo.setBoardFollow(b.id, on),
            ),
            ListTile(
              leading: const Icon(Icons.ios_share_rounded),
              title: const Text('Export'),
              subtitle: const Text('A file with every card, and a spreadsheet'),
              onTap: () => exportKolumn(context, ref, b),
            ),
          ]),
          if (manage)
            TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: c.error),
              onPressed: () async {
                if (boards.length < 2) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Make another Kolumn first. There is always at least one.')));
                  return;
                }
                final ok = await confirm(
                  context,
                  title: 'Delete "${b.name}"?',
                  body: 'The Kolumn and all its cards are removed for everyone who can see it.',
                  action: 'Delete Kolumn',
                );
                if (!ok) return;
                await repo.deleteBoard(b.id);
                if (await repo.setting('board.current') == b.id) {
                  await repo.setSetting('board.current', boards.firstWhere((x) => x.id != b.id).id);
                }
                if (context.mounted) Navigator.pop(context);
              },
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Delete Kolumn'),
            ),
        ],
      ),
    );
  }
}

/// The link anyone can open to see a Kolumn's cards (only cards: no notes,
/// comments, people or files), with no sign-in.
String shareUrl(String key) => '$kolumnServer/wp-json/hub/v1/kolumn-share/$key';

Future<void> showShareSheet(BuildContext context, WidgetRef ref, String boardId) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (context) => Consumer(
    builder: (context, ref, _) {
      final b = (ref.watch(boardsProvider).value ?? const <KBoard>[]).where((x) => x.id == boardId).firstOrNull;
      if (b == null) return const SizedBox(height: 100);
      final repo = ref.read(repositoryProvider);
      final pending = (ref.watch(pendingCountProvider).value ?? 0) > 0;
      final key = b.shareKey;
      final c = context.colors;
      Future<void> turnOn({bool renew = false}) async {
        await repo.setShare(b.id, on: true, renew: renew);
        await ref.read(syncServiceProvider).syncNow();
      }

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('View-only link', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(
                'Anyone with the link can see this Kolumn\'s cards, without signing in. They see titles, Priority, due days and tags only: never notes, comments, people, files or drafts.',
                style: TextStyle(color: c.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Link is on'),
                value: key != null,
                onChanged: (on) async {
                  if (on) {
                    await turnOn();
                  } else {
                    await repo.setShare(b.id, on: false);
                  }
                },
              ),
              if (key == null && pending)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('Making the link… it appears once the hub answers.', style: TextStyle(color: c.onSurfaceVariant)),
                ),
              if (key != null) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: context.palette.chip, borderRadius: BorderRadius.circular(14)),
                  child: SelectableText(shareUrl(key), style: const TextStyle(fontSize: 13)),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: shareUrl(key)));
                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link copied')));
                        },
                        icon: const Icon(Icons.copy_rounded),
                        label: const Text('Copy'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => SharePlus.instance.share(ShareParams(text: shareUrl(key), subject: b.name)),
                        icon: const Icon(Icons.ios_share_rounded),
                        label: const Text('Share'),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () async {
                    final ok = await confirm(context, title: 'Make a new link?', body: 'The old link stops working straight away.', action: 'New link');
                    if (ok) await turnOn(renew: true);
                  },
                  child: const Text('Make a new link (the old one stops working)'),
                ),
              ],
            ],
          ),
        ),
      );
    },
  ),
);

/// Saves a Kolumn as two files and hands them to the phone's share menu
/// (Drive, email, Files…).
Future<void> exportKolumn(BuildContext context, WidgetRef ref, KBoard b) async {
  final ex = KolumnExport(ref.read(repositoryProvider));
  final dir = Directory('${(await getTemporaryDirectory()).path}/kolumn-export');
  if (!dir.existsSync()) dir.createSync(recursive: true);
  final base = KolumnExport.fileName(b.name);
  final json = File('${dir.path}/$base.json')..writeAsStringSync(KolumnExport.pretty(await ex.kolumn(b.id)));
  final csv = File('${dir.path}/$base.csv')..writeAsStringSync(await ex.kolumnCsv(b.id));
  await SharePlus.instance.share(ShareParams(files: [XFile(json.path), XFile(csv.path)], subject: '${b.name} (Kolumn export)'));
}

/// Everything this person can see, as one file.
Future<void> exportEverything(BuildContext context, WidgetRef ref) async {
  final ex = KolumnExport(ref.read(repositoryProvider));
  final dir = Directory('${(await getTemporaryDirectory()).path}/kolumn-export');
  if (!dir.existsSync()) dir.createSync(recursive: true);
  final f = File('${dir.path}/${KolumnExport.fileName('everything')}.json')..writeAsStringSync(KolumnExport.pretty(await ex.everything()));
  await SharePlus.instance.share(ShareParams(files: [XFile(f.path)], subject: 'Kolumn export'));
}
