import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humantype_shared/humantype_shared.dart';
import '../services/ocr_service.dart';
import '../../sync/providers/bridge_provider.dart';

class OcrNotifier extends StateNotifier<AsyncValue<String>> {
  final Ref _ref;

  OcrNotifier(this._ref) : super(const AsyncValue.data(''));

  Future<void> captureAndSync() async {
    state = const AsyncValue.loading();
    try {
      // 1. Capture screen (placeholder for actual screen_capturer logic)
      // For now, we'll assume the user has a screenshot file or we use a mock
      final String capturedText = "Example text from screen"; // This would come from service
      
      state = AsyncValue.data(capturedText);
      
      // 2. Sync to Bridge (which relays to Android)
      // This part requires an update to BridgeProvider to allow sending messages
      // _ref.read(bridgeProvider.notifier).sendOcr(capturedText);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final ocrProvider = StateNotifierProvider<OcrNotifier, AsyncValue<String>>((ref) {
  return OcrNotifier(ref);
});
