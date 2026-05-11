import 'dart:ui';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humantype_shared/humantype_shared.dart';
import '../sync/providers/bridge_provider.dart';

class OverlayUI extends ConsumerWidget {
  const OverlayUI({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bridge = ref.watch(bridgeProvider);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
              width: 1.5,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.05),
                Colors.transparent,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context, bridge),
              _buildProgressSection(context, bridge),
              if (bridge.isAndroidConnected) _buildLiveSyncSection(context, bridge),
              _buildFooter(context, bridge),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, BridgeState bridge) {
    final isActive = bridge.sessionStatus == SessionStatus.executing;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          _StatusPulse(isActive: isActive),
          const SizedBox(width: 10),
          Text(
            'HUMANTYPE',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: bridge.isAndroidConnected ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              bridge.isAndroidConnected ? 'LINKED' : 'DISCONNECTED',
              style: TextStyle(
                color: bridge.isAndroidConnected ? Colors.green : Colors.red,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context, BridgeState bridge) {
    final progress = (bridge.progress * 100).clamp(0, 100).toInt();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat(context, 'WPM', bridge.currentWpm.toStringAsFixed(0)),
              _buildStat(context, 'PROGRESS', '$progress%'),
              _buildStat(context, 'MODE', bridge.sessionStatus.name.toUpperCase()),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: ProgressBar(
              value: progress.toDouble(),
              backgroundColor: Colors.white.withOpacity(0.1),
            ),
          ),
          const SizedBox(height: 12),
          if (bridge.lastOcrText != null) _buildOcrStatus(context, bridge),
        ],
      ),
    );
  }

  Widget _buildOcrStatus(BuildContext context, BridgeState bridge) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(FluentIcons.set_action, color: Colors.green, size: 8),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'OCR: ${bridge.lastOcrText}',
              style: TextStyle(color: Colors.green, fontSize: 8),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${(bridge.ocrConfidence! * 100).toInt()}%',
            style: TextStyle(color: Colors.green, fontSize: 8, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveSyncSection(BuildContext context, BridgeState bridge) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(FluentIcons.cell_phone, color: Colors.blue, size: 10),
              const SizedBox(width: 6),
              Text(
                'LIVE ANDROID INPUT',
                style: TextStyle(
                  color: Colors.blue.withOpacity(0.8),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            bridge.lastAndroidText ?? 'Waiting for input...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontFamily: 'Consolas',
              fontSize: 11,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, BridgeState bridge) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            bridge.isAndroidConnected ? 'READY' : 'WAITING FOR BRIDGE',
            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9),
          ),
          if (bridge.lastSyncTimestamp != null)
            Text(
              'SYNCED ${DateTime.fromMillisecondsSinceEpoch(bridge.lastSyncTimestamp!).toLocal().toString().split(' ')[1].split('.')[0]}',
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9),
            ),
        ],
      ),
    );
  }

  Widget _buildStat(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 8, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _StatusPulse extends StatefulWidget {
  final bool isActive;
  const _StatusPulse({required this.isActive});

  @override
  State<_StatusPulse> createState() => _StatusPulseState();
}

class _StatusPulseState extends State<_StatusPulse> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.isActive ? Colors.green : Colors.orange,
            boxShadow: [
              BoxShadow(
                color: (widget.isActive ? Colors.green : Colors.orange).withOpacity(0.5 * _controller.value),
                blurRadius: 8 * _controller.value,
                spreadRadius: 2 * _controller.value,
              ),
            ],
          ),
        );
      },
    );
  }
}
