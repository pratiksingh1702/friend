import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'core/router.dart';
import 'core/theme.dart';
import 'features/calibration/widgets/highlight_overlay.dart';
import 'features/tray/tray_manager_service.dart';
import 'core/services_initializer.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:local_notifier/local_notifier.dart';
import 'features/file_transfer/providers/pending_transfer_provider.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('[Main] App started with args: $args');
  String? fileToSend;
  if (args.contains('--send-file') && args.length > args.indexOf('--send-file') + 1) {
    fileToSend = args[args.indexOf('--send-file') + 1];
    print('[Main] File to send: $fileToSend');
  }
  
  // Initialize window manager
  await windowManager.ensureInitialized();
  
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1200, 800),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    title: 'HumanType Command Center',
  );
  
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  // Initialize Tray
  await TrayManagerService().init();

  // Initialize Global Hotkeys
  await hotKeyManager.unregisterAll();

  // Initialize Local Notifier
  await localNotifier.setup(
    appName: 'HumanType',
  );

  runApp(
    ProviderScope(
      overrides: [
        if (fileToSend != null)
          pendingFileTransferProvider.overrideWith((ref) => fileToSend),
      ],
      child: const HumanTypeWindowsApp(),
    ),
  );
}

class HumanTypeWindowsApp extends ConsumerWidget {
  const HumanTypeWindowsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlobalServicesInitializer(
      child: FluentApp.router(
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
      ),
    );
  }
}
