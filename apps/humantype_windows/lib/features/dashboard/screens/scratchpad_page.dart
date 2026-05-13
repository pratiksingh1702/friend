import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../scratchpad/providers/scratchpad_provider.dart';

class ScratchpadPage extends ConsumerStatefulWidget {
  const ScratchpadPage({super.key});

  @override
  ConsumerState<ScratchpadPage> createState() => _ScratchpadPageState();
}

class _ScratchpadPageState extends ConsumerState<ScratchpadPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.text = ref.read(scratchpadProvider).content;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ScratchpadState>(scratchpadProvider, (previous, next) {
      if (next.content != _controller.text) {
        _controller.text = next.content;
      }
    });

    final state = ref.watch(scratchpadProvider);
    final theme = FluentTheme.of(context);

    return ScaffoldPage(
      header: PageHeader(
        title: const Text('Shared Scratchpad'),
        commandBar: CommandBar(
          mainAxisAlignment: MainAxisAlignment.end,
          primaryItems: [
            CommandBarButton(
              icon: const Icon(FluentIcons.delete),
              label: const Text('Clear'),
              onPressed: () {
                _controller.clear();
                ref.read(scratchpadProvider.notifier).updateContent('');
              },
            ),
            CommandBarButton(
              icon: const Icon(FluentIcons.copy),
              label: const Text('Copy All'),
              onPressed: () {
                // Copy logic would go here
              },
            ),
          ],
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: TextBox(
                  controller: _controller,
                  maxLines: null,
                  minLines: 20,
                  placeholder: 'Start typing to sync with your phone...',
                  style: theme.typography.body?.copyWith(
                    fontFamily: 'Consolas',
                    fontSize: 14,
                  ),
                  decoration: WidgetStateProperty.all(
                    const BoxDecoration(color: Colors.transparent),
                  ),
                  onChanged: (value) {
                    ref.read(scratchpadProvider.notifier).updateContent(value);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildSyncStatus(state),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncStatus(ScratchpadState state) {
    final theme = FluentTheme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              state.isSyncing ? FluentIcons.sync : FluentIcons.accept,
              size: 14,
              color: state.isSyncing ? Colors.orange : Colors.green,
            ),
            const SizedBox(width: 8),
            Text(
              state.isSyncing ? 'Syncing with phone...' : 'All changes saved',
              style: theme.typography.caption?.copyWith(
                color: theme.typography.caption?.color?.withOpacity(0.6),
              ),
            ),
          ],
        ),
        if (state.lastSyncedAt != null)
          Text(
            'Last synced by ${state.lastSyncedBy} at ${state.lastSyncedAt!.hour}:${state.lastSyncedAt!.minute.toString().padLeft(2, '0')}',
            style: theme.typography.caption?.copyWith(
              color: theme.typography.caption?.color?.withOpacity(0.4),
            ),
          ),
      ],
    );
  }
}
