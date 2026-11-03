import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _autoSlideTimer;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoSlideTimer();
  }

  void _startAutoSlideTimer() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (_isNavigating || !mounted) return;
      if (_currentPage < 2) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 550),
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

    final storage = sl<LocalStorageService>();
    await storage.setOnboardingCompleted(true);
    final prefs = sl<SharedPreferences>();
    await prefs.setBool('is_first_launch', false);

    if (mounted) {
      final authRepo = sl<AuthRepository>();
      final isAuth = await authRepo.isAuthenticated();
      if (mounted) {
        if (isAuth) {
          context.go('/driver/home');
        } else {
          context.go('/login');
        }
      }
    }
  }

  void _nextPageOrComplete(int totalSlides) {
    HapticFeedback.mediumImpact();
    if (_currentPage < totalSlides - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = LocaleCubit.tagOf(context.watch<LocaleCubit>().state);
    String t(String uz, String cyrl, String ru) =>
        lang == 'ru' ? ru : (lang == 'uz_Cyrl' ? cyrl : uz);
    final screenHeight = MediaQuery.of(context).size.height;
    // 58% screen height for the hero visual as per specification
    final imageHeight = screenHeight * 0.58;

    final slides = [
      // 1. Pilot yo'nalishi
      _SlideData(
        title: t('Jalaquduq ⇄ Andijon:\nyo‘lovchilar sizni kutmoqda',
            'Жалақудуқ ⇄ Андижон:\nйўловчилар сизни кутмоқда',
            'Джалакудук ⇄ Андижан:\nпассажиры вас ждут'),
        description: t(
            'Ertalab yo‘nalish oching, kechqurun qaytishga oching. Bo‘sh o‘rindiq bilan yurmaysiz.',
            'Эрталаб йўналиш очинг, кечқурун қайтишга очинг. Бўш ўриндиқ билан юрмайсиз.',
            'Откройте маршрут утром и на обратный путь вечером. Без пустых мест.'),
        imagePath: 'assets/images/onboarding_1.jpg',
        badgeText: t('Pilot yo‘nalish', 'Пилот йўналиш', 'Пилотный маршрут'),
      ),

      // 2. So'rovlarni o'zi qabul qiladi
      _SlideData(
        title: t('So‘rovni o‘zingiz\nqabul qilasiz',
            'Сўровни ўзингиз\nқабул қиласиз', 'Запросы принимаете\nвы сами'),
        description: t(
            'Yo‘lovchi xaritada uyini belgilaydi. Qabul qilsangiz — manzili ko‘rinadi, uyidan olib ketasiz.',
            'Йўловчи харитада уйини белгилайди. Қабул қилсангиз — манзили кўринади, уйидан олиб кетасиз.',
            'Пассажир отмечает дом на карте. Примете — увидите адрес и заберёте его от дома.'),
        imagePath: 'assets/images/onboarding_3.jpg',
        badgeText: t('Uyidan olib ketish', 'Уйидан олиб кетиш', 'Забор от дома'),
      ),

      // 3. 0% Komissiya
      _SlideData(
        title: t('Pulingiz o‘zingizda,\nkomissiya yo‘q',
            'Пулингиз ўзингизда,\nкомиссия йўқ', 'Деньги у вас,\nбез комиссии'),
        description: t(
            'Yo‘lovchi sizga naqd to‘laydi. Narxni 20 000 – 30 000 so‘m oralig‘ida o‘zingiz belgilaysiz.',
            'Йўловчи сизга нақд тўлайди. Нархни 20 000 – 30 000 сўм оралиғида ўзингиз белгилайсиз.',
            'Пассажир платит наличными. Цену 20 000 – 30 000 сум выбираете сами.'),
        imagePath: 'assets/images/onboarding_2.jpg',
        badgeText: t('0% komissiya', '0% комиссия', '0% комиссия'),
      ),
    ];
    final isLast = _currentPage == slides.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. PageView with Parallax Swipe Drift & Breathing Animation
          PageView.builder(
            controller: _pageController,
            itemCount: slides.length,
            onPageChanged: (index) {
              HapticFeedback.mediumImpact();
              setState(() => _currentPage = index);
              _startAutoSlideTimer();
            },
            itemBuilder: (context, index) {
              final slide = slides[index];
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, _) {
                  double pageOffset = 0.0;
                  if (_pageController.position.haveDimensions) {
                    pageOffset =
                        (_pageController.page ?? _currentPage.toDouble()) -
                            index;
                  }
                  return _buildSlideItem(
                    slide: slide,
                    imageHeight: imageHeight,
                    isActive: index == _currentPage,
                    pageOffset: pageOffset,
                  );
                },
              );
            },
          ),

          // 2. Minimalist Bottom Action Bar: Dynamic Pill Indicators & Bold Glanceable Next Button
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
                    // Dynamic Pill Indicators (7px -> 24px)
                    Row(
                      children: List.generate(slides.length, (index) {
                        final isActive = index == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeOutCubic,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          height: 6,
                          width: isActive ? 24 : 7,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.taxiYellow
                                : AppColors.gray300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),

                    // Right: Primary Glanceable Action Button
                    Material(
                      color: AppColors.taxiYellow,
                      borderRadius: BorderRadius.circular(14),
                      elevation: 0,
                      child: InkWell(
                        onTap: () => _nextPageOrComplete(slides.length),
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isLast
                                    ? t('Boshlash', 'Бошлаш', 'Начать')
                                    : t('Keyingisi', 'Кейингиси', 'Далее'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                  color: AppColors.charcoalBlack,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 18,
                                color: AppColors.charcoalBlack,
                              ),
                            ],
                          ),
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
    required bool isActive,
    required double pageOffset,
  }) {
    return Column(
      children: [
        // Top Portion: Hero Image with 32px rounded bottom curve & Parallax Drift
        Container(
          height: imageHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(32),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Parallax Swipe Drift (-55px relative) + Cinematic Breathing
                Transform.translate(
                  offset: Offset(-pageOffset * 55.0, 0),
                  child: _CinematicBreathingImage(
                    imagePath: slide.imagePath,
                    isActive: isActive,
                  ),
                ),

                // Gradient fade at bottom of image for seamless atmospheric blend
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 75,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.white.withValues(alpha: 0.70),
                        ],
                      ),
                    ),
                  ),
                ),

                // Taxi Yellow accent edge line along bottom curve
                Positioned(
                  bottom: 0,
                  left: 32,
                  right: 32,
                  height: 2.5,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.taxiYellow.withValues(alpha: 0.8),
                          AppColors.taxiYellow,
                          AppColors.taxiYellow.withValues(alpha: 0.8),
                          Colors.transparent,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom Portion: Clean Glanceable Content Container
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 88),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Badge Tag
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.taxiYellow.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.taxiYellowDark.withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    slide.badgeText,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: AppColors.charcoalBlack,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Bold Driver Title
                Text(
                  slide.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    height: 1.25,
                    color: AppColors.charcoalBlack,
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 8),

                // Driver Description
                Text(
                  slide.description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13.5,
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
    required this.title,
    required this.description,
    required this.imagePath,
    required this.badgeText,
  });

  final String title;
  final String description;
  final String imagePath;
  final String badgeText;
}

/// Cinematic Breathing / Slow Zoom widget.
/// Smoothly scales between 1.08 and 1.16 over 5.5 seconds using Curves.easeInOutSine,
/// providing seamless +8% scale breathing and headroom for the 55px parallax swipe drift.
class _CinematicBreathingImage extends StatefulWidget {
  const _CinematicBreathingImage({
    required this.imagePath,
    required this.isActive,
  });

  final String imagePath;
  final bool isActive;

  @override
  State<_CinematicBreathingImage> createState() =>
      _CinematicBreathingImageState();
}

class _CinematicBreathingImageState extends State<_CinematicBreathingImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5500),
    );

    _scaleAnimation = Tween<double>(begin: 1.08, end: 1.16).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine,
      ),
    );

    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _CinematicBreathingImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.forward(from: 0.0);
        _controller.repeat(reverse: true);
      } else {
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: Image.asset(
        widget.imagePath,
        cacheWidth: 900,
        filterQuality: FilterQuality.medium,
        fit: BoxFit.cover,
      ),
    );
  }
}
