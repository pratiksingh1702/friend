import 'package:flutter/material.dart';
import 'package:humantype_shared/humantype_shared.dart';

import '../../../core/theme.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.section,
    required this.onEdit,
    required this.onDelete,
  });

  final Section section;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: HumanTypeSpacing.md),
      padding: const EdgeInsets.all(HumanTypeSpacing.lg),
      decoration: BoxDecoration(
        color: HumanTypeColors.bgElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HumanTypeColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(section.name, style: HumanTypeText.heading2),
              ),
              IconButton(
                tooltip: 'Edit',
                onPressed: onEdit,
                icon: const Icon(Icons.edit, color: Colors.white70),
              ),
              IconButton(
                tooltip: 'Delete',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: HumanTypeSpacing.xs),
          Text(
            _summary(section),
            style: HumanTypeText.bodySmall,
          ),
          const SizedBox(height: HumanTypeSpacing.sm),
          Text(
            section.content.isEmpty ? 'No content' : section.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: HumanTypeText.body,
          ),
        ],
      ),
    );
  }

  String _summary(Section section) {
    final speed = section.speed.type.name;
    final errors = section.errors.errorsPerLine;
    final mode = section.mode.name;
    return '${mode.toUpperCase()} · ${speed.toUpperCase()} · ${errors} err/ln';
  }
}
