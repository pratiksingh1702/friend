import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router.dart';
import '../../../core/theme.dart';
import '../../../core/widgets/human_type_scaffold.dart';

class ConnectScreen extends StatelessWidget {
  const ConnectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return HumanTypeScaffold(
      title: 'Connect',
      showBack: true,
      actions: [
        IconButton(
          onPressed: () => context.go(AppRoutes.home),
          icon: const Icon(Icons.close),
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nearby devices', style: HumanTypeText.heading1),
          const SizedBox(height: HumanTypeSpacing.sm),
          Text(
            'Scan for HumanType Bridge on your network.',
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
                const Icon(Icons.wifi_tethering, color: Colors.white70),
                const SizedBox(width: HumanTypeSpacing.md),
                Expanded(
                  child: Text(
                    'No devices found yet',
                    style: HumanTypeText.body,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: HumanTypeSpacing.xl),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.search),
            label: const Text('Scan for devices'),
          ),
          const SizedBox(height: HumanTypeSpacing.md),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit),
            label: const Text('Enter IP manually'),
          ),
        ],
      ),
    );
  }
}
