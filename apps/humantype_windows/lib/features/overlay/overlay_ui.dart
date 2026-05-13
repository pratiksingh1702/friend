import 'dart:ui';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humantype_shared/humantype_shared.dart';
import 'package:window_manager/window_manager.dart';
import '../sync/providers/bridge_provider.dart';
import 'providers/overlay_settings_provider.dart';
import '../scratchpad/widgets/scratchpad_panel.dart';

class OverlayUI extends ConsumerWidget {
  const OverlayUI({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bridge = ref.watch(bridgeProvider);
    final settings = ref.watch(overlaySettingsProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.75),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeader(context, ref, bridge, settings),
                        Container(height: 1, color: Colors.white.withOpacity(0.1)),
                        const SizedBox(height: 8),
                        _buildTabContent(context, bridge, settings),
                        const SizedBox(height: 8),
                        _buildFooter(context, bridge),
                      ],
                    ),
                  ),
                  // Resize Handle
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onPanStart: (_) => windowManager.startResizing(ResizeEdge.bottomRight),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.resizeDownRight,
                        child: Container(
                          width: 20,
                          height: 20,
                          padding: const EdgeInsets.all(4),
                          child: CustomPaint(
                            painter: _ResizeHandlePainter(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildTabContent(BuildContext context, BridgeState bridge, OverlaySettings settings) {
    switch (settings.activeTab) {
      case 0: // Status
        return Column(
          children: [
            _buildProgressSection(context, bridge),
            if (bridge.isAndroidConnected) _buildLiveSyncSection(context, bridge),
            _buildMetricsGrid(context, bridge),
          ],
        );
      case 1: // Scratchpad
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: ScratchpadPanel(),
        );
      case 2: // Clipboard
        return const Center(child: Padding(
          padding: EdgeInsets.all(40),
          child: Text('Clipboard Sync coming soon...', style: TextStyle(color: Colors.white, fontSize: 10)),
        ));
      case 3: // Notifications
        return const Center(child: Padding(
          padding: EdgeInsets.all(40),
          child: Text('Notification Mirror coming soon...', style: TextStyle(color: Colors.white, fontSize: 10)),
        ));
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, BridgeState bridge, OverlaySettings settings) {
    final isActive = bridge.sessionStatus == SessionStatus.executing;
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
      child: Column(
        children: [
          Row(
            children: [
              _StatusPulse(isActive: isActive),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HUMANTYPE HUD',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
                  ),
                  Text(
                    bridge.isConnected ? 'SYSTEM ONLINE' : 'OFFLINE',
                    style: TextStyle(
                      color: bridge.isConnected ? Colors.blue : Colors.red,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              _buildHeaderButton(
                icon: settings.opacity >= 0.9 ? FluentIcons.view : FluentIcons.hide,
                onPressed: () {
                  double next = 0.5;
                  if (settings.opacity <= 0.5) next = 0.75;
                  else if (settings.opacity <= 0.75) next = 1.0;
                  ref.read(overlaySettingsProvider.notifier).setOpacity(next);
                },
              ),
              const SizedBox(width: 8),
              _buildHeaderButton(
                icon: settings.isExpanded ? FluentIcons.back_to_window : FluentIcons.full_screen,
                onPressed: () {
                  ref.read(overlaySettingsProvider.notifier).toggleExpanded();
                },
              ),
              const SizedBox(width: 12),
              _buildLinkStatus(bridge),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTabButton(ref, 0, FluentIcons.info, 'STATUS', settings.activeTab == 0),
              _buildTabButton(ref, 1, FluentIcons.edit_note, 'NOTES', settings.activeTab == 1),
              _buildTabButton(ref, 2, FluentIcons.copy, 'CLIP', settings.activeTab == 2),
              _buildTabButton(ref, 3, FluentIcons.action_center, 'NOTIF', settings.activeTab == 3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(WidgetRef ref, int index, IconData icon, String label, bool isActive) {
    return HoverButton(
      onPressed: () => ref.read(overlaySettingsProvider.notifier).setTab(index),
      builder: (context, states) {
        final isHovered = states.contains(WidgetState.hovered);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? Colors.blue.withOpacity(0.1) : (isHovered ? Colors.white.withOpacity(0.05) : Colors.transparent),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive ? Colors.blue.withOpacity(0.3) : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: isActive ? Colors.blue : Colors.white.withOpacity(0.5), size: 12),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
                  fontSize: 8,
                  fontWeight: isActive ? FontWeight.w900 : FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderButton({required IconData icon, required VoidCallback onPressed}) {
    return HoverButton(
      onPressed: onPressed,
      builder: (context, states) {
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: states.contains(WidgetState.hovered) ? Colors.white.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, color: Colors.white.withOpacity(0.7), size: 14),
        );
      },
    );
  }

  Widget _buildLinkStatus(BridgeState bridge) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bridge.isAndroidConnected ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (bridge.isAndroidConnected ? Colors.green : Colors.red).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            bridge.isAndroidConnected ? FluentIcons.cell_phone : FluentIcons.error,
            color: bridge.isAndroidConnected ? Colors.green : Colors.red,
            size: 10,
          ),
          const SizedBox(width: 6),
          Text(
            bridge.isAndroidConnected ? 'LINKED' : 'NO LINK',
            style: TextStyle(
              color: bridge.isAndroidConnected ? Colors.green : Colors.red,
              fontSize: 8,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context, BridgeState bridge) {
    final progress = (bridge.progress * 100).clamp(0, 100).toInt();
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'EXECUTION PROGRESS',
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 8, fontWeight: FontWeight.bold),
              ),
              Text(
                '$progress%',
                style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 6,
              child: ProgressBar(
                value: progress.toDouble(),
                backgroundColor: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context, BridgeState bridge) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.2,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildMetricCard('CURRENT WPM', bridge.currentWpm.toStringAsFixed(0), FluentIcons.speed_high, Colors.blue),
          _buildMetricCard('LATENCY', '${bridge.latencyMs}ms', FluentIcons.timer, Colors.orange),
          _buildMetricCard('STABILITY', '98.2%', FluentIcons.heart, Colors.red),
          _buildMetricCard('SESSION', bridge.sessionStatus.name.toUpperCase(), FluentIcons.field_empty, Colors.purple),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color.withOpacity(0.7), size: 14),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 7, fontWeight: FontWeight.bold)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiveSyncSection(BuildContext context, BridgeState bridge) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withOpacity(0.1),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _BlinkingCursor(),
              const SizedBox(width: 8),
              Text(
                'LIVE TRANSMISSION',
                style: TextStyle(
                  color: Colors.blue.withOpacity(0.8),
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            bridge.lastAndroidText ?? 'READY FOR INPUT...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontFamily: 'Consolas',
              fontSize: 10,
              height: 1.5,
              fontStyle: bridge.lastAndroidText == null ? FontStyle.italic : FontStyle.normal,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, BridgeState bridge) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'V1.2.4-STABLE',
            style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 7, fontWeight: FontWeight.bold),
          ),
          if (bridge.lastSyncTimestamp != null)
            Text(
              'LAST SYNC: ${DateTime.fromMillisecondsSinceEpoch(bridge.lastSyncTimestamp!).toLocal().toString().split(' ')[1].split('.')[0]}',
              style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 7, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }
}

class _ResizeHandlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(size.width * 0.7, size.height * 0.9), Offset(size.width * 0.9, size.height * 0.7), paint);
    canvas.drawLine(Offset(size.width * 0.4, size.height * 0.9), Offset(size.width * 0.9, size.height * 0.4), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor();

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
      ),
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
