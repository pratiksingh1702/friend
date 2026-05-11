import 'package:flutter/material.dart' hide ConnectionState;
import 'package:humantype_shared/humantype_shared.dart' as shared;

import '../../../core/theme.dart';
import '../../connect/providers/connection_provider.dart';

class ConnectionStatusChip extends StatefulWidget {
  const ConnectionStatusChip({super.key, required this.state, this.onTap});

  final ConnectionState state;
  final VoidCallback? onTap;

  @override
  State<ConnectionStatusChip> createState() => _ConnectionStatusChipState();
}

class _ConnectionStatusChipState extends State<ConnectionStatusChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _glow = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _syncAnimation();
  }

  @override
  void didUpdateWidget(ConnectionStatusChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.isConnected != widget.state.isConnected) {
      _syncAnimation();
    }
  }

  void _syncAnimation() {
    if (widget.state.isConnected) {
      if (!_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _qualityColor(shared.ConnectionQuality quality) {
    switch (quality) {
      case shared.ConnectionQuality.excellent:
        return HumanTypeColors.connExcellent;
      case shared.ConnectionQuality.good:
        return HumanTypeColors.connGood;
      case shared.ConnectionQuality.fair:
        return HumanTypeColors.connFair;
      case shared.ConnectionQuality.poor:
        return HumanTypeColors.connPoor;
      case shared.ConnectionQuality.bluetooth:
        return HumanTypeColors.connBluetooth;
      case shared.ConnectionQuality.disconnected:
        return HumanTypeColors.connDisconnected;
    }
  }

  String _qualityLabel(shared.ConnectionQuality quality) {
    switch (quality) {
      case shared.ConnectionQuality.excellent:
        return 'Excellent';
      case shared.ConnectionQuality.good:
        return 'Good';
      case shared.ConnectionQuality.fair:
        return 'Fair';
      case shared.ConnectionQuality.poor:
        return 'Poor';
      case shared.ConnectionQuality.bluetooth:
        return 'Bluetooth';
      case shared.ConnectionQuality.disconnected:
        return 'Disconnected';
    }
  }

  String _methodLabel(shared.ConnectionMethod method) {
    switch (method) {
      case shared.ConnectionMethod.wifi:
        return 'WiFi';
      case shared.ConnectionMethod.bluetooth:
        return 'Bluetooth';
      case shared.ConnectionMethod.none:
        return 'Offline';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final color = _qualityColor(state.quality);
    final title = state.isConnected
        ? (state.device?.name ?? 'Connected device')
        : 'Not connected';
    final latency = state.device?.latencyMs;
    final status = state.isConnected
        ? '${_methodLabel(state.method)} - ${_qualityLabel(state.quality)}'
        : 'Tap to connect';

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: HumanTypeSpacing.lg,
          vertical: HumanTypeSpacing.md,
        ),
        decoration: BoxDecoration(
          color: HumanTypeColors.bgElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: HumanTypeColors.borderSubtle),
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _glow,
              builder: (context, child) {
                return Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.6 * _glow.value),
                        blurRadius: 8 + 8 * _glow.value,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(width: HumanTypeSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: HumanTypeText.bodyLarge),
                  const SizedBox(height: HumanTypeSpacing.xs),
                  Row(
                    children: [
                      Text(status, style: HumanTypeText.caption),
                      if (latency != null) ...[
                        const SizedBox(width: HumanTypeSpacing.sm),
                        Text('$latency ms', style: HumanTypeText.caption),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}
