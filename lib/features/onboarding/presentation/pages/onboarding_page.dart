import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoSlideTimer;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _startAutoSlideTimer();
  }

  void _startAutoSlideTimer() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (_isNavigating || !mounted) return;
      if (_currentPage < 2) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
        );
      } else {
        _autoSlideTimer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    if (_isNavigating) return;
    _autoSlideTimer?.cancel();

    HapticFeedback.mediumImpact();
    setState(() => _isNavigating = true);

    final storage = ref.read(localStorageServiceProvider);
    await storage.setOnboardingCompleted(true);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool('is_first_launch', false);

    if (mounted) {
      context.go('/driver/home');
    }
  }

  void _nextPageOrComplete(int totalSlides) {
    HapticFeedback.mediumImpact();
    if (_currentPage < totalSlides - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLocale = ref.watch(localeNotifierProvider);
    final isRu = currentLocale.languageCode == 'ru';
    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = screenHeight * 0.56;

    final slides = [
      // 1. Shaharlararo Taksi va Safar
      _SlideData(
        tag: isRu ? 'БЫСТРО И НАДЕЖНО' : 'ISHONCHLI VA TEZ',
        title: isRu
            ? 'Путь далекий иль короткий —\nдовезем надежно, четко!'
            : 'Yo‘lingiz bo‘lsin bexatar,\nBiz bilan oson har safar!',
        description: isRu
            ? 'Комфортные поездки по городам и регионам Узбекистана без лишних хлопот.'
            : 'O‘zbekiston bo‘ylab qulay taksilar — bir zumda eshigingiz oldida.',
        imagePath: 'assets/images/onboarding_1.jpg',
        badgeText: isRu ? 'Комфорт и скорость' : 'Tezkor & Qulay',
      ),

      // 2. To'g'ridan-to'g'ri kelishuv / 0% Komissiya
      _SlideData(
        tag: isRu ? 'БЕЗ ПОСРЕДНИКОВ' : '0% VOSITACHI',
        title: isRu
            ? 'Без посредников звоните,\nцену сами согласуйте!'
            : 'Narxni o‘zingiz kelishing,\nOrtiqcha to‘lovni unuting!',
        description: isRu
            ? 'Прямой контакт с водителем и честная цена без скрытых комиссий.'
            : 'Hech qanday ortiqcha to‘lovsiz, haydovchi bilan to‘g‘ridan-to‘g‘ri bog‘laning.',
        imagePath: 'assets/images/onboarding_2.jpg',
        badgeText: isRu ? 'Честная цена' : '0% Komissiya',
      ),

      // 3. Tezkor Posilka / 1 kunda yetkazish
      _SlideData(
        tag: isRu ? 'СРОЧНАЯ ПОЧТА' : 'TEZKOR POCHTA',
        title: isRu
            ? 'Утром отдадите груз —\nв тот же день доставят в плюс!'
            : 'Bugun topshiring posilka,\nBugunoq yetsin manzilga!',
        description: isRu
            ? 'Надежная экспресс-доставка посылок и документов прямо в руки адресату.'
            : 'Hujjat va yuklaringizni ishonchli haydovchilar bilan 1 kunda yetkazing.',
        imagePath: 'assets/images/onboarding_3.jpg',
        badgeText: isRu ? 'Доставка за 1 день' : '1 kunda yetkazish',
      ),
    ];

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Stack(
        children: [
          // 1. Main PageView with Top Image & Bottom Content
          PageView.builder(
            controller: _pageController,
            itemCount: slides.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
              _startAutoSlideTimer();
            },
            itemBuilder: (context, index) {
              final slide = slides[index];
              return _buildSlideItem(
                slide: slide,
                imageHeight: imageHeight,
                isDark: isDark,
              );
            },
          ),

          // 2. Bottom Action Bar: Dots on the Left, Next / Get Started on the Right
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Slide Indicator Dots
                    Row(
                      children: List.generate(slides.length, (index) {
                        final isActive = index == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          height: 5,
                          width: isActive ? 24 : 7,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.taxiYellow
                                : (isDark ? Colors.white24 : AppColors.gray300),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),

                    // Right: Next / Get Started Action
                    InkWell(
                      onTap: () => _nextPageOrComplete(slides.length),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _currentPage == slides.length - 1
                                  ? (isRu ? 'Начать' : 'Boshladik')
                                  : (isRu ? 'Далее' : 'Keyingisi'),
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: isDark
                                    ? AppColors.taxiYellow
                                    : AppColors.charcoalBlack,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              _currentPage == slides.length - 1
                                  ? Icons.arrow_forward_rounded
                                  : Icons.chevron_right_rounded,
                              size: 19,
                              color: isDark
                                  ? AppColors.taxiYellow
                                  : AppColors.charcoalBlack,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlideItem({
    required _SlideData slide,
    required double imageHeight,
    required bool isDark,
  }) {
    return Column(
      children: [
        // Top Portion: Full-Bleed Image (takes ~56% of screen height)
        SizedBox(
          height: imageHeight,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                slide.imagePath,
                cacheWidth: 800,
                filterQuality: FilterQuality.medium,
                fit: BoxFit.cover,
              ),

              // Gradient fade at bottom of image for seamless blend
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 50,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        (isDark ? const Color(0xFF14141B) : Colors.white)
                            .withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Bottom Portion: Text Content Container
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 80),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF14141B) : Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Badge Tag
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.taxiYellow.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.taxiYellowDark.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    slide.badgeText,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.charcoalBlack,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Catchy / Poetic Title
                Text(
                  slide.title,
                  style: AppTypography.displayMedium.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 21,
                    height: 1.28,
                    color: isDark ? Colors.white : AppColors.charcoalBlack,
                  ),
                ),

                const SizedBox(height: 10),

                // Concise Description
                Text(
                  slide.description,
                  style: TextStyle(
                    color: isDark ? Colors.white60 : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SlideData {
  const _SlideData({
    required this.tag,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.badgeText,
  });

  final String tag;
  final String title;
  final String description;
  final String imagePath;
  final String badgeText;
}
