import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../activity/activity_model.dart';
import '../data/database.dart';
import '../data/lanes.dart';
import '../data/repository.dart';
import '../planner/planner_model.dart';
import '../sync/sync_service.dart';

/// Replaced in main() (and in tests) with the real repository.
final repositoryProvider = Provider<KolumnRepository>((ref) => throw UnimplementedError('repositoryProvider not overridden'));

final boardsProvider = StreamProvider<List<KBoard>>((ref) => ref.watch(repositoryProvider).watchBoards());

final currentBoardIdProvider = StreamProvider<String?>((ref) => ref.watch(repositoryProvider).watchSetting('board.current'));

final columnsProvider = StreamProvider.family<List<KColumn>, String>((ref, boardId) => ref.watch(repositoryProvider).watchColumns(boardId));

final cardsProvider = StreamProvider.family<List<KCard>, String>((ref, boardId) => ref.watch(repositoryProvider).watchCards(boardId));

final cardProvider = StreamProvider.family<KCard?, String>((ref, id) => ref.watch(repositoryProvider).watchCard(id));

/// The column each board last had open (beside To-do on wide screens).
final openLaneProvider = StreamProvider.family<Lane?, String>(
  (ref, boardId) => ref.watch(repositoryProvider).watchSetting('open.$boardId').map((v) => v == null ? null : Lane.fromKey(v)),
);

final themeModeProvider = StreamProvider<ThemeMode>(
  (ref) => ref.watch(repositoryProvider).watchSetting('theme').map((v) {
    switch (v) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }),
);

/// Replaced in main() (and in tests) with the running sync.
final syncServiceProvider = Provider<SyncService>((ref) => throw UnimplementedError('syncServiceProvider not overridden'));

final syncStatusProvider = StreamProvider<SyncStatus>((ref) => ref.watch(syncServiceProvider).status);

final pendingCountProvider = StreamProvider<int>((ref) => ref.watch(repositoryProvider).watchPendingCount());

final peopleProvider = StreamProvider<List<KPerson>>((ref) => ref.watch(repositoryProvider).watchPeople());

final meNameProvider = StreamProvider<String?>((ref) => ref.watch(repositoryProvider).watchSetting('me.name'));

final meIdProvider = StreamProvider<int?>((ref) => ref.watch(repositoryProvider).watchSetting('me.id').map((v) => int.tryParse(v ?? '')));

/// True when this person's hub access to To-Dos is read-only: they can look
/// at boards but not change them.
final readOnlyProvider = StreamProvider<bool>((ref) => ref.watch(repositoryProvider).watchSetting('me.level').map((v) => v == 'read'));

// ---------------------------------------------------------------- Phase 4: everything on a card

final stepsProvider = StreamProvider.family<List<KStep>, String>((ref, id) => ref.watch(repositoryProvider).watchSteps(id));
final commentsProvider = StreamProvider.family<List<KComment>, String>((ref, id) => ref.watch(repositoryProvider).watchComments(id));
final reactionsProvider = StreamProvider.family<List<KReaction>, String>((ref, id) => ref.watch(repositoryProvider).watchReactions(id));
final filesProvider = StreamProvider.family<List<KFile>, String>((ref, id) => ref.watch(repositoryProvider).watchFiles(id));
final eventsProvider = StreamProvider.family<List<KEvent>, String>((ref, id) => ref.watch(repositoryProvider).watchEvents(id));
final watchProvider = StreamProvider.family<KWatch?, String>((ref, id) => ref.watch(repositoryProvider).watchWatch(id));
final pinsProvider = StreamProvider<List<KPin>>((ref) => ref.watch(repositoryProvider).watchPins());
final allTagsProvider = StreamProvider<List<KTag>>((ref) => ref.watch(repositoryProvider).watchTags());
final allAssigneesProvider = StreamProvider<List<KAssignee>>((ref) => ref.watch(repositoryProvider).watchAssignees());
final allStepsProvider = StreamProvider<List<KStep>>((ref) => ref.watch(repositoryProvider).watchAllSteps());
final allCommentsProvider = StreamProvider<List<KComment>>((ref) => ref.watch(repositoryProvider).watchAllComments());
final allFilesProvider = StreamProvider<List<KFile>>((ref) => ref.watch(repositoryProvider).watchAllFiles());
final allCardsProvider = StreamProvider<List<KCard>>((ref) => ref.watch(repositoryProvider).watchAllCards());

/// What a card face shows besides its title.
class CardExtras {
  CardExtras();
  final tags = <String>[];
  final assignees = <int>[];
  int steps = 0;
  int stepsDone = 0;
  int comments = 0;
  int files = 0;
}

final cardExtrasProvider = Provider<Map<String, CardExtras>>((ref) {
  final out = <String, CardExtras>{};
  CardExtras of(String id) => out.putIfAbsent(id, CardExtras.new);
  for (final t in ref.watch(allTagsProvider).value ?? const <KTag>[]) {
    of(t.cardId).tags.add(t.tag);
  }
  for (final a in ref.watch(allAssigneesProvider).value ?? const <KAssignee>[]) {
    of(a.cardId).assignees.add(a.userId);
  }
  for (final s in ref.watch(allStepsProvider).value ?? const <KStep>[]) {
    final e = of(s.cardId);
    e.steps++;
    if (s.done) e.stepsDone++;
  }
  for (final c in ref.watch(allCommentsProvider).value ?? const <KComment>[]) {
    of(c.cardId).comments++;
  }
  for (final f in ref.watch(allFilesProvider).value ?? const <KFile>[]) {
    if (f.commentId == null) of(f.cardId).files++;
  }
  for (final e in out.values) {
    e.tags.sort();
  }
  return out;
});

/// Names for user ids; "You" for this person.
final peopleNamesProvider = Provider<Map<int, String>>((ref) {
  final map = <int, String>{for (final p in ref.watch(peopleProvider).value ?? const <KPerson>[]) p.id: p.name};
  return map;
});

/// A file's picture (or bytes): from this phone if it has a copy, otherwise
/// fetched from the hub once and kept.
final fileBytesProvider = FutureProvider.family<Uint8List?, (String, bool)>((ref, key) async {
  final (id, thumb) = key;
  final repo = ref.watch(repositoryProvider);
  // A file on a card, or (Phase 5) on a to-do.
  final card = await repo.file(id);
  final todo = card == null ? await repo.todoFile(id) : null;
  if (card == null && todo == null) return null;
  final local = card?.localPath ?? todo?.localPath;
  final hasThumb = card?.hasThumb ?? todo!.hasThumb;
  if (local != null && File(local).existsSync()) return File(local).readAsBytes();
  final dir = Directory('${(await getApplicationCacheDirectory()).path}/kolumn-files');
  if (!dir.existsSync()) dir.createSync(recursive: true);
  final cached = File('${dir.path}/$id${thumb ? '.thumb' : ''}');
  if (cached.existsSync()) return cached.readAsBytes();
  try {
    final bytes = await ref.read(syncServiceProvider).hub.downloadFile(id, thumb: thumb && hasThumb);
    await cached.writeAsBytes(bytes, flush: true);
    if (!thumb) await (card != null ? repo.setFileLocalPath(id, cached.path) : repo.setTodoFileLocalPath(id, cached.path));
    return Uint8List.fromList(bytes);
  } catch (_) {
    return null;
  }
});

// ---------------------------------------------------------------- Phase 6: alerts and finding things

final notificationsProvider = StreamProvider<List<KNotification>>((ref) => ref.watch(repositoryProvider).watchNotifications());
final boardWatchesProvider = StreamProvider<List<KBoardWatch>>((ref) => ref.watch(repositoryProvider).watchBoardWatches());
final viewsProvider = StreamProvider<List<KView>>((ref) => ref.watch(repositoryProvider).watchViews());
final allEventsProvider = StreamProvider<List<KEvent>>((ref) => ref.watch(repositoryProvider).watchAllEvents());
final allColumnsProvider = StreamProvider<List<KColumn>>((ref) => ref.watch(repositoryProvider).watchAllColumns());

// 2026-11-13: the Planner in Activity and Alerts.
final allTodosProvider = StreamProvider<List<KTodo>>((ref) => ref.watch(repositoryProvider).watchAllTodos());
final allTodoEventsProvider = StreamProvider<List<KTodoEvent>>((ref) => ref.watch(repositoryProvider).watchAllTodoEvents());
final reminderReadsProvider = StreamProvider<List<KReminderRead>>((ref) => ref.watch(repositoryProvider).watchReminderReads());

/// Reminders that have gone off, for the Alerts tab.
final passedRemindersProvider = Provider<List<PassedReminder>>((ref) {
  final now = DateTime.fromMillisecondsSinceEpoch(ref.watch(plannerNowProvider)());
  return passedReminders(
    reminders: ref.watch(remindersProvider).value ?? const <KReminder>[],
    cards: {for (final c in ref.watch(allCardsProvider).value ?? const <KCard>[]) c.id: c},
    todos: {for (final t in ref.watch(allTodosProvider).value ?? const <KTodo>[]) t.id: t},
    read: {for (final r in ref.watch(reminderReadsProvider).value ?? const <KReminderRead>[]) (r.itemId, r.at)},
    now: now,
  );
});

/// How many alerts are waiting to be read (for the badge): alerts, and reminders that went off.
final unreadAlertsProvider = Provider<int>(
  (ref) =>
      (ref.watch(notificationsProvider).value ?? const <KNotification>[]).where((n) => n.readAt == null).length +
      ref.watch(passedRemindersProvider).where((r) => !r.read).length,
);

/// Whether this person follows a Kolumn: their own choice, or (if they never
/// chose) yes for a Kolumn they made.
final followsProvider = Provider<Map<String, bool>>((ref) {
  final me = ref.watch(meIdProvider).value;
  final chosen = {for (final w in ref.watch(boardWatchesProvider).value ?? const <KBoardWatch>[]) w.boardId: w.watching};
  return {for (final b in ref.watch(boardsProvider).value ?? const <KBoard>[]) b.id: chosen[b.id] ?? (me != null && b.creatorId == me)};
});
