import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humantype_shared/humantype_shared.dart';
import '../../connect/services/wifi_service.dart';
import '../../../core/services/device_identity.dart';

class ClipboardMonitorService {
  final WiFiService _wifiService;
  Timer? _timer;
  String? _lastClipboard;
  bool _suppressNextChange = false;

  ClipboardMonitorService(this._wifiService);

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) => _checkClipboard());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _checkClipboard() async {
    if (!_wifiService.isConnected) return;

    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;

    if (text != null && text != _lastClipboard) {
      if (_suppressNextChange) {
        _suppressNextChange = false;
        _lastClipboard = text;
        return;
      }

      _lastClipboard = text;
      _sendToRemote(text);
    }
  }

  Future<void> _sendToRemote(String text) async {
    final deviceId = await DeviceIdentityService().getDeviceId();
    
    _wifiService.router.route(WsMessage(
      type: MessageType.clipboardSync,
      sender: DeviceInfo.android(deviceId: deviceId),
      target: MessageTarget.broadcast,
      payload: {
        'content': text,
        'content_type': 'text',
        'source': 'android',
        'char_count': text.length,
      },
    ));
  }

  Future<void> applyIncoming(String text) async {
    if (text == _lastClipboard) return;
    
    _suppressNextChange = true;
    _lastClipboard = text;
    await Clipboard.setData(ClipboardData(text: text));
    print('[Clipboard] Applied incoming from PC');
  }
}

final clipboardMonitorServiceProvider = Provider<ClipboardMonitorService>((ref) {
  final service = ClipboardMonitorService(ref.watch(wifiServiceProvider));
  return service;
});
