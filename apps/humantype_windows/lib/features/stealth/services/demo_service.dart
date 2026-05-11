import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DemoSession {
  final String text;
  final int wpm;
  final double progress;

  DemoSession({required this.text, required this.wpm, required this.progress});
}

class DemoService extends StateNotifier<DemoSession?> {
  Timer? _timer;
  final Random _random = Random();

  DemoService() : super(null);

  void startDemo() {
    _timer?.cancel();
    
    final fullText = "The quick brown fox jumps over the lazy dog. Programming is the art of algorithm design and the craft of debugging errant code.";
    int index = 0;
    
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      index = (index + 1) % fullText.length;
      if (index == 0) index = 1;
      
      state = DemoSession(
        text: fullText.substring(0, index),
        wpm: 60 + _random.nextInt(15),
        progress: index / fullText.length,
      );
    });
  }

  void stopDemo() {
    _timer?.cancel();
    state = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final demoProvider = StateNotifierProvider<DemoService, DemoSession?>((ref) {
  return DemoService();
});
