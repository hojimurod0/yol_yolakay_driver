import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../providers/ride_search_provider.dart';

class RideFilterSheet extends StatefulWidget {
  const RideFilterSheet({
    super.key,
    required this.initialFilter,
    required this.onApply,
  });

  final RideSearchFilter initialFilter;
  final ValueChanged<RideSearchFilter> onApply;

  @override
  State<RideFilterSheet> createState() => _RideFilterSheetState();
}

class _RideFilterSheetState extends State<RideFilterSheet> {
  late double _maxPrice;
  late double _minRating;
  late bool _hasAc;
  late RideSortOption _sortOption;

  @override
  void initState() {
    super.initState();
    _maxPrice = (widget.initialFilter.maxPrice ?? 300000).toDouble();
    _minRating = widget.initialFilter.minRating ?? 4.0;
    _hasAc = widget.initialFilter.hasAc ?? false;
    _sortOption = widget.initialFilter.sortOption;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final localeCode = Localizations.localeOf(context).languageCode;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.filter,
                    style: AppTypography.headlineMedium.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _maxPrice = 300000;
                        _minRating = 4.0;
                        _hasAc = false;
                        _sortOption = RideSortOption.cheapest;
                      });
                    },
                    child: Text(l10n.clear),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Max Price Slider
              Text(
                '${l10n.pricePerSeat}: ${AppCurrencyFormatter.format(_maxPrice.toInt(), locale: localeCode)}',
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Slider(
                value: _maxPrice,
                min: 50000,
                max: 400000,
                divisions: 14,
                activeColor: AppColors.primary,
                label: AppCurrencyFormatter.format(_maxPrice.toInt(),
                    locale: localeCode),
                onChanged: (val) => setState(() => _maxPrice = val),
              ),

              const SizedBox(height: AppSpacing.md),

              // Minimum Driver Rating
              Text(
                '${l10n.filterRating}: ${_minRating.toStringAsFixed(1)} ★',
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Slider(
                value: _minRating,
                min: 3.5,
                max: 5.0,
                divisions: 3,
                activeColor: AppColors.starGold,
                label: _minRating.toStringAsFixed(1),
                onChanged: (val) => setState(() => _minRating = val),
              ),

              const SizedBox(height: AppSpacing.md),

              // AC Switch
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  l10n.amenityAc,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                value: _hasAc,
                onChanged: (val) => setState(() => _hasAc = val),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Apply CTA
              AppButton(
                text: l10n.apply,
                onPressed: () {
                  widget.onApply(
                    RideSearchFilter(
                      maxPrice: _maxPrice.toInt(),
                      minRating: _minRating,
                      hasAc: _hasAc ? true : null,
                      sortOption: _sortOption,
                    ),
                  );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
