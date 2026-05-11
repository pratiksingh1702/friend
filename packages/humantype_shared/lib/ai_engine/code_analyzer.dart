enum ProgrammingLanguage { python, javascript, dart, java, unknown }

enum CodeZone {
  syntaxKeyword,
  syntaxOperator,
  syntaxStructure,
  variableName,
  stringContent,
  comment,
  importPath,
}

class CodeAnalyzer {
  static ProgrammingLanguage detectLanguage(String code) {
    if (code.contains('def ') ||
        code.contains('import ') && code.contains(':')) {
      return ProgrammingLanguage.python;
    }
    if (code.contains('function ') ||
        code.contains('const ') ||
        code.contains('=>')) {
      return ProgrammingLanguage.javascript;
    }
    if (code.contains('Widget') || code.contains('@override')) {
      return ProgrammingLanguage.dart;
    }
    if (code.contains('public class') || code.contains('System.out')) {
      return ProgrammingLanguage.java;
    }
    return ProgrammingLanguage.unknown;
  }

  static Map<int, CodeZone> analyzeZones(
    String code,
    ProgrammingLanguage lang,
  ) {
    final zones = <int, CodeZone>{};
    final lines = code.split('\n');
    var offset = 0;

    for (final line in lines) {
      final lineZones = _analyzeLine(line, lang);
      for (var i = 0; i < line.length; i++) {
        zones[offset + i] = lineZones[i] ?? CodeZone.variableName;
      }
      offset += line.length + 1;
    }

    return zones;
  }

  static bool isSafeZone(int charIndex, String code) {
    final zones = analyzeZones(code, detectLanguage(code));
    final zone = zones[charIndex];
    return zone == CodeZone.variableName ||
        zone == CodeZone.stringContent ||
        zone == CodeZone.comment;
  }

  static Map<int, CodeZone> _analyzeLine(
    String line,
    ProgrammingLanguage lang,
  ) {
    final zones = <int, CodeZone>{};
    if (line.isEmpty) return zones;

    _markCommentZones(line, zones, lang);
    _markStringZones(line, zones);
    _markImportZones(line, zones, lang);
    _markKeywordZones(line, zones, lang);
    _markOperatorZones(line, zones);
    _markStructureZones(line, zones);

    return zones;
  }

  static void _markCommentZones(
    String line,
    Map<int, CodeZone> zones,
    ProgrammingLanguage lang,
  ) {
    final commentIndex = _commentStartIndex(line, lang);
    if (commentIndex == -1) return;
    for (var i = commentIndex; i < line.length; i++) {
      zones[i] = CodeZone.comment;
    }
  }

  static int _commentStartIndex(String line, ProgrammingLanguage lang) {
    final trimmed = line.trimLeft();
    if (trimmed.isEmpty) return -1;
    switch (lang) {
      case ProgrammingLanguage.python:
        return line.indexOf('#');
      case ProgrammingLanguage.javascript:
      case ProgrammingLanguage.dart:
      case ProgrammingLanguage.java:
        return line.indexOf('//');
      case ProgrammingLanguage.unknown:
        return -1;
    }
  }

  static void _markStringZones(String line, Map<int, CodeZone> zones) {
    var inString = false;
    var quoteChar = '';

    for (var i = 0; i < line.length; i++) {
      final char = line[i];
      if (!inString && (char == '"' || char == '\'')) {
        inString = true;
        quoteChar = char;
        zones[i] = CodeZone.stringContent;
        continue;
      }

      if (inString) {
        zones[i] = CodeZone.stringContent;
        if (char == quoteChar && !_isEscaped(line, i)) {
          inString = false;
          quoteChar = '';
        }
      }
    }
  }

  static void _markImportZones(
    String line,
    Map<int, CodeZone> zones,
    ProgrammingLanguage lang,
  ) {
    if (!_isImportLine(line, lang)) return;
    for (var i = 0; i < line.length; i++) {
      if (zones[i] == CodeZone.stringContent) {
        zones[i] = CodeZone.importPath;
      }
    }
  }

  static bool _isImportLine(String line, ProgrammingLanguage lang) {
    final trimmed = line.trimLeft();
    switch (lang) {
      case ProgrammingLanguage.python:
        return trimmed.startsWith('import ') || trimmed.startsWith('from ');
      case ProgrammingLanguage.javascript:
      case ProgrammingLanguage.dart:
        return trimmed.startsWith('import ');
      case ProgrammingLanguage.java:
        return trimmed.startsWith('import ') || trimmed.startsWith('package ');
      case ProgrammingLanguage.unknown:
        return false;
    }
  }

  static void _markKeywordZones(
    String line,
    Map<int, CodeZone> zones,
    ProgrammingLanguage lang,
  ) {
    final keywords = _keywordsFor(lang);
    for (final keyword in keywords) {
      var start = 0;
      while (start < line.length) {
        final index = line.indexOf(keyword, start);
        if (index == -1) break;
        final end = index + keyword.length;
        if (_isWordBoundary(line, index - 1) && _isWordBoundary(line, end)) {
          for (var i = index; i < end; i++) {
            zones.putIfAbsent(i, () => CodeZone.syntaxKeyword);
          }
        }
        start = end;
      }
    }
  }

  static void _markOperatorZones(String line, Map<int, CodeZone> zones) {
    const operators = [
      '==',
      '!=',
      '>=',
      '<=',
      '=>',
      '+=',
      '-=',
      '*=',
      '/=',
      '=',
    ];
    for (final op in operators) {
      var start = 0;
      while (start < line.length) {
        final index = line.indexOf(op, start);
        if (index == -1) break;
        for (var i = index; i < index + op.length; i++) {
          zones.putIfAbsent(i, () => CodeZone.syntaxOperator);
        }
        start = index + op.length;
      }
    }
  }

  static void _markStructureZones(String line, Map<int, CodeZone> zones) {
    const structureChars = ['(', ')', '{', '}', '[', ']', ':', ';'];
    for (var i = 0; i < line.length; i++) {
      if (structureChars.contains(line[i])) {
        zones.putIfAbsent(i, () => CodeZone.syntaxStructure);
      }
    }
  }

  static bool _isWordBoundary(String line, int index) {
    if (index < 0 || index >= line.length) return true;
    final char = line[index];
    return !RegExp(r'[A-Za-z0-9_]').hasMatch(char);
  }

  static bool _isEscaped(String line, int index) {
    if (index <= 0) return false;
    var backslashes = 0;
    for (var i = index - 1; i >= 0; i--) {
      if (line[i] == '\\') {
        backslashes++;
      } else {
        break;
      }
    }
    return backslashes.isOdd;
  }

  static List<String> _keywordsFor(ProgrammingLanguage lang) {
    switch (lang) {
      case ProgrammingLanguage.python:
        return [
          'def',
          'class',
          'import',
          'from',
          'return',
          'if',
          'elif',
          'else',
        ];
      case ProgrammingLanguage.javascript:
        return ['function', 'const', 'let', 'var', 'return', 'if', 'else'];
      case ProgrammingLanguage.dart:
        return ['class', 'import', 'return', 'if', 'else', 'final', 'const'];
      case ProgrammingLanguage.java:
        return ['class', 'public', 'private', 'import', 'return', 'if', 'else'];
      case ProgrammingLanguage.unknown:
        return const [];
    }
  }
}
