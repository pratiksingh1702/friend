import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fluent_ui/fluent_ui.dart' show FluentIcons;
import '../../../core/theme/ht_colors.dart';
import '../../../core/theme/ht_typography.dart';

class HeroStatusCard extends StatelessWidget {
  final String? deviceName;
  final bool isConnected;
  final String uptime;

  const HeroStatusCard({
    super.key,
    this.deviceName,
    required this.isConnected,
    this.uptime = '2h 14m',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        color: HTColors.bgSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: HTColors.border.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Concentric Waves on the right
            Positioned(
              right: -80,
              top: -80,
              bottom: -80,
              child: _buildWaves(),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Row(
                children: [
                  _buildPhoneMock(),
                  const SizedBox(width: 40),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStatusHeader(),
                        const SizedBox(height: 8),
                        Text(deviceName ?? 'Pixel 8 Pro', style: HTTypography.heroHeading.copyWith(fontSize: 32)),
                        const SizedBox(height: 4),
                        Text(
                          'Android 14  •  Secure Link Active', 
                          style: HTTypography.cardSubtitle.copyWith(color: HTColors.textSecondary.withOpacity(0.8)),
                        ),
                        const SizedBox(height: 24),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _buildStatBox('Battery', '78%', FluentIcons.power_button, HTColors.accentGreen),
                            _buildStatBox('Uptime', uptime, FluentIcons.history, HTColors.accentAmber),
                            _buildStatBox('Latency', '< 20ms', FluentIcons.glimmer, HTColors.accentCyan),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildSecureSyncModule(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaves() {
    return SizedBox(
      width: 400,
      child: Stack(
        alignment: Alignment.center,
        children: List.generate(6, (index) {
          return Container(
            width: (index + 1) * 80.0,
            height: (index + 1) * 80.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: HTColors.accentGreen.withOpacity(0.03 * (6 - index)),
                width: 1,
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat())
           .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: (2 + index).seconds, curve: Curves.easeInOut);
        }),
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: HTColors.accentGreen,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: HTColors.accentGreen.withOpacity(0.4), blurRadius: 4),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'CONNECTED', 
          style: HTTypography.statusLabel.copyWith(
            color: HTColors.accentGreen, 
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneMock() {
    return Container(
      width: 100,
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF374151), width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Internal Screen Mockup
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      HTColors.accentBlue.withOpacity(0.2),
                      Colors.black,
                    ],
                  ),
                ),
              ),
            ),
            // Floating circles on screen
            Positioned(
              top: 40,
              left: 20,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: HTColors.accentBlue.withOpacity(0.3), width: 2),
                ),
              ).animate(onPlay: (controller) => controller.repeat())
               .scale(duration: 3.seconds, curve: Curves.easeInOut, begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2)),
            ),
            Center(
              child: Icon(FluentIcons.cell_phone, color: HTColors.accentBlue.withOpacity(0.5), size: 32),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: HTColors.bgBase.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HTColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: HTTypography.micro.copyWith(color: HTColors.textSecondary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value, style: HTTypography.readout.copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(width: 8),
              Icon(icon, color: color, size: 12),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecureSyncModule() {
    return Container(
      width: 140,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: HTColors.accentGreen,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: HTColors.accentGreen.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(FluentIcons.shield, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 20),
          Text(
            'Secure & Synced', 
            style: HTTypography.cardTitle.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'All systems operational', 
            textAlign: TextAlign.center,
            style: HTTypography.micro.copyWith(color: HTColors.textMuted),
          ),
        ],
      ),
    );
  }
}
