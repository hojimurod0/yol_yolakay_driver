import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_localizations_helper.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/theme_cubit.dart';

/// Settings: language (radio list) and appearance (light / dark / auto cards).
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currentTag = LocaleCubit.tagOf(context.watch<LocaleCubit>().state);
    final currentTheme = context.watch<ThemeCubit>().state;

    void setLanguage(String tag) =>
        context.read<LocaleCubit>().changeLanguage(tag);
    void setTheme(ThemeMode mode) =>
        context.read<ThemeCubit>().setThemeMode(mode);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _SectionLabel(l10n.language),
          _Group(
            children: [
              _RadioRow(
                title: 'O\'zbekcha',
                subtitle: l10n.languageLatinScript,
                selected: currentTag == 'uz',
                onTap: () => setLanguage('uz'),
              ),
              _RadioRow(
                title: 'Ўзбекча',
                subtitle: l10n.languageCyrillicScript,
                selected: currentTag == 'uz_Cyrl',
                onTap: () => setLanguage('uz_Cyrl'),
              ),
              _RadioRow(
                title: 'Русский',
                subtitle: l10n.languageRussianHint,
                selected: currentTag == 'ru',
                onTap: () => setLanguage('ru'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionLabel(l10n.appearance),
          Row(
            children: [
              Expanded(
                child: _ThemeCard(
                  icon: Icons.light_mode_rounded,
                  title: l10n.themeLightShort,
                  hint: l10n.themeLightHint,
                  selected: currentTheme == ThemeMode.light,
                  onTap: () => setTheme(ThemeMode.light),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _ThemeCard(
                  icon: Icons.dark_mode_rounded,
                  title: l10n.themeDarkShort,
                  hint: l10n.themeDarkHint,
                  selected: currentTheme == ThemeMode.dark,
                  onTap: () => setTheme(ThemeMode.dark),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _ThemeCard(
                  icon: Icons.brightness_auto_rounded,
                  title: l10n.themeAuto,
                  hint: l10n.themeAutoHint,
                  selected: currentTheme == ThemeMode.system,
                  onTap: () => setTheme(ThemeMode.system),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          Center(
            child: Text(
              '${l10n.appName} • ${l10n.appVersion} 1.0.0',
              style: AppTypography.labelSmall.copyWith(
                color: _isDark(context)
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

bool _isDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.xs),
      child: Text(
        text.toUpperCase(),
        style: AppTypography.labelMedium.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: _isDark(context)
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);
    final divider = Divider(
      height: 1,
      indent: AppSpacing.md,
      endIndent: AppSpacing.md,
      color: isDark ? AppColors.borderDark : AppColors.borderLight,
    );
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) divider,
            children[i],
          ],
        ],
      ),
    );
  }
}

class _RadioRow extends StatelessWidget {
  const _RadioRow({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? AppColors.primaryHover
                        : (isDark
                            ? AppColors.borderDarkHover
                            : AppColors.borderLightHover),
                    width: selected ? 7 : 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.icon,
    required this.title,
    required this.hint,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String hint;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);
    final ink = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    return Semantics(
      button: true,
      selected: selected,
      label: '$title, $hint',
      excludeSemantics: true,
      child: Material(
        color: selected
            ? (isDark
                ? AppColors.primary.withValues(alpha: 0.14)
                : AppColors.primaryLight)
            : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderLg,
          side: BorderSide(
            color: selected
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: selected ? 2 : 1.5,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          customBorder:
              const RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.sm,
              horizontal: AppSpacing.xxs,
            ),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? AppColors.primary
                        : (isDark
                            ? AppColors.surfaceSubtleDark
                            : AppColors.surfaceSubtleLight),
                  ),
                  child: Icon(
                    icon,
                    size: 22,
                    color: selected ? AppColors.textPrimaryLight : ink,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  title,
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: ink,
                  ),
                ),
                Text(
                  hint,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelSmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
