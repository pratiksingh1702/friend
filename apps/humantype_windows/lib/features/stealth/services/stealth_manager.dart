import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

class StealthState {
  final bool isStealthActive;
  final double currentOpacity;

  StealthState({required this.isStealthActive, required this.currentOpacity});

  StealthState copyWith({bool? isStealthActive, double? currentOpacity}) {
    return StealthState(
      isStealthActive: isStealthActive ?? this.isStealthActive,
      currentOpacity: currentOpacity ?? this.currentOpacity,
    );
  }
}

class StealthManager extends StateNotifier<StealthState> {
  StealthManager() : super(StealthState(isStealthActive: false, currentOpacity: 1.0));

  void toggleStealth() async {
    final newState = !state.isStealthActive;
    state = state.copyWith(
      isStealthActive: newState,
      currentOpacity: newState ? 0.05 : 1.0,
    );

    // Apply window transparency
    if (newState) {
      await windowManager.setOpacity(0.05);
      await windowManager.setIgnoreMouseEvents(true);
    } else {
      await windowManager.setOpacity(1.0);
      await windowManager.setIgnoreMouseEvents(false);
    }
  }

  void setOpacity(double opacity) async {
    state = state.copyWith(currentOpacity: opacity);
    await windowManager.setOpacity(opacity);
  }
}

final stealthProvider = StateNotifierProvider<StealthManager, StealthState>((ref) {
  return StealthManager();
});
