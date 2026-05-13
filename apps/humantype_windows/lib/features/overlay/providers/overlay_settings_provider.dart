import 'package:flutter_riverpod/flutter_riverpod.dart';

class OverlaySettings {
  final double opacity;
  final bool isExpanded;
  final int activeTab;

  const OverlaySettings({
    this.opacity = 0.9,
    this.isExpanded = false,
    this.activeTab = 0,
  });

  OverlaySettings copyWith({
    double? opacity,
    bool? isExpanded,
    int? activeTab,
  }) {
    return OverlaySettings(
      opacity: opacity ?? this.opacity,
      isExpanded: isExpanded ?? this.isExpanded,
      activeTab: activeTab ?? this.activeTab,
    );
  }
}

class OverlaySettingsNotifier extends StateNotifier<OverlaySettings> {
  OverlaySettingsNotifier() : super(const OverlaySettings());

  void setOpacity(double value) {
    state = state.copyWith(opacity: value);
  }

  void toggleExpanded() {
    state = state.copyWith(isExpanded: !state.isExpanded);
  }

  void setTab(int index) {
    state = state.copyWith(activeTab: index);
  }
}

final overlaySettingsProvider = StateNotifierProvider<OverlaySettingsNotifier, OverlaySettings>((ref) {
  return OverlaySettingsNotifier();
});
