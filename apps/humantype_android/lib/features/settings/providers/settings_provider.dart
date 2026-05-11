import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppSettings {
  const AppSettings({
    required this.keepScreenOn,
    required this.hapticsEnabled,
    required this.aiEnabled,
  });

  final bool keepScreenOn;
  final bool hapticsEnabled;
  final bool aiEnabled;

  factory AppSettings.defaults() {
    return const AppSettings(
      keepScreenOn: true,
      hapticsEnabled: true,
      aiEnabled: false,
    );
  }

  AppSettings copyWith({
    bool? keepScreenOn,
    bool? hapticsEnabled,
    bool? aiEnabled,
  }) {
    return AppSettings(
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      aiEnabled: aiEnabled ?? this.aiEnabled,
    );
  }
}

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => AppSettings.defaults();

  void setKeepScreenOn(bool value) {
    state = state.copyWith(keepScreenOn: value);
  }

  void setHapticsEnabled(bool value) {
    state = state.copyWith(hapticsEnabled: value);
  }

  void setAiEnabled(bool value) {
    state = state.copyWith(aiEnabled: value);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
