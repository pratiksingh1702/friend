import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/dashboard/screens/overview_page.dart';
import '../features/dashboard/screens/scratchpad_page.dart';
import '../features/dashboard/screens/file_transfer_page.dart';
import '../features/dashboard/screens/notifications_page.dart';
import '../features/dashboard/screens/clipboard_page.dart';
import '../features/dashboard/screens/vault_page.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/calibration/screens/calibration_screen.dart';
import '../features/overlay/overlay_window.dart';

import '../features/shell/widgets/floating_bottom_nav.dart';
import '../features/dashboard/widgets/noise_background.dart';
import '../features/shell/widgets/sidebar.dart';
import '../features/shell/widgets/top_header.dart';
import 'theme/ht_colors.dart';

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
          builder: (context, state) => const OverviewPage(),
        ),
        GoRoute(
          path: '/vault',
          builder: (context, state) => const VaultPage(),
        ),
        GoRoute(
          path: '/scratchpad',
          builder: (context, state) => const ScratchpadPage(),
        ),
        GoRoute(
          path: '/files',
          builder: (context, state) => const FileTransferPage(),
        ),
        GoRoute(
          path: '/clipboard',
          builder: (context, state) => const ClipboardPage(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsPage(),
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
    GoRoute(
      path: '/overlay',
      builder: (context, state) => const OverlayWindow(),
    ),
  ],
);



class AppShell extends ConsumerWidget {
  final Widget child;
  final String location;
  const AppShell({super.key, required this.child, required this.location});

  int _selectedIndex() {
    switch (location) {
      case '/': return 0;
      case '/vault': return 1;
      case '/scratchpad': return 2;
      case '/files': return 3;
      case '/clipboard': return 4;
      case '/notifications': return 5;
      case '/settings': return 6;
      case '/calibration': return 7;
      default: return 0;
    }
  }

  void _onItemSelected(BuildContext context, int index) {
    switch (index) {
      case 0: context.go('/'); break;
      case 1: context.go('/vault'); break;
      case 2: context.go('/scratchpad'); break;
      case 3: context.go('/files'); break;
      case 4: context.go('/clipboard'); break;
      case 5: context.go('/notifications'); break;
      case 6: context.go('/settings'); break;
      case 7: context.go('/calibration'); break;
    }
  }

  void _onRouteSelected(BuildContext context, String route) {
    context.go(route);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: HTColors.bgBase,
      child: Row(
        children: [
          Sidebar(
            activeRoute: location,
            onRouteSelected: (route) => _onRouteSelected(context, route),
          ),
          Expanded(
            child: Column(
              children: [
                const TopHeader(),
                Expanded(
                  child: Stack(
                    children: [
                      child,
                      FloatingBottomNav(
                        selectedIndex: _selectedIndex(),
                        onItemSelected: (index) => _onItemSelected(context, index),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
