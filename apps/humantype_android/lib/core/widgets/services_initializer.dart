import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/file_transfer/services/file_transfer_service.dart';
import '../../features/clipboard/services/clipboard_monitor_service.dart';
import '../../features/otp/services/sms_listener_service.dart';
import '../../features/scratchpad/providers/scratchpad_provider.dart';
import '../../features/connect/services/wifi_service.dart';
import 'package:humantype_shared/humantype_shared.dart';

class ServicesInitializer extends ConsumerStatefulWidget {
  final Widget child;
  const ServicesInitializer({super.key, required this.child});

  @override
  ConsumerState<ServicesInitializer> createState() => _ServicesInitializerState();
}

class _ServicesInitializerState extends ConsumerState<ServicesInitializer> {
  @override
  void initState() {
    super.initState();
    // Initialize global background services
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final wifi = ref.read(wifiServiceProvider);
      
      // 1. File Transfer
      ref.read(fileTransferServiceProvider);

      // 2. Clipboard Sync
      final clipboard = ref.read(clipboardMonitorServiceProvider);
      clipboard.start();
      wifi.router.register(MessageType.clipboardSync, (msg) async {
        final text = msg.payload['content'] as String?;
        if (text != null) await clipboard.applyIncoming(text);
      });

      // 3. OTP Listener
      ref.read(smsListenerServiceProvider).startListening();

      // 4. Scratchpad Sync
      wifi.router.register(MessageType.scratchpadSync, (msg) async {
        final content = msg.payload['content'] as String?;
        if (content != null) {
          ref.read(scratchpadProvider.notifier).updateContent(content, remote: true);
        }
      });

      print('[Services] Phase 9 background services initialized');
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
