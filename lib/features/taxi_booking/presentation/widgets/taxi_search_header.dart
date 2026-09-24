import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/map_location.dart';

/// Authentic Yandex Go style top search header for "Where are you going?" with autocomplete.
class TaxiSearchHeader extends StatefulWidget {
  const TaxiSearchHeader({
    super.key,
    required this.pickupLocation,
    required this.destinationLocation,
    required this.searchResults,
    required this.onSearchChanged,
    required this.onDestinationSelected,
    required this.onPickupTap,
    required this.onBackTap,
    required this.isSearching,
    required this.onClearSearch,
  });

  final MapLocation? pickupLocation;
  final MapLocation? destinationLocation;
  final List<MapLocation> searchResults;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<MapLocation> onDestinationSelected;
  final VoidCallback onPickupTap;
  final VoidCallback onBackTap;
  final bool isSearching;
  final VoidCallback onClearSearch;

  @override
  State<TaxiSearchHeader> createState() => _TaxiSearchHeaderState();
}

class _TaxiSearchHeaderState extends State<TaxiSearchHeader> {
  final TextEditingController _destinationController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void didUpdateWidget(covariant TaxiSearchHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.destinationLocation != oldWidget.destinationLocation) {
      if (widget.destinationLocation != null) {
        _destinationController.text = widget.destinationLocation!.title;
      } else {
        _destinationController.clear();
      }
    }
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localeCode = Localizations.localeOf(context).languageCode;
    final isRu = localeCode == 'ru';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main Search Bar Floating Card
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.yandexDarkSurface : Colors.white,
            borderRadius: AppRadius.borderXl,
            border: Border.all(
              color: isDark ? const Color(0xFF2A2A30) : const Color(0xFFE8E8ED),
              width: 1.0,
            ),
            boxShadow: isDark ? AppShadows.darkLg : AppShadows.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row 1: Back Button & Pickup Indicator (Green Dot)
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, AppSpacing.sm, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, size: 22),
                      onPressed: widget.onBackTap,
                      tooltip: isRu ? 'Назад' : 'Orqaga',
                    ),
                    Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        color: AppColors.yandexGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: widget.onPickupTap,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isRu
                                    ? 'Откуда (Мое местоположение)'
                                    : 'Jo\'nash joyi (Mening joylashuvim)',
                                style: AppTypography.labelSmall.copyWith(
                                  fontSize: 10,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                              Text(
                                widget.pickupLocation?.title ??
                                    (isRu
                                        ? 'Текущее местоположение'
                                        : 'Joriy GPS joylashuv'),
                                style: AppTypography.titleSmall.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Hairline Route Track Divider
              Padding(
                padding: const EdgeInsets.only(left: 48, right: AppSpacing.sm),
                child: Divider(
                  height: 1,
                  thickness: 0.8,
                  color: isDark
                      ? const Color(0xFF282830)
                      : const Color(0xFFECEEF2),
                ),
              ),

              // Row 2: Destination Search Field (Red Pin / "Куда едем?")
              Padding(
                padding: const EdgeInsets.fromLTRB(48, 2, 8, 4),
                child: Row(
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        color: AppColors.yandexRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _destinationController,
                        focusNode: _focusNode,
                        style: AppTypography.titleMedium.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: InputDecoration(
                          hintText: isRu ? 'Куда едем?' : 'Qayerga borasiz?',
                          hintStyle: AppTypography.bodyMedium.copyWith(
                            color: isDark
                                ? AppColors.textTertiaryDark
                                : AppColors.textTertiaryLight,
                            fontSize: 13.5,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 8),
                        ),
                        onChanged: widget.onSearchChanged,
                      ),
                    ),
                    if (_destinationController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          _destinationController.clear();
                          widget.onClearSearch();
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Autocomplete Search Results Dropdown Card
        if (widget.searchResults.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            constraints: const BoxConstraints(maxHeight: 240),
            decoration: BoxDecoration(
              color: isDark ? AppColors.yandexDarkSurface : Colors.white,
              borderRadius: AppRadius.borderLg,
              border: Border.all(
                color:
                    isDark ? const Color(0xFF2A2A30) : const Color(0xFFE8E8ED),
              ),
              boxShadow: isDark ? AppShadows.darkLg : AppShadows.md,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: widget.searchResults.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color:
                    isDark ? const Color(0xFF282830) : const Color(0xFFECEEF2),
              ),
              itemBuilder: (context, idx) {
                final place = widget.searchResults[idx];
                return ListTile(
                  dense: true,
                  leading: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.yandexYellow
                          .withValues(alpha: isDark ? 0.2 : 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.location_on_rounded,
                      size: 16,
                      color: isDark
                          ? AppColors.yandexYellow
                          : const Color(0xFFB38600),
                    ),
                  ),
                  title: Text(
                    place.title,
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: place.subtitle.isNotEmpty
                      ? Text(
                          place.subtitle,
                          style: AppTypography.bodySmall.copyWith(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : null,
                  onTap: () {
                    _focusNode.unfocus();
                    _destinationController.text = place.title;
                    widget.onDestinationSelected(place);
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
