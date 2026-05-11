import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../../core/theme.dart';
import '../../../core/widgets/human_type_scaffold.dart';
import '../../settings/providers/settings_provider.dart';
import '../providers/execution_provider.dart';
import '../providers/session_provider.dart';
import '../providers/ocr_provider.dart';

class ExecutionScreen extends ConsumerWidget {
  const ExecutionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final execution = ref.watch(executionProvider);
    final settings = ref.watch(settingsProvider);

    final total = execution.charsTotal == 0 ? 1 : execution.charsTotal;
    final progress = (execution.charsCompleted / total).clamp(0.0, 1.0);

    return HumanTypeScaffold(
      title: 'Execution',
      showBack: true,
      enableScroll: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Typing in progress', style: HumanTypeText.heading1),
          const SizedBox(height: HumanTypeSpacing.sm),
          Text(
            'Stay focused on your laptop. Controls are below.',
            style: HumanTypeText.bodySmall,
          ),
          const SizedBox(height: HumanTypeSpacing.lg),
          _SectionDots(
            total: session.sections.length,
            currentIndex: session.currentSectionIndex,
          ),
          const SizedBox(height: HumanTypeSpacing.lg),
          _LivePreview(currentChar: execution.currentChar),
          const SizedBox(height: HumanTypeSpacing.lg),
          _ProgressBar(progress: progress),
          const SizedBox(height: HumanTypeSpacing.sm),
          Text(
            '${execution.charsCompleted} / ${execution.charsTotal} chars',
            style: HumanTypeText.bodySmall,
          ),
          const SizedBox(height: HumanTypeSpacing.xs),
            '${execution.estimatedSecondsRemaining}s remaining · '
            '${execution.currentWpm.toStringAsFixed(1)} WPM',
            style: HumanTypeText.bodySmall,
          ),
          const SizedBox(height: HumanTypeSpacing.lg),
          const _OcrLivePanel(),
          const Spacer(),
          if (!execution.isRunning)
            ElevatedButton.icon(
              onPressed: () async {
                if (settings.hapticsEnabled) {
                  HapticFeedback.mediumImpact();
                }
                await ref.read(executionProvider.notifier).start();
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start'),
            )
          else if (execution.isPaused)
            ElevatedButton.icon(
              onPressed: () {
                if (settings.hapticsEnabled) {
                  HapticFeedback.mediumImpact();
                }
                ref.read(executionProvider.notifier).resume();
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Resume'),
            )
          else
            ElevatedButton.icon(
              onPressed: () {
                if (settings.hapticsEnabled) {
                  HapticFeedback.mediumImpact();
                }
                ref.read(executionProvider.notifier).pause();
              },
              icon: const Icon(Icons.pause),
              label: const Text('Pause'),
            ),
          const SizedBox(height: HumanTypeSpacing.md),
          OutlinedButton.icon(
            onPressed: () {
              if (settings.hapticsEnabled) {
                HapticFeedback.heavyImpact();
              }
              ref.read(executionProvider.notifier).stop();
            },
            icon: const Icon(Icons.stop),
            label: const Text('Stop session'),
          ),
        ],
      ),
    );
  }
}

class _SectionDots extends StatelessWidget {
  const _SectionDots({required this.total, required this.currentIndex});

  final int total;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    if (total <= 1) return const SizedBox.shrink();
    return Row(
      children: List.generate(total, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: HumanTypeAnimation.standard,
          margin: const EdgeInsets.only(right: HumanTypeSpacing.sm),
          width: isActive ? 18 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: isActive
                ? HumanTypeColors.accentPrimary
                : HumanTypeColors.borderDefault,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }
}

class _LivePreview extends StatelessWidget {
  const _LivePreview({required this.currentChar});

  final String? currentChar;

  @override
  Widget build(BuildContext context) {
    final preview = currentChar == null ? '' : currentChar!;
    return Container(
      padding: const EdgeInsets.all(HumanTypeSpacing.lg),
      decoration: BoxDecoration(
        color: HumanTypeColors.bgElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HumanTypeColors.borderSubtle),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              preview.isEmpty ? 'Waiting for input' : preview,
              style: HumanTypeText.monoLarge,
            ),
          ),
          Container(
            width: 10,
            height: 20,
            decoration: BoxDecoration(
              color: HumanTypeColors.accentPrimary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 10,
        backgroundColor: HumanTypeColors.bgOverlay,
        valueColor: const AlwaysStoppedAnimation(HumanTypeColors.accentPrimary),
      ),
    );
  }
}

class _OcrLivePanel extends ConsumerWidget {
  const _OcrLivePanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ocr = ref.watch(ocrProvider);
    if (ocr.lastResult == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(HumanTypeSpacing.md),
      decoration: BoxDecoration(
        color: HumanTypeColors.bgElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HumanTypeColors.accentSecondary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.visibility, size: 14, color: HumanTypeColors.accentSecondary),
              const SizedBox(width: 8),
              Text('LIVE SCREEN CAPTURE',
                  style: HumanTypeText.caption
                      .copyWith(color: HumanTypeColors.accentSecondary)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.clear, size: 14),
                onPressed: () => ref.read(ocrProvider.notifier).clear(),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            ocr.lastResult!,
            style: HumanTypeText.mono.copyWith(fontSize: 12),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
