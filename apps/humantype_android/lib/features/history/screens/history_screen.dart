import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humantype_shared/humantype_shared.dart';
import 'package:intl/intl.dart';

import '../../../core/theme.dart';
import '../../../core/widgets/human_type_scaffold.dart';
import '../../settings/providers/settings_provider.dart';
import '../providers/history_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final history = ref.watch(historyProvider);

    return HumanTypeScaffold(
      title: 'History',
      showBack: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Session history', style: HumanTypeText.heading1),
          const SizedBox(height: HumanTypeSpacing.sm),
          Text(
            'Review recent sessions and performance.',
            style: HumanTypeText.bodySmall,
          ),
          const SizedBox(height: HumanTypeSpacing.lg),
          if (!settings.historyEnabled)
            _EmptyHistoryCard(
              message: 'History logging is disabled in settings.',
            )
          else
            history.when(
              data: (items) {
                if (items.isEmpty) {
                  return const _EmptyHistoryCard(
                    message: 'No sessions logged yet.',
                  );
                }
                return Column(
                  children: items
                      .map((session) => _HistoryCard(session: session))
                      .toList(),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (_, __) => const _EmptyHistoryCard(
                message: 'History unavailable. Try again later.',
              ),
            ),
          if (settings.historyEnabled) ...[
            const SizedBox(height: HumanTypeSpacing.xl),
            OutlinedButton.icon(
              onPressed: () =>
                  ref.read(historyProvider.notifier).clearHistory(),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Clear history'),
            ),
          ]
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.session});

  final SessionModel session;

  @override
  Widget build(BuildContext context) {
    final timestamp = DateFormat('MMM d, HH:mm').format(session.createdAt);
    return Container(
      margin: const EdgeInsets.only(bottom: HumanTypeSpacing.md),
      padding: const EdgeInsets.all(HumanTypeSpacing.lg),
      decoration: BoxDecoration(
        color: HumanTypeColors.bgElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HumanTypeColors.borderSubtle),
      ),
      child: Row(
        children: [
          const Icon(Icons.history, color: Colors.white70),
          const SizedBox(width: HumanTypeSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(timestamp, style: HumanTypeText.bodyLarge),
                const SizedBox(height: HumanTypeSpacing.xs),
                Text(
                  '${session.charsCompleted} chars · ${session.currentWpm.toStringAsFixed(1)} WPM',
                  style: HumanTypeText.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHistoryCard extends StatelessWidget {
  const _EmptyHistoryCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(HumanTypeSpacing.lg),
      decoration: BoxDecoration(
        color: HumanTypeColors.bgElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HumanTypeColors.borderSubtle),
      ),
      child: Row(
        children: [
          const Icon(Icons.history, color: Colors.white70),
          const SizedBox(width: HumanTypeSpacing.md),
          Expanded(
            child: Text(message, style: HumanTypeText.body),
          ),
        ],
      ),
    );
  }
}
