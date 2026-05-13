import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fluent_ui/fluent_ui.dart' show FluentIcons;
import '../../../core/theme/ht_colors.dart';
import '../../../core/theme/ht_typography.dart';

class FloatingBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const FloatingBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 32,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: HTColors.bgSurface.withOpacity(0.9),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: HTColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _NavItem(
                    icon: FluentIcons.home,
                    label: 'Dashboard',
                    isSelected: selectedIndex == 0,
                    onTap: () => onItemSelected(0),
                  ),
                  _NavItem(
                    icon: FluentIcons.shield,
                    label: 'Vault',
                    isSelected: selectedIndex == 1,
                    onTap: () => onItemSelected(1),
                  ),
                  _NavItem(
                    icon: FluentIcons.fabric_folder,
                    label: 'Files',
                    isSelected: selectedIndex == 3,
                    onTap: () => onItemSelected(3),
                  ),
                  _buildAddButton(),
                  _NavItem(
                    icon: FluentIcons.copy,
                    label: 'Clipboard',
                    isSelected: selectedIndex == 4,
                    onTap: () => onItemSelected(4),
                  ),
                  _NavItem(
                    icon: FluentIcons.ringer,
                    label: 'Notifications',
                    isSelected: selectedIndex == 5,
                    onTap: () => onItemSelected(5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().slideY(begin: 1, end: 0, duration: 600.ms, curve: Curves.easeOutBack);
  }

  Widget _buildAddButton() {
    return Container(
      width: 36,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        color: HTColors.accentBlue,
        shape: BoxShape.circle,
      ),
      child: const Icon(FluentIcons.add, color: Colors.white, size: 18),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 300.ms,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? HTColors.accentBlue.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? HTColors.accentBlue : HTColors.textSecondary,
              size: 18,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: HTTypography.sidebarLabel.copyWith(
                  color: HTColors.accentBlue,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
