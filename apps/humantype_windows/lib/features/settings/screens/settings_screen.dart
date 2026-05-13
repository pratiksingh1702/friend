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
    final theme = FluentTheme.of(context);

    return ScaffoldPage.scrollable(
      header: PageHeader(
        title: Text(
          'Settings',
          style: theme.typography.title?.copyWith(fontWeight: FontWeight.w900),
        ),
      ),
      children: [
        _buildSection(
          context,
          'Connection & Link',
          FluentIcons.cell_phone,
          children: [
            Row(
              children: [
                Expanded(
                  child: InfoLabel(
                    label: 'Bridge Endpoint (Android IP)',
                    child: TextBox(
                      controller: _ipController,
                      placeholder: '192.168.1.xxx',
                      prefix: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(FluentIcons.network_tower, size: 14),
                      ),
                      onChanged: (v) => notifier.setLastConnectedIp(v),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: FilledButton(
                    child: const Text('Check Connection'),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSettingToggle(
              'Auto-connect on Launch',
              'Automatically attempt to bridge with the phone when app starts',
              settings.autoConnectOnStartup,
              notifier.setAutoConnect,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSection(
          context,
          'Feature Synchronization',
          FluentIcons.sync,
          children: [
            _buildSettingToggle(
              'Universal Clipboard',
              'Sync clipboard content between Windows and Android',
              settings.clipboardSyncEnabled,
              notifier.setClipboardSync,
            ),
            _buildSettingToggle(
              'Notification Mirroring',
              'Show phone notifications as Windows toasts',
              settings.notificationMirroringEnabled,
              notifier.setNotificationMirroring,
            ),
            _buildSettingToggle(
              'Shared Scratchpad',
              'Enable the synchronized notes panel',
              settings.scratchpadEnabled,
              notifier.setScratchpad,
            ),
            _buildSettingToggle(
              'OTP Auto-Type',
              'Automatically type received OTP codes on Windows',
              settings.autoTypeOtpEnabled,
              notifier.setAutoTypeOtp,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSection(
          context,
          'Overlay & Appearance',
          FluentIcons.view,
          children: [
            _buildSettingToggle(
              'Stealth Mode Default',
              'Start the HUD in high-transparency stealth mode',
              settings.defaultStealthMode,
              notifier.setStealthMode,
            ),
            const SizedBox(height: 16),
            InfoLabel(
              label: 'Default HUD Opacity: ${(settings.overlayOpacity * 100).toInt()}%',
              child: Slider(
                min: 0.2,
                max: 1.0,
                value: settings.overlayOpacity,
                onChanged: notifier.setOverlayOpacity,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSection(
          context,
          'Advanced System',
          FluentIcons.settings,
          children: [
            _buildSettingToggle(
              'Launch on Windows Startup',
              'Automatically start HumanType when Windows logs in',
              _startupEnabled,
              (v) async {
                if (v) await StartupRegistrar.enable(); else await StartupRegistrar.disable();
                await _checkStartup();
              },
            ),
            _buildSettingToggle(
              'Auto-start Bridge Service',
              'Launch the Python relay bridge automatically',
              settings.launchBridgeOnStartup,
              (v) => notifier.update(settings.copyWith(launchBridgeOnStartup: v)),
            ),
          ],
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title, IconData icon, {required List<Widget> children}) {
    final theme = FluentTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: theme.accentColor.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: theme.accentColor),
                const SizedBox(width: 12),
                Text(
                  title.toUpperCase(),
                  style: theme.typography.caption?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: theme.accentColor,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingToggle(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    final theme = FluentTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.typography.bodyStrong),
                Text(
                  subtitle,
                  style: theme.typography.caption?.copyWith(
                    color: theme.typography.caption?.color?.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          ToggleSwitch(
            checked: value,
            onChanged: onChanged,
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
