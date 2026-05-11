import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/code_mode/screens/code_mode_screen.dart';
import '../features/connect/screens/connect_screen.dart';
import '../features/history/screens/history_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/templates/screens/templates_screen.dart';
import '../features/text_mode/screens/text_mode_screen.dart';
import '../features/text_mode/screens/execution_screen.dart';
import '../features/home/screens/onboarding_screen.dart';

class AppRoutes {
  static const home = '/';
  static const connect = '/connect';
  static const textMode = '/text-mode';
  static const execution = '/execution';
  static const codeMode = '/code-mode';
  static const templates = '/templates';
  static const history = '/history';
  static const settings = '/settings';
  static const onboarding = '/onboarding';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.connect,
      builder: (context, state) => const ConnectScreen(),
    ),
    GoRoute(
      path: AppRoutes.textMode,
      builder: (context, state) => const TextModeScreen(),
    ),
    GoRoute(
      path: AppRoutes.execution,
      builder: (context, state) => const ExecutionScreen(),
    ),
    GoRoute(
      path: AppRoutes.codeMode,
      builder: (context, state) => const CodeModeScreen(),
    ),
    GoRoute(
      path: AppRoutes.templates,
      builder: (context, state) => const TemplatesScreen(),
    ),
    GoRoute(
      path: AppRoutes.history,
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
  ],
  errorBuilder: (context, state) => const _RouteErrorScreen(),
);

class _RouteErrorScreen extends StatelessWidget {
  const _RouteErrorScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          'Route not found',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
