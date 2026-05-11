import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocalStore {
  LocalStore._();

  static final LocalStore instance = LocalStore._();
  static const _encryptionKeyName = 'humantype_hive_key';

  late final Box<Map> templatesBox;
  late final Box<Map> historyBox;
  late final Box<Map> devicesBox;
  late final Box<Map> fieldMapsBox;
  late final Box<Map> settingsBox;

  Future<void> init() async {
    await Hive.initFlutter();
    final key = await _getEncryptionKey();
    final cipher = HiveAesCipher(key);

    templatesBox = await Hive.openBox<Map>('templates', encryptionCipher: cipher);
    historyBox = await Hive.openBox<Map>('history', encryptionCipher: cipher);
    devicesBox = await Hive.openBox<Map>('devices', encryptionCipher: cipher);
    fieldMapsBox = await Hive.openBox<Map>('field_maps', encryptionCipher: cipher);
    settingsBox = await Hive.openBox<Map>('settings', encryptionCipher: cipher);
  }

  Future<Uint8List> _getEncryptionKey() async {
    const storage = FlutterSecureStorage();
    final existing = await storage.read(key: _encryptionKeyName);
    if (existing != null && existing.isNotEmpty) {
      return Uint8List.fromList(base64Decode(existing));
    }
    final key = Hive.generateSecureKey();
    await storage.write(key: _encryptionKeyName, value: base64Encode(key));
    return Uint8List.fromList(key);
  }
}
