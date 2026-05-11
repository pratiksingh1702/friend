import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:humantype_shared/humantype_shared.dart';

import '../../../core/router.dart';
import '../../../core/theme.dart';
import '../../../core/widgets/human_type_scaffold.dart';
import '../../text_mode/providers/execution_provider.dart';
import '../../text_mode/providers/session_provider.dart';
import '../providers/code_session_provider.dart';

class CodeModeScreen extends ConsumerWidget {
  const CodeModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(codeSessionProvider);
    final sessionNotifier = ref.read(sessionProvider.notifier);

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
            maxLines: 8,
            style: HumanTypeText.mono,
            onChanged: (value) =>
                ref.read(codeSessionProvider.notifier).setCode(value),
            decoration: const InputDecoration(
              hintText: 'Paste your code here',
            ),
          ),
          const SizedBox(height: HumanTypeSpacing.lg),
          DropdownButtonFormField<SpeedProfileType>(
            value: state.speed.type,
            items: SpeedProfileType.values
                .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type.name),
                    ))
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              ref
                  .read(codeSessionProvider.notifier)
                  .setSpeed(SpeedProfile.preset(value));
            },
            decoration: const InputDecoration(labelText: 'Speed profile'),
          ),
          const SizedBox(height: HumanTypeSpacing.lg),
          Slider(
            value: state.errors.errorsPerLine.toDouble(),
            min: 0,
            max: 3,
            divisions: 3,
            label: '${state.errors.errorsPerLine} errors/line',
            onChanged: (value) {
              ref.read(codeSessionProvider.notifier).setErrors(
                    ErrorProfile(
                      errorsPerLine: value.round(),
                      allowedErrorTypes: state.errors.allowedErrorTypes,
                      correctionStyle: state.errors.correctionStyle,
                    ),
                  );
            },
          ),
          const SizedBox(height: HumanTypeSpacing.xl),
          ElevatedButton.icon(
            onPressed: state.code.trim().isEmpty
                ? null
                : () async {
                    sessionNotifier.resetSession();
                    sessionNotifier.addSection(
                      Section(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: 'Code session',
                        content: state.code,
                        target: SectionTarget.activeWindow(),
                        mode: TypingMode.code,
                        speed: state.speed,
                        errors: state.errors,
                        preAction: PreAction.none(),
                        postAction: PostAction.none(),
                        waitForManualStart: false,
                      ),
                    );
                    final session = ref.read(sessionProvider);
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
        ],
      ),
    );
  }
}
