import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:humantype_shared/humantype_shared.dart';

import '../../../core/services/device_identity.dart';
import '../providers/connection_provider.dart';
import '../../settings/providers/settings_provider.dart';

final wifiServiceProvider = Provider<WiFiService>((ref) => WiFiService(ref));

class WiFiService {
  WiFiService(this._ref) : _identity = DeviceIdentityService() {
    _pairing = PairingTokenStore(_identity);
  }

  final Ref _ref;
  final DeviceIdentityService _identity;
  late final PairingTokenStore _pairing;
  final MessageRouter _router = MessageRouter();
  final StreamController<WsMessage> _messages =
      StreamController<WsMessage>.broadcast();

  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  int? _lastHeartbeatAt;
  String? _deviceId;
  String? _lastHost;
  int _reconnectAttempts = 0;

  Stream<WsMessage> get messages => _messages.stream;
  MessageRouter get router => _router;

  bool get isConnected => _channel != null;
  String? get lastHost => _lastHost;

  Future<void> autoConnect() async {
    if (_lastHost != null && !isConnected) {
      await connect(_lastHost!);
    }
  }

  Future<void> connect(String host,
      {int port = AppConstants.defaultWsPort}) async {
    // Prevent connecting to localhost on Android
    if (host == '127.0.0.1' || host == 'localhost') {
      final settings = _ref.read(settingsProvider);
      host = settings.serverIp;
    }
    
    _lastHost = host;
    final uri = Uri.parse('ws://$host:$port');
    
    try {
      _deviceId ??= await _identity.getDeviceId();
      final pairingToken = await _pairing.getOrCreateToken(host);

      // Timeout for connection attempt
      print('[WiFiService] Connecting to ws://$host:$port...');
      _channel = WebSocketChannel.connect(uri);
      
      // We wrap the listener to handle initial connection errors better
      _sub = _channel!.stream.listen(
        _onMessage,
        onDone: _onDisconnected,
        onError: (e) {
          print('[WiFiService] Connection error: $e');
          _onDisconnected();
        },
        cancelOnError: true,
      );

      // Wait for the WebSocket to actually connect before sending handshake
      await _channel!.ready;

      // Send initial handshake
      final deviceInfo = DeviceInfo.android(
        deviceId: _deviceId!,
        appVersion: AppConstants.appVersion,
        protocolVersion: AppConstants.protocolVersion,
      );

      _sendHandshake(pairingToken, deviceInfo);
      _sendCapabilities(deviceInfo);

      final connected = ConnectedDevice(
        id: 'bridge-$host',
        name: 'Bridge:$host',
        deviceType: DeviceType.bridge,
        ip: host,
        port: port,
        latencyMs: null,
        lastSeen: DateTime.now(),
      );
      
      _ref.read(connectionProvider.notifier).setConnected(
            connected,
            method: ConnectionMethod.wifi,
          );

      _reconnectAttempts = 0;
      _reconnectTimer?.cancel();
      print('[WiFiService] Connected successfully to $host');
      _startHeartbeat(deviceInfo);
    } catch (e) {
      _onDisconnected();
      throw Exception('Failed to connect to $host:$port. Error: $e');
    }
  }

  void _sendHandshake(String token, DeviceInfo deviceInfo) {
    _send(
      WsMessage(
        type: MessageType.handshake,
        sender: deviceInfo,
        target: MessageTarget.broadcast,
        payload: {'pairing_token': token},
      ),
    );
  }

  void _sendCapabilities(DeviceInfo deviceInfo) {
    _send(
      WsMessage(
        type: MessageType.capabilityAdvertisement,
        sender: deviceInfo,
        target: MessageTarget.broadcast,
        payload: Capabilities(
          canBeController: true,
          canBeExecutor: false,
          hasAiEngine: true,
          hasKeyboardControl: false,
          hasOcr: false,
          hasCamera: true,
          platform: 'android',
          appVersion: AppConstants.appVersion,
          protocolVersion: AppConstants.protocolVersion,
        ).toJson(),
      ),
    );
  }

  void _startHeartbeat(DeviceInfo deviceInfo) {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_channel == null) return;
      _lastHeartbeatAt = DateTime.now().millisecondsSinceEpoch;
      _send(
        WsMessage(
          type: MessageType.heartbeat,
          sender: deviceInfo,
          target: MessageTarget.broadcast,
          payload: const {},
        ),
      );
    });
  }

  void _onMessage(dynamic raw) {
    try {
      final jsonMsg = jsonDecode(raw as String) as Map<String, dynamic>;
      final msg = WsMessage.fromJson(jsonMsg);
      _messages.add(msg);
      print('[WiFiService] Received message: ${msg.type}');
      _router.route(msg);

      switch (msg.type) {
        case MessageType.heartbeatAck:
          _handleHeartbeatAck();
          break;
        case MessageType.settingsSync:
          _applySettingsSync(msg);
          break;
        case MessageType.ocrResult:
          // Will be handled by OCR provider listener
          break;
        default:
          break;
      }
    } catch (_) {}
  }

  void _handleHeartbeatAck() {
    if (_lastHeartbeatAt == null) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final latency = max(0, now - _lastHeartbeatAt!);
    _ref.read(connectionProvider.notifier).updateLatency(latency);
  }

  void _applySettingsSync(WsMessage message) {
    final key = message.payload['changed_key'] as String?;
    final value = message.payload['new_value'];
    if (key == null) return;
    _ref.read(settingsProvider.notifier).applyRemoteSetting(key, value);
  }

  void _onDisconnected() {
    print('[WiFiService] Disconnected from bridge');
    disconnect();
    final settings = _ref.read(settingsProvider);
    if (settings.autoReconnect && _lastHost != null && _reconnectAttempts < 5) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    final delay = Duration(seconds: pow(2, _reconnectAttempts).toInt());
    _reconnectAttempts++;
    
    _reconnectTimer = Timer(delay, () {
      if (_lastHost != null && !isConnected) {
        connect(_lastHost!);
      }
    });
  }

  Future<void> sendCommand(TypeCommand cmd) async {
    if (_channel == null || _deviceId == null) {
      throw StateError('Not connected');
    }
    _send(
      WsMessage(
        type: MessageType.cmd,
        sender: DeviceInfo.android(deviceId: _deviceId!),
        target: MessageTarget.broadcast,
        payload: cmd.toJson(),
      ),
    );
    // Tiny delay to prevent flooding
    await Future<void>.delayed(const Duration(milliseconds: 2));
  }

  void sendSessionControl(String action) {
    if (_channel == null || _deviceId == null) return;
    _send(
      WsMessage(
        type: MessageType.sessionControl,
        sender: DeviceInfo.android(deviceId: _deviceId!),
        target: MessageTarget.broadcast,
        payload: {'action': action},
      ),
    );
  }

  void sendSettingsSync(String key, Object? value) {
    if (_channel == null || _deviceId == null) return;
    _send(
      WsMessage(
        type: MessageType.settingsSync,
        sender: DeviceInfo.android(deviceId: _deviceId!),
        target: MessageTarget.broadcast,
        payload: {
          'changed_key': key,
          'new_value': value,
          'source_device': 'android',
        },
      ),
    );
  }

  void sendLiveText(String text) {
    if (_channel == null || _deviceId == null) return;
    _send(
      WsMessage(
        type: MessageType.liveTextSync,
        sender: DeviceInfo.android(deviceId: _deviceId!),
        target: MessageTarget.broadcast,
        payload: {'text': text},
      ),
    );
  }

  void _send(WsMessage message) {
    if (_channel == null) return;
    _channel?.sink.add(jsonEncode(message.toJson()));
  }

  void disconnect() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    try {
      _sub?.cancel();
    } catch (_) {}
    try {
      _channel?.sink.close();
    } catch (_) {}
    _sub = null;
    _channel = null;
    _ref.read(connectionProvider.notifier).setDisconnected();
  }
}
