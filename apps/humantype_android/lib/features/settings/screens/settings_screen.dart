import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import '../../../core/widgets/human_type_scaffold.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return HumanTypeScaffold(
      title: 'Settings',
      showBack: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Typing defaults', style: HumanTypeText.heading1),
          const SizedBox(height: HumanTypeSpacing.lg),
          _SettingsTile(
            title: 'Keep screen on',
            subtitle: 'Prevent the display from sleeping during sessions.',
            value: settings.keepScreenOn,
            onChanged: (value) =>
                ref.read(settingsProvider.notifier).setKeepScreenOn(value),
          ),
          const SizedBox(height: HumanTypeSpacing.sm),
          _SettingsTile(
            title: 'Haptic feedback',
            subtitle: 'Enable haptic feedback for start, pause, and stop.',
            value: settings.hapticsEnabled,
            onChanged: (value) =>
                ref.read(settingsProvider.notifier).setHapticsEnabled(value),
          ),
          const SizedBox(height: HumanTypeSpacing.xl),
          Text('AI features', style: HumanTypeText.heading1),
          const SizedBox(height: HumanTypeSpacing.lg),
          _SettingsTile(
            title: 'Enable AI parsing',
            subtitle: 'Use cloud AI for complex instructions when enabled.',
            value: settings.aiEnabled,
            onChanged: (value) =>
                ref.read(settingsProvider.notifier).setAiEnabled(value),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(HumanTypeSpacing.lg),
      decoration: BoxDecoration(
        color: HumanTypeColors.bgElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HumanTypeColors.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: HumanTypeText.bodyLarge),
                const SizedBox(height: HumanTypeSpacing.xs),
                Text(subtitle, style: HumanTypeText.bodySmall),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: HumanTypeColors.accentPrimary,
          ),
        ],
      ),
    );
  }
}
