import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScaffoldPage.scrollable(
      header: const PageHeader(
        title: Text('Dashboard'),
      ),
      children: [
        _buildStatusSection(context),
        const SizedBox(height: 24),
        _buildQuickActions(context),
        const SizedBox(height: 24),
        _buildRecentSessions(context),
      ],
    );
  }

  Widget _buildStatusSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: FluentTheme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatusItem(
            context,
            icon: FluentIcons.cell_phone,
            label: 'Android Link',
            status: 'Disconnected',
            statusColor: Colors.red,
          ),
          const Spacer(),
          _buildStatusItem(
            context,
            icon: FluentIcons.server_processes,
            label: 'Bridge Status',
            status: 'Active (Port 8765)',
            statusColor: Colors.green,
          ),
          const Spacer(),
          _buildStatusItem(
            context,
            icon: FluentIcons.view,
            label: 'Overlay',
            status: 'Inactive',
            statusColor: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String status,
    required Color statusColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: FluentTheme.of(context).accentColor),
            const SizedBox(width: 8),
            Text(label, style: FluentTheme.of(context).typography.bodyStrong),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            status,
            style: FluentTheme.of(context).typography.caption?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: FluentTheme.of(context).typography.subtitle),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildActionCard(
              context,
              icon: FluentIcons.screen_cast,
              title: 'Launch Overlay',
              description: 'Show floating HUD on screen',
              onPressed: () {},
            ),
            const SizedBox(width: 16),
            _buildActionCard(
              context,
              icon: FluentIcons.camera,
              title: 'OCR Capture',
              description: 'Start screen text extraction',
              onPressed: () {},
            ),
            const SizedBox(width: 16),
            _buildActionCard(
              context,
              icon: FluentIcons.bluetooth,
              title: 'Pair Device',
              description: 'Link new Android phone',
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: Button(
        onPressed: onPressed,
        style: ButtonStyle(
          padding: WidgetStateProperty.all(const EdgeInsets.all(16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: FluentTheme.of(context).accentColor),
            const SizedBox(height: 12),
            Text(title, style: FluentTheme.of(context).typography.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              description,
              style: FluentTheme.of(context).typography.caption,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSessions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Activity', style: FluentTheme.of(context).typography.subtitle),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: FluentTheme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text('No recent activity found.'),
          ),
        ),
      ],
    );
  }
}
