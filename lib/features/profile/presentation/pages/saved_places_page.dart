import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations_helper.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../domain/entities/saved_place_entity.dart';
import '../providers/profile_provider.dart';

class SavedPlacesPage extends ConsumerWidget {
  const SavedPlacesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;
    final locale = ref.watch(localeNotifierProvider);
    final localeCode = locale.languageCode;
    final state = ref.watch(profileNotifierProvider);
    final places = state.savedPlaces;

    final emptyDesc = localeCode == 'ru'
        ? 'У вас пока нет сохраненных адресов'
        : (localeCode == 'en'
            ? 'You have no saved places yet'
            : 'Sizda hali saqlangan manzillar yo\'q');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.savedPlaces,
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: places.isEmpty
          ? AppEmptyState(
              icon: Icons.bookmark_border_rounded,
              title: l10n.savedPlaces,
              description: emptyDesc,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: places.length,
              itemBuilder: (context, index) {
                final place = places[index];
                IconData icon;
                switch (place.type) {
                  case SavedPlaceType.home:
                    icon = Icons.home_rounded;
                    break;
                  case SavedPlaceType.work:
                    icon = Icons.work_rounded;
                    break;
                  case SavedPlaceType.other:
                    icon = Icons.place_rounded;
                    break;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    borderRadius: AppRadius.borderMd,
                    border: Border.all(
                      color:
                          isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                    boxShadow: isDark ? AppShadows.darkMd : AppShadows.sm,
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(AppSpacing.xs + 2),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceSubtleDark
                            : AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: AppColors.primary, size: 20),
                    ),
                    title: Text(
                      place.localizedTitle(localeCode),
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      place.localizedAddress(localeCode),
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded),
                      onPressed: () {
                        ref
                            .read(profileNotifierProvider.notifier)
                            .deleteSavedPlace(place.id);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
