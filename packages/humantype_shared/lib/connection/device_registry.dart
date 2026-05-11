import '../models/connected_device.dart';

class DeviceRegistry {
  final Map<String, ConnectedDevice> _devices = {};

  List<ConnectedDevice> get devices => _devices.values.toList(growable: false);

  ConnectedDevice? getById(String id) => _devices[id];

  void upsert(ConnectedDevice device) {
    _devices[device.id] = device;
  }

  void remove(String id) {
    _devices.remove(id);
  }

  void clear() {
    _devices.clear();
  }
}
