enum DeviceType { android, windows, bridge, unknown }

enum DeviceRole { controller, executor, both, passive }

class DeviceInfo {
  const DeviceInfo({
    required this.deviceId,
    required this.deviceType,
    required this.currentRole,
    this.platform,
    this.appVersion,
    this.protocolVersion,
  });

  final String deviceId;
  final DeviceType deviceType;
  final DeviceRole currentRole;
  final String? platform;
  final String? appVersion;
  final String? protocolVersion;

  factory DeviceInfo.android({
    required String deviceId,
    DeviceRole currentRole = DeviceRole.controller,
    String? appVersion,
    String? protocolVersion,
  }) {
    return DeviceInfo(
      deviceId: deviceId,
      deviceType: DeviceType.android,
      currentRole: currentRole,
      platform: 'android',
      appVersion: appVersion,
      protocolVersion: protocolVersion,
    );
  }

  factory DeviceInfo.windows({
    required String deviceId,
    DeviceRole currentRole = DeviceRole.passive,
    String? appVersion,
    String? protocolVersion,
  }) {
    return DeviceInfo(
      deviceId: deviceId,
      deviceType: DeviceType.windows,
      currentRole: currentRole,
      platform: 'windows',
      appVersion: appVersion,
      protocolVersion: protocolVersion,
    );
  }

  factory DeviceInfo.bridge({
    required String deviceId,
    DeviceRole currentRole = DeviceRole.executor,
    String? appVersion,
    String? protocolVersion,
  }) {
    return DeviceInfo(
      deviceId: deviceId,
      deviceType: DeviceType.bridge,
      currentRole: currentRole,
      platform: 'bridge',
      appVersion: appVersion,
      protocolVersion: protocolVersion,
    );
  }

  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      deviceId: json['device_id'] as String? ?? '',
      deviceType: deviceTypeFromString(json['device_type'] as String?),
      currentRole: deviceRoleFromString(json['current_role'] as String?),
      platform: json['platform'] as String?,
      appVersion: json['app_version'] as String?,
      protocolVersion: json['protocol_version'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'device_type': deviceTypeToString(deviceType),
      'current_role': deviceRoleToString(currentRole),
      if (platform != null) 'platform': platform,
      if (appVersion != null) 'app_version': appVersion,
      if (protocolVersion != null) 'protocol_version': protocolVersion,
    };
  }

  DeviceInfo copyWith({
    String? deviceId,
    DeviceType? deviceType,
    DeviceRole? currentRole,
    String? platform,
    String? appVersion,
    String? protocolVersion,
  }) {
    return DeviceInfo(
      deviceId: deviceId ?? this.deviceId,
      deviceType: deviceType ?? this.deviceType,
      currentRole: currentRole ?? this.currentRole,
      platform: platform ?? this.platform,
      appVersion: appVersion ?? this.appVersion,
      protocolVersion: protocolVersion ?? this.protocolVersion,
    );
  }
}

DeviceType deviceTypeFromString(String? value) {
  switch (value) {
    case 'android':
      return DeviceType.android;
    case 'windows':
      return DeviceType.windows;
    case 'bridge':
      return DeviceType.bridge;
    default:
      return DeviceType.unknown;
  }
}

DeviceRole deviceRoleFromString(String? value) {
  switch (value) {
    case 'controller':
      return DeviceRole.controller;
    case 'executor':
      return DeviceRole.executor;
    case 'both':
      return DeviceRole.both;
    case 'passive':
      return DeviceRole.passive;
    default:
      return DeviceRole.passive;
  }
}

String deviceTypeToString(DeviceType type) {
  switch (type) {
    case DeviceType.android:
      return 'android';
    case DeviceType.windows:
      return 'windows';
    case DeviceType.bridge:
      return 'bridge';
    case DeviceType.unknown:
      return 'unknown';
  }
}

String deviceRoleToString(DeviceRole role) {
  switch (role) {
    case DeviceRole.controller:
      return 'controller';
    case DeviceRole.executor:
      return 'executor';
    case DeviceRole.both:
      return 'both';
    case DeviceRole.passive:
      return 'passive';
  }
}
