import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations_helper.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_avatar_initials.dart';
import '../../../../core/widgets/vehicle_card.dart';
import '../../../../core/widgets/logout_delete_modal.dart';
import '../../../../core/widgets/settings_modal.dart';
import '../providers/driver_provider.dart';

class DriverProfilePage extends ConsumerWidget {
  const DriverProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = ref.watch(localeNotifierProvider);
    final isRu = locale.languageCode == 'ru';
    final l10n = context.l10n;
    final driverState = ref.watch(driverNotifierProvider);
    final profile = driverState.profile;
    final vehicle = profile?.vehicle;

    final currentTheme = ref.watch(themeNotifierProvider);

    final langName = switch (locale.languageCode) {
      'uz' => '🇺🇿 O\'zbekcha',
      'ru' => '🇷🇺 Русский',
      'en' => '🇬🇧 English',
      _ => '🇺🇿 O\'zbekcha',
    };

    final themeName = switch (currentTheme) {
      ThemeMode.system => (isRu ? '🌓 Авто' : '🌓 Tizim'),
      ThemeMode.light => (isRu ? '☀️ Светлая' : '☀️ Yorug\''),
      ThemeMode.dark => (isRu ? '🌙 Тёмная' : '🌙 Qorong\'i'),
    };

    final name = profile?.fullName ?? 'Rizo Karimov';
    final phone = profile?.phoneNumber ?? '+998 90 123 45 67';
    final plateNumber = vehicle?.licensePlate ?? '01 A 777 AA';

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        top: true,
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            110, // Clearance for bottom navigation bar
          ),
          children: [
            // 1. Personal Info Unboxed Row (Avatar + Name & Phone + Edit Button)
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 4, vertical: AppSpacing.xs),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: AppColors.taxiYellow, width: 2.2),
                    ),
                    child:
                        AppAvatarInitials(name: name, size: 58, fontSize: 22),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: AppTypography.titleLarge.copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          phone,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColors.textTertiaryDark
                                : AppColors.textSecondaryLight,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // 2. Road24 style Vehicle Card (Chevy logo, Model, Side Profile, Edit pen, Uzbek plate)
            VehicleSideCard(
              make: vehicle?.make ?? 'Chevrolet',
              model: vehicle?.model ?? 'Cobalt',
              plateNumber: plateNumber,
              onEdit: () => context.push('/driver/register'),
            ),

            const SizedBox(height: AppSpacing.md),

            // 3. Unified Settings & Support Card (Til, Ko'rinish, Qo'llab-quvvatlash, Ilova haqida)
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: AppRadius.borderXl,
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
                boxShadow: isDark ? AppShadows.darkSm : AppShadows.sm,
              ),
              child: Column(
                children: [
                  // Language
                  _MenuItemTile(
                    isDark: isDark,
                    icon: Icons.language_rounded,
                    iconColor: const Color(0xFF6366F1),
                    title: l10n.language,
                    subtitle: langName,
                    onTap: () => showLanguageModal(context),
                    isTop: true,
                  ),
                  Divider(
                    height: 1,
                    indent: 54,
                    color:
                        isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),

                  // Theme / Appearance
                  _MenuItemTile(
                    isDark: isDark,
                    icon: Icons.palette_outlined,
                    iconColor: const Color(0xFFF59E0B),
                    title: l10n.theme,
                    subtitle: themeName,
                    onTap: () => showThemeModal(context),
                  ),
                  Divider(
                    height: 1,
                    indent: 54,
                    color:
                        isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),

                  // Support
                  _MenuItemTile(
                    isDark: isDark,
                    icon: Icons.headset_mic_rounded,
                    iconColor: const Color(0xFF10B981),
                    title: l10n.support,
                    onTap: () => context.push('/support'),
                  ),
                  Divider(
                    height: 1,
                    indent: 54,
                    color:
                        isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),

                  // About App
                  _MenuItemTile(
                    isDark: isDark,
                    icon: Icons.info_outline_rounded,
                    iconColor: const Color(0xFF8B5CF6),
                    title: isRu ? 'О приложении' : 'Ilova haqida',
                    trailingText: 'v1.0.0',
                    onTap: () => _showAboutAppDialog(context, isRu, isDark),
                    isBottom: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // 6. Logout & Account Actions Card
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: AppRadius.borderXl,
                border: Border.all(
                  color: AppColors.error.withValues(alpha: isDark ? 0.35 : 0.2),
                ),
                boxShadow: isDark ? AppShadows.darkSm : AppShadows.sm,
              ),
              child: ListTile(
                shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.borderXl),
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color:
                        AppColors.error.withValues(alpha: isDark ? 0.18 : 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.error,
                    size: 19,
                  ),
                ),
                title: Text(
                  l10n.logout,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.error,
                  size: 20,
                ),
                onTap: () => showLogoutDeleteAccountModal(context, ref),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutAppDialog(BuildContext context, bool isRu, bool isDark) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
              isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
          title: Text(
            isRu ? 'О приложении YolYolakay' : 'YolYolakay haqida',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          content: Text(
            isRu
                ? 'YolYolakay — современный сервис междугородних поездок и такси по городам и районам Ферганской долины (Андижан, Фергана, Наманган).\n\nВерсия: 1.0.0'
                : 'YolYolakay — Farg\'ona vodiysi (Andijon, Farg\'ona, Namangan) bo\'ylab shahar va tumanlararo qulay qatnovlar va taksi platformasi.\n\nVersiya: 1.0.0',
            style: TextStyle(
              fontSize: 13.5,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: AppColors.taxiYellowDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MenuItemTile extends StatelessWidget {
  const _MenuItemTile({
    required this.isDark,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailingText,
    this.isTop = false,
    this.isBottom = false,
  });

  final bool isDark;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final String? trailingText;
  final bool isTop;
  final bool isBottom;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: isTop ? const Radius.circular(20) : Radius.zero,
          bottom: isBottom ? const Radius.circular(20) : Radius.zero,
        ),
      ),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: isDark ? 0.18 : 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 19),
      ),
      title: Text(
        title,
        style: AppTypography.titleSmall.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 14.5,
          color:
              isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 12.5,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null) ...[
            Text(
              trailingText!,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Icon(
            Icons.chevron_right_rounded,
            color: isDark
                ? AppColors.textTertiaryDark
                : AppColors.textTertiaryLight,
            size: 20,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
