import 'device_model.dart';

enum ConnectionQuality { excellent, good, fair, poor, bluetooth, disconnected }

enum ConnectionMethod { wifi, bluetooth, none }

class ConnectedDevice {
  const ConnectedDevice({
    required this.id,
    required this.name,
    required this.deviceType,
    this.ip,
    this.port,
    this.latencyMs,
    this.lastSeen,
  });

  final String id;
  final String name;
  final DeviceType deviceType;
  final String? ip;
  final int? port;
  final int? latencyMs;
  final DateTime? lastSeen;

  factory ConnectedDevice.fromJson(Map<String, dynamic> json) {
    return ConnectedDevice(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      deviceType: deviceTypeFromString(json['device_type'] as String?),
      ip: json['ip'] as String?,
      port: json['port'] as int?,
      latencyMs: json['latency_ms'] as int?,
      lastSeen: json['last_seen'] == null
          ? null
          : DateTime.parse(json['last_seen'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'device_type': deviceTypeToString(deviceType),
      if (ip != null) 'ip': ip,
      if (port != null) 'port': port,
      if (latencyMs != null) 'latency_ms': latencyMs,
      if (lastSeen != null) 'last_seen': lastSeen!.toIso8601String(),
    };
  }

  ConnectedDevice copyWith({
    String? id,
    String? name,
    DeviceType? deviceType,
    String? ip,
    int? port,
    int? latencyMs,
    DateTime? lastSeen,
  }) {
    return ConnectedDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      deviceType: deviceType ?? this.deviceType,
      ip: ip ?? this.ip,
      port: port ?? this.port,
      latencyMs: latencyMs ?? this.latencyMs,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}
