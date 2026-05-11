import 'package:uuid/uuid.dart';

import '../constants/protocol_constants.dart';
import '../models/device_model.dart';
import 'message_types.dart';

class MessageTarget {
  const MessageTarget({required this.deviceId, this.deviceType});

  final String deviceId;
  final DeviceType? deviceType;

  static const broadcast = MessageTarget(deviceId: 'broadcast');

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      if (deviceType != null) 'device_type': deviceTypeToString(deviceType!),
    };
  }

  factory MessageTarget.fromJson(Map<String, dynamic> json) {
    return MessageTarget(
      deviceId: json['device_id'] as String? ?? 'broadcast',
      deviceType: json['device_type'] == null
          ? null
          : deviceTypeFromString(json['device_type'] as String?),
    );
  }
}

class WsMessage {
  WsMessage({
    required this.type,
    required this.sender,
    required this.target,
    Map<String, dynamic>? payload,
    String? id,
    int? timestamp,
    String? version,
  }) : id = id ?? const Uuid().v4(),
       timestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch,
       version = version ?? ProtocolConstants.version,
       payload = payload ?? <String, dynamic>{};

  final String version;
  final MessageType type;
  final String id;
  final int timestamp;
  final DeviceInfo sender;
  final MessageTarget target;
  final Map<String, dynamic> payload;

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'type': type.wireName,
      'id': id,
      'timestamp': timestamp,
      'sender': sender.toJson(),
      'target': target.toJson(),
      'payload': payload,
    };
  }

  factory WsMessage.fromJson(Map<String, dynamic> json) {
    return WsMessage(
      version: json['version'] as String?,
      type: messageTypeFromWire(json['type'] as String?),
      id: json['id'] as String?,
      timestamp: (json['timestamp'] as num?)?.toInt(),
      sender: DeviceInfo.fromJson(
        (json['sender'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      target: MessageTarget.fromJson(
        (json['target'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      payload: (json['payload'] as Map?)?.cast<String, dynamic>() ?? const {},
    );
  }
}
