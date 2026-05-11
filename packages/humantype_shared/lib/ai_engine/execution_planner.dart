import 'dart:math';

import '../models/section_model.dart';
import 'code_analyzer.dart';
import 'error_injector.dart';
import 'humanizer.dart';
import 'type_command.dart';

class ExecutionPlanner {
  Future<List<TypeCommand>> buildQueue(
    List<Section> sections, {
    Map<String, ClickTarget>? fieldTargets,
  }) async {
    final queue = <TypeCommand>[];
    for (final section in sections) {
      queue.addAll(_buildTargetCommands(section.target, fieldTargets));
      if (section.waitForManualStart ||
          section.preAction.type == PreActionType.waitForTap) {
        queue.add(const TypeCommand(type: CommandType.pause, delayMs: 0));
      }
      queue.addAll(_buildPreActionCommands(section.preAction));
      queue.addAll(await _buildSectionCommands(section));
      queue.addAll(_buildPostActionCommands(section.postAction));
    }
    return queue;
  }

  List<TypeCommand> _buildTargetCommands(
    SectionTarget target,
    Map<String, ClickTarget>? fieldTargets,
  ) {
    switch (target.type) {
      case TargetType.activeWindow:
        return const [];
      case TargetType.tabN:
        final count = target.tabCount ?? 0;
        return List.generate(count, (_) => TypeCommand.keyCommand('tab', 30));
      case TargetType.clickField:
        final fieldName = target.fieldName;
        if (fieldName == null || fieldTargets == null) {
          return const [];
        }
        final targetPoint = fieldTargets[fieldName];
        if (targetPoint == null) return const [];
        return [TypeCommand.click(targetPoint.x, targetPoint.y, 60)];
    }
  }

  List<TypeCommand> _buildPreActionCommands(PreAction action) {
    switch (action.type) {
      case PreActionType.none:
      case PreActionType.waitForTap:
        return const [];
      case PreActionType.waitSeconds:
        final seconds = action.waitSeconds ?? 0;
        return [TypeCommand.pause(seconds * 1000)];
      case PreActionType.pressKey:
        if (action.key == null) return const [];
        return [TypeCommand.keyCommand(action.key!, 40)];
      case PreActionType.pressHotkey:
        if (action.hotkey == null || action.hotkey!.isEmpty) {
          return const [];
        }
        return [TypeCommand.hotkey(action.hotkey!, 60)];
    }
  }

  List<TypeCommand> _buildPostActionCommands(PostAction action) {
    switch (action.type) {
      case PostActionType.none:
        return const [];
      case PostActionType.waitSeconds:
        final seconds = action.waitSeconds ?? 0;
        return [TypeCommand.pause(seconds * 1000)];
      case PostActionType.pressEnter:
        return [TypeCommand.keyCommand('enter', 50)];
      case PostActionType.pressTab:
        return [TypeCommand.keyCommand('tab', 50)];
      case PostActionType.pressHotkey:
        if (action.hotkey == null || action.hotkey!.isEmpty) {
          return const [];
        }
        return [TypeCommand.hotkey(action.hotkey!, 60)];
    }
  }

  Future<List<TypeCommand>> _buildSectionCommands(Section section) async {
    final text = section.content;
    if (text.isEmpty) return const [];

    final delays = section.mode == TypingMode.code
        ? Humanizer.analyzeCodeRhythm(
            text,
            section.speed,
            CodeAnalyzer.detectLanguage(text),
          )
        : Humanizer.analyzeRhythm(text, section.speed);

    final errorPlan = ErrorInjector.createPlan(
      text,
      section.errors,
      section.mode,
    );
    final queue = <TypeCommand>[];
    final pendingCorrections = <_PendingCorrection>[];

    var skipNext = 0;

    for (var i = 0; i < text.length; i++) {
      if (skipNext > 0) {
        skipNext--;
        continue;
      }

      final char = text[i];
      final delay = delays[i];
      final error = errorPlan[i];
      if (error != null && pendingCorrections.isEmpty) {
        final result = _buildErrorOutput(text, i, delay, error);

        for (final cmd in result.commands) {
          queue.add(cmd);
          _recordTypedAfter(pendingCorrections, cmd);
        }

        if (result.pendingCorrection != null) {
          pendingCorrections.add(result.pendingCorrection!);
        }
        skipNext = result.skipNext;
      } else {
        final cmd = TypeCommand.charCommand(char, delay);
        queue.add(cmd);
        _recordTypedAfter(pendingCorrections, cmd);
      }

      final isWordEnd = char == ' ' || char == '\n';
      final isSentenceEnd = char == '.' || char == '!' || char == '?';
      _flushCorrections(
        pendingCorrections,
        queue,
        section.speed,
        isWordEnd: isWordEnd,
        isSentenceEnd: isSentenceEnd,
      );
    }

    _flushCorrections(
      pendingCorrections,
      queue,
      section.speed,
      isWordEnd: true,
      isSentenceEnd: true,
    );

    return queue;
  }

  void _recordTypedAfter(
    List<_PendingCorrection> corrections,
    TypeCommand cmd,
  ) {
    if (corrections.isEmpty) return;
    if (cmd.type != CommandType.char) return;
    for (final correction in corrections) {
      correction.typedAfter.add(_TypedChar(cmd.char ?? '', cmd.delayMs));
    }
  }

  void _flushCorrections(
    List<_PendingCorrection> corrections,
    List<TypeCommand> queue,
    SpeedProfile speed, {
    required bool isWordEnd,
    required bool isSentenceEnd,
  }) {
    if (corrections.isEmpty) return;
    final ready = <_PendingCorrection>[];

    for (final correction in corrections) {
      if (correction.shouldTrigger(isWordEnd, isSentenceEnd)) {
        ready.add(correction);
      }
    }

    for (final correction in ready) {
      corrections.remove(correction);
      queue.addAll(_buildCorrectionCommands(correction, speed));
    }
  }

  List<TypeCommand> _buildCorrectionCommands(
    _PendingCorrection correction,
    SpeedProfile speed,
  ) {
    final commands = <TypeCommand>[];
    final backspaceCount =
        correction.typedAfter.length + correction.errorTypedCount;

    for (var i = 0; i < backspaceCount; i++) {
      commands.add(TypeCommand.backspace(35, isCorrection: true));
    }

    for (final char in correction.correctChars) {
      commands.add(
        TypeCommand.charCommand(
          char,
          max(30, speed.baseDelayMs ~/ 2),
          isCorrection: true,
        ),
      );
    }

    for (final typed in correction.typedAfter) {
      commands.add(
        TypeCommand.charCommand(typed.char, typed.delayMs, isCorrection: true),
      );
    }

    return commands;
  }

  _ErrorBuildResult _buildErrorOutput(
    String text,
    int index,
    int delay,
    PlannedError error,
  ) {
    final char = text[index];

    switch (error.type) {
      case ErrorType.adjacentKey:
        final wrong = ErrorInjector.pickAdjacentKey(char);
        return _ErrorBuildResult(
          commands: [TypeCommand.charCommand(wrong, delay, isError: true)],
          pendingCorrection: _PendingCorrection.from(
            error,
            correctChars: [char],
            errorTypedCount: 1,
          ),
        );
      case ErrorType.caseError:
        final wrong = char == char.toUpperCase()
            ? char.toLowerCase()
            : char.toUpperCase();
        return _ErrorBuildResult(
          commands: [TypeCommand.charCommand(wrong, delay, isError: true)],
          pendingCorrection: _PendingCorrection.from(
            error,
            correctChars: [char],
            errorTypedCount: 1,
          ),
        );
      case ErrorType.doubleChar:
        return _ErrorBuildResult(
          commands: [
            TypeCommand.charCommand(char, delay),
            TypeCommand.charCommand(char, max(20, delay ~/ 2), isError: true),
          ],
          pendingCorrection: _PendingCorrection.from(
            error,
            correctChars: const [],
            errorTypedCount: 1,
          ),
        );
      case ErrorType.missingChar:
        return _ErrorBuildResult(
          commands: const [],
          pendingCorrection: _PendingCorrection.from(
            error,
            correctChars: [char],
            errorTypedCount: 0,
          ),
        );
      case ErrorType.transposition:
        if (index + 1 >= text.length) {
          return _ErrorBuildResult(
            commands: [TypeCommand.charCommand(char, delay, isError: true)],
            pendingCorrection: _PendingCorrection.from(
              error,
              correctChars: [char],
              errorTypedCount: 1,
            ),
          );
        }
        final nextChar = text[index + 1];
        return _ErrorBuildResult(
          commands: [
            TypeCommand.charCommand(nextChar, delay, isError: true),
            TypeCommand.charCommand(char, max(20, delay ~/ 2), isError: true),
          ],
          pendingCorrection: _PendingCorrection.from(
            error,
            correctChars: [char, nextChar],
            errorTypedCount: 2,
          ),
          skipNext: 1,
        );
    }
  }
}

class ClickTarget {
  const ClickTarget({required this.x, required this.y});

  final int x;
  final int y;
}

class _TypedChar {
  const _TypedChar(this.char, this.delayMs);

  final String char;
  final int delayMs;
}

class _PendingCorrection {
  _PendingCorrection({
    required this.style,
    required this.correctChars,
    required this.errorTypedCount,
    required this.triggerAfterChars,
  });

  final CorrectionStyle style;
  final List<String> correctChars;
  final int errorTypedCount;
  final int triggerAfterChars;
  final List<_TypedChar> typedAfter = [];

  bool shouldTrigger(bool isWordEnd, bool isSentenceEnd) {
    switch (style) {
      case CorrectionStyle.immediate:
        return true;
      case CorrectionStyle.shortDelay:
        return typedAfter.length >= triggerAfterChars;
      case CorrectionStyle.wordEnd:
        return isWordEnd;
      case CorrectionStyle.sentenceEnd:
        return isSentenceEnd;
    }
  }

  factory _PendingCorrection.from(
    PlannedError error, {
    required List<String> correctChars,
    required int errorTypedCount,
  }) {
    return _PendingCorrection(
      style: error.correctionStyle,
      correctChars: correctChars,
      errorTypedCount: errorTypedCount,
      triggerAfterChars: error.correctionStyle == CorrectionStyle.shortDelay
          ? 2
          : 0,
    );
  }
}

class _ErrorBuildResult {
  const _ErrorBuildResult({
    required this.commands,
    this.pendingCorrection,
    this.skipNext = 0,
  });

  final List<TypeCommand> commands;
  final _PendingCorrection? pendingCorrection;
  final int skipNext;
}
