import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:humantype_shared/humantype_shared.dart';

import '../../../core/router.dart';
import '../../../core/theme.dart';
import '../../../core/widgets/human_type_scaffold.dart';
import '../../settings/providers/settings_provider.dart';
import '../providers/execution_provider.dart';
import '../providers/session_provider.dart';
import '../services/instruction_parser.dart';
import '../widgets/section_builder_sheet.dart';
import '../widgets/section_card.dart';

class TextModeScreen extends ConsumerStatefulWidget {
  const TextModeScreen({super.key});

  @override
  ConsumerState<TextModeScreen> createState() => _TextModeScreenState();
}

class _TextModeScreenState extends ConsumerState<TextModeScreen> {
  final _instructionController = TextEditingController();
  final _parser = InstructionParser();

  @override
  void dispose() {
    _instructionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);

    return HumanTypeScaffold(
      title: 'Text Mode',
      showBack: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AI instructions', style: HumanTypeText.heading1),
          const SizedBox(height: HumanTypeSpacing.sm),
          Text(
            'Describe what to type and how. We will turn it into sections.',
            style: HumanTypeText.bodySmall,
          ),
          const SizedBox(height: HumanTypeSpacing.lg),
          TextField(
            controller: _instructionController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Type the name slowly, then fill the essay.',
            ),
          ),
          const SizedBox(height: HumanTypeSpacing.md),
          OutlinedButton.icon(
            onPressed: _parseInstruction,
            icon: const Icon(Icons.auto_fix_high),
            label: const Text('Parse instruction'),
          ),
          const SizedBox(height: HumanTypeSpacing.xl),
          Text('Sections', style: HumanTypeText.heading1),
          const SizedBox(height: HumanTypeSpacing.sm),
          Text(
            'Build your typing session section by section.',
            style: HumanTypeText.bodySmall,
          ),
          const SizedBox(height: HumanTypeSpacing.lg),
          if (session.sections.isEmpty)
            _EmptySectionCard(onAdd: () => _showSectionSheet(context, ref))
          else
            Column(
              children: session.sections
                  .map(
                    (section) => SectionCard(
                      section: section,
                      onEdit: () => _showSectionSheet(
                        context,
                        ref,
                        initial: section,
                      ),
                      onDelete: () => ref
                          .read(sessionProvider.notifier)
                          .removeSection(section.id),
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: HumanTypeSpacing.xl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showSectionSheet(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('New section'),
                ),
              ),
              const SizedBox(width: HumanTypeSpacing.md),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: session.sections.isEmpty
                      ? null
                      : () async {
                          await ref
                              .read(executionProvider.notifier)
                              .buildQueue(session.sections);
                          if (context.mounted) {
                            context.push(AppRoutes.execution);
                          }
                        },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Build session'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _parseInstruction() async {
    final input = _instructionController.text.trim();
    if (input.isEmpty) return;
    final settings = ref.read(settingsProvider);
    final sections = await _parser.parse(
      input,
      aiEnabled: settings.aiEnabled,
    );
    if (!mounted) return;
    if (sections.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No sections generated.')),
      );
      return;
    }
    for (final section in sections) {
      ref.read(sessionProvider.notifier).addSection(section);
    }
  }

  void _showSectionSheet(
    BuildContext context,
    WidgetRef ref, {
    Section? initial,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: HumanTypeColors.bgPrimary,
      builder: (context) => SectionBuilderSheet(
        initial: initial,
        onSave: (section) {
          if (initial == null) {
            ref.read(sessionProvider.notifier).addSection(section);
          } else {
            ref.read(sessionProvider.notifier).updateSection(section);
          }
        },
      ),
    );
  }
}

class _EmptySectionCard extends StatelessWidget {
  const _EmptySectionCard({required this.onAdd});

  final VoidCallback onAdd;

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
          const Icon(Icons.subject, color: Colors.white70),
          const SizedBox(width: HumanTypeSpacing.md),
          Expanded(
            child: Text(
              'No sections yet. Add your first section.',
              style: HumanTypeText.body,
            ),
          ),
          IconButton(
            onPressed: onAdd,
            icon: const Icon(Icons.add, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
