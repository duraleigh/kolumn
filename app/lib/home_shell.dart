import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'board/board_screen.dart';
import 'planner/planner_screen.dart';
import 'state/providers.dart';

/// Kolumn's two homes: the Kolumns (boards) and the Planner. A bar at the
/// bottom on a phone, a rail down the side on a computer. Both stay alive,
/// so switching back keeps your place.
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  static const wide = 840.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(_tabProvider).value == 'planner' ? 1 : 0;
    void pick(int i) => ref.read(repositoryProvider).setSetting('home.tab', i == 1 ? 'planner' : 'kolumns');
    final pages = IndexedStack(index: tab, children: const [BoardScreen(), PlannerScreen()]);
    if (MediaQuery.sizeOf(context).width >= wide) {
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
                  NavigationRailDestination(icon: Icon(Icons.calendar_today_outlined), selectedIcon: Icon(Icons.calendar_today_rounded), label: Text('Planner')),
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

final _tabProvider = StreamProvider<String?>((ref) => ref.watch(repositoryProvider).watchSetting('home.tab'));
