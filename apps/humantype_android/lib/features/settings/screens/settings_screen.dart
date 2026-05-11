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
          const SizedBox(height: HumanTypeSpacing.sm),
          _SettingsTile(
            title: 'Stealth mode',
            subtitle: 'Hide the Windows HUD from screen-sharing and recordings.',
            value: settings.stealthMode,
            onChanged: (value) =>
                ref.read(settingsProvider.notifier).setStealthMode(value),
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
          DropdownButtonFormField<AiProvider>(
            value: settings.selectedAiProvider,
            dropdownColor: HumanTypeColors.bgElevated,
            decoration: const InputDecoration(labelText: 'AI Provider'),
            items: AiProvider.values
                .map((p) => DropdownMenuItem(
                      value: p,
                      child: Text(p.name.toUpperCase()),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                ref.read(settingsProvider.notifier).setAiProvider(value);
              }
            },
          ),
          const SizedBox(height: HumanTypeSpacing.md),
          TextField(
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: InputDecoration(
              labelText:
                  '${settings.selectedAiProvider.name.toUpperCase()} API key',
              hintText: 'Paste your API key',
            ),
            onChanged: (value) {
              final notifier = ref.read(settingsProvider.notifier);
              final key = value.trim();
              switch (settings.selectedAiProvider) {
                case AiProvider.gemini:
                  notifier.setGeminiApiKey(key);
                  break;
                case AiProvider.claude:
                  notifier.setClaudeApiKey(key);
                  break;
                case AiProvider.openai:
                  notifier.setOpenAiApiKey(key);
                  break;
              }
            },
          ),
          const SizedBox(height: HumanTypeSpacing.xl),
          Text('History', style: HumanTypeText.heading1),
          const SizedBox(height: HumanTypeSpacing.lg),
          _SettingsTile(
            title: 'Session history',
            subtitle: 'Log session details locally for replay and analytics.',
            value: settings.historyEnabled,
            onChanged: (value) =>
                ref.read(settingsProvider.notifier).setHistoryEnabled(value),
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
