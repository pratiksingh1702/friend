import 'package:flutter/material.dart';
import '../../../core/theme/ht_colors.dart';

class NoiseBackground extends StatelessWidget {
  const NoiseBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base background color
        Container(color: HTColors.bgBase),
        
        // Top-right radial gradient
        Positioned(
          top: -200,
          right: -100,
          child: Container(
            width: 600,
            height: 600,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  HTColors.accentCyan.withOpacity(0.08),
                  HTColors.accentCyan.withOpacity(0),
                ],
              ),
            ),
          ),
        ),
        
        // Bottom-left radial gradient
        Positioned(
          bottom: -150,
          left: -100,
          child: Container(
            width: 500,
            height: 500,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  HTColors.accentViolet.withOpacity(0.06),
                  HTColors.accentViolet.withOpacity(0),
                ],
              ),
            ),
          ),
        ),
        
        // Subtle mesh overlay (simulated noise)
        Opacity(
          opacity: 0.03,
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://www.transparenttextures.com/patterns/carbon-fibre.png'),
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
