class Capabilities {
  const Capabilities({
    required this.canBeController,
    required this.canBeExecutor,
    required this.hasAiEngine,
    required this.hasKeyboardControl,
    required this.hasOcr,
    required this.hasCamera,
    required this.platform,
    required this.appVersion,
    required this.protocolVersion,
  });

  final bool canBeController;
  final bool canBeExecutor;
  final bool hasAiEngine;
  final bool hasKeyboardControl;
  final bool hasOcr;
  final bool hasCamera;
  final String platform;
  final String appVersion;
  final String protocolVersion;

  Map<String, dynamic> toJson() {
    return {
      'can_be_controller': canBeController,
      'can_be_executor': canBeExecutor,
      'has_ai_engine': hasAiEngine,
      'has_keyboard_control': hasKeyboardControl,
      'has_ocr': hasOcr,
      'has_camera': hasCamera,
      'platform': platform,
      'app_version': appVersion,
      'protocol_version': protocolVersion,
    };
  }

  factory Capabilities.fromJson(Map<String, dynamic> json) {
    return Capabilities(
      canBeController: json['can_be_controller'] as bool? ?? false,
      canBeExecutor: json['can_be_executor'] as bool? ?? false,
      hasAiEngine: json['has_ai_engine'] as bool? ?? false,
      hasKeyboardControl: json['has_keyboard_control'] as bool? ?? false,
      hasOcr: json['has_ocr'] as bool? ?? false,
      hasCamera: json['has_camera'] as bool? ?? false,
      platform: json['platform'] as String? ?? '',
      appVersion: json['app_version'] as String? ?? '',
      protocolVersion: json['protocol_version'] as String? ?? '',
    );
  }
}
