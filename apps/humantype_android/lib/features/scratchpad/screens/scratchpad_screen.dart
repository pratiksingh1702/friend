import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../core/widgets/human_type_scaffold.dart';
import '../providers/scratchpad_provider.dart';

class ScratchpadScreen extends ConsumerStatefulWidget {
  const ScratchpadScreen({super.key});

  @override
  ConsumerState<ScratchpadScreen> createState() => _ScratchpadScreenState();
}

class _ScratchpadScreenState extends ConsumerState<ScratchpadScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(scratchpadProvider).content);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scratchpadProvider);
    
    // Update controller if content changed remotely
    if (_controller.text != state.content && !state.isSyncing) {
      _controller.text = state.content;
    }

    return HumanTypeScaffold(
      title: 'Scratchpad',
      actions: [
        if (state.isSyncing)
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
          )
        else if (state.lastSyncedAt != null)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(Icons.check_circle, size: 16, color: HumanTypeColors.accentPrimary.withOpacity(0.5)),
          ),
      ],
      body: Column(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              maxLines: null,
              expands: true,
              style: HumanTypeText.body.copyWith(
                fontFamily: 'monospace',
                fontSize: 16,
              ),
              decoration: const InputDecoration(
                hintText: 'Start typing. It appears on your laptop instantly.',
                border: InputBorder.none,
              ),
              onChanged: (value) {
                ref.read(scratchpadProvider.notifier).updateContent(value);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${state.content.length} characters',
                  style: HumanTypeText.caption,
                ),
                if (state.lastSyncedAt != null)
                  Text(
                    'Last synced: ${_formatTime(state.lastSyncedAt!)}',
                    style: HumanTypeText.caption,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
