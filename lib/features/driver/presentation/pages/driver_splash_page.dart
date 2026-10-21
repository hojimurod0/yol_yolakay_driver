import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../profile/domain/repositories/driver_profile_repository.dart';

class DriverSplashPage extends StatefulWidget {
  const DriverSplashPage({super.key});

  @override
  State<DriverSplashPage> createState() => _DriverSplashPageState();
}

class _DriverSplashPageState extends State<DriverSplashPage>
    with SingleTickerProviderStateMixin {
  Timer? _navTimer;
  late AnimationController _animController;
  late Animation<double> _logoScaleAnim;
  late Animation<double> _logoFadeAnim;
  late Animation<Offset> _textSlideAnim;
  late Animation<double> _textFadeAnim;
  late Animation<double> _badgeScaleAnim;
  late Animation<double> _badgeFadeAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _logoScaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _logoFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeIn),
      ),
    );

    _textSlideAnim = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.35, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    _textFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.35, 0.75, curve: Curves.easeIn),
      ),
    );

    _badgeScaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.55, 0.95, curve: Curves.easeOutBack),
      ),
    );

    _badgeFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.55, 0.9, curve: Curves.easeIn),
      ),
    );

    _startFlow();
  }

  Future<void> _startFlow() async {
    // 1. Splash animatsiyasini to'liq va ravon ijro etish
    await _animController.forward();
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    // 2. Notification (bildirishnoma) ga ruxsat so'rash (Android 13+)
    try {
      final notifPlugin = FlutterLocalNotificationsPlugin();
      await notifPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (_) {}

    if (!mounted) return;

    // 3. Haydovchi uchun muhim bo'lgan GPS / Joylashuv ruxsatini tekshirish
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
    } catch (_) {}

    if (!mounted) return;

    // 4. Onboarding va Auth holatini tekshirib to'g'ri sahifaga yo'naltirish
    try {
      final storage = sl<LocalStorageService>();
      final authRepo = sl<AuthRepository>();

      if (!storage.isOnboardingCompleted()) {
        context.go('/onboarding');
        return;
      }

      final isAuthenticated = await authRepo.isAuthenticated();
      if (!mounted) return;

      if (isAuthenticated) {
        try {
          if (sl.isRegistered<DriverProfileRepository>()) {
            final profile = await sl<DriverProfileRepository>()
                .getProfile()
                .timeout(const Duration(seconds: 4));
            if (sl.isRegistered<SecureStorageService>()) {
              await sl<SecureStorageService>()
                  .saveVerificationStatus(profile.verificationStatus);
            }
          }
        } catch (_) {}

        if (!mounted) return;
        context.go('/driver/home');
      } else {
        context.go('/login');
      }
    } catch (_) {
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. Animated Logo
                AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _logoFadeAnim,
                      child: ScaleTransition(
                        scale: _logoScaleAnim,
                        child: child,
                      ),
                    );
                  },
                  child: const AppLogo(
                    size: 110,
                    showGlow: true,
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Animated Brand Text
                AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _textFadeAnim,
                      child: SlideTransition(
                        position: _textSlideAnim,
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Yo\'l',
                            style: AppTypography.displayLarge.copyWith(
                              color: const Color(0xFF111111),
                              fontWeight: FontWeight.w900,
                              fontSize: 32,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Yo\'lakay',
                            style: AppTypography.displayLarge.copyWith(
                              color: AppColors.taxiYellowDark,
                              fontWeight: FontWeight.w900,
                              fontSize: 32,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),

                // 3. Animated Driver Badge
                AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _badgeFadeAnim,
                      child: ScaleTransition(
                        scale: _badgeScaleAnim,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.taxiYellow.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.taxiYellowDark,
                        width: 1.2,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.directions_car_filled_rounded,
                          color: Color(0xFFB45309),
                          size: 15,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'HAYDOVCHI',
                          style: TextStyle(
                            color: Color(0xFFB45309),
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Subtitle
                AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _badgeFadeAnim,
                      child: child,
                    );
                  },
                  child: const Text(
                    'Haydovchilar uchun yagona platforma',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Subtle smooth animated progress line
                AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _badgeFadeAnim,
                      child: Container(
                        width: 48,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppColors.taxiYellow.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: (_animController.value).clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.taxiYellowDark,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            const Positioned(
              bottom: 40,
              child: Text(
                'v1.0.0 Driver • Professional haydovchilar tizimi',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF9CA3AF),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
