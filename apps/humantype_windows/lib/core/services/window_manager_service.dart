import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

class WindowState {
  final Rect? previousBounds;
  final bool isHudMode;

  const WindowState({
    this.previousBounds,
    this.isHudMode = false,
  });

  WindowState copyWith({
    Rect? previousBounds,
    bool? isHudMode,
  }) {
    return WindowState(
      previousBounds: previousBounds ?? this.previousBounds,
      isHudMode: isHudMode ?? this.isHudMode,
    );
  }
}

class WindowManagerNotifier extends StateNotifier<WindowState> {
  WindowManagerNotifier() : super(const WindowState());

  Future<void> enterHudMode() async {
    if (state.isHudMode) return;

    final bounds = await windowManager.getBounds();
    state = state.copyWith(previousBounds: bounds, isHudMode: true);

    await windowManager.setAsFrameless();
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setBackgroundColor(Colors.transparent);
    
    // Set a default HUD size or use a saved one
    await windowManager.setSize(const Size(320, 450));
    await windowManager.setAlignment(Alignment.topRight);
  }

  Future<void> exitHudMode() async {
    if (!state.isHudMode) return;

    await windowManager.setAlwaysOnTop(false);
    await windowManager.setTitleBarStyle(TitleBarStyle.normal);
    // There is no setAsFrameless(false), we just restore the style.
    
    if (state.previousBounds != null) {
      await windowManager.setBounds(state.previousBounds!);
    } else {
      await windowManager.setSize(const Size(1200, 800));
      await windowManager.center();
    }

    state = state.copyWith(isHudMode: false);
  }
}

final windowManagerProvider = StateNotifierProvider<WindowManagerNotifier, WindowState>((ref) {
  return WindowManagerNotifier();
});
