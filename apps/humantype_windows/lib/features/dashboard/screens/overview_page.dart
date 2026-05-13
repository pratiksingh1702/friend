import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:humantype_shared/humantype_shared.dart';
import '../../sync/providers/bridge_provider.dart';
import '../../../core/services/window_manager_service.dart';

class OverviewPage extends ConsumerWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bridge = ref.watch(bridgeProvider);
    final theme = FluentTheme.of(context);

    return ScaffoldPage.scrollable(
      header: PageHeader(
        title: Text(
          'Overview',
          style: theme.typography.title?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ),
      children: [
        _buildHeroStatus(context, bridge),
        const SizedBox(height: 32),
        _buildFeatureGrid(context, ref),
        const SizedBox(height: 32),
        _buildSystemStats(context, bridge),
      ],
    );
  }

  Widget _buildHeroStatus(BuildContext context, BridgeState bridge) {
    final theme = FluentTheme.of(context);
    final isConnected = bridge.isAndroidConnected;

    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isConnected 
            ? [theme.accentColor.normal, theme.accentColor.darker]
            : [Colors.grey.withOpacity(0.1), Colors.grey.withOpacity(0.2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (isConnected ? theme.accentColor : Colors.black).withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              isConnected ? FluentIcons.cell_phone : FluentIcons.mobile_report,
              size: 160,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isConnected ? 'SYSTEM LINKED' : 'AWAITING LINK',
                  style: theme.typography.caption?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isConnected ? bridge.androidDeviceName ?? 'Android Phone' : 'No Device Connected',
                  style: theme.typography.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context, WidgetRef ref) {
    final theme = FluentTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Core Features',
          style: theme.typography.subtitle?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 3,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.3,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildFeatureTile(
              context,
              icon: FluentIcons.shield,
              title: 'Biometric Vault',
              subtitle: 'Passwords & OTP',
              color: Colors.blue,
              onTap: () => context.go('/vault'),
            ),
            _buildFeatureTile(
              context,
              icon: FluentIcons.edit_note,
              title: 'Scratchpad',
              subtitle: 'Shared Notes',
              color: Colors.orange,
              onTap: () => context.go('/scratchpad'),
            ),
            _buildFeatureTile(
              context,
              icon: FluentIcons.sync,
              title: 'File Transfer',
              subtitle: 'Send & Receive',
              color: Colors.teal,
              onTap: () => context.go('/files'),
            ),
            _buildFeatureTile(
              context,
              icon: FluentIcons.copy,
              title: 'Clipboard',
              subtitle: 'Sync History',
              color: Colors.purple,
              onTap: () => context.go('/clipboard'),
            ),
            _buildFeatureTile(
              context,
              icon: FluentIcons.message_fill,
              title: 'Notifications',
              subtitle: 'Mirror Hub',
              color: Colors.green,
              onTap: () => context.go('/notifications'),
            ),
            _buildFeatureTile(
              context,
              icon: FluentIcons.screen_cast,
              title: 'Launch HUD',
              subtitle: 'Active Overlay',
              color: Colors.red,
              onTap: () async {
                await ref.read(windowManagerProvider.notifier).enterHudMode();
                context.go('/overlay');
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = FluentTheme.of(context);
    return Button(
      onPressed: onTap,
      style: ButtonStyle(
        padding: WidgetStateProperty.all(EdgeInsets.zero),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.isHovered) return theme.cardColor.withOpacity(0.8);
          return theme.cardColor;
        }),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(title, style: theme.typography.body?.copyWith(fontWeight: FontWeight.bold)),
            Text(
              subtitle, 
              style: theme.typography.caption?.copyWith(
                color: theme.typography.caption?.color?.withOpacity(0.5),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemStats(BuildContext context, BridgeState bridge) {
    final theme = FluentTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Protocol Status', style: theme.typography.bodyStrong),
          const SizedBox(height: 16),
          _buildStatRow(context, 'WebSocket Relay', bridge.isConnected ? 'Stable' : 'Connecting', bridge.isConnected),
          const SizedBox(height: 12),
          _buildStatRow(context, 'Command Latency', bridge.isAndroidConnected ? '< 20ms' : 'N/A', bridge.isAndroidConnected),
        ],
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value, bool isOk) {
    final theme = FluentTheme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.typography.body?.copyWith(color: theme.typography.body?.color?.withOpacity(0.6))),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isOk ? Colors.green : Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(value, style: theme.typography.bodyStrong),
          ],
        ),
      ],
    );
  }
}
