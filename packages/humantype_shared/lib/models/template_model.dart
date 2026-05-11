import 'section_model.dart';

class TemplateModel {
  const TemplateModel({
    required this.id,
    required this.name,
    required this.description,
    required this.sections,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String description;
  final List<Section> sections;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'sections': sections.map((section) => section.toJson()).toList(),
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TemplateModel.fromJson(Map<String, dynamic> json) {
    return TemplateModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      sections: ((json['sections'] as List?) ?? const [])
          .map(
            (section) =>
                Section.fromJson((section as Map).cast<String, dynamic>()),
          )
          .toList(),
      tags: ((json['tags'] as List?) ?? const []).cast<String>(),
      createdAt: _parseDate(json['createdAt'] as String?),
      updatedAt: _parseDate(json['updatedAt'] as String?),
    );
  }

  TemplateModel copyWith({
    String? id,
    String? name,
    String? description,
    List<Section>? sections,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TemplateModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      sections: sections ?? this.sections,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

DateTime _parseDate(String? value) {
  if (value == null || value.isEmpty) {
    return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }
  return DateTime.parse(value);
}
