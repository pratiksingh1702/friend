import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fluent_ui/fluent_ui.dart' show FluentIcons;
import '../../../core/theme/ht_colors.dart';
import '../../../core/theme/ht_typography.dart';

class BentoCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? value;
  final String? status;
  final Color color;
  final VoidCallback onTap;
  final bool isHUD;

  const BentoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.value,
    this.status,
    required this.color,
    required this.onTap,
    this.isHUD = false,
  });

  @override
  State<BentoCard> createState() => _BentoCardState();
}

class _BentoCardState extends State<BentoCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: 200.ms,
          height: 180,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: HTColors.bgSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _isHovered ? widget.color.withOpacity(0.4) : HTColors.border.withOpacity(0.8),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered 
                    ? widget.color.withOpacity(0.06) 
                    : Colors.black.withOpacity(0.01),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Icon and Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(widget.icon, color: widget.color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title, 
                      style: HTTypography.cardTitle.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Icon(FluentIcons.chevron_right, color: HTColors.textMuted, size: 12),
                ],
              ),
              const Spacer(),
              // Center: Large Value
              if (widget.value != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.value!.split(' ').first,
                      style: HTTypography.heroHeading.copyWith(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -1),
                    ),
                    Text(
                      widget.value!.split(' ').skip(1).join(' '),
                      style: HTTypography.micro.copyWith(fontSize: 11, color: HTColors.textSecondary, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              const Spacer(),
              // Bottom: Status Badge
              if (widget.status != null)
                _buildStatusBadge(widget.status!),
            ],
          ),
        ),
      ).animate(target: _isHovered ? 1.0 : 0.0)
       .scale(begin: const Offset(1, 1), end: const Offset(1.02, 1.02), duration: 200.ms),
    );
  }

  Widget _buildStatusBadge(String status) {
    final bool isPositive = status.toLowerCase().contains('sync') || status.toLowerCase().contains('live') || status.toLowerCase().contains('up to date') || status.toLowerCase().contains('protected');
    final Color badgeColor = isPositive ? HTColors.accentGreen : HTColors.accentBlue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: HTColors.bgBase.withOpacity(0.5),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: HTColors.border.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: badgeColor.withOpacity(0.3), blurRadius: 4),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            status,
            style: HTTypography.micro.copyWith(
              color: HTColors.textPrimary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
