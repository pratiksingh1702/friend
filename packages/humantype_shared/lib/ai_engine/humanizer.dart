import 'dart:math';

import '../models/section_model.dart';
import 'code_analyzer.dart';

class Humanizer {
  static final Random _random = Random();

  static List<int> analyzeRhythm(String text, SpeedProfile speed) {
    final baseDelay = speed.baseDelayMs;
    final delays = List<int>.filled(text.length, baseDelay);

    for (var i = 0; i < text.length; i++) {
      final char = text[i];
      var delay = baseDelay;
      delay = _applyCapitalModifier(char, delay);
      delay = _applyWordBoundaryModifier(text, i, delay);
      delay = _applyBurstModifier(text, i, delay);
      delay = _applyPunctuationPause(char, delay);
      delay = _applyVariance(delay);
      delays[i] = delay;
    }

    return delays;
  }

  static List<int> analyzeCodeRhythm(
    String code,
    SpeedProfile speed,
    ProgrammingLanguage language,
  ) {
    final baseDelay = speed.baseDelayMs;
    final delays = List<int>.filled(code.length, baseDelay);
    final zones = CodeAnalyzer.analyzeZones(code, language);
    final lines = code.split('\n');
    var offset = 0;

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isNotEmpty && _isFunctionDef(trimmed, language)) {
        if (offset < delays.length) {
          delays[offset] = delays[offset] + _randomInRange(1200, 2500);
        }
      } else if (trimmed.isNotEmpty && _isComplexLogic(trimmed, language)) {
        if (offset < delays.length) {
          delays[offset] = delays[offset] + _randomInRange(400, 900);
        }
      }

      for (var i = 0; i < line.length; i++) {
        final index = offset + i;
        final zone = zones[index] ?? CodeZone.variableName;
        var delay = baseDelay;

        switch (zone) {
          case CodeZone.syntaxKeyword:
          case CodeZone.syntaxOperator:
            delay = (delay * 0.7).round();
            break;
          case CodeZone.syntaxStructure:
            delay = (delay * 0.85).round();
            break;
          case CodeZone.comment:
            delay = (delay * 1.35).round();
            break;
          case CodeZone.stringContent:
            delay = (delay * 1.15).round();
            break;
          case CodeZone.importPath:
            delay = (delay * 0.8).round();
            break;
          case CodeZone.variableName:
            delay = (delay * 1.0).round();
            break;
        }

        if (_isUppercaseAlpha(code[index])) {
          delay = (delay * 1.2).round();
        }

        delays[index] = _applyVariance(delay);
      }

      final lineEndIndex = offset + line.length;
      if (lineEndIndex < delays.length) {
        delays[lineEndIndex] = _randomInRange(200, 600);
      }
      offset += line.length + 1;
    }

    return delays;
  }

  static int _applyCapitalModifier(String char, int delay) {
    if (_isUppercaseAlpha(char)) {
      return (delay * 1.4).round();
    }
    return delay;
  }

  static int _applyWordBoundaryModifier(String text, int i, int delay) {
    if (i > 0 && text[i - 1] == ' ') {
      return (delay * 1.2).round();
    }
    return delay;
  }

  static const List<String> _fastDigraphs = [
    'th',
    'er',
    'on',
    'an',
    'in',
    're',
    'he',
    'nd',
    'at',
    'en',
  ];

  static const List<String> _fastTrigraphs = [
    'the',
    'and',
    'ing',
    'ion',
    'ent',
    'for',
    'tio',
    'ere',
  ];

  static int _applyBurstModifier(String text, int i, int delay) {
    if (i >= 1) {
      final digraph = text.substring(i - 1, i + 1).toLowerCase();
      if (_fastDigraphs.contains(digraph)) {
        return (delay * 0.7).round();
      }
    }
    if (i >= 2) {
      final trigraph = text.substring(i - 2, i + 1).toLowerCase();
      if (_fastTrigraphs.contains(trigraph)) {
        return (delay * 0.65).round();
      }
    }
    return delay;
  }

  static int _applyPunctuationPause(String char, int delay) {
    switch (char) {
      case '.':
        return delay + _randomInRange(300, 800);
      case ',':
        return delay + _randomInRange(80, 200);
      case '\n':
        return delay + _randomInRange(400, 1200);
      case ';':
      case ':':
        return delay + _randomInRange(120, 300);
      default:
        return delay;
    }
  }

  static int _applyVariance(int delay) {
    final variance = (delay * 0.15).round();
    return max(5, delay + _randomInRange(-variance, variance));
  }

  static int _randomInRange(int min, int max) {
    if (max <= min) return min;
    return min + _random.nextInt(max - min + 1);
  }

  static bool _isUppercaseAlpha(String char) {
    return char == char.toUpperCase() && char != char.toLowerCase();
  }

  static bool _isFunctionDef(String line, ProgrammingLanguage language) {
    switch (language) {
      case ProgrammingLanguage.python:
        return line.startsWith('def ') || line.startsWith('class ');
      case ProgrammingLanguage.javascript:
        return line.startsWith('function ') || line.contains('=>');
      case ProgrammingLanguage.dart:
        return line.startsWith('class ') || line.contains('Widget ');
      case ProgrammingLanguage.java:
        return line.contains(' class ') || line.startsWith('public ');
      case ProgrammingLanguage.unknown:
        return false;
    }
  }

  static bool _isComplexLogic(String line, ProgrammingLanguage language) {
    if (line.contains('if ') ||
        line.contains('for ') ||
        line.contains('while')) {
      return true;
    }
    switch (language) {
      case ProgrammingLanguage.python:
        return line.contains('try:') || line.contains('except');
      case ProgrammingLanguage.javascript:
      case ProgrammingLanguage.dart:
      case ProgrammingLanguage.java:
        return line.contains('switch') || line.contains('catch');
      case ProgrammingLanguage.unknown:
        return false;
    }
  }
}
