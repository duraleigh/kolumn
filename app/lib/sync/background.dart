import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../data/database.dart';
import '../data/repository.dart';
import 'hub_client.dart';
import 'reminders.dart';
import 'sync_service.dart';

/// Kolumn checks the hub every 15 minutes even when it is closed (his choice,
/// 2026-11-11, instead of Google's instant alerts), so new alerts still pop
/// up, a little late. Android decides the exact moment, only with a
/// connection, and may wait longer to save battery.
const _mainPort = 'kolumn_main';
const _task = 'kolumn.check';

@pragma('vm:entry-point')
void kolumnBackgroundCheck() {
  Workmanager().executeTask((task, input) async {
    try {
      await backgroundCheck();
    } catch (_) {
      // A check that fails just waits for the next one.
    }
    return true;
  });
}

/// One check. If Kolumn is still running (just not on screen), it is asked
/// to check itself, so two copies never work on the phone's store at once.
Future<void> backgroundCheck() async {
  final running = IsolateNameServer.lookupPortByName(_mainPort);
  if (running != null) {
    running.send('check');
    return;
  }
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  final repo = KolumnRepository(KolumnDb());
  try {
    final sync = SyncService(repo: repo, hub: HubClient(credentials: SecureCredentialStore()));
    await sync.syncNow();
    await ReminderService(repo).runOnce();
  } finally {
    await repo.db.close();
  }
}

/// Called once when Kolumn opens: answers checks while it runs, and asks
/// Android for the check every 15 minutes.
Future<void> startBackgroundChecks(SyncService sync) async {
  final port = ReceivePort();
  IsolateNameServer.removePortNameMapping(_mainPort);
  IsolateNameServer.registerPortWithName(port.sendPort, _mainPort);
  port.listen((_) => sync.syncNow());
  try {
    await Workmanager().initialize(kolumnBackgroundCheck);
    await Workmanager().registerPeriodicTask(
      'kolumn-check',
      _task,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  } catch (_) {
    // Not on a phone (tests): nothing to set up.
  }
}
