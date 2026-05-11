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
    this.confidence = 1.0,
    this.lastSuccessTimestamp,
    this.status = 'idle',
  });

  final String? lastResult;
  final bool isProcessing;
  final String? aiResponse;
  final String? error;
  final double confidence;
  final DateTime? lastSuccessTimestamp;
  final String status;

  OcrState copyWith({
    String? lastResult,
    bool? isProcessing,
    String? aiResponse,
    String? error,
    double? confidence,
    DateTime? lastSuccessTimestamp,
    String? status,
  }) {
    return OcrState(
      lastResult: lastResult ?? this.lastResult,
      isProcessing: isProcessing ?? this.isProcessing,
      aiResponse: aiResponse ?? this.aiResponse,
      error: error ?? this.error,
      confidence: confidence ?? this.confidence,
      lastSuccessTimestamp: lastSuccessTimestamp ?? this.lastSuccessTimestamp,
      status: status ?? this.status,
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
        final confidence = (msg.payload['confidence'] as num?)?.toDouble() ?? 1.0;
        
        if (text != null && text.trim().isNotEmpty) {
          state = state.copyWith(
            lastResult: text,
            confidence: confidence,
            lastSuccessTimestamp: DateTime.now(),
            status: 'active',
            error: null,
          );
        } else if (text != null && text.trim().isEmpty) {
           state = state.copyWith(status: 'empty');
        }
      }
    });

    return const OcrState();
  }

  Future<void> askAi(AiTaskType task, {String? customIntent}) async {
    final ai = ref.read(aiServiceProvider);
    final text = state.lastResult;
    if (ai == null || text == null || text.isEmpty) return;

    state = state.copyWith(isProcessing: true, error: null, status: 'ai_processing');
    try {
      final request = AiRequest(
        text: text,
        task: task,
        context: {'customIntent': customIntent},
      );
      final response = await ai.processRequest(request);
      state = state.copyWith(
        aiResponse: response.result ?? response.suggestions.join('\n'),
        isProcessing: false,
        status: 'ai_done',
      );
    } catch (e) {
      state = state.copyWith(isProcessing: false, error: e.toString(), status: 'error');
    }
  }

  void clear() {
    state = const OcrState();
  }
}

final ocrProvider = NotifierProvider<OcrNotifier, OcrState>(OcrNotifier.new);
