import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humantype_shared/humantype_shared.dart';

import 'package:permission_handler/permission_handler.dart';

final bluetoothServiceProvider = Provider<BluetoothService>(
  (ref) => BluetoothService(),
);

class DiscoveredBluetoothDevice {
  DiscoveredBluetoothDevice({required this.device, required this.rssi});

  final BluetoothDevice device;
  final int rssi;

  String get displayName {
    final name = device.platformName;
    return name.isNotEmpty ? name : device.remoteId.str;
  }
}

class BluetoothService {
  Future<List<DiscoveredBluetoothDevice>> scan({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    // Request permissions for Android 12+
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    if (statuses[Permission.bluetoothScan] != PermissionStatus.granted ||
        statuses[Permission.bluetoothConnect] != PermissionStatus.granted) {
      throw Exception('Bluetooth permissions not granted');
    }

    final results = <String, DiscoveredBluetoothDevice>{};
    StreamSubscription? sub;

    sub = FlutterBluePlus.scanResults.listen((scanResults) {
      for (final result in scanResults) {
        results[result.device.remoteId.str] =
            DiscoveredBluetoothDevice(device: result.device, rssi: result.rssi);
      }
    });

    await FlutterBluePlus.startScan(timeout: timeout);
    await FlutterBluePlus.stopScan();
    await sub.cancel();

    return results.values.toList(growable: false);
  }

  // HumanType GATT Service & Characteristic UUIDs
  static const String serviceUuid = '6e400001-b5a3-f393-e0a9-e50e24dcca9e';
  static const String charUuid = '6e400002-b5a3-f393-e0a9-e50e24dcca9e';

  BluetoothCharacteristic? _activeChar;

  Future<void> connect(BluetoothDevice device) async {
    await device.connect(timeout: const Duration(seconds: 10));
    final services = await device.discoverServices();
    for (final service in services) {
      if (service.uuid.toString() == serviceUuid) {
        for (final char in service.characteristics) {
          if (char.uuid.toString() == charUuid) {
            _activeChar = char;
            break;
          }
        }
      }
    }
  }

  Future<void> sendCommand(TypeCommand command) async {
    if (_activeChar == null) return;
    final json = command.toJson();
    final data = utf8.encode(jsonEncode(json));
    await _activeChar!.write(data, withoutResponse: true);
  }

  Future<void> disconnect(BluetoothDevice device) async {
    _activeChar = null;
    await device.disconnect();
  }
}
