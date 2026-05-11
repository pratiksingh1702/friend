import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Application settings model
class AppSettings {
  final String? lastConnectedIp;
  final int bridgePort;
  final bool autoConnectOnStartup;
  final bool launchBridgeOnStartup;
  final bool defaultStealthMode;
  final double overlayOpacity;
  final String overlayPosition; // 'top-left', 'top-right', etc.

  const AppSettings({
    this.lastConnectedIp,
    this.bridgePort = 8765,
    this.autoConnectOnStartup = true,
    this.launchBridgeOnStartup = true,
    this.defaultStealthMode = false,
    this.overlayOpacity = 0.9,
    this.overlayPosition = 'top-right',
  });

  AppSettings copyWith({
    String? lastConnectedIp,
    int? bridgePort,
    bool? autoConnectOnStartup,
    bool? launchBridgeOnStartup,
    bool? defaultStealthMode,
    double? overlayOpacity,
    String? overlayPosition,
  }) {
    return AppSettings(
      lastConnectedIp: lastConnectedIp ?? this.lastConnectedIp,
      bridgePort: bridgePort ?? this.bridgePort,
      autoConnectOnStartup: autoConnectOnStartup ?? this.autoConnectOnStartup,
      launchBridgeOnStartup: launchBridgeOnStartup ?? this.launchBridgeOnStartup,
      defaultStealthMode: defaultStealthMode ?? this.defaultStealthMode,
      overlayOpacity: overlayOpacity ?? this.overlayOpacity,
      overlayPosition: overlayPosition ?? this.overlayPosition,
    );
  }

  Map<String, dynamic> toMap() => {
        'lastConnectedIp': lastConnectedIp,
        'bridgePort': bridgePort,
        'autoConnectOnStartup': autoConnectOnStartup,
        'launchBridgeOnStartup': launchBridgeOnStartup,
        'defaultStealthMode': defaultStealthMode,
        'overlayOpacity': overlayOpacity,
        'overlayPosition': overlayPosition,
      };

  factory AppSettings.fromMap(Map<dynamic, dynamic> m) => AppSettings(
        lastConnectedIp: m['lastConnectedIp'] as String?,
        bridgePort: (m['bridgePort'] as int?) ?? 8765,
        autoConnectOnStartup: (m['autoConnectOnStartup'] as bool?) ?? true,
        launchBridgeOnStartup: (m['launchBridgeOnStartup'] as bool?) ?? true,
        defaultStealthMode: (m['defaultStealthMode'] as bool?) ?? false,
        overlayOpacity: (m['overlayOpacity'] as double?) ?? 0.9,
        overlayPosition: (m['overlayPosition'] as String?) ?? 'top-right',
      );
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  static const String _boxName = 'settings';
  Box? _box;

  SettingsNotifier() : super(const AppSettings());

  Future<void> load() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
    final saved = _box?.get('app_settings');
    if (saved != null) {
      state = AppSettings.fromMap(saved as Map<dynamic, dynamic>);
    }
    print('[Settings] Loaded: ${state.toMap()}');
  }

  void update(AppSettings settings) {
    state = settings;
    _box?.put('app_settings', state.toMap());
  }

  void setAutoConnect(bool value) => update(state.copyWith(autoConnectOnStartup: value));
  void setStealthMode(bool value) => update(state.copyWith(defaultStealthMode: value));
  void setOverlayOpacity(double value) => update(state.copyWith(overlayOpacity: value));
  void setLastConnectedIp(String ip) => update(state.copyWith(lastConnectedIp: ip));
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final notifier = SettingsNotifier();
  notifier.load(); // Load async on init
  return notifier;
});
