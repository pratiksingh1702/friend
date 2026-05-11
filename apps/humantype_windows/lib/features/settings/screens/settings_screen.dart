import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../services/startup_registrar.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _ipController = TextEditingController();
  bool _startupEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkStartup();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ipController.text = ref.read(settingsProvider).lastConnectedIp ?? '';
    });
  }

  Future<void> _checkStartup() async {
    final enabled = await StartupRegistrar.isEnabled();
    if (mounted) setState(() => _startupEnabled = enabled);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('Settings')),
      children: [
        _sectionTitle(context, 'Connection'),
        _buildConnectionSection(context, settings, notifier),
        const SizedBox(height: 24),
        _sectionTitle(context, 'Overlay'),
        _buildOverlaySection(context, settings, notifier),
        const SizedBox(height: 24),
        _sectionTitle(context, 'System'),
        _buildSystemSection(context, settings, notifier),
      ],
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: FluentTheme.of(context).typography.subtitle),
    );
  }

  Widget _buildConnectionSection(BuildContext context, AppSettings settings, SettingsNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FluentTheme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: InfoLabel(
                  label: 'Last Connected Android IP',
                  child: TextBox(
                    controller: _ipController,
                    placeholder: '192.168.1.xxx',
                    onChanged: (v) => notifier.setLastConnectedIp(v),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: FilledButton(
                  child: const Text('Connect'),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ToggleSwitch(
                checked: settings.autoConnectOnStartup,
                onChanged: notifier.setAutoConnect,
              ),
              const SizedBox(width: 12),
              const Text('Auto-connect on app launch'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverlaySection(BuildContext context, AppSettings settings, SettingsNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FluentTheme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ToggleSwitch(
                checked: settings.defaultStealthMode,
                onChanged: notifier.setStealthMode,
              ),
              const SizedBox(width: 12),
              const Text('Enable Stealth Mode by default'),
            ],
          ),
          const SizedBox(height: 16),
          InfoLabel(
            label: 'Overlay Opacity: ${(settings.overlayOpacity * 100).toInt()}%',
            child: Slider(
              min: 0.2,
              max: 1.0,
              value: settings.overlayOpacity,
              onChanged: notifier.setOverlayOpacity,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemSection(BuildContext context, AppSettings settings, SettingsNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FluentTheme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ToggleSwitch(
                checked: _startupEnabled,
                onChanged: (v) async {
                  if (v) {
                    await StartupRegistrar.enable();
                  } else {
                    await StartupRegistrar.disable();
                  }
                  await _checkStartup();
                },
              ),
              const SizedBox(width: 12),
              const Text('Launch on Windows startup'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ToggleSwitch(
                checked: settings.launchBridgeOnStartup,
                onChanged: (v) => notifier.update(settings.copyWith(launchBridgeOnStartup: v)),
              ),
              const SizedBox(width: 12),
              const Text('Auto-start Python Bridge'),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }
}
