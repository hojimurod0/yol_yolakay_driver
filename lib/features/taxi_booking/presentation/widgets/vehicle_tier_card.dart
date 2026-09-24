import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/taxi_vehicle_tier.dart';

/// Authentic compact Yandex Go style vehicle tier card (Ekonom, Komfort, Biznes)
/// designed to fit perfectly side-by-side in a horizontal row.
class VehicleTierCard extends StatelessWidget {
  const VehicleTierCard({
    super.key,
    required this.tier,
    required this.isSelected,
    required this.localeCode,
    required this.onTap,
  });

  final TaxiVehicleTier tier;
  final bool isSelected;
  final String localeCode;
  final VoidCallback onTap;

  IconData _getTierIcon(VehicleTierType type) {
    switch (type) {
      case VehicleTierType.economy:
        return Icons.directions_car_filled_rounded;
      case VehicleTierType.comfort:
        return Icons.local_taxi_rounded;
      case VehicleTierType.business:
        return Icons.airport_shuttle_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRu = localeCode == 'ru';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark ? const Color(0xFF2E2A12) : const Color(0xFFFFFBEA))
            : (isDark ? const Color(0xFF1E1E26) : const Color(0xFFF6F7F9)),
        borderRadius: AppRadius.borderMd,
        border: Border.all(
          color: isSelected
              ? AppColors.yandexYellow
              : (isDark ? const Color(0xFF2C2C38) : const Color(0xFFE5E7EB)),
          width: isSelected ? 2.0 : 1.0,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.yandexYellow
                      .withValues(alpha: isDark ? 0.25 : 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.borderMd,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Car Icon + ETA Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.yandexYellow
                            : (isDark
                                ? const Color(0xFF282834)
                                : const Color(0xFFE5E7EB)),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Center(
                        child: Icon(
                          _getTierIcon(tier.type),
                          color: isSelected
                              ? AppColors.yandexBlack
                              : (isDark
                                  ? Colors.white
                                  : const Color(0xFF374151)),
                          size: 18,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF2B2B36)
                            : const Color(0xFFE5E7EB),
                        borderRadius: AppRadius.borderPill,
                      ),
                      child: Text(
                        '${tier.etaMinutes} ${isRu ? 'мин' : 'daq'}',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Middle: Tier Name
                Text(
                  tier.localizedName(localeCode),
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 2),

                // Bottom: Price
                Text(
                  AppCurrencyFormatter.format(tier.estimatedFare,
                      locale: localeCode),
                  style: TextStyle(
                    color: isSelected && !isDark
                        ? const Color(0xFF8A6500)
                        : (isDark ? Colors.white : AppColors.textPrimaryLight),
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
