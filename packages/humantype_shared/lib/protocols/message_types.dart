enum MessageType {
  handshake,
  handshakeAck,
  capabilityAdvertisement,
  heartbeat,
  heartbeatAck,
  disconnect,
  cmd,
  sessionControl,
  progress,
  sectionComplete,
  settingsSync,
  ocrResult,
  roleChange,
  deviceRegistry,
  statusUpdate,
  liveTextSync,
  aiCompletion,
  unsupported,
}

extension MessageTypeWire on MessageType {
  String get wireName {
    switch (this) {
      case MessageType.handshake:
        return 'handshake';
      case MessageType.handshakeAck:
        return 'handshake_ack';
      case MessageType.capabilityAdvertisement:
        return 'capability_advertisement';
      case MessageType.heartbeat:
        return 'heartbeat';
      case MessageType.heartbeatAck:
        return 'heartbeat_ack';
      case MessageType.disconnect:
        return 'disconnect';
      case MessageType.cmd:
        return 'cmd';
      case MessageType.sessionControl:
        return 'session_control';
      case MessageType.progress:
        return 'progress';
      case MessageType.sectionComplete:
        return 'section_complete';
      case MessageType.settingsSync:
        return 'settings_sync';
      case MessageType.ocrResult:
        return 'ocr_result';
      case MessageType.roleChange:
        return 'role_change';
      case MessageType.deviceRegistry:
        return 'device_registry';
      case MessageType.statusUpdate:
        return 'status_update';
      case MessageType.liveTextSync:
        return 'live_text_sync';
      case MessageType.aiCompletion:
        return 'ai_completion';
      case MessageType.unsupported:
        return 'unsupported';
    }
  }
}

MessageType messageTypeFromWire(String? value) {
  switch (value) {
    case 'handshake':
      return MessageType.handshake;
    case 'handshake_ack':
      return MessageType.handshakeAck;
    case 'capability_advertisement':
      return MessageType.capabilityAdvertisement;
    case 'heartbeat':
      return MessageType.heartbeat;
    case 'heartbeat_ack':
      return MessageType.heartbeatAck;
    case 'disconnect':
      return MessageType.disconnect;
    case 'cmd':
      return MessageType.cmd;
    case 'session_control':
      return MessageType.sessionControl;
    case 'progress':
      return MessageType.progress;
    case 'section_complete':
      return MessageType.sectionComplete;
    case 'settings_sync':
      return MessageType.settingsSync;
    case 'ocr_result':
      return MessageType.ocrResult;
    case 'role_change':
      return MessageType.roleChange;
    case 'device_registry':
      return MessageType.deviceRegistry;
    case 'status_update':
      return MessageType.statusUpdate;
    case 'live_text_sync':
      return MessageType.liveTextSync;
    case 'ai_completion':
      return MessageType.aiCompletion;
    case 'unsupported':
      return MessageType.unsupported;
    default:
      return MessageType.unsupported;
  }
}
