import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router.dart';
import '../../../core/theme.dart';
import '../../../core/widgets/human_type_scaffold.dart';
import '../../connect/providers/connection_provider.dart';
import '../../connect/services/wifi_service.dart';
import '../../settings/providers/settings_provider.dart';
import '../widgets/connection_status_chip.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    }
    if (hour < 17) {
      return 'Good afternoon';
    }
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connection = ref.watch(connectionProvider);

    // Show onboarding on first run or auto-connect
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(settingsProvider);
      if (settings.isFirstRun) {
        ref.read(settingsProvider.notifier).setFirstRun(false);
        context.go(AppRoutes.onboarding);
      } else {
        // Auto-connect to last host if available
        final wifi = ref.read(wifiServiceProvider);
        if (!wifi.isConnected && wifi.lastHost != null) {
          wifi.autoConnect().catchError((_) {});
        }
      }
    });

    return HumanTypeScaffold(
      actions: [
        IconButton(
          onPressed: () => context.push(AppRoutes.settings),
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('HumanType', style: HumanTypeText.display),
          const SizedBox(height: HumanTypeSpacing.xs),
          Text(_greeting(), style: HumanTypeText.bodySmall),
          const SizedBox(height: HumanTypeSpacing.lg),
          ConnectionStatusChip(
            state: connection,
            onTap: () => context.push(AppRoutes.connect),
          ),
          const SizedBox(height: HumanTypeSpacing.xl),
          Row(
            children: [
              Expanded(
                child: _ModeCard(
                  title: 'Text Mode',
                  subtitle: 'Compose and control',
                  icon: Icons.text_fields,
                  onTap: () => context.push(AppRoutes.textMode),
                ),
              ),
              const SizedBox(width: HumanTypeSpacing.md),
              Expanded(
                child: _ModeCard(
                  title: 'Code Mode',
                  subtitle: 'Precision typing',
                  icon: Icons.code,
                  onTap: () => context.push(AppRoutes.codeMode),
                ),
              ),
            ],
          ),
          const SizedBox(height: HumanTypeSpacing.xl),
          _QuickActionCard(
            title: 'Send File',
            subtitle: 'Transfer to laptop',
            icon: Icons.upload_file,
            onTap: () => context.push(AppRoutes.fileTransfer),
          ),
          const SizedBox(height: HumanTypeSpacing.md),
          _QuickActionCard(
            title: 'Browse Laptop',
            subtitle: 'Remote file system',
            icon: Icons.folder_open,
            onTap: () => context.push(AppRoutes.fileBrowser),
          ),
          const SizedBox(height: HumanTypeSpacing.md),
          _QuickActionCard(
            title: 'Scratchpad',
            subtitle: 'Shared notes',
            icon: Icons.edit_note,
            onTap: () => context.push(AppRoutes.scratchpad),
          ),
          const SizedBox(height: HumanTypeSpacing.md),
          _QuickActionCard(
            title: 'Templates',
            subtitle: 'Saved sessions',
            icon: Icons.inventory_2_outlined,
            onTap: () => context.push(AppRoutes.templates),
          ),
          const SizedBox(height: HumanTypeSpacing.md),
          _QuickActionCard(
            title: 'Last session',
            subtitle: 'No recent sessions',
            icon: Icons.history,
            onTap: () => context.push(AppRoutes.history),
          ),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(HumanTypeSpacing.lg),
        decoration: BoxDecoration(
          color: HumanTypeColors.bgElevated,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: HumanTypeColors.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(HumanTypeSpacing.sm),
              decoration: BoxDecoration(
                color: HumanTypeColors.bgOverlay,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(height: HumanTypeSpacing.md),
            Text(title, style: HumanTypeText.heading2),
            const SizedBox(height: HumanTypeSpacing.xs),
            Text(subtitle, style: HumanTypeText.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(HumanTypeSpacing.lg),
        decoration: BoxDecoration(
          color: HumanTypeColors.bgElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: HumanTypeColors.borderSubtle),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(HumanTypeSpacing.sm),
              decoration: BoxDecoration(
                color: HumanTypeColors.bgOverlay,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: HumanTypeSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: HumanTypeText.heading2),
                  const SizedBox(height: HumanTypeSpacing.xs),
                  Text(subtitle, style: HumanTypeText.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}
