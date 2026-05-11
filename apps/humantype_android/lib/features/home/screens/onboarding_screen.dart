import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router.dart';
import '../../../core/theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = [
    const _OnboardingPage(
      title: 'Human-Like Typing',
      description: 'HumanType simulates realistic typing rhythm and errors, making your remote sessions indistinguishable from manual work.',
      icon: Icons.keyboard,
      color: HumanTypeColors.accentPrimary,
    ),
    const _OnboardingPage(
      title: 'Live Screen Capture',
      description: 'See what your laptop sees. Real-time OCR streams text from your Windows screen directly to your phone.',
      icon: Icons.visibility,
      color: HumanTypeColors.accentSecondary,
    ),
    const _OnboardingPage(
      title: 'AI Intelligence',
      description: 'Expand brief notes into professional text or analyze screen content with integrated LLM providers.',
      icon: Icons.psychology,
      color: HumanTypeColors.accentPrimary,
    ),
    const _OnboardingPage(
      title: 'Stealth Mode',
      description: 'Protect your privacy. Our Windows HUD automatically excludes itself from screen sharing and recording software.',
      icon: Icons.security,
      color: HumanTypeColors.accentSecondary,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final page = _pages[index];
              return Container(
                padding: const EdgeInsets.all(HumanTypeSpacing.xxl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(page.icon, size: 100, color: page.color),
                    const SizedBox(height: HumanTypeSpacing.xxxl),
                    Text(page.title, style: HumanTypeText.display, textAlign: TextAlign.center),
                    const SizedBox(height: HumanTypeSpacing.lg),
                    Text(
                      page.description,
                      style: HumanTypeText.bodyLarge.copyWith(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            bottom: HumanTypeSpacing.xxxl,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (index) {
                    final isActive = _currentPage == index;
                    return AnimatedContainer(
                      duration: HumanTypeAnimation.standard,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isActive ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive ? HumanTypeColors.accentPrimary : HumanTypeColors.borderDefault,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: HumanTypeSpacing.xxl),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: HumanTypeSpacing.xxl),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentPage < _pages.length - 1) {
                        _controller.nextPage(
                          duration: HumanTypeAnimation.standard,
                          curve: HumanTypeAnimation.easeInOut,
                        );
                      } else {
                        context.go(AppRoutes.home);
                      }
                    },
                    child: Text(_currentPage == _pages.length - 1 ? 'Get Started' : 'Next'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage {
  const _OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
}
