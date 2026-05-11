import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../core/widgets/human_type_scaffold.dart';

class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return HumanTypeScaffold(
      title: 'Templates',
      showBack: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Template library', style: HumanTypeText.heading1),
          const SizedBox(height: HumanTypeSpacing.sm),
          Text(
            'Save and reuse full sessions.',
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
                const Icon(Icons.inventory_2_outlined, color: Colors.white70),
                const SizedBox(width: HumanTypeSpacing.md),
                Expanded(
                  child: Text(
                    'No templates yet. Create your first one.',
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
            label: const Text('Create template'),
          ),
        ],
      ),
    );
  }
}
