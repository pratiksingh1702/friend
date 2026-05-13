import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' show FluentIcons;
import 'package:window_manager/window_manager.dart';
import '../../../core/theme/ht_colors.dart';
import '../../../core/theme/ht_typography.dart';

class TopHeader extends StatelessWidget {
  const TopHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Stack(
        children: [
          // Draggable area
          const DragToMoveArea(child: SizedBox.expand()),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                _buildSearchBar(),
                const Spacer(),
                _buildActionIcons(),
                const SizedBox(width: 20),
                _buildProfile(),
                const SizedBox(width: 20),
                _buildWindowControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: 280,
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: HTColors.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HTColors.border),
      ),
      child: Row(
        children: [
          const Icon(FluentIcons.search, color: HTColors.textMuted, size: 14),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Search or press ⌘ K',
              style: HTTypography.micro.copyWith(color: HTColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcons() {
    return Row(
      children: [
        _HeaderIcon(icon: FluentIcons.sunny, size: 16),
        const SizedBox(width: 4),
        _HeaderIcon(icon: FluentIcons.ringer, hasNotification: true, size: 16),
      ],
    );
  }

  Widget _buildProfile() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: HTColors.border, width: 1.5),
        image: const DecorationImage(
          image: NetworkImage('https://i.pravatar.cc/150?u=alex'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildWindowControls() {
    return Row(
      children: [
        _WindowBtn(
          icon: FluentIcons.chrome_minimize,
          onTap: () => windowManager.minimize(),
        ),
        _WindowBtn(
          icon: FluentIcons.chrome_restore,
          onTap: () async {
            bool isMaximized = await windowManager.isMaximized();
            if (isMaximized) {
              windowManager.unmaximize();
            } else {
              windowManager.maximize();
            }
          },
        ),
        _WindowBtn(
          icon: FluentIcons.chrome_close,
          isClose: true,
          onTap: () => windowManager.close(),
        ),
      ],
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final bool hasNotification;
  final double size;

  const _HeaderIcon({required this.icon, this.hasNotification = false, this.size = 18});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: Colors.transparent,
          ),
          child: Icon(icon, color: HTColors.textSecondary, size: size),
        ),
        if (hasNotification)
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: HTColors.accentBlue,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

class _WindowBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isClose;

  const _WindowBtn({required this.icon, required this.onTap, this.isClose = false});

  @override
  State<_WindowBtn> createState() => _WindowBtnState();
}

class _WindowBtnState extends State<_WindowBtn> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 44,
          height: 32,
          decoration: BoxDecoration(
            color: _isHovered 
                ? (widget.isClose ? Colors.red : HTColors.textSecondary.withOpacity(0.1)) 
                : Colors.transparent,
          ),
          child: Center(
            child: Icon(
              widget.icon,
              color: _isHovered && widget.isClose ? Colors.white : HTColors.textSecondary,
              size: 12,
            ),
          ),
        ),
      ),
    );
  }
}
