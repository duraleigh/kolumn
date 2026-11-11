import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'board/board_screen.dart';
import 'data/database.dart';
import 'data/repository.dart';
import 'state/providers.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repo = KolumnRepository(KolumnDb());
  await repo.ensureStarterBoard();
  runApp(ProviderScope(overrides: [repositoryProvider.overrideWithValue(repo)], child: const KolumnApp()));
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
      home: const BoardScreen(),
    );
  }
}
