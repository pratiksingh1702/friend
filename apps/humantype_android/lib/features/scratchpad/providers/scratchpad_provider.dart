import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humantype_shared/humantype_shared.dart';
import '../../connect/services/wifi_service.dart';
import '../../../core/services/device_identity.dart';

class ScratchpadState {
  final String content;
  final bool isSyncing;
  final DateTime? lastSyncedAt;
  final String? lastSyncedBy;

  const ScratchpadState({
    this.content = '',
    this.isSyncing = false,
    this.lastSyncedAt,
    this.lastSyncedBy,
  });

  ScratchpadState copyWith({
    String? content,
    bool? isSyncing,
    DateTime? lastSyncedAt,
    String? lastSyncedBy,
  }) {
    return ScratchpadState(
      content: content ?? this.content,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      lastSyncedBy: lastSyncedBy ?? this.lastSyncedBy,
    );
  }
}

class ScratchpadNotifier extends Notifier<ScratchpadState> {
  Timer? _debounce;

  @override
  ScratchpadState build() {
    final wifi = ref.watch(wifiServiceProvider);
    
    // Listen for incoming syncs
    ref.listen(wifiServiceProvider, (previous, next) {
      // WiFi service handles routing, but we can also listen to the message stream
    });

    // We can't use ref.listen inside build easily for stream, so we use a sub in build
    // Actually, it's better to use ref.onDispose to clean up a subscription.
    return const ScratchpadState();
  }

  void updateContent(String newContent, {bool remote = false}) {
    if (state.content == newContent) return;

    state = state.copyWith(
      content: newContent,
      isSyncing: !remote,
      lastSyncedAt: DateTime.now(),
      lastSyncedBy: remote ? 'windows' : 'android',
    );

    if (!remote) {
      _syncToRemote(newContent);
    }
  }

  void _syncToRemote(String content) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final wifi = ref.read(wifiServiceProvider);
      if (!wifi.isConnected) return;

      final deviceId = await DeviceIdentityService().getDeviceId();
      
      wifi.router.route(WsMessage(
        type: MessageType.scratchpadSync,
        sender: DeviceInfo.android(deviceId: deviceId),
        target: MessageTarget.broadcast,
        payload: {
          'content': content,
          'last_modified_by': 'android',
          'timestamp_ms': DateTime.now().millisecondsSinceEpoch,
        },
      ));

      state = state.copyWith(isSyncing: false);
    });
  }
}

final scratchpadProvider = NotifierProvider<ScratchpadNotifier, ScratchpadState>(() {
  return ScratchpadNotifier();
});
