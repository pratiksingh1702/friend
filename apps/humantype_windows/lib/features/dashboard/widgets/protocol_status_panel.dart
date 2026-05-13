import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' show FluentIcons;
import '../../../core/theme/ht_colors.dart';
import '../../../core/theme/ht_typography.dart';

class ProtocolStatusPanel extends StatelessWidget {
  final bool isWsConnected;
  final bool isDeviceLinked;
  final String latency;

  const ProtocolStatusPanel({
    super.key,
    required this.isWsConnected,
    required this.isDeviceLinked,
    required this.latency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: HTColors.bgSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: HTColors.border.withOpacity(0.8)),
      ),
      child: Row(
        children: [
          _buildProtocolInfo(),
          _buildVerticalDivider(),
          _buildConnectivity(),
          _buildVerticalDivider(),
          _buildLatencyGraph(),
        ],
      ),
    );
  }

  Widget _buildProtocolInfo() {
    return Expanded(
      flex: 3,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: HTColors.bgBase,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: HTColors.border),
            ),
            child: const Icon(FluentIcons.shield, color: HTColors.accentBlue, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Protocol Status', style: HTTypography.cardTitle.copyWith(fontSize: 13), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('All systems running', style: HTTypography.micro, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectivity() {
    return Expanded(
      flex: 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStatusRow('WebSocket', isWsConnected),
          const SizedBox(height: 8),
          _buildStatusRow('Device Link', isDeviceLinked),
          const SizedBox(height: 8),
          _buildStatusRow('Bridge', true),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, bool isOk) {
    return Row(
      children: [
        Flexible(child: Text(label, style: HTTypography.micro.copyWith(fontSize: 9), overflow: TextOverflow.ellipsis)),
        const SizedBox(width: 4),
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: isOk ? HTColors.accentGreen : HTColors.accentRed,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          isOk ? 'OK' : 'OFF',
          style: HTTypography.micro.copyWith(
            fontSize: 9,
            color: isOk ? HTColors.accentGreen : HTColors.accentRed,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLatencyGraph() {
    return Expanded(
      flex: 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(latency, style: HTTypography.micro.copyWith(fontWeight: FontWeight.bold, color: HTColors.textPrimary)),
              const SizedBox(width: 4),
              Text('20ms', style: HTTypography.micro),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 30,
            child: CustomPaint(
              painter: _WavePainter(color: HTColors.accentBlue),
              size: Size.infinite,
            ),
          ),
          const SizedBox(height: 4),
          Text('Current Latency', style: HTTypography.micro.copyWith(fontSize: 8)),
        ],
      ),
    );
  }


  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      color: HTColors.divider,
    );
  }
}

class _WavePainter extends CustomPainter {
  final Color color;
  _WavePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    path.moveTo(0, size.height * 0.5);
    
    for (double i = 0; i <= size.width; i++) {
      path.lineTo(
        i,
        size.height * 0.5 + 
        (i % 20 < 10 ? -4 : 4) * (i / size.width) * 1.5,
      );
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
