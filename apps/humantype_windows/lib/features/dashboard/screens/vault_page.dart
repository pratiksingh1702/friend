import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../sync/services/android_sync_service.dart';

class VaultPage extends ConsumerWidget {
  const VaultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = FluentTheme.of(context);

    return ScaffoldPage(
      header: const PageHeader(
        title: Text('Biometric Vault'),
      ),
      content: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVaultStatus(context),
            const SizedBox(height: 32),
            Text('Quick Access', style: theme.typography.subtitle),
            const SizedBox(height: 16),
            _buildActionGrid(context, ref),
            const SizedBox(height: 32),
            _buildSecurityNotice(context),
          ],
        ),
      ),
    );
  }

  Widget _buildVaultStatus(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.darker, Colors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(FluentIcons.shield, size: 48, color: Colors.white),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'VAULT SECURED',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Connected to Phone Biometrics',
                  style: theme.typography.title?.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: () {},
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.white.withOpacity(0.2)),
            ),
            child: const Text('Locked'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context, WidgetRef ref) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 2.5,
      children: [
        _buildVaultActionTile(
          context,
          icon: FluentIcons.password_field,
          title: 'Request Password',
          subtitle: 'Triggers phone biometric prompt',
          onTap: () {
            ref.read(androidSyncServiceProvider).sendPasswordRequest();
          },
        ),
        _buildVaultActionTile(
          context,
          icon: FluentIcons.authenticator_app,
          title: 'Auto-Type OTP',
          subtitle: 'Active for detected codes',
          onTap: () {},
          isActive: true,
        ),
      ],
    );
  }

  Widget _buildVaultActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    final theme = FluentTheme.of(context);
    return Button(
      onPressed: onTap,
      style: ButtonStyle(
        padding: WidgetStateProperty.all(const EdgeInsets.all(16)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: isActive ? Colors.green : theme.accentColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.typography.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                Text(subtitle, style: theme.typography.caption?.copyWith(color: theme.typography.caption?.color?.withOpacity(0.6))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityNotice(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(FluentIcons.info, size: 16, color: Colors.orange),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'All vault requests require explicit biometric approval on your Android device. Passwords are typed directly into the active window and are never stored on your PC.',
              style: theme.typography.caption?.copyWith(
                color: theme.typography.caption?.color?.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
