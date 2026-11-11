import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'activity/activity_screen.dart';
import 'activity/alerts_screen.dart';
import 'board/board_screen.dart';
import 'planner/planner_screen.dart';
import 'state/providers.dart';

/// Kolumn's homes: the Kolumns, Activity, the Planner and Alerts. A bar at
/// the bottom on a phone, a rail down the side on a computer. All stay
/// alive, so switching back keeps your place. Kolumn opens on the one chosen
/// in Settings.
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
      _tab = startScreens.indexOf(start.value ?? 'kolumns').clamp(0, 2);
    }
    final tab = _tab!;
    void pick(int i) => setState(() => _tab = i);
    final unread = ref.watch(unreadAlertsProvider);
    Widget bell(bool on) => Badge(
      isLabelVisible: unread > 0,
      label: Text(unread > 99 ? '99+' : '$unread'),
      child: Icon(on ? Icons.notifications_rounded : Icons.notifications_none_rounded),
    );
    final pages = IndexedStack(index: tab, children: const [BoardScreen(), ActivityScreen(), PlannerScreen(), AlertsScreen()]);
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
                destinations: [
                  const NavigationRailDestination(icon: Icon(Icons.view_kanban_outlined), selectedIcon: Icon(Icons.view_kanban_rounded), label: Text('Kolumns')),
                  const NavigationRailDestination(icon: Icon(Icons.show_chart_rounded), label: Text('Activity')),
                  const NavigationRailDestination(icon: Icon(Icons.calendar_today_outlined), selectedIcon: Icon(Icons.calendar_today_rounded), label: Text('Planner')),
                  NavigationRailDestination(icon: bell(false), selectedIcon: bell(true), label: const Text('Alerts')),
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
        destinations: [
          const NavigationDestination(icon: Icon(Icons.view_kanban_outlined), selectedIcon: Icon(Icons.view_kanban_rounded), label: 'Kolumns'),
          const NavigationDestination(icon: Icon(Icons.show_chart_rounded), label: 'Activity'),
          const NavigationDestination(icon: Icon(Icons.calendar_today_outlined), selectedIcon: Icon(Icons.calendar_today_rounded), label: 'Planner'),
          NavigationDestination(icon: bell(false), selectedIcon: bell(true), label: 'Alerts'),
        ],
      ),
    );
  }
}

/// The screens Kolumn can open on, in tab order.
const startScreens = ['kolumns', 'activity', 'planner'];

/// Which screen Kolumn opens on: 'kolumns' (the usual), 'activity' or 'planner'.
final startScreenProvider = StreamProvider<String?>((ref) => ref.watch(repositoryProvider).watchSetting('home.start'));
