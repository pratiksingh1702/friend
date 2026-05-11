class DiscoveredDevice {
  const DiscoveredDevice({
    required this.id,
    required this.name,
    required this.host,
    required this.port,
    required this.deviceType,
  });

  final String id;
  final String name;
  final String host;
  final int port;
  final String deviceType;
}

class MdnsDiscovery {
  Future<List<DiscoveredDevice>> scan({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    return <DiscoveredDevice>[];
  }
}
