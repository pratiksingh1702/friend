import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../core/widgets/human_type_scaffold.dart';

class CodeModeScreen extends StatelessWidget {
  const CodeModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return HumanTypeScaffold(
      title: 'Code Mode',
      showBack: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Code input', style: HumanTypeText.heading1),
          const SizedBox(height: HumanTypeSpacing.sm),
          Text(
            'Paste or type code to simulate realistic coding cadence.',
            style: HumanTypeText.bodySmall,
          ),
          const SizedBox(height: HumanTypeSpacing.lg),
          TextField(
            maxLines: 6,
            style: HumanTypeText.mono,
            decoration: const InputDecoration(
              hintText: 'Paste your code here',
            ),
          ),
          const SizedBox(height: HumanTypeSpacing.xl),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.play_arrow),
            label: const Text('Build session'),
          ),
        ],
      ),
    );
  }
}
