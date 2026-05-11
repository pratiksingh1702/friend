import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

/// Service for localhost communication between the Flutter Windows App
/// and the Python Bridge. Port 8766 is used to avoid conflict with the
/// Android WebSocket on port 8765.
class BridgeSyncService {
  WebSocketChannel? _channel;
  bool _connected = false;
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  bool get isConnected => _connected;

  Future<void> connect({String host = '127.0.0.1', int port = 8765}) async {
    try {
      final uri = Uri.parse('ws://$host:$port');
      _channel = WebSocketChannel.connect(uri);
      _connected = true;
      print('[BridgeSync] Connected to bridge at $host:$port');

      _channel!.stream.listen(
        (raw) {
          final msg = jsonDecode(raw as String) as Map<String, dynamic>;
          _handleMessage(msg);
        },
        onDone: () {
          _connected = false;
          print('[BridgeSync] Bridge disconnected. Retrying...');
          Future.delayed(const Duration(seconds: 3), () => connect(host: host, port: port));
        },
        onError: (e) {
          _connected = false;
          print('[BridgeSync] Error: $e');
        },
      );
    } catch (e) {
      _connected = false;
      print('[BridgeSync] Connection failed: $e. Retrying in 5s...');
      Future.delayed(const Duration(seconds: 5), () => connect(host: host, port: port));
    }
  }

  void sendCommand(Map<String, dynamic> command) {
    if (_connected) {
      _channel?.sink.add(jsonEncode(command));
    } else {
      print('[BridgeSync] Cannot send command — not connected to bridge.');
    }
  }

  void requestStatus() {
    sendCommand({'type': 'status_request'});
  }

  void _handleMessage(Map<String, dynamic> message) {
    _messageController.add(message);
  }

  void disconnect() {
    _channel?.sink.close(status.normalClosure);
    _connected = false;
  }

  void dispose() {
    disconnect();
    _messageController.close();
  }
}
