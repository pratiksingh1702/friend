import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

/// State model representing the sync connection to the Android app
class AndroidSyncState {
  final bool isConnected;
  final String? connectedDeviceName;
  final String? connectedDeviceId;
  final int latencyMs;
  final String? highlightFieldId; // New: tracking which field to highlight

  const AndroidSyncState({
    this.isConnected = false,
    this.connectedDeviceName,
    this.connectedDeviceId,
    this.latencyMs = 0,
    this.highlightFieldId,
  });

  AndroidSyncState copyWith({
    bool? isConnected,
    String? connectedDeviceName,
    String? connectedDeviceId,
    int? latencyMs,
    String? highlightFieldId,
  }) {
    return AndroidSyncState(
      isConnected: isConnected ?? this.isConnected,
      connectedDeviceName: connectedDeviceName ?? this.connectedDeviceName,
      connectedDeviceId: connectedDeviceId ?? this.connectedDeviceId,
      latencyMs: latencyMs ?? this.latencyMs,
      highlightFieldId: highlightFieldId ?? this.highlightFieldId,
    );
  }
}

/// Service that manages the WebSocket connection between the Windows App
/// and the Android "Brain" app. Handles bidirectional settings sync.
class AndroidSyncService {
  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();
  Timer? _heartbeatTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  bool _connected = false;

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  bool get isConnected => _connected;

  Future<void> connect(String ip, int port) async {
    if (_connected) return;
    
    try {
      final uri = Uri.parse('ws://$ip:$port');
      _channel = WebSocketChannel.connect(uri);
      
      // Wait for the stream to establish
      await _channel!.ready;
      
      _connected = true;
      _reconnectAttempts = 0;
      print('[AndroidSync] Connected to Android at $ip:$port');

      // Send handshake
      send({
        'type': 'handshake',
        'sender': {'device_id': 'windows_app', 'current_role': 'controller'},
        'payload': {
          'pairing_token': 'WINDOWS_APP_TOKEN', // Load from secure storage in real impl
        },
      });

      // Start listening
      _channel!.stream.listen(
        (raw) {
          try {
            final msg = jsonDecode(raw as String) as Map<String, dynamic>;
            _handleMessage(msg);
          } catch (e) {
            print('[AndroidSync] Failed to parse message: $e');
          }
        },
        onDone: () {
          _connected = false;
          print('[AndroidSync] Disconnected from Android.');
          _handleDisconnect(ip, port);
        },
        onError: (e) {
          _connected = false;
          print('[AndroidSync] Error: $e');
          _handleDisconnect(ip, port);
        },
      );

      // Start heartbeat
      _heartbeatTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (_connected) {
          send({'type': 'heartbeat'});
        }
      });
    } catch (e) {
      _connected = false;
      print('[AndroidSync] Connection failed: $e');
    }
  }

  void disconnect() {
    _heartbeatTimer?.cancel();
    _channel?.sink.close(status.normalClosure);
    _connected = false;
  }

  void sendSettings(Map<String, dynamic> settings) {
    send({'type': 'settings_sync', 'payload': settings});
  }

  void sendOcrResult(String text) {
    send({'type': 'ocr_result', 'payload': {'text': text}});
  }

  void sendScratchpad(String content) {
    send({
      'type': 'scratchpad_sync',
      'payload': {
        'content': content,
        'last_modified_by': 'windows',
        'timestamp_ms': DateTime.now().millisecondsSinceEpoch,
      }
    });
  }

  void sendClipboard(String content) {
    send({
      'type': 'clipboard_sync',
      'payload': {
        'content': content,
        'content_type': 'text',
        'source': 'windows',
        'char_count': content.length,
      }
    });
  }

  void sendPasswordRequest() {
    send({
      'type': 'password_request',
      'payload': {
        'timestamp_ms': DateTime.now().millisecondsSinceEpoch,
      }
    });
  }

  void send(Map<String, dynamic> message) {
    if (_connected) {
      _channel?.sink.add(jsonEncode(message));
    }
  }

  void _handleMessage(Map<String, dynamic> message) {
    final type = message['type'] as String?;
    _messageController.add(message);
  }

  void _handleDisconnect(String ip, int port) {
    if (_reconnectAttempts < _maxReconnectAttempts) {
      _reconnectAttempts++;
      final delay = Duration(seconds: 2 * _reconnectAttempts);
      print('[AndroidSync] Reconnecting in ${delay.inSeconds}s (Attempt $_reconnectAttempts/$_maxReconnectAttempts)');
      Timer(delay, () => connect(ip, port));
    } else {
      print('[AndroidSync] Max reconnection attempts reached.');
      _messageController.add({'type': 'connection_error', 'payload': {'message': 'Connection lost'}});
    }
  }

  void dispose() {
    disconnect();
    _messageController.close();
  }
}

/// Riverpod provider for the Android sync service
final androidSyncServiceProvider = Provider<AndroidSyncService>((ref) {
  final service = AndroidSyncService();
  ref.onDispose(service.dispose);
  return service;
});

final androidSyncStateProvider = StateNotifierProvider<AndroidSyncNotifier, AndroidSyncState>((ref) {
  return AndroidSyncNotifier(ref.watch(androidSyncServiceProvider));
});

class AndroidSyncNotifier extends StateNotifier<AndroidSyncState> {
  final AndroidSyncService _service;
  StreamSubscription? _sub;

  AndroidSyncNotifier(this._service) : super(const AndroidSyncState()) {
    _sub = _service.messageStream.listen(_onMessage);
  }

  void _onMessage(Map<String, dynamic> msg) {
    if (msg['type'] == 'handshake_ack') {
      state = state.copyWith(isConnected: true, connectedDeviceName: 'Android Phone');
    } else if (msg['type'] == 'heartbeat_ack') {
      state = state.copyWith(latencyMs: 0); 
    } else if (msg['type'] == 'field_highlight') {
      final fieldId = msg['payload']?['field_id'] as String?;
      state = state.copyWith(highlightFieldId: fieldId);
      // Clear highlight after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (state.highlightFieldId == fieldId) {
          state = state.copyWith(highlightFieldId: null);
        }
      });
    }
  }

  Future<void> connect(String ip, int port) async {
    await _service.connect(ip, port);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
