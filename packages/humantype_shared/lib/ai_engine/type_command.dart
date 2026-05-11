enum CommandType { char, specialKey, hotkey, pause, click }

class TypeCommand {
  const TypeCommand({
    required this.type,
    this.char,
    this.key,
    this.keys,
    required this.delayMs,
    this.x,
    this.y,
    this.isError = false,
    this.isCorrection = false,
  });

  final CommandType type;
  final String? char;
  final String? key;
  final List<String>? keys;
  final int delayMs;
  final int? x;
  final int? y;
  final bool isError;
  final bool isCorrection;

  static TypeCommand charCommand(
    String value,
    int delayMs, {
    bool isError = false,
    bool isCorrection = false,
  }) {
    return TypeCommand(
      type: CommandType.char,
      char: value,
      delayMs: delayMs,
      isError: isError,
      isCorrection: isCorrection,
    );
  }

  static TypeCommand keyCommand(
    String value,
    int delayMs, {
    bool isCorrection = false,
  }) {
    return TypeCommand(
      type: CommandType.specialKey,
      key: value,
      delayMs: delayMs,
      isCorrection: isCorrection,
    );
  }

  static TypeCommand backspace(int delayMs, {bool isCorrection = false}) {
    return keyCommand('backspace', delayMs, isCorrection: isCorrection);
  }

  static TypeCommand hotkey(List<String> keys, int delayMs) {
    return TypeCommand(type: CommandType.hotkey, keys: keys, delayMs: delayMs);
  }

  static TypeCommand pause(int durationMs) {
    return TypeCommand(type: CommandType.pause, delayMs: durationMs);
  }

  static TypeCommand click(int x, int y, int delayMs) {
    return TypeCommand(type: CommandType.click, x: x, y: y, delayMs: delayMs);
  }

  Map<String, dynamic> toJson() {
    return {
      'action': _commandTypeToWire(type),
      if (char != null) 'char': char,
      if (key != null) 'key': key,
      if (keys != null) 'keys': keys,
      'delay_pre_ms': delayMs,
      if (x != null) 'x': x,
      if (y != null) 'y': y,
      if (isError) 'is_error': isError,
      if (isCorrection) 'is_correction': isCorrection,
    };
  }

  factory TypeCommand.fromJson(Map<String, dynamic> json) {
    return TypeCommand(
      type: _commandTypeFromWire(json['action'] as String?),
      char: json['char'] as String?,
      key: json['key'] as String?,
      keys: (json['keys'] as List?)?.cast<String>(),
      delayMs: (json['delay_pre_ms'] as num?)?.toInt() ?? 0,
      x: (json['x'] as num?)?.toInt(),
      y: (json['y'] as num?)?.toInt(),
      isError: json['is_error'] as bool? ?? false,
      isCorrection: json['is_correction'] as bool? ?? false,
    );
  }
}

String _commandTypeToWire(CommandType type) {
  switch (type) {
    case CommandType.char:
      return 'CHAR';
    case CommandType.specialKey:
      return 'SPECIAL_KEY';
    case CommandType.hotkey:
      return 'HOTKEY';
    case CommandType.pause:
      return 'PAUSE';
    case CommandType.click:
      return 'CLICK';
  }
}

CommandType _commandTypeFromWire(String? value) {
  switch (value) {
    case 'CHAR':
      return CommandType.char;
    case 'SPECIAL_KEY':
      return CommandType.specialKey;
    case 'HOTKEY':
      return CommandType.hotkey;
    case 'PAUSE':
      return CommandType.pause;
    case 'CLICK':
      return CommandType.click;
    default:
      return CommandType.char;
  }
}
