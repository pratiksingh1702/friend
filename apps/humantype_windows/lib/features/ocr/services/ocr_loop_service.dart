import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../sync/providers/bridge_provider.dart';
import 'ocr_service.dart';
import 'screenshot_service.dart';
import 'package:humantype_shared/humantype_shared.dart';

/// Continuously captures a screen region and extracts text from it.
/// Sends the result back via the Bridge for the Android app to consume.
class OcrLoopService {
  final Ref _ref;
  Timer? _timer;
  final StreamController<String> _textController = StreamController<String>.broadcast();
  bool _running = false;
  String _lastText = '';

  OcrLoopService(this._ref);

  Stream<String> get textStream => _textController.stream;
  bool get isRunning => _running;

  /// Start the real-time OCR loop.
  void start({Duration interval = const Duration(seconds: 4)}) {
    if (_running) return;
    _running = true;

    _timer = Timer.periodic(interval, (_) async {
      await _tick();
    });
    print('[OcrLoop] Started. Interval: ${interval.inSeconds}s');
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _running = false;
    print('[OcrLoop] Stopped.');
  }

  void dispose() {
    stop();
    _textController.close();
  }

  Future<void> _tick() async {
    try {
      final String? imgPath = await ScreenshotService.captureScreen();
      if (imgPath == null) return;

      final String text = await OcrService.extractText(imgPath);
      
      // Cleanup temp image
      try { await File(imgPath).delete(); } catch (_) {}

      if (text.isNotEmpty && text != _lastText) {
        _lastText = text;
        _textController.add(text);
        
        // Sync to Bridge
        _ref.read(bridgeProvider.notifier).sendMessage(
          WsMessage(
            type: MessageType.ocrResult,
            sender: DeviceInfo.windows(deviceId: 'local-pc'),
            target: MessageTarget.broadcast,
            payload: {
              'text': text,
              'confidence': 0.95, // Mock confidence
            },
          ),
        );
        
        print('[OcrLoop] New text detected and synced.');
      }
    } catch (e) {
      print('[OcrLoop] Error during tick: $e');
    }
  }
}

/// Riverpod provider for the OCR loop service.
final ocrLoopServiceProvider = Provider<OcrLoopService>((ref) {
  final service = OcrLoopService(ref);
  ref.onDispose(() => service.dispose());
  return service;
});
