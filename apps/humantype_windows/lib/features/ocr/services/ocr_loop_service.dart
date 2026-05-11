import 'dart:async';
import 'package:flutter/services.dart';
import 'ocr_service.dart';
import 'screenshot_service.dart';

/// Continuously captures a screen region and extracts text from it.
/// Sends the result back via a stream for the Android app to consume.
class OcrLoopService {
  Timer? _timer;
  final StreamController<String> _textController = StreamController<String>.broadcast();
  Rect? _captureArea;
  bool _running = false;
  String _lastText = '';

  Stream<String> get textStream => _textController.stream;
  bool get isRunning => _running;

  /// Start the real-time OCR loop.
  /// [area] is the screen Rect to capture. If null, captures full screen.
  void start({Rect? area, Duration interval = const Duration(seconds: 2)}) {
    if (_running) return;
    _captureArea = area;
    _running = true;

    _timer = Timer.periodic(interval, (_) async {
      await _tick();
    });
    print('[OcrLoop] Started. Area: $area, Interval: ${interval.inMilliseconds}ms');
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
      if (text.isNotEmpty && text != _lastText) {
        _lastText = text;
        _textController.add(text);
        print('[OcrLoop] New text detected: ${text.substring(0, text.length.clamp(0, 60))}...');
      }
    } catch (e) {
      print('[OcrLoop] Error during tick: $e');
    }
  }
}

/// Riverpod provider for the OCR loop service.
final ocrLoopServiceProvider = OcrLoopService();
