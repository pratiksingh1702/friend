import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'overlay_ui.dart';
import 'wda_manager.dart';

class OverlayWindow extends StatefulWidget {
  const OverlayWindow({super.key});

  @override
  State<OverlayWindow> createState() => _OverlayWindowState();
}

class _OverlayWindowState extends State<OverlayWindow> with WindowListener {
  bool _isCollapsed = false;
  bool _isStealthMode = false;
  double _opacity = 0.9;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _initWindow();
  }

  void _initWindow() async {
    // Set window as topmost and transparent
    await windowManager.setAsFrameless();
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setBackgroundColor(Colors.transparent);
    
    // Enable WDA protection
    final hwnd = WdaManager.findWindow('HumanType Command Center'); // Matches main.dart title
    if (hwnd != 0) {
      WdaManager.setExcludeFromCapture(hwnd, true);
    }
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  void _toggleStealth() {
    setState(() {
      _isStealthMode = !_isStealthMode;
      _opacity = _isStealthMode ? 0.05 : 0.9;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isCollapsed = false),
      onExit: (_) => setState(() => _isCollapsed = true),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: _isCollapsed ? 0.3 : _opacity,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: _isCollapsed ? 120 : 300,
          curve: Curves.easeInOut,
          child: _isCollapsed ? _buildCollapsedHUD() : const OverlayUI(),
        ),
      ),
    );
  }

  Widget _buildCollapsedHUD() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(FluentIcons.edit, size: 12, color: Colors.green),
          SizedBox(width: 4),
          Text('67%', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
