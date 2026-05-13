import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' show FluentIcons;
import '../../../core/theme/ht_colors.dart';
import '../../../core/theme/ht_typography.dart';

class Sidebar extends StatelessWidget {
  final String activeRoute;
  final Function(String) onRouteSelected;

  const Sidebar({
    super.key,
    required this.activeRoute,
    required this.onRouteSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: HTColors.bgSurface,
        border: Border(
          right: BorderSide(color: HTColors.border, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLogo(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _NavItem(
                    icon: FluentIcons.home,
                    label: 'Dashboard',
                    isSelected: activeRoute == '/',
                    onTap: () => onRouteSelected('/'),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionHeader('CORE'),
                  _NavItem(
                    icon: FluentIcons.shield,
                    label: 'Biometric Vault',
                    isSelected: activeRoute == '/vault',
                    onTap: () => onRouteSelected('/vault'),
                  ),
                  _NavItem(
                    icon: FluentIcons.fabric_folder,
                    label: 'Files',
                    isSelected: activeRoute == '/files',
                    onTap: () => onRouteSelected('/files'),
                  ),
                  _NavItem(
                    icon: FluentIcons.edit_note,
                    label: 'Scratchpad',
                    isSelected: activeRoute == '/scratchpad',
                    onTap: () => onRouteSelected('/scratchpad'),
                  ),
                  _NavItem(
                    icon: FluentIcons.copy,
                    label: 'Clipboard',
                    isSelected: activeRoute == '/clipboard',
                    onTap: () => onRouteSelected('/clipboard'),
                  ),
                  _NavItem(
                    icon: FluentIcons.ringer,
                    label: 'Notifications',
                    isSelected: activeRoute == '/notifications',
                    onTap: () => onRouteSelected('/notifications'),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionHeader('SYSTEM'),
                  _NavItem(
                    icon: FluentIcons.cell_phone,
                    label: 'Devices',
                    isSelected: activeRoute == '/devices',
                    onTap: () => onRouteSelected('/devices'),
                  ),
                  _NavItem(
                    icon: FluentIcons.connect_contacts,
                    label: 'Protocol',
                    isSelected: activeRoute == '/protocol',
                    onTap: () => onRouteSelected('/protocol'),
                  ),
                  _NavItem(
                    icon: FluentIcons.settings,
                    label: 'Settings',
                    isSelected: activeRoute == '/settings',
                    onTap: () => onRouteSelected('/settings'),
                  ),
                  const SizedBox(height: 40),
                  _buildDeviceWidget(),
                  const SizedBox(height: 16),
                  _buildUpgradeCard(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [HTColors.accentBlue, HTColors.accentViolet],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: HTColors.accentBlue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'H',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HumanType',
                style: HTTypography.sectionTitle.copyWith(fontSize: 18, letterSpacing: -0.5),
              ),
              Text(
                'v5.0',
                style: HTTypography.micro.copyWith(fontWeight: FontWeight.bold, color: HTColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 12),
      child: Text(
        title,
        style: HTTypography.sidebarCategory.copyWith(
          color: HTColors.textMuted.withOpacity(0.8),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildDeviceWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HTColors.bgBase.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HTColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: HTColors.border),
                ),
                child: const Icon(FluentIcons.cell_phone, color: HTColors.textPrimary, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pixel 8 Pro', style: HTTypography.cardTitle.copyWith(fontSize: 12)),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: HTColors.accentGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text('Connected', style: HTTypography.micro.copyWith(color: HTColors.accentGreen, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Uptime', style: HTTypography.micro),
              Text('78%', style: HTTypography.micro.copyWith(color: HTColors.textPrimary, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: HTColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              FractionallySizedBox(
                widthFactor: 0.78,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [HTColors.accentGreen, Color(0xFF34D399)],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('2h 14m', style: HTTypography.micro.copyWith(fontSize: 8)),
        ],
      ),
    );
  }

  Widget _buildUpgradeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HTColors.accentBlue.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HTColors.accentBlue.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(FluentIcons.diamond, color: HTColors.accentBlue, size: 18),
              const SizedBox(width: 10),
              Text('Upgrade to Pro', style: HTTypography.cardTitle.copyWith(fontSize: 13)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Unlock advanced sync, HUD themes and more.',
            style: HTTypography.micro.copyWith(height: 1.5, color: HTColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('Learn more', style: HTTypography.micro.copyWith(color: HTColors.accentBlue, fontWeight: FontWeight.bold)),
              const Spacer(),
              const Icon(FluentIcons.chevron_right, size: 10, color: HTColors.accentBlue),
            ],
          ),
        ],
      ),
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
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          height: 40,
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? HTColors.accentBlue.withOpacity(0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? HTColors.accentBlue : HTColors.textSecondary,
                size: 18,
              ),
              const SizedBox(width: 14),
              Text(
                label,
                style: HTTypography.sidebarLabel.copyWith(
                  color: isSelected ? HTColors.accentBlue : HTColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              if (isSelected) const Spacer(),
              if (isSelected)
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: HTColors.accentBlue,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
