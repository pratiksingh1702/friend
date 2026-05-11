import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/calibration/screens/calibration_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: shellNavigatorKey,
      builder: (context, state, child) {
        return AppShell(child: child, location: state.uri.toString());
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/calibration',
          builder: (context, state) => const CalibrationScreen(),
        ),
      ],
    ),
  ],
);

class AppShell extends ConsumerWidget {
  final Widget child;
  final String location;
  const AppShell({super.key, required this.child, required this.location});

  int _selectedIndex() {
    if (location.startsWith('/settings')) return 1;
    if (location.startsWith('/calibration')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScaffoldPage(
      header: const PageHeader(
        title: Text('HumanType Command Center'),
      ),
      content: NavigationView(
        pane: NavigationPane(
          selected: _selectedIndex(),
          displayMode: PaneDisplayMode.auto,
          onChanged: (index) {
            switch (index) {
              case 0:
                context.go('/');
                break;
              case 1:
                context.go('/settings');
                break;
              case 2:
                context.go('/calibration');
                break;
            }
          },
          items: [
            PaneItem(
              icon: const Icon(FluentIcons.home),
              title: const Text('Dashboard'),
              body: child,
            ),
            PaneItem(
              icon: const Icon(FluentIcons.settings),
              title: const Text('Settings'),
              body: child,
            ),
            PaneItem(
              icon: const Icon(FluentIcons.location),
              title: const Text('Calibration'),
              body: child,
            ),
          ],
        ),
      ),
    );
  }
}
