class RemoteFileInfo {
  final String name;
  final String path;
  final bool isDirectory;
  final int? sizeBytes;
  final DateTime? modifiedAt;
  final String? mimeType;

  RemoteFileInfo({
    required this.name,
    required this.path,
    required this.isDirectory,
    this.sizeBytes,
    this.modifiedAt,
    this.mimeType,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'path': path,
    'is_directory': isDirectory,
    'size_bytes': sizeBytes,
    'modified_at_ms': modifiedAt?.millisecondsSinceEpoch,
    'mime_type': mimeType,
  };

  factory RemoteFileInfo.fromJson(Map<String, dynamic> json) => RemoteFileInfo(
    name: json['name'] as String,
    path: json['path'] as String,
    isDirectory: json['is_directory'] as bool,
    sizeBytes: json['size_bytes'] as int?,
    modifiedAt: json['modified_at_ms'] != null 
        ? DateTime.fromMillisecondsSinceEpoch(json['modified_at_ms'] as int)
        : null,
    mimeType: json['mime_type'] as String?,
  );
}
