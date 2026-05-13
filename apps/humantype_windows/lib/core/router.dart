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
          path: '/scratchpad',
          builder: (context, state) => const ScratchpadPage(),
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
          path: '/files',
          builder: (context, state) => const FileTransferPage(),
        ),
        GoRoute(
          path: '/vault',
          builder: (context, state) => const VaultPage(),
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
      case '/scratchpad': return 2;
      case '/clipboard': return 3;
      case '/notifications': return 4;
      case '/files': return 5;
      case '/vault': return 6;
      case '/settings': return 8;
      case '/calibration': return 9;
      default: return 0;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NavigationView(
      pane: NavigationPane(
        selected: _selectedIndex(),
        displayMode: PaneDisplayMode.auto,
        header: const Padding(
          padding: EdgeInsets.only(left: 12, bottom: 12),
          child: Text(
            'HumanType v5.0',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        onChanged: (index) {
          switch (index) {
            case 0: context.go('/'); break;
            case 1: context.go('/scratchpad'); break;
            case 2: context.go('/clipboard'); break;
            case 3: context.go('/notifications'); break;
            case 4: context.go('/files'); break;
            case 5: context.go('/vault'); break;
            case 6: context.go('/settings'); break;
            case 7: context.go('/calibration'); break;
          }
        },
        items: [
          PaneItem(
            icon: const Icon(FluentIcons.home),
            title: const Text('Overview'),
            body: child,
          ),
          PaneItemSeparator(),
          PaneItem(
            icon: const Icon(FluentIcons.edit_note),
            title: const Text('Shared Scratchpad'),
            body: child,
          ),
          PaneItem(
            icon: const Icon(FluentIcons.copy),
            title: const Text('Clipboard Sync'),
            body: child,
          ),
          PaneItem(
            icon: const Icon(FluentIcons.message_fill),
            title: const Text('Notification Hub'),
            body: child,
          ),
          PaneItem(
            icon: const Icon(FluentIcons.sync),
            title: const Text('File Transfer'),
            body: child,
          ),
          PaneItem(
            icon: const Icon(FluentIcons.shield),
            title: const Text('Biometric Vault'),
            body: child,
          ),
          PaneItemSeparator(),
          PaneItem(
            icon: const Icon(FluentIcons.settings),
            title: const Text('System Settings'),
            body: child,
          ),
          PaneItem(
            icon: const Icon(FluentIcons.compass_n_w),
            title: const Text('Calibration'),
            body: child,
          ),
        ],
      ),
    );
  }
}
