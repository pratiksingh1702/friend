import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../clipboard/providers/clipboard_history_provider.dart';

class ClipboardPage extends ConsumerWidget {
  const ClipboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(clipboardHistoryProvider);
    final theme = FluentTheme.of(context);

    return ScaffoldPage(
      header: PageHeader(
        title: const Text('Universal Clipboard'),
        commandBar: CommandBar(
          mainAxisAlignment: MainAxisAlignment.end,
          primaryItems: [
            CommandBarButton(
              icon: const Icon(FluentIcons.clear),
              label: const Text('Clear History'),
              onPressed: () => ref.read(clipboardHistoryProvider.notifier).clear(),
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
                return _buildClipboardCard(context, item);
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
          Icon(FluentIcons.copy, size: 64, color: theme.typography.caption?.color?.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text(
            'Clipboard history is empty',
            style: theme.typography.body?.copyWith(
              color: theme.typography.caption?.color?.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Copied text will automatically sync across your devices.',
            style: theme.typography.caption?.copyWith(
              color: theme.typography.caption?.color?.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClipboardCard(BuildContext context, ClipboardItem item) {
    final theme = FluentTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    item.isFromRemote ? FluentIcons.cell_phone : FluentIcons.laptop_selected,
                    size: 14,
                    color: theme.accentColor.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.isFromRemote ? 'RECEIVED FROM PHONE' : 'COPIED ON WINDOWS',
                    style: theme.typography.caption?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                      color: theme.accentColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              Text(
                '${item.timestamp.hour}:${item.timestamp.minute.toString().padLeft(2, '0')}',
                style: theme.typography.caption?.copyWith(
                  color: theme.typography.caption?.color?.withOpacity(0.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.content,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.typography.body?.copyWith(
              fontFamily: 'Consolas',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Button(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: item.content));
                },
                child: const Row(
                  children: [
                    Icon(FluentIcons.copy, size: 12),
                    SizedBox(width: 8),
                    Text('Copy Again'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
