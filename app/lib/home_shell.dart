import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'board/board_screen.dart';
import 'planner/planner_screen.dart';
import 'state/providers.dart';

/// Kolumn's two homes: the Kolumns and the Planner. A bar at the bottom on a
/// phone, a rail down the side on a computer. Both stay alive, so switching
/// back keeps your place. Kolumn opens on the one chosen in Settings.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  static const wide = 840.0;

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int? _tab;

  @override
  Widget build(BuildContext context) {
    final start = ref.watch(startScreenProvider);
    if (_tab == null) {
      if (!start.hasValue) return const Scaffold(body: SizedBox.shrink());
      _tab = start.value == 'planner' ? 1 : 0;
    }
    final tab = _tab!;
    void pick(int i) => setState(() => _tab = i);
    final pages = IndexedStack(index: tab, children: const [BoardScreen(), PlannerScreen()]);
    if (MediaQuery.sizeOf(context).width >= HomeShell.wide) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                selectedIndex: tab,
                onDestinationSelected: pick,
                labelType: NavigationRailLabelType.all,
                groupAlignment: -0.9,
                destinations: const [
                  NavigationRailDestination(icon: Icon(Icons.view_kanban_outlined), selectedIcon: Icon(Icons.view_kanban_rounded), label: Text('Kolumns')),
                  NavigationRailDestination(
                    icon: Icon(Icons.calendar_today_outlined),
                    selectedIcon: Icon(Icons.calendar_today_rounded),
                    label: Text('Planner'),
                  ),
                ],
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: pages),
          ],
        ),
      );
    }
    return Scaffold(
      body: pages,
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: pick,
        height: 68,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.view_kanban_outlined), selectedIcon: Icon(Icons.view_kanban_rounded), label: 'Kolumns'),
          NavigationDestination(icon: Icon(Icons.calendar_today_outlined), selectedIcon: Icon(Icons.calendar_today_rounded), label: 'Planner'),
        ],
      ),
    );
  }
}

/// Which screen Kolumn opens on: 'kolumns' (the usual) or 'planner'.
final startScreenProvider = StreamProvider<String?>((ref) => ref.watch(repositoryProvider).watchSetting('home.start'));
