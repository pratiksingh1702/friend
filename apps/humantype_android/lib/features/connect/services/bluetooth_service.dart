import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  Future<void> connect(BluetoothDevice device) async {
    await device.connect(timeout: const Duration(seconds: 10));
  }

  Future<void> disconnect(BluetoothDevice device) async {
    await device.disconnect();
  }
}
