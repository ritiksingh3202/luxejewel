import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/luxe_button.dart';
import '../../shared/widgets/luxe_image.dart';

class _Slide {
  const _Slide({
    required this.title,
    required this.description,
    required this.imageAsset,
    required this.icon,
  });

  final String title;
  final String description;
  final String imageAsset;
  final IconData icon;
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _index = 0;

  static final _slides = <_Slide>[
    _Slide(
      title: 'Exquisite Collection',
      description: 'Discover handcrafted jewelry pieces that tell your unique story',
      imageAsset: AppAssets.onboarding[0],
      icon: Icons.diamond_outlined,
    ),
    _Slide(
      title: 'Premium Quality',
      description: 'Each piece is crafted with the finest materials and precious stones',
      imageAsset: AppAssets.onboarding[1],
      icon: Icons.star_rounded,
    ),
    _Slide(
      title: 'Certified & Insured',
      description: 'Every purchase comes with authenticity certificate and full insurance',
      imageAsset: AppAssets.onboarding[2],
      icon: Icons.verified_user_outlined,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_index < _slides.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final s = _slides[i];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                    child: Column(
                      children: [
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: KeyedSubtree(
                              key: ValueKey(s.title),
                              child: Column(
                                children: [
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: 260,
                                    height: 260,
                                    child: Stack(
                                      alignment: Alignment.bottomCenter,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(28),
                                          child: LuxeImage(source: s.imageAsset),
                                        ),
                                        Positioned.fill(
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(28),
                                              gradient: LinearGradient(
                                                begin: Alignment.bottomCenter,
                                                end: Alignment.topCenter,
                                                colors: [
                                                  AppColors.bgPrimary.withOpacity(0.85),
                                                  Colors.transparent,
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 16),
                                          child: Icon(s.icon, size: 48, color: AppColors.gold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                  Text(
                                    s.title,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    s.description,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (i) {
                      final active = i == _index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: active ? 32 : 8,
                        decoration: BoxDecoration(
                          color: active ? AppColors.gold : AppColors.divider,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: LuxeButton(
                          label: 'Skip',
                          variant: LuxeButtonVariant.outline,
                          onPressed: () => context.go('/login'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: LuxeButton(
                          label: _index == _slides.length - 1 ? 'Get Started' : 'Next',
                          onPressed: _next,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
