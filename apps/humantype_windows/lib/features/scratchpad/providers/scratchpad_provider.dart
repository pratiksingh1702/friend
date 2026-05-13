import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../sync/services/android_sync_service.dart';
import 'package:humantype_shared/protocols/message_types.dart';

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

class ScratchpadNotifier extends StateNotifier<ScratchpadState> {
  final AndroidSyncService _syncService;
  StreamSubscription? _sub;
  Timer? _debounceTimer;

  ScratchpadNotifier(this._syncService) : super(const ScratchpadState()) {
    _sub = _syncService.messageStream.listen(_onMessage);
  }

  void _onMessage(Map<String, dynamic> msg) {
    final type = msg['type'] as String?;
    if (type == MessageType.scratchpadSync.wireName) {
      final payload = msg['payload'] as Map<String, dynamic>?;
      final newContent = payload?['content'] as String?;
      final timestamp = payload?['timestamp_ms'] as int?;
      
      if (newContent != null && newContent != state.content) {
        state = state.copyWith(
          content: newContent,
          isSyncing: false,
          lastSyncedAt: timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : DateTime.now(),
          lastSyncedBy: payload?['last_modified_by'] as String? ?? 'android',
        );
      }
    }
  }

  void updateContent(String newContent) {
    if (newContent == state.content) return;
    
    state = state.copyWith(content: newContent, isSyncing: true);
    
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _syncService.sendScratchpad(newContent);
      state = state.copyWith(
        isSyncing: false, 
        lastSyncedAt: DateTime.now(),
        lastSyncedBy: 'windows'
      );
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _debounceTimer?.cancel();
    super.dispose();
  }
}

final scratchpadProvider = StateNotifierProvider<ScratchpadNotifier, ScratchpadState>((ref) {
  return ScratchpadNotifier(ref.watch(androidSyncServiceProvider));
});
