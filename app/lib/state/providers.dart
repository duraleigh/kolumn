import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../data/lanes.dart';
import '../data/repository.dart';
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
