class MirroredNotification {
  final String id;
  final String appName;
  final String? appPackage;
  final String title;
  final String body;
  final DateTime timestamp;
  final String? iconBase64;

  MirroredNotification({
    required this.id,
    required this.appName,
    this.appPackage,
    required this.title,
    required this.body,
    required this.timestamp,
    this.iconBase64,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'app_name': appName,
      'app_package': appPackage,
      'title': title,
      'body': body,
      'timestamp_ms': timestamp.millisecondsSinceEpoch,
      'icon_base64': iconBase64,
    };
  }

  factory MirroredNotification.fromJson(Map<String, dynamic> json) {
    return MirroredNotification(
      id: json['id'] as String,
      appName: json['app_name'] as String,
      appPackage: json['app_package'] as String?,
      title: json['title'] as String,
      body: json['body'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp_ms'] as int),
      iconBase64: json['icon_base64'] as String?,
    );
  }
}
