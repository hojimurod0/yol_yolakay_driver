import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/localization/app_localizations_helper.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/widgets/settings_modal.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currentLocale = context.watch<LocaleCubit>().state;
    final currentTheme = context.watch<ThemeCubit>().state;

    final langName = switch (currentLocale.languageCode) {
      'uz' => 'O\'zbekcha',
      'ru' => 'Русский',
      'en' => 'English',
      _ => 'O\'zbekcha',
    };

    final themeName = switch (currentTheme) {
      ThemeMode.system => l10n.themeSystem,
      ThemeMode.light => l10n.themeLight,
      ThemeMode.dark => l10n.themeDark,
    };

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
          ListTile(
            leading: const Icon(Icons.language_rounded, color: AppColors.taxiYellowDark),
            title: Text(l10n.language),
            subtitle: Text(langName),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => showLanguageModal(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.palette_outlined, color: AppColors.taxiYellowDark),
            title: Text(l10n.theme),
            subtitle: Text(themeName),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => showThemeModal(context),
          ),
        ],
      ),
    );
  }
}
