import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../localization/app_localizations_helper.dart';
import '../localization/locale_cubit.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/theme_cubit.dart';

/// Opens dedicated Language Selection Modal Bottom Sheet.
Future<void> showLanguageModal(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (modalCtx) {
      return const _LanguageModalContent();
    },
  );
}

/// Opens dedicated Theme / Display Mode Selection Modal Bottom Sheet.
Future<void> showThemeModal(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (modalCtx) {
      return const _ThemeModalContent();
    },
  );
}

class _LanguageModalContent extends StatelessWidget {
  const _LanguageModalContent();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;
    final currentLocale = context.watch<LocaleCubit>().state;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppRadius.topXl,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        MediaQuery.of(context).padding.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.borderDarkHover
                    : const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Modal Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1)
                          .withValues(alpha: isDark ? 0.2 : 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.language_rounded,
                      color: Color(0xFF6366F1),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    l10n.language,
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, size: 20),
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceSubtleDark
                  : const Color(0xFFF9FAFB),
              borderRadius: AppRadius.borderLg,
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Column(
              children: [
                _OptionTile(
                  iconText: '🇺🇿',
                  title: 'O\'zbekcha',
                  subtitle: 'O\'zbek tili (Lotin)',
                  isSelected: currentLocale.languageCode == 'uz',
                  isDark: isDark,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    context.read<LocaleCubit>().changeLanguage('uz');
                    Navigator.pop(context);
                  },
                ),
                Divider(
                  height: 1,
                  indent: 52,
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
                _OptionTile(
                  iconText: '🇷🇺',
                  title: 'Русский',
                  subtitle: 'Русский язык',
                  isSelected: currentLocale.languageCode == 'ru',
                  isDark: isDark,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    context.read<LocaleCubit>().changeLanguage('ru');
                    Navigator.pop(context);
                  },
                ),
                Divider(
                  height: 1,
                  indent: 52,
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
                _OptionTile(
                  iconText: '🇬🇧',
                  title: 'English',
                  subtitle: 'English language',
                  isSelected: currentLocale.languageCode == 'en',
                  isDark: isDark,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    context.read<LocaleCubit>().changeLanguage('en');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeModalContent extends StatelessWidget {
  const _ThemeModalContent();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;
    final currentTheme = context.watch<ThemeCubit>().state;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppRadius.topXl,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        MediaQuery.of(context).padding.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.borderDarkHover
                    : const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Modal Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B)
                          .withValues(alpha: isDark ? 0.2 : 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.palette_outlined,
                      color: Color(0xFFF59E0B),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    l10n.theme,
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, size: 20),
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceSubtleDark
                  : const Color(0xFFF9FAFB),
              borderRadius: AppRadius.borderLg,
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Column(
              children: [
                _OptionTile(
                  iconData: Icons.light_mode_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  title: l10n.themeLight,
                  subtitle: l10n.themeLightDesc,
                  isSelected: currentTheme == ThemeMode.light,
                  isDark: isDark,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    context.read<ThemeCubit>().setThemeMode(ThemeMode.light);
                    Navigator.pop(context);
                  },
                ),
                Divider(
                  height: 1,
                  indent: 52,
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
                _OptionTile(
                  iconData: Icons.dark_mode_rounded,
                  iconColor: const Color(0xFF8B5CF6),
                  title: l10n.themeDark,
                  subtitle: l10n.themeDarkDesc,
                  isSelected: currentTheme == ThemeMode.dark,
                  isDark: isDark,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    context.read<ThemeCubit>().setThemeMode(ThemeMode.dark);
                    Navigator.pop(context);
                  },
                ),
                Divider(
                  height: 1,
                  indent: 52,
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
                _OptionTile(
                  iconData: Icons.brightness_auto_rounded,
                  iconColor: const Color(0xFF6366F1),
                  title: l10n.themeSystem,
                  subtitle: l10n.themeSystemDesc,
                  isSelected: currentTheme == ThemeMode.system,
                  isDark: isDark,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    context.read<ThemeCubit>().setThemeMode(ThemeMode.system);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    this.iconText,
    this.iconData,
    this.iconColor,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final String? iconText;
  final IconData? iconData;
  final Color? iconColor;
  final String title;
  final String subtitle;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: iconText != null
          ? Text(iconText!, style: const TextStyle(fontSize: 22))
          : Icon(
              iconData,
              color: iconColor ??
                  (isDark ? Colors.white : AppColors.charcoalBlack),
              size: 22,
            ),
      title: Text(
        title,
        style: AppTypography.titleSmall.copyWith(
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          fontSize: 14.5,
          color: isSelected
              ? AppColors.taxiYellowDark
              : (isDark ? Colors.white : AppColors.textPrimaryLight),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.bodySmall.copyWith(
          fontSize: 11.5,
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      ),
      trailing: isSelected
          ? Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: AppColors.taxiYellow,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppColors.charcoalBlack,
                size: 14,
              ),
            )
          : null,
    );
  }
}
