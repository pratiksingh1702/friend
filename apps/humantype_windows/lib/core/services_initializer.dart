import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import '../features/clipboard/services/clipboard_sync_service.dart';
import '../features/notifications/services/notification_receiver_service.dart';
import '../features/sync/services/android_sync_service.dart';
import '../features/file_transfer/providers/pending_transfer_provider.dart';
import '../features/file_transfer/services/file_sender_service.dart';
import '../features/file_transfer/services/remote_file_browser_service.dart';
import '../features/file_transfer/services/file_receiver_service.dart';

class GlobalServicesInitializer extends ConsumerStatefulWidget {
  final Widget child;
  const GlobalServicesInitializer({super.key, required this.child});

  @override
  ConsumerState<GlobalServicesInitializer> createState() => _GlobalServicesInitializerState();
}

class _GlobalServicesInitializerState extends ConsumerState<GlobalServicesInitializer> {
  @override
  void initState() {
    super.initState();
    // Initialize services
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(clipboardSyncServiceProvider).startMonitoring();
      ref.read(notificationReceiverServiceProvider).init();
      _initHotkeys();
    });
  }

  void _initHotkeys() async {
    // Register Ctrl+Shift+V for Password Request
    final hotKey = HotKey(
      key: LogicalKeyboardKey.keyV,
      modifiers: [HotKeyModifier.control, HotKeyModifier.shift],
      scope: HotKeyScope.system,
    );

    await hotKeyManager.register(
      hotKey,
      keyDownHandler: (hotKey) {
        print('[Hotkey] Ctrl+Shift+V pressed - Requesting password...');
        ref.read(androidSyncServiceProvider).sendPasswordRequest();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingFile = ref.watch(pendingFileTransferProvider);
    // Initialize file receiver
    ref.watch(fileReceiverServiceProvider);
    // Initialize file browser responder
    ref.watch(remoteFileBrowserServiceProvider);

    // Listen for connection status to restart monitoring if needed
    ref.listen(androidSyncServiceProvider, (previous, next) {
      if (next.isConnected) {
        ref.read(clipboardSyncServiceProvider).startMonitoring();
        
        // Handle pending file transfer from CLI
        if (pendingFile != null) {
          print('[Services] Starting pending file transfer: $pendingFile');
          ref.read(fileSenderServiceProvider).sendFile(pendingFile).listen((progress) {
            print('[Transfer] ${progress.status.name}: ${progress.progressFraction}');
          });
          // Clear it so it doesn't repeat on reconnect
          ref.read(pendingFileTransferProvider.notifier).state = null;
        }
      } else {
        ref.read(clipboardSyncServiceProvider).stopMonitoring();
      }
    });

    return widget.child;
  }
}
