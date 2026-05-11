import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humantype_shared/humantype_shared.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme.dart';
import '../../../core/widgets/human_type_scaffold.dart';
import '../../text_mode/providers/session_provider.dart';
import '../providers/templates_provider.dart';

class TemplatesScreen extends ConsumerWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(templatesProvider);
    final session = ref.watch(sessionProvider);

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
          templates.when(
            data: (items) {
              if (items.isEmpty) {
                return _EmptyTemplateCard(
                  onCreate: () => _showCreateDialog(context, ref, session),
                );
              }
              return Column(
                children: items
                    .map((template) => _TemplateCard(
                          template: template,
                          onDelete: () => ref
                              .read(templatesProvider.notifier)
                              .removeTemplate(template.id),
                        ))
                    .toList(),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (_, __) => _EmptyTemplateCard(
              onCreate: () => _showCreateDialog(context, ref, session),
            ),
          ),
          const SizedBox(height: HumanTypeSpacing.xl),
          ElevatedButton.icon(
            onPressed: session.sections.isEmpty
                ? null
                : () => _showCreateDialog(context, ref, session),
            icon: const Icon(Icons.add),
            label: const Text('Create template'),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateDialog(
    BuildContext context,
    WidgetRef ref,
    SessionModel session,
  ) async {
    if (session.sections.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add sections before saving a template.')),
      );
      return;
    }

    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final tagsController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: HumanTypeColors.bgElevated,
        title: Text('New template', style: HumanTypeText.heading2),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: HumanTypeSpacing.sm),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: HumanTypeSpacing.sm),
            TextField(
              controller: tagsController,
              decoration: const InputDecoration(labelText: 'Tags (comma separated)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != true) return;

    final template = TemplateModel(
      id: const Uuid().v4(),
      name: nameController.text.trim().isEmpty
          ? 'Untitled template'
          : nameController.text.trim(),
      description: descriptionController.text.trim(),
      sections: session.sections,
      tags: tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await ref.read(templatesProvider.notifier).addTemplate(template);
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({required this.template, required this.onDelete});

  final TemplateModel template;
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.inventory_2_outlined, color: Colors.white70),
          const SizedBox(width: HumanTypeSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(template.name, style: HumanTypeText.bodyLarge),
                const SizedBox(height: HumanTypeSpacing.xs),
                Text(
                  template.description.isEmpty
                      ? 'No description'
                      : template.description,
                  style: HumanTypeText.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _EmptyTemplateCard extends StatelessWidget {
  const _EmptyTemplateCard({required this.onCreate});

  final VoidCallback onCreate;

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
          const Icon(Icons.inventory_2_outlined, color: Colors.white70),
          const SizedBox(width: HumanTypeSpacing.md),
          Expanded(
            child: Text(
              'No templates yet. Create your first one.',
              style: HumanTypeText.body,
            ),
          ),
          IconButton(
            onPressed: onCreate,
            icon: const Icon(Icons.add, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
