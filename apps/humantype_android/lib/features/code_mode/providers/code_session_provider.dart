import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humantype_shared/humantype_shared.dart';

final codeSessionProvider =
    NotifierProvider<CodeSessionNotifier, CodeSessionState>(
  CodeSessionNotifier.new,
);

class CodeSessionState {
  const CodeSessionState({
    required this.code,
    required this.speed,
    required this.errors,
  });

  final String code;
  final SpeedProfile speed;
  final ErrorProfile errors;

  factory CodeSessionState.initial() {
    return CodeSessionState(
      code: '',
      speed: SpeedProfile.preset(SpeedProfileType.medium),
      errors: ErrorProfile.defaults(),
    );
  }

  CodeSessionState copyWith({
    String? code,
    SpeedProfile? speed,
    ErrorProfile? errors,
  }) {
    return CodeSessionState(
      code: code ?? this.code,
      speed: speed ?? this.speed,
      errors: errors ?? this.errors,
    );
  }
}

class CodeSessionNotifier extends Notifier<CodeSessionState> {
  @override
  CodeSessionState build() => CodeSessionState.initial();

  void setCode(String code) {
    state = state.copyWith(code: code);
  }

  void setSpeed(SpeedProfile speed) {
    state = state.copyWith(speed: speed);
  }

  void setErrors(ErrorProfile errors) {
    state = state.copyWith(errors: errors);
  }
}
