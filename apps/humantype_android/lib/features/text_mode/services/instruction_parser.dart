import 'package:humantype_shared/humantype_shared.dart';
import 'package:uuid/uuid.dart';

class InstructionParser {
  const InstructionParser();

  Future<List<Section>> parse(
    String instruction, {
    AiService? aiService,
  }) async {
    final local = _tryLocalParse(instruction);
    if (local.isNotEmpty) return local;

    if (aiService != null) {
      return aiService.parseInstructions(instruction);
    }

    return [];
  }

  List<Section> _tryLocalParse(String instruction) {
    final trimmed = instruction.trim();
    if (trimmed.isEmpty) return [];

    final parts = trimmed
        .split(RegExp(r'\bthen\b', caseSensitive: false))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    final sections = <Section>[];
    for (final part in parts) {
      final speed = _parseSpeed(part);
      final errors = _parseErrors(part);
      final content = _extractContent(part);
      if (content.isEmpty) continue;

      sections.add(
        Section(
          id: const Uuid().v4(),
          name: 'Instruction',
          content: content,
          target: SectionTarget.activeWindow(),
          mode: TypingMode.text,
          speed: speed,
          errors: errors,
          preAction: PreAction.none(),
          postAction: PostAction.none(),
          waitForManualStart: part.toLowerCase().contains('wait for tap'),
        ),
      );
    }

    return sections;
  }

  SpeedProfile _parseSpeed(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('very fast')) {
      return SpeedProfile.preset(SpeedProfileType.veryFast);
    }
    if (lower.contains('fast')) {
      return SpeedProfile.preset(SpeedProfileType.fast);
    }
    if (lower.contains('very slow')) {
      return SpeedProfile.preset(SpeedProfileType.verySlow);
    }
    if (lower.contains('slow')) {
      return SpeedProfile.preset(SpeedProfileType.slow);
    }
    if (lower.contains('medium')) {
      return SpeedProfile.preset(SpeedProfileType.medium);
    }
    return SpeedProfile.preset(SpeedProfileType.medium);
  }

  ErrorProfile _parseErrors(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('no mistakes') || lower.contains('zero mistakes')) {
      return ErrorProfile.defaults();
    }

    final match = RegExp(r'(\d+)\s*mistake').firstMatch(lower);
    if (match != null) {
      final count = int.tryParse(match.group(1) ?? '') ?? 0;
      return ErrorProfile(
        errorsPerLine: count,
        allowedErrorTypes: [ErrorType.adjacentKey, ErrorType.transposition],
        correctionStyle: CorrectionStyle.wordEnd,
      );
    }

    return ErrorProfile.defaults();
  }

  String _extractContent(String text) {
    final lower = text.toLowerCase();
    if (lower.startsWith('type ')) {
      return text.substring(5).trim();
    }
    if (lower.startsWith('write ')) {
      return text.substring(6).trim();
    }
    return text.trim();
  }
}
