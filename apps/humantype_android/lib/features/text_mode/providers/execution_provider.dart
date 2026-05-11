import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:humantype_shared/humantype_shared.dart';

import '../../connect/services/wifi_service.dart';
import '../../history/providers/history_provider.dart';
import '../../settings/providers/settings_provider.dart';
import 'session_provider.dart';

final executionProvider = NotifierProvider<ExecutionNotifier, ExecutionState>(
  ExecutionNotifier.new,
);

class ExecutionState {
  const ExecutionState({
    required this.queue,
    required this.queuePosition,
    required this.isRunning,
    required this.isPaused,
    required this.currentChar,
    required this.charsCompleted,
    required this.charsTotal,
    required this.estimatedSecondsRemaining,
    required this.currentWpm,
  });

  final List<TypeCommand> queue;
  final int queuePosition;
  final bool isRunning;
  final bool isPaused;
  final String? currentChar;
  final int charsCompleted;
  final int charsTotal;
  final int estimatedSecondsRemaining;
  final double currentWpm;

  factory ExecutionState.idle() {
    return const ExecutionState(
      queue: [],
      queuePosition: 0,
      isRunning: false,
      isPaused: false,
      currentChar: null,
      charsCompleted: 0,
      charsTotal: 0,
      estimatedSecondsRemaining: 0,
      currentWpm: 0,
    );
  }

  ExecutionState copyWith({
    List<TypeCommand>? queue,
    int? queuePosition,
    bool? isRunning,
    bool? isPaused,
    String? currentChar,
    int? charsCompleted,
    int? charsTotal,
    int? estimatedSecondsRemaining,
    double? currentWpm,
  }) {
    return ExecutionState(
      queue: queue ?? this.queue,
      queuePosition: queuePosition ?? this.queuePosition,
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      currentChar: currentChar ?? this.currentChar,
      charsCompleted: charsCompleted ?? this.charsCompleted,
      charsTotal: charsTotal ?? this.charsTotal,
      estimatedSecondsRemaining:
          estimatedSecondsRemaining ?? this.estimatedSecondsRemaining,
      currentWpm: currentWpm ?? this.currentWpm,
    );
  }
}

class ExecutionNotifier extends Notifier<ExecutionState> {
  final ExecutionPlanner _planner = ExecutionPlanner();
  bool _sending = false;
  bool _stopRequested = false;
  Completer<void>? _resumeCompleter;
  int _charSent = 0;

  @override
  ExecutionState build() => ExecutionState.idle();

  Future<void> buildQueue(List<Section> sections) async {
    ref.read(sessionProvider.notifier).setStatus(SessionStatus.planning);
    state = state.copyWith(
      isRunning: false,
      isPaused: false,
      queuePosition: 0,
      charsCompleted: 0,
      currentChar: null,
    );

    final queue = await _planner.buildQueue(sections);
    final totalChars =
        queue.where((cmd) => cmd.type == CommandType.char).length;
    final remainingMs = queue.fold<int>(
      0,
      (sum, cmd) => sum + cmd.delayMs,
    );
    state = state.copyWith(
      queue: queue,
      charsTotal: totalChars,
      estimatedSecondsRemaining: (remainingMs / 1000).round(),
    );
    ref.read(sessionProvider.notifier).setStatus(SessionStatus.ready);
  }

  Future<void> start() async {
    if (_sending || state.queue.isEmpty) return;
    final wifi = ref.read(wifiServiceProvider);
    if (!wifi.isConnected) return;

    _sending = true;
    _stopRequested = false;
    _charSent = state.charsCompleted;
    state = state.copyWith(isRunning: true, isPaused: false);
    wifi.sendSessionControl('START');
    ref.read(sessionProvider.notifier).setStatus(SessionStatus.executing);
    final settings = ref.read(settingsProvider);
    if (settings.keepScreenOn) {
      await WakelockPlus.enable();
    }

    for (var i = state.queuePosition; i < state.queue.length; i++) {
      if (_stopRequested) break;

      while (state.isPaused) {
        _resumeCompleter ??= Completer<void>();
        await _resumeCompleter!.future;
        _resumeCompleter = null;
      }

      final cmd = state.queue[i];
      if (cmd.type == CommandType.pause && cmd.delayMs == 0) {
        state = state.copyWith(
          isPaused: true,
          queuePosition: i + 1,
          currentChar: null,
        );
        ref
            .read(sessionProvider.notifier)
            .setStatus(SessionStatus.sectionBreak);
        continue;
      }
      await wifi.sendCommand(cmd);

      if (cmd.type == CommandType.char) {
        _charSent += 1;
      }

      final remainingMs = _remainingDelayMs(i + 1);
      state = state.copyWith(
        queuePosition: i + 1,
        currentChar: cmd.char,
        charsCompleted: _charSent,
        estimatedSecondsRemaining: (remainingMs / 1000).round(),
        currentWpm: _calculateWpm(_charSent, remainingMs),
      );
    }

    _sending = false;
    state = state.copyWith(isRunning: false, isPaused: false);
    await WakelockPlus.disable();
    if (!_stopRequested) {
      final settings = ref.read(settingsProvider);
      ref.read(sessionProvider.notifier).setStatus(SessionStatus.completed);
      if (settings.historyEnabled) {
        final session = ref.read(sessionProvider);
        final completed = session.copyWith(
          charsCompleted: state.charsCompleted,
          charsTotal: state.charsTotal,
          estimatedSecondsRemaining: 0,
          currentWpm: state.currentWpm,
          status: SessionStatus.completed,
        );
        await ref.read(historyProvider.notifier).addSession(completed);
      }
    }
  }

  void pause() {
    if (!state.isRunning) return;
    state = state.copyWith(isPaused: true);
    ref.read(wifiServiceProvider).sendSessionControl('PAUSE');
    ref.read(sessionProvider.notifier).setStatus(SessionStatus.paused);
  }

  void resume() {
    if (!state.isRunning) return;
    state = state.copyWith(isPaused: false);
    ref.read(wifiServiceProvider).sendSessionControl('RESUME');
    _resumeCompleter?.complete();
    ref.read(sessionProvider.notifier).setStatus(SessionStatus.executing);
  }

  void stop() {
    if (!state.isRunning) return;
    _stopRequested = true;
    state = state.copyWith(isRunning: false, isPaused: false);
    ref.read(wifiServiceProvider).sendSessionControl('ABORT');
    ref.read(sessionProvider.notifier).setStatus(SessionStatus.aborted);
    WakelockPlus.disable();
  }

  int _remainingDelayMs(int startIndex) {
    if (startIndex >= state.queue.length) return 0;
    return state.queue
        .sublist(startIndex)
        .fold<int>(0, (sum, cmd) => sum + cmd.delayMs);
  }

  double _calculateWpm(int charsCompleted, int remainingMs) {
    final elapsedMs = max(1, _totalDelayMs() - remainingMs);
    final elapsedMinutes = elapsedMs / 60000.0;
    final words = charsCompleted / 5.0;
    return elapsedMinutes <= 0 ? 0 : words / elapsedMinutes;
  }

  int _totalDelayMs() {
    return state.queue.fold<int>(0, (sum, cmd) => sum + cmd.delayMs);
  }
}
