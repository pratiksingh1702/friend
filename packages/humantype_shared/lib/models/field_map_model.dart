class MappedField {
  const MappedField({
    required this.id,
    required this.name,
    required this.xPercent,
    required this.yPercent,
  });

  final String id;
  final String name;
  final double xPercent;
  final double yPercent;

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'xPercent': xPercent, 'yPercent': yPercent};
  }

  factory MappedField.fromJson(Map<String, dynamic> json) {
    return MappedField(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      xPercent: (json['xPercent'] as num?)?.toDouble() ?? 0,
      yPercent: (json['yPercent'] as num?)?.toDouble() ?? 0,
    );
  }
}

class FieldMapModel {
  const FieldMapModel({
    required this.id,
    required this.appName,
    required this.windowTitle,
    required this.fields,
    required this.createdAt,
    required this.lastUsed,
  });

  final String id;
  final String appName;
  final String windowTitle;
  final List<MappedField> fields;
  final DateTime createdAt;
  final DateTime lastUsed;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appName': appName,
      'windowTitle': windowTitle,
      'fields': fields.map((field) => field.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'lastUsed': lastUsed.toIso8601String(),
    };
  }

  factory FieldMapModel.fromJson(Map<String, dynamic> json) {
    return FieldMapModel(
      id: json['id'] as String? ?? '',
      appName: json['appName'] as String? ?? '',
      windowTitle: json['windowTitle'] as String? ?? '',
      fields: ((json['fields'] as List?) ?? const [])
          .map(
            (field) =>
                MappedField.fromJson((field as Map).cast<String, dynamic>()),
          )
          .toList(),
      createdAt: _parseDate(json['createdAt'] as String?),
      lastUsed: _parseDate(json['lastUsed'] as String?),
    );
  }

  FieldMapModel copyWith({
    String? id,
    String? appName,
    String? windowTitle,
    List<MappedField>? fields,
    DateTime? createdAt,
    DateTime? lastUsed,
  }) {
    return FieldMapModel(
      id: id ?? this.id,
      appName: appName ?? this.appName,
      windowTitle: windowTitle ?? this.windowTitle,
      fields: fields ?? this.fields,
      createdAt: createdAt ?? this.createdAt,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }
}

DateTime _parseDate(String? value) {
  if (value == null || value.isEmpty) {
    return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }
  return DateTime.parse(value);
}
