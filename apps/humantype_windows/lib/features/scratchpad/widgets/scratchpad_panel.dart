import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/scratchpad_provider.dart';

class ScratchpadPanel extends ConsumerStatefulWidget {
  const ScratchpadPanel({super.key});

  @override
  ConsumerState<ScratchpadPanel> createState() => _ScratchpadPanelState();
}

class _ScratchpadPanelState extends ConsumerState<ScratchpadPanel> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controller with current state
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
    // Listen to provider and update controller if content changed remotely
    ref.listen<ScratchpadState>(scratchpadProvider, (previous, next) {
      if (next.content != _controller.text) {
        _controller.text = next.content;
      }
    });

    final state = ref.watch(scratchpadProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
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
                    FluentIcons.edit_note,
                    color: Colors.blue.withOpacity(0.8),
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'SHARED SCRATCHPAD',
                    style: TextStyle(
                      color: Colors.blue.withOpacity(0.8),
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              _buildSyncIndicator(state),
            ],
          ),
          const SizedBox(height: 12),
          TextBox(
            controller: _controller,
            maxLines: 8,
            minLines: 3,
            placeholder: 'Type here to sync with phone...',
            placeholderStyle: TextStyle(
              color: Colors.white.withOpacity(0.2),
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Consolas',
              fontSize: 12,
              height: 1.4,
            ),
            decoration: WidgetStateProperty.all(const BoxDecoration(color: Colors.transparent)),
            onChanged: (value) {
              ref.read(scratchpadProvider.notifier).updateContent(value);
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (state.lastSyncedAt != null)
                Text(
                  'Last synced by ${state.lastSyncedBy}: ${state.lastSyncedAt!.hour}:${state.lastSyncedAt!.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.2),
                    fontSize: 7,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSyncIndicator(ScratchpadState state) {
    final color = state.isSyncing ? Colors.orange : Colors.green;
    return Tooltip(
      message: state.isSyncing ? 'Syncing...' : 'Synced',
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: color.withOpacity(0.8),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}
