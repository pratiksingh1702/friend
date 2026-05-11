import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'core/router.dart';
import 'core/theme.dart';
import 'features/calibration/widgets/highlight_overlay.dart';
import 'features/tray/tray_manager_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize window manager
  await windowManager.ensureInitialized();
  
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1200, 800),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    title: 'HumanType Command Center',
  );
  
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  // Initialize Tray
  await TrayManagerService().init();

  runApp(
    const ProviderScope(
      child: HumanTypeWindowsApp(),
    ),
  );
}

class HumanTypeWindowsApp extends ConsumerWidget {
  const HumanTypeWindowsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FluentApp.router(
      title: 'HumanType Windows',
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      color: AppTheme.primaryColor,
      routerConfig: router,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            const HighlightOverlay(),
          ],
        );
      },
    );
  }
}
