import 'section_model.dart';

enum SessionStatus {
  idle,
  planning,
  ready,
  executing,
  paused,
  sectionBreak,
  completed,
  aborted,
}

class SessionModel {
  const SessionModel({
    required this.id,
    required this.createdAt,
    required this.sections,
    required this.status,
    required this.currentSectionIndex,
    required this.charsCompleted,
    required this.charsTotal,
    required this.estimatedSecondsRemaining,
    required this.currentWpm,
  });

  final String id;
  final DateTime createdAt;
  final List<Section> sections;
  final SessionStatus status;
  final int currentSectionIndex;
  final int charsCompleted;
  final int charsTotal;
  final int estimatedSecondsRemaining;
  final double currentWpm;

  factory SessionModel.empty(String id) {
    return SessionModel(
      id: id,
      createdAt: DateTime.now(),
      sections: const [],
      status: SessionStatus.idle,
      currentSectionIndex: 0,
      charsCompleted: 0,
      charsTotal: 0,
      estimatedSecondsRemaining: 0,
      currentWpm: 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'sections': sections.map((section) => section.toJson()).toList(),
      'status': _enumName(status),
      'currentSectionIndex': currentSectionIndex,
      'charsCompleted': charsCompleted,
      'charsTotal': charsTotal,
      'estimatedSecondsRemaining': estimatedSecondsRemaining,
      'currentWpm': currentWpm,
    };
  }

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as String? ?? '',
      createdAt: _parseDate(json['createdAt'] as String?),
      sections: ((json['sections'] as List?) ?? const [])
          .map(
            (section) =>
                Section.fromJson((section as Map).cast<String, dynamic>()),
          )
          .toList(),
      status: _enumFromString(
        SessionStatus.values,
        json['status'] as String?,
        SessionStatus.idle,
      ),
      currentSectionIndex: (json['currentSectionIndex'] as num?)?.toInt() ?? 0,
      charsCompleted: (json['charsCompleted'] as num?)?.toInt() ?? 0,
      charsTotal: (json['charsTotal'] as num?)?.toInt() ?? 0,
      estimatedSecondsRemaining:
          (json['estimatedSecondsRemaining'] as num?)?.toInt() ?? 0,
      currentWpm: (json['currentWpm'] as num?)?.toDouble() ?? 0,
    );
  }

  SessionModel copyWith({
    String? id,
    DateTime? createdAt,
    List<Section>? sections,
    SessionStatus? status,
    int? currentSectionIndex,
    int? charsCompleted,
    int? charsTotal,
    int? estimatedSecondsRemaining,
    double? currentWpm,
  }) {
    return SessionModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      sections: sections ?? this.sections,
      status: status ?? this.status,
      currentSectionIndex: currentSectionIndex ?? this.currentSectionIndex,
      charsCompleted: charsCompleted ?? this.charsCompleted,
      charsTotal: charsTotal ?? this.charsTotal,
      estimatedSecondsRemaining:
          estimatedSecondsRemaining ?? this.estimatedSecondsRemaining,
      currentWpm: currentWpm ?? this.currentWpm,
    );
  }
}

String _enumName(Object value) => value.toString().split('.').last;

DateTime _parseDate(String? value) {
  if (value == null || value.isEmpty) {
    return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }
  return DateTime.parse(value);
}

T _enumFromString<T extends Object>(List<T> values, String? value, T fallback) {
  if (value == null) return fallback;
  for (final entry in values) {
    if (_enumName(entry).toLowerCase() == value.toLowerCase()) {
      return entry;
    }
  }
  return fallback;
}
