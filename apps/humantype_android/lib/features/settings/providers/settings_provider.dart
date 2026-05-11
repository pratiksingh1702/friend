import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../connect/services/wifi_service.dart';

enum AiProvider { gemini, claude, openai }

class AppSettings {
  const AppSettings({
    required this.keepScreenOn,
    required this.hapticsEnabled,
    required this.aiEnabled,
    required this.historyEnabled,
    required this.autoReconnect,
    required this.selectedAiProvider,
    required this.geminiApiKey,
    required this.claudeApiKey,
    required this.openaiApiKey,
  });

  final bool keepScreenOn;
  final bool hapticsEnabled;
  final bool aiEnabled;
  final bool historyEnabled;
  final bool autoReconnect;
  final AiProvider selectedAiProvider;
  final String geminiApiKey;
  final String claudeApiKey;
  final String openaiApiKey;

  factory AppSettings.defaults() {
    return const AppSettings(
      keepScreenOn: true,
      hapticsEnabled: true,
      aiEnabled: false,
      historyEnabled: false,
      autoReconnect: true,
      selectedAiProvider: AiProvider.gemini,
      geminiApiKey: '',
      claudeApiKey: '',
      openaiApiKey: '',
    );
  }

  AppSettings copyWith({
    bool? keepScreenOn,
    bool? hapticsEnabled,
    bool? aiEnabled,
    bool? historyEnabled,
    bool? autoReconnect,
    AiProvider? selectedAiProvider,
    String? geminiApiKey,
    String? claudeApiKey,
    String? openaiApiKey,
  }) {
    return AppSettings(
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      aiEnabled: aiEnabled ?? this.aiEnabled,
      historyEnabled: historyEnabled ?? this.historyEnabled,
      autoReconnect: autoReconnect ?? this.autoReconnect,
      selectedAiProvider: selectedAiProvider ?? this.selectedAiProvider,
      geminiApiKey: geminiApiKey ?? this.geminiApiKey,
      claudeApiKey: claudeApiKey ?? this.claudeApiKey,
      openaiApiKey: openaiApiKey ?? this.openaiApiKey,
    );
  }
}

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => AppSettings.defaults();

  void setKeepScreenOn(bool value) {
    state = state.copyWith(keepScreenOn: value);
    _sync('display.keep_screen_on', value);
  }

  void setHapticsEnabled(bool value) {
    state = state.copyWith(hapticsEnabled: value);
    _sync('ui.haptics_enabled', value);
  }

  void setAiEnabled(bool value) {
    state = state.copyWith(aiEnabled: value);
    _sync('ai.enabled', value);
  }

  void setAutoReconnect(bool value) {
    state = state.copyWith(autoReconnect: value);
    _sync('connection.auto_reconnect', value);
  }

  void setAiProvider(AiProvider provider) {
    state = state.copyWith(selectedAiProvider: provider);
  }

  void setGeminiApiKey(String value) {
    state = state.copyWith(geminiApiKey: value);
  }

  void setClaudeApiKey(String value) {
    state = state.copyWith(claudeApiKey: value);
  }

  void setOpenAiApiKey(String value) {
    state = state.copyWith(openaiApiKey: value);
  }

  void setHistoryEnabled(bool value) {
    state = state.copyWith(historyEnabled: value);
    _sync('history.enabled', value);
  }

  void applyRemoteSetting(String key, Object? value) {
    switch (key) {
      case 'display.keep_screen_on':
        if (value is bool) state = state.copyWith(keepScreenOn: value);
        break;
      case 'ui.haptics_enabled':
        if (value is bool) state = state.copyWith(hapticsEnabled: value);
        break;
      case 'ai.enabled':
        if (value is bool) state = state.copyWith(aiEnabled: value);
        break;
      case 'connection.auto_reconnect':
        if (value is bool) state = state.copyWith(autoReconnect: value);
        break;
      case 'history.enabled':
        if (value is bool) state = state.copyWith(historyEnabled: value);
        break;
    }
  }

  void _sync(String key, Object? value) {
    ref.read(wifiServiceProvider).sendSettingsSync(key, value);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
