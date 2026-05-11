import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humantype_shared/humantype_shared.dart';

import '../../connect/services/wifi_service.dart';
import '../../settings/providers/ai_provider.dart';

class OcrState {
  const OcrState({
    this.lastResult,
    this.isProcessing = false,
    this.aiResponse,
    this.error,
  });

  final String? lastResult;
  final bool isProcessing;
  final String? aiResponse;
  final String? error;

  OcrState copyWith({
    String? lastResult,
    bool? isProcessing,
    String? aiResponse,
    String? error,
  }) {
    return OcrState(
      lastResult: lastResult ?? this.lastResult,
      isProcessing: isProcessing ?? this.isProcessing,
      aiResponse: aiResponse ?? this.aiResponse,
      error: error ?? this.error,
    );
  }
}

class OcrNotifier extends Notifier<OcrState> {
  @override
  OcrState build() {
    // Listen for OCR messages from WiFi service
    ref.read(wifiServiceProvider).messages.listen((msg) {
      if (msg.type == MessageType.ocrResult) {
        final text = msg.payload['text'] as String?;
        if (text != null) {
          state = state.copyWith(lastResult: text);
        }
      }
    });

    return const OcrState();
  }

  Future<void> askAi(String intent) async {
    final ai = ref.read(aiServiceProvider);
    final text = state.lastResult;
    if (ai == null || text == null || text.isEmpty) return;

    state = state.copyWith(isProcessing: true, error: null);
    try {
      final response = await ai.processOcrResult(text, intent);
      state = state.copyWith(aiResponse: response, isProcessing: false);
    } catch (e) {
      state = state.copyWith(isProcessing: false, error: e.toString());
    }
  }

  void clear() {
    state = const OcrState();
  }
}

final ocrProvider = NotifierProvider<OcrNotifier, OcrState>(OcrNotifier.new);
