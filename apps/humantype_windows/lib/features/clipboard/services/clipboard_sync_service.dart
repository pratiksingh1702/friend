import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../sync/services/android_sync_service.dart';
import 'package:humantype_shared/protocols/message_types.dart';
import '../providers/clipboard_history_provider.dart';

class ClipboardSyncService {
  final Ref _ref;
  final AndroidSyncService _syncService;
  StreamSubscription? _sub;
  String? _lastClipboardContent;
  bool _isProcessingRemoteUpdate = false;
  Timer? _pollingTimer;

  ClipboardSyncService(this._ref, this._syncService) {
    _sub = _syncService.messageStream.listen(_onMessage);
  }

  void _onMessage(Map<String, dynamic> msg) {
    final type = msg['type'] as String?;
    if (type == MessageType.clipboardSync.wireName) {
      final payload = msg['payload'] as Map<String, dynamic>?;
      final content = payload?['content'] as String?;
      
      if (content != null && content != _lastClipboardContent) {
        _ref.read(clipboardHistoryProvider.notifier).addItem(content, true);
        _applyRemoteClipboard(content);
      }
    }
  }

  Future<void> _applyRemoteClipboard(String content) async {
    _isProcessingRemoteUpdate = true;
    _lastClipboardContent = content;
    await Clipboard.setData(ClipboardData(text: content));
    print('[Clipboard] Applied remote clipboard content');
    
    await Future.delayed(const Duration(milliseconds: 500));
    _isProcessingRemoteUpdate = false;
  }

  void startMonitoring() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) async {
      if (_isProcessingRemoteUpdate || !_syncService.isConnected) return;

      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final currentContent = data?.text;

      if (currentContent != null && 
          currentContent.isNotEmpty && 
          currentContent != _lastClipboardContent) {
        _lastClipboardContent = currentContent;
        _ref.read(clipboardHistoryProvider.notifier).addItem(currentContent, false);
        _syncService.sendClipboard(currentContent);
        print('[Clipboard] Sent local clipboard update');
      }
    });
  }

  void stopMonitoring() {
    _pollingTimer?.cancel();
  }

  void dispose() {
    _sub?.cancel();
    _pollingTimer?.cancel();
  }
}

final clipboardSyncServiceProvider = Provider<ClipboardSyncService>((ref) {
  final service = ClipboardSyncService(ref, ref.watch(androidSyncServiceProvider));
  ref.onDispose(service.dispose);
  return service;
});
