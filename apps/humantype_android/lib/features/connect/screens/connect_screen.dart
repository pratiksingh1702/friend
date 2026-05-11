import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:humantype_shared/humantype_shared.dart';

import '../../../core/router.dart';
import '../../../core/theme.dart';
import '../../../core/widgets/human_type_scaffold.dart';
import '../services/bluetooth_service.dart';
import '../services/wifi_service.dart';

class ConnectScreen extends ConsumerStatefulWidget {
  const ConnectScreen({super.key});

  @override
  ConsumerState<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends ConsumerState<ConnectScreen> {
  final _manualIp = TextEditingController();
  bool _scanning = false;
  List<DiscoveredDevice> _wifiDevices = const [];
  List<DiscoveredBluetoothDevice> _bluetoothDevices = const [];

  @override
  void initState() {
    super.initState();
    _scanDevices();
  }

  @override
  void dispose() {
    _manualIp.dispose();
    super.dispose();
  }

  Future<void> _scanDevices() async {
    setState(() => _scanning = true);
    final discovery = MdnsDiscovery();
    final wifiDevices = await discovery.scan();
    final bluetooth = await ref.read(bluetoothServiceProvider).scan();
    setState(() {
      _wifiDevices = wifiDevices;
      _bluetoothDevices = bluetooth;
      _scanning = false;
    });
  }

  Future<void> _connectToWifi(String host, int port) async {
    final wifi = ref.read(wifiServiceProvider);
    try {
      await wifi.connect(host, port: port);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connected to $host:$port')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connection failed. Check the bridge.')),
      );
    }
  }

  Future<void> _connectToBluetooth(DiscoveredBluetoothDevice device) async {
    try {
      await ref.read(bluetoothServiceProvider).connect(device.device);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connected to ${device.displayName}')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bluetooth connection failed.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return HumanTypeScaffold(
      title: 'Connect',
      showBack: true,
      actions: [
        IconButton(
          onPressed: () => context.push(AppRoutes.home),
          icon: const Icon(Icons.close),
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nearby devices', style: HumanTypeText.heading1),
                    const SizedBox(height: HumanTypeSpacing.xs),
                    Text(
                      'Scan for HumanType Bridge on WiFi or Bluetooth.',
                      style: HumanTypeText.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _scanning ? null : _scanDevices,
                icon: _scanning
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: HumanTypeSpacing.lg),
          _buildSectionTitle('WiFi devices'),
          const SizedBox(height: HumanTypeSpacing.sm),
          if (_wifiDevices.isEmpty)
            _EmptyCard(
              icon: Icons.wifi_tethering,
              message: _scanning
                  ? 'Scanning for bridge devices...'
                  : 'No WiFi devices found yet.',
            )
          else
            Column(
              children: _wifiDevices
                  .map((device) => _DeviceCard(
                        title: device.name,
                        subtitle: '${device.host}:${device.port}',
                        icon: Icons.wifi,
                        onTap: () => _connectToWifi(device.host, device.port),
                      ))
                  .toList(),
            ),
          const SizedBox(height: HumanTypeSpacing.xl),
          _buildSectionTitle('Bluetooth devices'),
          const SizedBox(height: HumanTypeSpacing.sm),
          if (_bluetoothDevices.isEmpty)
            _EmptyCard(
              icon: Icons.bluetooth,
              message: _scanning
                  ? 'Scanning for Bluetooth devices...'
                  : 'No Bluetooth devices found yet.',
            )
          else
            Column(
              children: _bluetoothDevices
                  .map((device) => _DeviceCard(
                        title: device.displayName,
                        subtitle: 'Signal ${device.rssi} dBm',
                        icon: Icons.bluetooth_connected,
                        onTap: () => _connectToBluetooth(device),
                      ))
                  .toList(),
            ),
          const SizedBox(height: HumanTypeSpacing.xl),
          _buildSectionTitle('Manual IP'),
          const SizedBox(height: HumanTypeSpacing.sm),
          TextField(
            controller: _manualIp,
            keyboardType: TextInputType.url,
            style: HumanTypeText.body,
            decoration: const InputDecoration(
              hintText: '192.168.0.5',
            ),
          ),
          const SizedBox(height: HumanTypeSpacing.md),
          ElevatedButton.icon(
            onPressed: () {
              final ip = _manualIp.text.trim();
              if (ip.isEmpty) return;
              _connectToWifi(ip, AppConstants.defaultWsPort);
            },
            icon: const Icon(Icons.link),
            label: const Text('Connect to IP'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: HumanTypeText.heading2);
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: HumanTypeSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(HumanTypeSpacing.lg),
          decoration: BoxDecoration(
            color: HumanTypeColors.bgElevated,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: HumanTypeColors.borderSubtle),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(HumanTypeSpacing.sm),
                decoration: BoxDecoration(
                  color: HumanTypeColors.bgOverlay,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: HumanTypeSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: HumanTypeText.bodyLarge),
                    const SizedBox(height: HumanTypeSpacing.xs),
                    Text(subtitle, style: HumanTypeText.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(HumanTypeSpacing.lg),
      decoration: BoxDecoration(
        color: HumanTypeColors.bgElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HumanTypeColors.borderSubtle),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(width: HumanTypeSpacing.md),
          Expanded(
            child: Text(message, style: HumanTypeText.body),
          ),
        ],
      ),
    );
  }
}
