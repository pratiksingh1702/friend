import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../core/widgets/human_type_scaffold.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          Container(
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
                  child: Text(
                    'History logging is empty or disabled.',
                    style: HumanTypeText.body,
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
