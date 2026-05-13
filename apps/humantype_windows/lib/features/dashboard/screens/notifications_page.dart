import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../notifications/providers/notification_history_provider.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(notificationHistoryProvider);
    final theme = FluentTheme.of(context);

    return ScaffoldPage(
      header: PageHeader(
        title: const Text('Notification Mirror'),
        commandBar: CommandBar(
          mainAxisAlignment: MainAxisAlignment.end,
          primaryItems: [
            CommandBarButton(
              icon: const Icon(FluentIcons.clear),
              label: const Text('Clear Log'),
              onPressed: () => ref.read(notificationHistoryProvider.notifier).clear(),
            ),
          ],
        ),
      ),
      content: history.isEmpty
          ? _buildEmptyState(context)
          : ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: history.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = history[index];
                return _buildNotificationCard(context, item);
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FluentIcons.message_fill, size: 64, color: theme.typography.caption?.color?.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text(
            'No notifications mirrored yet',
            style: theme.typography.body?.copyWith(
              color: theme.typography.caption?.color?.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enable notification access on your Android app to see them here.',
            style: theme.typography.caption?.copyWith(
              color: theme.typography.caption?.color?.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, MirroredNotification item) {
    final theme = FluentTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.accentColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(FluentIcons.cell_phone, size: 16, color: theme.accentColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.packageName.toUpperCase(),
                      style: theme.typography.caption?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: theme.accentColor,
                      ),
                    ),
                    Text(
                      '${item.timestamp.hour}:${item.timestamp.minute.toString().padLeft(2, '0')}',
                      style: theme.typography.caption?.copyWith(
                        color: theme.typography.caption?.color?.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(item.title, style: theme.typography.bodyStrong),
                const SizedBox(height: 2),
                Text(
                  item.body,
                  style: theme.typography.body?.copyWith(
                    color: theme.typography.body?.color?.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
