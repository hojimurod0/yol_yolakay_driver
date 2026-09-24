import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations_helper.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_logo.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() {
    _navTimer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      final prefs = ref.read(sharedPreferencesProvider);
      final storage = ref.read(localStorageServiceProvider);

      final hasSelectedLanguage =
          prefs.getBool('has_selected_language') ?? false;
      if (!hasSelectedLanguage) {
        context.go('/language-select');
        return;
      }

      final isFirstLaunch = (prefs.getBool('is_first_launch') ?? true) &&
          !storage.isOnboardingCompleted();
      if (isFirstLaunch) {
        context.go('/onboarding');
        return;
      }

      // Direct launch to passenger home - no role selection prompt
      context.go('/home');
    });
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF111111),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Center Branding Section (Clean static display, no bouncing/pulsing/spinning animations)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppLogo(
                  size: 110,
                  showGlow: false,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Yo\'l',
                      style: AppTypography.displayLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 32,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Yo\'lakay',
                      style: AppTypography.displayLarge.copyWith(
                        color: AppColors.taxiYellow,
                        fontWeight: FontWeight.w900,
                        fontSize: 32,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Text(
                    l10n.appTagline,
                    style: AppTypography.bodyMedium.copyWith(
                      color: const Color(0xFFE2E8F0),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),

            // Bottom Version Tag
            Positioned(
              bottom: 40,
              child: Text(
                'v1.0.0 • O\'zbekiston bo\'ylab qulay safarlar',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.45),
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
