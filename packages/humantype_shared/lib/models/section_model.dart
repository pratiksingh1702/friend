enum TypingMode { text, code, fastFill }

enum TargetType { activeWindow, tabN, clickField }

enum PreActionType { none, waitSeconds, waitForTap, pressKey, pressHotkey }

enum PostActionType { none, waitSeconds, pressEnter, pressTab, pressHotkey }

enum CorrectionStyle { immediate, shortDelay, wordEnd, sentenceEnd }

enum ErrorType {
  adjacentKey,
  transposition,
  doubleChar,
  missingChar,
  caseError,
}

enum SpeedProfileType { verySlow, slow, medium, fast, veryFast, custom }

class SpeedProfile {
  const SpeedProfile({required this.type, required this.wpm});

  final SpeedProfileType type;
  final int wpm;

  factory SpeedProfile.preset(SpeedProfileType type) {
    return SpeedProfile(type: type, wpm: _defaultWpm(type));
  }

  factory SpeedProfile.custom(int wpm) {
    return SpeedProfile(type: SpeedProfileType.custom, wpm: wpm);
  }

  int get baseDelayMs {
    final adjustedWpm = wpm <= 0 ? 1 : wpm;
    return (60000 / (adjustedWpm * 5)).round();
  }

  Map<String, dynamic> toJson() {
    return {'type': _enumName(type), 'wpm': wpm};
  }

  factory SpeedProfile.fromJson(Map<String, dynamic> json) {
    final type = _enumFromString(
      SpeedProfileType.values,
      json['type'] as String?,
      SpeedProfileType.medium,
    );
    final wpm = (json['wpm'] as num?)?.toInt() ?? _defaultWpm(type);
    return SpeedProfile(type: type, wpm: wpm);
  }
}

class ErrorProfile {
  const ErrorProfile({
    required this.errorsPerLine,
    required this.allowedErrorTypes,
    required this.correctionStyle,
  });

  final int errorsPerLine;
  final List<ErrorType> allowedErrorTypes;
  final CorrectionStyle correctionStyle;

  factory ErrorProfile.defaults() {
    return const ErrorProfile(
      errorsPerLine: 0,
      allowedErrorTypes: [ErrorType.adjacentKey],
      correctionStyle: CorrectionStyle.wordEnd,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'errorsPerLine': errorsPerLine,
      'allowedErrorTypes': allowedErrorTypes.map(_enumName).toList(),
      'correctionStyle': _enumName(correctionStyle),
    };
  }

  factory ErrorProfile.fromJson(Map<String, dynamic> json) {
    final rawTypes = (json['allowedErrorTypes'] as List?) ?? const [];
    final types = rawTypes
        .map(
          (value) => _enumFromString(
            ErrorType.values,
            value as String?,
            ErrorType.adjacentKey,
          ),
        )
        .toList();

    return ErrorProfile(
      errorsPerLine: (json['errorsPerLine'] as num?)?.toInt() ?? 0,
      allowedErrorTypes: types.isEmpty ? [ErrorType.adjacentKey] : types,
      correctionStyle: _enumFromString(
        CorrectionStyle.values,
        json['correctionStyle'] as String?,
        CorrectionStyle.wordEnd,
      ),
    );
  }
}

class PreAction {
  const PreAction({
    required this.type,
    this.waitSeconds,
    this.key,
    this.hotkey,
  });

  final PreActionType type;
  final int? waitSeconds;
  final String? key;
  final List<String>? hotkey;

  factory PreAction.none() => const PreAction(type: PreActionType.none);

  Map<String, dynamic> toJson() {
    return {
      'type': _enumName(type),
      if (waitSeconds != null) 'waitSeconds': waitSeconds,
      if (key != null) 'key': key,
      if (hotkey != null) 'hotkey': hotkey,
    };
  }

  factory PreAction.fromJson(Map<String, dynamic> json) {
    return PreAction(
      type: _enumFromString(
        PreActionType.values,
        json['type'] as String?,
        PreActionType.none,
      ),
      waitSeconds: (json['waitSeconds'] as num?)?.toInt(),
      key: json['key'] as String?,
      hotkey: (json['hotkey'] as List?)?.cast<String>(),
    );
  }
}

class PostAction {
  const PostAction({
    required this.type,
    this.waitSeconds,
    this.key,
    this.hotkey,
  });

  final PostActionType type;
  final int? waitSeconds;
  final String? key;
  final List<String>? hotkey;

  factory PostAction.none() => const PostAction(type: PostActionType.none);

  Map<String, dynamic> toJson() {
    return {
      'type': _enumName(type),
      if (waitSeconds != null) 'waitSeconds': waitSeconds,
      if (key != null) 'key': key,
      if (hotkey != null) 'hotkey': hotkey,
    };
  }

  factory PostAction.fromJson(Map<String, dynamic> json) {
    return PostAction(
      type: _enumFromString(
        PostActionType.values,
        json['type'] as String?,
        PostActionType.none,
      ),
      waitSeconds: (json['waitSeconds'] as num?)?.toInt(),
      key: json['key'] as String?,
      hotkey: (json['hotkey'] as List?)?.cast<String>(),
    );
  }
}

class SectionTarget {
  const SectionTarget({required this.type, this.tabCount, this.fieldName});

  final TargetType type;
  final int? tabCount;
  final String? fieldName;

  factory SectionTarget.activeWindow() {
    return const SectionTarget(type: TargetType.activeWindow);
  }

  Map<String, dynamic> toJson() {
    return {
      'type': _enumName(type),
      if (tabCount != null) 'tabCount': tabCount,
      if (fieldName != null) 'fieldName': fieldName,
    };
  }

  factory SectionTarget.fromJson(Map<String, dynamic> json) {
    return SectionTarget(
      type: _enumFromString(
        TargetType.values,
        json['type'] as String?,
        TargetType.activeWindow,
      ),
      tabCount: (json['tabCount'] as num?)?.toInt(),
      fieldName: json['fieldName'] as String?,
    );
  }
}

class Section {
  const Section({
    required this.id,
    required this.name,
    required this.content,
    required this.target,
    required this.mode,
    required this.speed,
    required this.errors,
    required this.preAction,
    required this.postAction,
    required this.waitForManualStart,
  });

  final String id;
  final String name;
  final String content;
  final SectionTarget target;
  final TypingMode mode;
  final SpeedProfile speed;
  final ErrorProfile errors;
  final PreAction preAction;
  final PostAction postAction;
  final bool waitForManualStart;

  factory Section.basic({
    required String id,
    required String name,
    required String content,
  }) {
    return Section(
      id: id,
      name: name,
      content: content,
      target: SectionTarget.activeWindow(),
      mode: TypingMode.text,
      speed: SpeedProfile.preset(SpeedProfileType.medium),
      errors: ErrorProfile.defaults(),
      preAction: PreAction.none(),
      postAction: PostAction.none(),
      waitForManualStart: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'content': content,
      'target': target.toJson(),
      'mode': _enumName(mode),
      'speed': speed.toJson(),
      'errors': errors.toJson(),
      'preAction': preAction.toJson(),
      'postAction': postAction.toJson(),
      'waitForManualStart': waitForManualStart,
    };
  }

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      content: json['content'] as String? ?? '',
      target: SectionTarget.fromJson(
        (json['target'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      mode: _enumFromString(
        TypingMode.values,
        json['mode'] as String?,
        TypingMode.text,
      ),
      speed: SpeedProfile.fromJson(
        (json['speed'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      errors: ErrorProfile.fromJson(
        (json['errors'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      preAction: PreAction.fromJson(
        (json['preAction'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      postAction: PostAction.fromJson(
        (json['postAction'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      waitForManualStart: json['waitForManualStart'] as bool? ?? false,
    );
  }

  Section copyWith({
    String? id,
    String? name,
    String? content,
    SectionTarget? target,
    TypingMode? mode,
    SpeedProfile? speed,
    ErrorProfile? errors,
    PreAction? preAction,
    PostAction? postAction,
    bool? waitForManualStart,
  }) {
    return Section(
      id: id ?? this.id,
      name: name ?? this.name,
      content: content ?? this.content,
      target: target ?? this.target,
      mode: mode ?? this.mode,
      speed: speed ?? this.speed,
      errors: errors ?? this.errors,
      preAction: preAction ?? this.preAction,
      postAction: postAction ?? this.postAction,
      waitForManualStart: waitForManualStart ?? this.waitForManualStart,
    );
  }
}

int _defaultWpm(SpeedProfileType type) {
  switch (type) {
    case SpeedProfileType.verySlow:
      return 20;
    case SpeedProfileType.slow:
      return 35;
    case SpeedProfileType.medium:
      return 60;
    case SpeedProfileType.fast:
      return 90;
    case SpeedProfileType.veryFast:
      return 120;
    case SpeedProfileType.custom:
      return 60;
  }
}

String _enumName(Object value) => value.toString().split('.').last;

T _enumFromString<T>(List<T> values, String? value, T fallback) {
  if (value == null) return fallback;
  for (final entry in values) {
    if (_enumName(entry).toLowerCase() == value.toLowerCase()) {
      return entry;
    }
  }
  return fallback;
}
