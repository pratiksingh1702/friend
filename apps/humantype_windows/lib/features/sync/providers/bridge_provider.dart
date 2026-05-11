import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:humantype_shared/humantype_shared.dart';

class BridgeState {
  final bool isConnected;
  final bool isAndroidConnected;
  final String? androidDeviceName;
  final int latencyMs;
  final SessionStatus sessionStatus;
  final double currentWpm;
  final double progress;
  final String? lastAndroidText;
  final int? lastSyncTimestamp;
  final String? lastOcrText;
  final double? ocrConfidence;

  const BridgeState({
    this.isConnected = false,
    this.isAndroidConnected = false,
    this.androidDeviceName,
    this.latencyMs = 0,
    this.sessionStatus = SessionStatus.idle,
    this.currentWpm = 0,
    this.progress = 0,
    this.lastAndroidText,
    this.lastSyncTimestamp,
    this.lastOcrText,
    this.ocrConfidence = 1.0,
  });

  BridgeState copyWith({
    bool? isConnected,
    bool? isAndroidConnected,
    String? androidDeviceName,
    int? latencyMs,
    SessionStatus? sessionStatus,
    double? currentWpm,
    double? progress,
    String? lastAndroidText,
    int? lastSyncTimestamp,
    String? lastOcrText,
    double? ocrConfidence,
  }) {
    return BridgeState(
      isConnected: isConnected ?? this.isConnected,
      isAndroidConnected: isAndroidConnected ?? this.isAndroidConnected,
      androidDeviceName: androidDeviceName ?? this.androidDeviceName,
      latencyMs: latencyMs ?? this.latencyMs,
      sessionStatus: sessionStatus ?? this.sessionStatus,
      currentWpm: currentWpm ?? this.currentWpm,
      progress: progress ?? this.progress,
      lastAndroidText: lastAndroidText ?? this.lastAndroidText,
      lastSyncTimestamp: lastSyncTimestamp ?? this.lastSyncTimestamp,
      lastOcrText: lastOcrText ?? this.lastOcrText,
      ocrConfidence: ocrConfidence ?? this.ocrConfidence,
    );
  }
}

class BridgeNotifier extends StateNotifier<BridgeState> {
  BridgeNotifier() : super(const BridgeState()) {
    _connect();
  }

  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  final _router = MessageRouter();

  void _connect() {
    _reconnectTimer?.cancel();
    final uri = Uri.parse('ws://127.0.0.1:8765');
    print('[BridgeProvider] Attempting connection to $uri');
    
    try {
      _channel = WebSocketChannel.connect(uri);
      
      // We need to listen to establish the connection
      _channel!.stream.listen(
        (data) {
          if (!state.isConnected) {
            print('[BridgeProvider] Successfully connected to Bridge');
            state = state.copyWith(isConnected: true);
          }
          _handleMessage(data);
        },
        onDone: () {
          print('[BridgeProvider] Connection closed by Bridge');
          _onDisconnected();
        },
        onError: (e) {
          print('[BridgeProvider] Connection Error: $e');
          _onDisconnected();
        },
      );

      // Send Handshake IMMEDIATELY without waiting for isConnected
      // because we are the ones who initiate the handshake
      final info = DeviceInfo(
        deviceId: 'windows-cmd-center',
        name: 'Command Center',
        deviceType: DeviceType.bridge, 
        currentRole: DeviceRole.passive,
        appVersion: AppConstants.appVersion,
        protocolVersion: AppConstants.protocolVersion,
      );

      print('[BridgeProvider] Sending Handshake...');
      final handshake = WsMessage(
        type: MessageType.handshake,
        sender: info,
        target: MessageTarget.broadcast,
        payload: {
          'app': 'windows',
          'pairing_token': 'local-admin' // Bypass token for local cmd center
        },
      );
      
      _channel?.sink.add(jsonEncode(handshake.toJson()));
      
    } catch (e) {
      print('[BridgeProvider] Failed to connect: $e');
      _onDisconnected();
    }
  }

  void _onDisconnected() {
    if (state.isConnected) {
      state = state.copyWith(isConnected: false, isAndroidConnected: false);
    }
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), _connect);
  }

  void _handleMessage(dynamic data) {
    try {
      final json = jsonDecode(data as String);
      print('[BridgeProvider] Received: ${json['type']}');
      final msg = WsMessage.fromJson(json);
      
      switch (msg.type) {
        case MessageType.handshakeAck:
          print('[BridgeProvider] Handshake Accepted');
          break;
        case MessageType.deviceRegistry:
          _handleDeviceRegistry(msg);
          break;
        case MessageType.statusUpdate:
          _handleStatusUpdate(msg);
          break;
        case MessageType.heartbeatAck:
          state = state.copyWith(latencyMs: 0);
          break;
        case MessageType.liveTextSync:
          _handleLiveText(msg);
          break;
        case MessageType.ocrResult:
          _handleOcrResult(msg);
          break;
        default:
          break;
      }
    } catch (e) {
      print('[BridgeProvider] Error parsing message: $e');
    }
  }

  void _handleDeviceRegistry(WsMessage msg) {
    final List devices = msg.payload['devices'] ?? [];
    final hasAndroid = devices.any((d) => d['device_type'] == 'android');
    final androidDevice = devices.firstWhere(
      (d) => d['device_type'] == 'android',
      orElse: () => null,
    );

    print('[BridgeProvider] Registry Updated. Android Linked: $hasAndroid');
    
    state = state.copyWith(
      isAndroidConnected: hasAndroid,
      androidDeviceName: androidDevice != null ? androidDevice['name'] : null,
    );
  }

  void _handleStatusUpdate(WsMessage msg) {
    final payload = msg.payload;
    state = state.copyWith(
      sessionStatus: SessionStatus.values.firstWhere(
        (e) => e.name == payload['status'],
        orElse: () => SessionStatus.idle,
      ),
      currentWpm: (payload['wpm'] as num?)?.toDouble() ?? 0,
      progress: (payload['progress'] as num?)?.toDouble() ?? 0,
    );
  }

  void _handleLiveText(WsMessage msg) {
    state = state.copyWith(
      lastAndroidText: msg.payload['text'] as String?,
      lastSyncTimestamp: msg.timestamp,
    );
  }

  void _handleOcrResult(WsMessage msg) {
    state = state.copyWith(
      lastOcrText: msg.payload['text'] as String?,
      ocrConfidence: (msg.payload['confidence'] as num?)?.toDouble() ?? 1.0,
    );
  }

  void sendMessage(WsMessage msg) {
    _send(msg);
  }

  void _send(WsMessage msg) {
    if (state.isConnected) {
      _channel?.sink.add(jsonEncode(msg.toJson()));
    }
  }

  @override
  void dispose() {
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    super.dispose();
  }
}

final bridgeProvider = StateNotifierProvider<BridgeNotifier, BridgeState>((ref) {
  return BridgeNotifier();
});
