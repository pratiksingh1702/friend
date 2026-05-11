import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class DeviceIdentityService {
  static const _deviceIdKey = 'humantype_device_id';
  static const _storage = FlutterSecureStorage();

  Future<String> getDeviceId() async {
    final existing = await _storage.read(key: _deviceIdKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final generated = const Uuid().v4();
    await _storage.write(key: _deviceIdKey, value: generated);
    return generated;
  }
}

class PairingTokenStore {
  PairingTokenStore(this._identity);

  final DeviceIdentityService _identity;
  static const _storage = FlutterSecureStorage();

  Future<String> getOrCreateToken(String host) async {
    final key = 'pairing_token_$host';
    final existing = await _storage.read(key: key);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final deviceId = await _identity.getDeviceId();
    final seed = '$deviceId:$host:${DateTime.now().millisecondsSinceEpoch}';
    final token = sha256.convert(utf8.encode(seed)).toString();
    await _storage.write(key: key, value: token);
    return token;
  }
}
