import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../driver/presentation/providers/driver_provider.dart';

class RoleSelectPage extends ConsumerStatefulWidget {
  const RoleSelectPage({super.key});

  @override
  ConsumerState<RoleSelectPage> createState() => _RoleSelectPageState();
}

class _RoleSelectPageState extends ConsumerState<RoleSelectPage> {
  AppUserRole _selectedRole = AppUserRole.passenger;

  void _onRoleSelected(AppUserRole role) {
    HapticFeedback.selectionClick();
    setState(() => _selectedRole = role);
  }

  void _handleContinue() {
    HapticFeedback.mediumImpact();
    ref.read(driverNotifierProvider.notifier).switchRole(_selectedRole);

    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setBool('is_role_selected', true);
    prefs.setString('app_user_role',
        _selectedRole == AppUserRole.driver ? 'driver' : 'passenger');

    if (_selectedRole == AppUserRole.passenger) {
      context.go('/home');
    } else {
      // Driver flow: check if vehicle profile is already filled
      final driverState = ref.read(driverNotifierProvider);
      if (driverState.profile == null ||
          driverState.profile!.vehicle.licensePlate.isEmpty) {
        context.go('/driver/register');
      } else {
        context.go('/driver/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = ref.watch(localeNotifierProvider);
    final localeCode = locale.languageCode;
    final isRu = localeCode == 'ru';
    final isEn = localeCode == 'en';

    final title = isRu
        ? 'Как вы будете использовать приложение?'
        : (isEn
            ? 'How will you use the app?'
            : 'Ilovadan qanday maqsadda foydalanasiz?');

    final subtitle = isRu
        ? 'Выберите режим пассажира для поездок или водителя для заработка'
        : (isEn
            ? 'Choose passenger mode to travel or driver mode to earn'
            : 'Safar qilish uchun Yo\'lovchi, daromad topish uchun Haydovchi rejimini tanlang');

    final passengerTitle =
        isRu ? 'Пассажир' : (isEn ? 'Passenger' : 'Yo\'lovchi');
    final driverTitle = isRu ? 'Водитель' : (isEn ? 'Driver' : 'Haydovchi');
    final continueBtn =
        isRu ? 'Продолжить' : (isEn ? 'Continue' : 'Davom etish');

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // Minimal Logo
              const AppLogo(size: 64, showGlow: false),

              const SizedBox(height: 16),

              // Title
              Text(
                title,
                style: AppTypography.displayMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: isDark ? Colors.white : AppColors.charcoalBlack,
                  letterSpacing: -0.3,
                  height: 1.25,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 6),

              // Subtitle
              Text(
                subtitle,
                style: AppTypography.bodySmall.copyWith(
                  color: isDark ? Colors.white60 : AppColors.textSecondary,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 28),

              // Role Cards
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // 1. Passenger Option Card
                    _buildRoleCard(
                      role: AppUserRole.passenger,
                      isSelected: _selectedRole == AppUserRole.passenger,
                      icon: Icons.person_pin_circle_rounded,
                      title: passengerTitle,
                      isDark: isDark,
                    ),

                    const SizedBox(height: 14),

                    // 2. Driver Option Card
                    _buildRoleCard(
                      role: AppUserRole.driver,
                      isSelected: _selectedRole == AppUserRole.driver,
                      icon: Icons.local_taxi_rounded,
                      title: driverTitle,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Continue Action Button
              AppButton(
                text: continueBtn,
                trailingIcon: const Icon(Icons.arrow_forward_rounded,
                    color: AppColors.charcoalBlack, size: 18),
                onPressed: _handleContinue,
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required AppUserRole role,
    required bool isSelected,
    required IconData icon,
    required String title,
    required bool isDark,
  }) {
    final cardBg = isSelected
        ? (isDark ? const Color(0xFF221F14) : const Color(0xFFFFFDF5))
        : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight);

    final borderColor = isSelected
        ? AppColors.taxiYellowDark
        : (isDark ? AppColors.cardBorderDark : AppColors.cardBorder);

    return InkWell(
      onTap: () => _onRoleSelected(role),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.taxiYellow.withValues(alpha: 0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Icon Box
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.taxiYellow.withValues(alpha: 0.22)
                    : (isDark ? Colors.white10 : AppColors.gray100),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? AppColors.charcoalBlack
                    : (isDark ? Colors.white70 : AppColors.textSecondary),
                size: 26,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Text(
                title,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16.5,
                  color: isDark ? Colors.white : AppColors.charcoalBlack,
                ),
              ),
            ),

            // Selected Radio Indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.taxiYellow : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.taxiYellowDark
                      : (isDark ? Colors.white30 : AppColors.gray400),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 15,
                      color: AppColors.charcoalBlack,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
