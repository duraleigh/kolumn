import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/database.dart';
import 'data/repository.dart';
import 'home_shell.dart';
import 'state/providers.dart';
import 'sync/hub_client.dart';
import 'sync/reminders.dart';
import 'sync/sync_service.dart';
import 'theme/app_theme.dart';
import 'ui/sign_in_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repo = KolumnRepository(KolumnDb());
  final sync = SyncService(
    repo: repo,
    hub: HubClient(credentials: SecureCredentialStore()),
  );
  await sync.start();
  // Reminders the person set, shown at their time even with Kolumn closed.
  unawaited(ReminderService(repo).start());
  runApp(ProviderScope(overrides: [repositoryProvider.overrideWithValue(repo), syncServiceProvider.overrideWithValue(sync)], child: const KolumnApp()));
}

class KolumnApp extends ConsumerWidget {
  const KolumnApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider).value ?? ThemeMode.system;
    return MaterialApp(
      title: 'Kolumn',
      debugShowCheckedModeBanner: false,
      theme: KolumnTheme.light(),
      darkTheme: KolumnTheme.dark(),
      themeMode: mode,
      home: const AppGate(),
    );
  }
}

/// Signed in: Kolumns and the Planner. Signed out: the hub sign-in.
class AppGate extends ConsumerWidget {
  const AppGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncStatusProvider).value ?? ref.read(syncServiceProvider).current;
    if (status.state == SyncState.signedOut) {
      return SignInScreen(message: status.message == null ? null : 'Your session ended. Please sign in again.');
    }
    return const HomeShell();
  }
}
