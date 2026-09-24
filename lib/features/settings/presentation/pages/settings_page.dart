import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations_helper.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;
    final currentLocale = ref.watch(localeNotifierProvider);
    final currentTheme = ref.watch(themeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Language Settings Section
          Text(
            l10n.language,
            style: AppTypography.titleSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: AppRadius.borderLg,
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
              boxShadow: isDark ? AppShadows.darkMd : AppShadows.sm,
            ),
            child: Column(
              children: [
                _buildOptionTile(
                  icon: '🇺🇿',
                  title: 'O\'zbekcha',
                  subtitle: 'O\'zbek tili (Lotin)',
                  isSelected: currentLocale.languageCode == 'uz',
                  onTap: () =>
                      ref.read(localeNotifierProvider.notifier).setLocale('uz'),
                  isDark: isDark,
                  isFirst: true,
                ),
                Divider(
                  height: 1,
                  indent: 52,
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
                _buildOptionTile(
                  icon: '🇷🇺',
                  title: 'Русский',
                  subtitle: 'Русский язык',
                  isSelected: currentLocale.languageCode == 'ru',
                  onTap: () =>
                      ref.read(localeNotifierProvider.notifier).setLocale('ru'),
                  isDark: isDark,
                ),
                Divider(
                  height: 1,
                  indent: 52,
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
                _buildOptionTile(
                  icon: '🇬🇧',
                  title: 'English',
                  subtitle: 'English language',
                  isSelected: currentLocale.languageCode == 'en',
                  onTap: () =>
                      ref.read(localeNotifierProvider.notifier).setLocale('en'),
                  isDark: isDark,
                  isLast: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Theme Settings Section
          Text(
            l10n.theme,
            style: AppTypography.titleSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: AppRadius.borderLg,
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
              boxShadow: isDark ? AppShadows.darkMd : AppShadows.sm,
            ),
            child: Column(
              children: [
                _buildOptionTile(
                  iconWidget: const Icon(
                    Icons.brightness_auto_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  title: l10n.themeSystem,
                  subtitle: l10n.themeSystemDesc,
                  isSelected: currentTheme == ThemeMode.system,
                  onTap: () => ref
                      .read(themeNotifierProvider.notifier)
                      .setThemeMode(ThemeMode.system),
                  isDark: isDark,
                  isFirst: true,
                ),
                Divider(
                  height: 1,
                  indent: 52,
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
                _buildOptionTile(
                  iconWidget: const Icon(
                    Icons.light_mode_rounded,
                    color: AppColors.warning,
                    size: 22,
                  ),
                  title: l10n.themeLight,
                  subtitle: l10n.themeLightDesc,
                  isSelected: currentTheme == ThemeMode.light,
                  onTap: () => ref
                      .read(themeNotifierProvider.notifier)
                      .setThemeMode(ThemeMode.light),
                  isDark: isDark,
                ),
                Divider(
                  height: 1,
                  indent: 52,
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
                _buildOptionTile(
                  iconWidget: const Icon(
                    Icons.dark_mode_rounded,
                    color: AppColors.secondary,
                    size: 22,
                  ),
                  title: l10n.themeDark,
                  subtitle: l10n.themeDarkDesc,
                  isSelected: currentTheme == ThemeMode.dark,
                  onTap: () => ref
                      .read(themeNotifierProvider.notifier)
                      .setThemeMode(ThemeMode.dark),
                  isDark: isDark,
                  isLast: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          // App Version Footer
          Center(
            child: Text(
              '${l10n.appName} • ${l10n.appVersion} 1.0.0',
              style: AppTypography.labelSmall.copyWith(
                color: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    String? icon,
    Widget? iconWidget,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(16) : Radius.zero,
        bottom: isLast ? const Radius.circular(16) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceSubtleDark
                    : AppColors.surfaceSubtleLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: iconWidget ??
                    Text(
                      icon ?? '',
                      style: const TextStyle(fontSize: 18),
                    ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? AppColors.borderDark : AppColors.borderLight),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
