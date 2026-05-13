import 'dart:io';
import 'package:multicast_dns/multicast_dns.dart';

import '../constants/app_constants.dart';

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
    final devices = <DiscoveredDevice>[];
    final client = MDnsClient(
      rawDatagramSocketFactory: (
        dynamic host,
        int port, {
        bool reuseAddress = true,
        bool reusePort = false,
        int ttl = 1,
      }) {
        return RawDatagramSocket.bind(
          host,
          port,
          reuseAddress: reuseAddress,
          reusePort: false,
          ttl: ttl,
        );
      },
    );
    final endAt = DateTime.now().add(timeout);

    await client.start();
    try {
      await for (final PtrResourceRecord ptr
          in client.lookup<PtrResourceRecord>(
            ResourceRecordQuery.serverPointer(AppConstants.mdnsServiceName),
          )) {
        if (DateTime.now().isAfter(endAt)) break;
        await for (final SrvResourceRecord srv
            in client.lookup<SrvResourceRecord>(
              ResourceRecordQuery.service(ptr.domainName),
            )) {
          if (DateTime.now().isAfter(endAt)) break;
          await for (final IPAddressResourceRecord ip
              in client.lookup<IPAddressResourceRecord>(
                ResourceRecordQuery.addressIPv4(srv.target),
              )) {
            if (DateTime.now().isAfter(endAt)) break;
            devices.add(
              DiscoveredDevice(
                id: '${srv.target}:${srv.port}',
                name: ptr.domainName,
                host: ip.address.address,
                port: srv.port,
                deviceType: 'bridge',
              ),
            );
          }
        }
      }
    } finally {
      client.stop();
    }

    return devices;
  }
}
