import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../core/widgets/human_type_scaffold.dart';

class TextModeScreen extends StatelessWidget {
  const TextModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return HumanTypeScaffold(
      title: 'Text Mode',
      showBack: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sections', style: HumanTypeText.heading1),
          const SizedBox(height: HumanTypeSpacing.sm),
          Text(
            'Build your typing session section by section.',
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
                const Icon(Icons.subject, color: Colors.white70),
                const SizedBox(width: HumanTypeSpacing.md),
                Expanded(
                  child: Text(
                    'No sections yet. Add your first section.',
                    style: HumanTypeText.body,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: HumanTypeSpacing.xl),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('New section'),
          ),
        ],
      ),
    );
  }
}
