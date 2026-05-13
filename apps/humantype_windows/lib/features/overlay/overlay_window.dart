import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:go_router/go_router.dart';
import 'package:humantype_shared/humantype_shared.dart';
import '../../core/services/window_manager_service.dart';
import '../sync/providers/bridge_provider.dart';
import 'providers/overlay_settings_provider.dart';
import 'overlay_ui.dart';
import 'wda_manager.dart';

class OverlayWindow extends ConsumerStatefulWidget {
  const OverlayWindow({super.key});

  @override
  ConsumerState<OverlayWindow> createState() => _OverlayWindowState();
}

class _OverlayWindowState extends ConsumerState<OverlayWindow> with WindowListener {
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _initWindow();
  }

  void _initWindow() async {
    await windowManager.setAsFrameless();
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setBackgroundColor(Colors.transparent);
    
    final hwnd = WdaManager.findWindow('HumanType Command Center');
    if (hwnd != 0) {
      WdaManager.setExcludeFromCapture(hwnd, true);
    }
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch settings and bridge
    final bridge = ref.watch(bridgeProvider);
    final settings = ref.watch(overlaySettingsProvider);
    final isActive = bridge.sessionStatus == SessionStatus.executing;
    
    // Adaptive opacity logic with user override
    double baseOpacity = settings.opacity;
    double targetOpacity = baseOpacity;
    
    if (_isCollapsed) {
      targetOpacity = (baseOpacity * 0.5).clamp(0.2, 0.5);
    } else if (isActive) {
      targetOpacity = (baseOpacity * 0.8).clamp(0.4, 0.8);
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isCollapsed = false),
      onExit: (_) => setState(() => _isCollapsed = true),
      child: GestureDetector(
        onPanStart: (_) => windowManager.startDragging(),
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: targetOpacity),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          builder: (context, opacity, child) {
            return Opacity(
              opacity: opacity,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _isCollapsed ? 120 : (settings.isExpanded ? 480 : 320),
                curve: Curves.easeInOutBack,
                child: _isCollapsed ? _buildCollapsedHUD(bridge) : _buildFullOverlay(context, bridge),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFullOverlay(BuildContext context, BridgeState bridge) {
    return Stack(
      children: [
        const OverlayUI(),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: const Icon(FluentIcons.chrome_back, size: 12),
            onPressed: () async {
              await ref.read(windowManagerProvider.notifier).exitHudMode();
              if (mounted) context.go('/');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCollapsedHUD(BridgeState bridge) {
    final progress = (bridge.progress * 100).toInt();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            bridge.sessionStatus == SessionStatus.executing
                ? FluentIcons.edit
                : FluentIcons.pause,
            size: 12,
            color: bridge.sessionStatus == SessionStatus.executing
                ? Colors.green
                : Colors.orange,
          ),
          const SizedBox(width: 6),
          Text(
            '$progress%',
            style: const TextStyle(
                color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
