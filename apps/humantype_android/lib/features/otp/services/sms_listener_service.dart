import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:another_telephony/telephony.dart';
import 'package:humantype_shared/humantype_shared.dart';
import '../../connect/services/wifi_service.dart';
import '../../../core/services/device_identity.dart';

class SmsListenerService {
  final WiFiService _wifiService;
  final Telephony _telephony = Telephony.instance;
  final _otpController = StreamController<String>.broadcast();
  
  Stream<String> get otpStream => _otpController.stream;

  SmsListenerService(this._wifiService);

  void startListening() {
    _telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) {
        final body = message.body;
        if (body == null) return;

        // Extract 4-8 digit codes near keywords
        final keywords = ['otp', 'code', 'verification', 'one-time', 'use'];
        final hasKeyword = keywords.any((k) => body.toLowerCase().contains(k));
        
        if (hasKeyword) {
          final otpMatch = RegExp(r'\b\d{4,8}\b').firstMatch(body);
          if (otpMatch != null) {
            final code = otpMatch.group(0)!;
            _otpController.add(code);
            _sendOtpToBridge(code, body);
          }
        }
      },
      listenInBackground: true,
    );
  }

  Future<void> _sendOtpToBridge(String code, String rawSnippet) async {
    if (!_wifiService.isConnected) return;

    final deviceId = await DeviceIdentityService().getDeviceId();
    
    _wifiService.router.route(WsMessage(
      type: MessageType.otpDetected,
      sender: DeviceInfo.android(deviceId: deviceId),
      target: MessageTarget.broadcast,
      payload: {
        'code': code,
        'source_app': 'SMS',
        'raw_snippet': rawSnippet,
      },
    ));
  }

  void stopListening() {
    // Telephony doesn't have a clear "stop" for this listener in the same way,
    // but it stops when the app process is killed or we can manage it via flags.
  }
}

final smsListenerServiceProvider = Provider<SmsListenerService>((ref) {
  final service = SmsListenerService(ref.watch(wifiServiceProvider));
  return service;
});
