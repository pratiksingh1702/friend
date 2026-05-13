import 'package:fluent_ui/fluent_ui.dart' hide Scaffold, Colors;
import 'package:flutter/material.dart' show Scaffold, Colors, SingleChildScrollView, WidgetStateProperty;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:humantype_shared/humantype_shared.dart';

import '../../sync/providers/bridge_provider.dart';
import '../../../core/services/window_manager_service.dart';
import '../../../core/theme/ht_colors.dart';
import '../../../core/theme/ht_typography.dart';
import '../widgets/hero_status_card.dart';
import '../widgets/bento_card.dart';
import '../widgets/protocol_status_panel.dart';

class OverviewPage extends ConsumerWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            // Row 1: Device Status
            const HeroStatusCard(isConnected: true),
            const SizedBox(height: 24),
            // Row 2: Core Bento Cards
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildBentoWrapper(
                  context,
                  BentoCard(
                    icon: FluentIcons.shield,
                    title: 'Biometric Vault',
                    subtitle: 'Passwords & OTP',
                    value: '12 Items Stored',
                    status: 'Protected',
                    color: HTColors.tileVault,
                    onTap: () => context.go('/vault'),
                  ),
                ),
                _buildBentoWrapper(
                  context,
                  BentoCard(
                    icon: FluentIcons.edit_note,
                    title: 'Scratchpad',
                    subtitle: 'Shared Notes',
                    value: '8 Notes',
                    status: 'Synced',
                    color: HTColors.tileScratch,
                    onTap: () => context.go('/scratchpad'),
                  ),
                ),
                _buildBentoWrapper(
                  context,
                  BentoCard(
                    icon: FluentIcons.fabric_folder,
                    title: 'Files',
                    subtitle: 'Transfer & Share',
                    value: '128 Files',
                    status: 'Up to date',
                    color: HTColors.tileFiles,
                    onTap: () => context.go('/files'),
                  ),
                ),
                _buildBentoWrapper(
                  context,
                  BentoCard(
                    icon: FluentIcons.copy,
                    title: 'Clipboard',
                    subtitle: 'History & Sync',
                    value: '24 Items',
                    status: 'Live Sync',
                    color: HTColors.tileClipboard,
                    onTap: () => context.go('/clipboard'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Row 3: Notifications + HUD
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: BentoCard(
                    icon: FluentIcons.ringer,
                    title: 'Notifications Hub',
                    subtitle: 'Real-time Mirror',
                    value: '18 New',
                    status: 'Live',
                    color: HTColors.tileNotif,
                    onTap: () => context.go('/notifications'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: _buildHUDCard(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Row 4: Protocol Status + Metrics
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: 500,
                  child: const ProtocolStatusPanel(
                    isWsConnected: true,
                    isDeviceLinked: true,
                    latency: '< 20ms',
                  ),
                ),
                _buildBentoWrapper(context, _buildStorageCard(), width: 250),
                _buildBentoWrapper(context, _buildHUDModeCard(), width: 250),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBentoWrapper(BuildContext context, Widget child, {double width = 200}) {
    return SizedBox(
      width: width,
      child: child,
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good morning, Alex 👋',
          style: HTTypography.cardSubtitle.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          'Dashboard',
          style: HTTypography.heroHeading.copyWith(fontSize: 24),
        ),
        const SizedBox(height: 2),
        Text(
          'Everything is connected. You\'re in control.',
          style: HTTypography.micro.copyWith(fontSize: 11),
        ),
      ],
    );
  }


  Widget _buildHUDCard(BuildContext context) {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        color: HTColors.bgSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HTColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 200,
              child: Opacity(
                opacity: 0.05,
                child: const Icon(FluentIcons.home, size: 150, color: HTColors.accentBlue),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: HTColors.accentBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(FluentIcons.t_v_monitor, color: HTColors.accentBlue, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Launch Active HUD', style: HTTypography.cardTitle),
                        Text('Enter Cinematic Overlay Mode', style: HTTypography.micro),
                        const SizedBox(height: 12),
                        Button(
                          onPressed: () {},
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(HTColors.accentBlue),
                            padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
                            shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          ),
                          child: Text('Launch HUD', style: HTTypography.micro.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildStorageCard() {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HTColors.bgSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: HTColors.border.withOpacity(0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Storage Used', style: HTTypography.cardTitle.copyWith(fontSize: 12)),
              Text('42% used', style: HTTypography.micro.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(color: HTColors.bgBase, borderRadius: BorderRadius.circular(3)),
              ),
              FractionallySizedBox(
                widthFactor: 0.42,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [HTColors.accentBlue, HTColors.accentViolet]),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('84.2 GB / 200 GB', style: HTTypography.micro),
        ],
      ),
    );
  }

  Widget _buildHUDModeCard() {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HTColors.bgSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: HTColors.border.withOpacity(0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('HUD Mode', style: HTTypography.cardTitle.copyWith(fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(color: HTColors.textMuted, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text('Inactive', style: HTTypography.micro.copyWith(color: HTColors.textMuted)),
            ],
          ),
          const SizedBox(height: 12),
          Text('Press launch to activate overlay', style: HTTypography.micro.copyWith(fontSize: 8)),
        ],
      ),
    );
  }
}

