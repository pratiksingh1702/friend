import 'dart:math';

import '../models/section_model.dart';
import 'code_analyzer.dart';

class PlannedError {
  const PlannedError({required this.type, required this.correctionStyle});

  final ErrorType type;
  final CorrectionStyle correctionStyle;
}

class ErrorInjector {
  static final Random _random = Random();

  static const Map<String, List<String>> _adjacentKeys = {
    'q': ['w', 'a'],
    'w': ['q', 'e', 'a', 's'],
    'e': ['w', 'r', 's', 'd'],
    'r': ['e', 't', 'd', 'f'],
    't': ['r', 'y', 'f', 'g'],
    'y': ['t', 'u', 'g', 'h'],
    'u': ['y', 'i', 'h', 'j'],
    'i': ['u', 'o', 'j', 'k'],
    'o': ['i', 'p', 'k', 'l'],
    'p': ['o', 'l'],
    'a': ['q', 'w', 's', 'z'],
    's': ['a', 'd', 'w', 'e', 'z', 'x'],
    'd': ['s', 'f', 'e', 'r', 'x', 'c'],
    'f': ['d', 'g', 'r', 't', 'c', 'v'],
    'g': ['f', 'h', 't', 'y', 'v', 'b'],
    'h': ['g', 'j', 'y', 'u', 'b', 'n'],
    'j': ['h', 'k', 'u', 'i', 'n', 'm'],
    'k': ['j', 'l', 'i', 'o', 'm'],
    'l': ['k', 'o', 'p'],
    'z': ['a', 's', 'x'],
    'x': ['z', 's', 'd', 'c'],
    'c': ['x', 'd', 'f', 'v'],
    'v': ['c', 'f', 'g', 'b'],
    'b': ['v', 'g', 'h', 'n'],
    'n': ['b', 'h', 'j', 'm'],
    'm': ['n', 'j', 'k'],
  };

  static const List<String> _skipWords = [
    'a',
    'is',
    'of',
    'the',
    'to',
    'in',
    'it',
    'be',
    'as',
    'at',
    'by',
    'we',
  ];

  static Map<int, PlannedError> createPlan(
    String text,
    ErrorProfile profile,
    TypingMode mode,
  ) {
    if (profile.errorsPerLine <= 0) return <int, PlannedError>{};

    final plan = <int, PlannedError>{};
    final lines = text.split('\n');
    var offset = 0;
    var lastErrorIndex = -10;

    for (final line in lines) {
      final words = _tokenize(line, offset);
      if (words.isEmpty) {
        offset += line.length + 1;
        continue;
      }

      final eligible = words
          .where((word) => _isEligibleWord(word.text))
          .toList();
      if (eligible.isEmpty) {
        offset += line.length + 1;
        continue;
      }

      final targetErrors = min(profile.errorsPerLine, eligible.length);
      eligible.shuffle(_random);

      var placed = 0;
      for (final word in eligible) {
        if (placed >= targetErrors) break;
        final charIndex = _chooseErrorPosition(word);
        if (charIndex - lastErrorIndex < 5) {
          continue;
        }
        if (mode == TypingMode.code &&
            !CodeAnalyzer.isSafeZone(charIndex, text)) {
          continue;
        }

        plan[charIndex] = PlannedError(
          type: _chooseErrorType(text[charIndex], profile),
          correctionStyle: profile.correctionStyle,
        );
        lastErrorIndex = charIndex;
        placed++;
      }

      offset += line.length + 1;
    }

    return plan;
  }

  static ErrorType _chooseErrorType(String char, ErrorProfile profile) {
    final allowed = profile.allowedErrorTypes;
    if (allowed.contains(ErrorType.adjacentKey) &&
        _adjacentKeys.containsKey(char.toLowerCase())) {
      return ErrorType.adjacentKey;
    }
    if (allowed.contains(ErrorType.transposition))
      return ErrorType.transposition;
    if (allowed.contains(ErrorType.doubleChar)) return ErrorType.doubleChar;
    if (allowed.contains(ErrorType.missingChar)) return ErrorType.missingChar;
    if (allowed.contains(ErrorType.caseError)) return ErrorType.caseError;
    return allowed.isEmpty ? ErrorType.adjacentKey : allowed.first;
  }

  static String pickAdjacentKey(String char) {
    final neighbors = _adjacentKeys[char.toLowerCase()];
    if (neighbors == null || neighbors.isEmpty) return char;
    return neighbors[_random.nextInt(neighbors.length)];
  }

  static bool _isEligibleWord(String text) {
    final lower = text.toLowerCase();
    if (text.length <= 2) return false;
    if (_skipWords.contains(lower)) return false;
    return true;
  }

  static int _chooseErrorPosition(_WordSpan word) {
    if (word.length <= 1) return word.start;
    final index = _random.nextInt(word.length - 1) + 1;
    return word.start + index;
  }

  static List<_WordSpan> _tokenize(String line, int offset) {
    final words = <_WordSpan>[];
    var start = -1;

    for (var i = 0; i < line.length; i++) {
      final char = line[i];
      final isWordChar = RegExp(r'[A-Za-z]').hasMatch(char);
      if (isWordChar) {
        if (start == -1) start = i;
      } else if (start != -1) {
        words.add(
          _WordSpan(
            start: offset + start,
            end: offset + i,
            text: line.substring(start, i),
          ),
        );
        start = -1;
      }
    }

    if (start != -1) {
      words.add(
        _WordSpan(
          start: offset + start,
          end: offset + line.length,
          text: line.substring(start, line.length),
        ),
      );
    }

    return words;
  }
}

class _WordSpan {
  _WordSpan({required this.start, required this.end, required this.text});

  final int start;
  final int end;
  final String text;

  int get length => end - start;
}
