import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/entities/taxi_route.dart';
import '../../domain/entities/taxi_vehicle_tier.dart';
import 'vehicle_tier_card.dart';

/// Authentic Yandex Go style Compact Bottom Sheet for Taxi Tier Selection & Ordering.
/// Sits sleekly at the bottom of the screen to preserve map visibility.
class TaxiBottomSheet extends StatelessWidget {
  const TaxiBottomSheet({
    super.key,
    required this.route,
    required this.vehicleTiers,
    required this.selectedTierType,
    required this.localeCode,
    required this.onTierSelected,
    required this.onOrderTaxi,
    required this.isLoading,
  });

  final TaxiRoute route;
  final List<TaxiVehicleTier> vehicleTiers;
  final VehicleTierType selectedTierType;
  final String localeCode;
  final ValueChanged<VehicleTierType> onTierSelected;
  final VoidCallback onOrderTaxi;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRu = localeCode == 'ru';

    final orderButtonText = isRu
        ? 'Заказать такси'
        : (localeCode == 'en' ? 'Order Taxi' : 'Taksi chaqirish');

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16161C) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: isDark ? AppShadows.darkLg : AppShadows.lg,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF282832) : const Color(0xFFE5E7EB),
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle bar
            Center(
              child: Container(
                width: 36,
                height: 3.5,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF383844)
                      : const Color(0xFFD0D0D8),
                  borderRadius: AppRadius.borderPill,
                ),
              ),
            ),

            const SizedBox(height: 6),

            // Route Distance & Estimated Travel Time Badge Row
            Row(
              children: [
                // Distance Chip
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF222228)
                        : const Color(0xFFF2F3F7),
                    borderRadius: AppRadius.borderPill,
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF33333C)
                          : const Color(0xFFE0E2E8),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.route_rounded,
                          size: 12, color: AppColors.yandexGreen),
                      const SizedBox(width: 4),
                      Text(
                        route.formattedDistance,
                        style: AppTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 10.5,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 6),

                // Duration Chip
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.yandexYellow
                        .withValues(alpha: isDark ? 0.2 : 0.15),
                    borderRadius: AppRadius.borderPill,
                    border: Border.all(
                      color: AppColors.yandexYellow.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 12,
                        color: isDark
                            ? AppColors.yandexYellow
                            : const Color(0xFF9E7700),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        route.formattedDuration,
                        style: AppTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 10.5,
                          color: isDark
                              ? AppColors.yandexYellow
                              : const Color(0xFF9E7700),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Recommended Route Text
                Expanded(
                  child: Text(
                    route.recommendedRoute,
                    style: AppTypography.labelSmall.copyWith(
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiaryLight,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Vehicle Tier Cards: Compact Horizontal 3-in-a-row Row
            Row(
              children: vehicleTiers.map((tier) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: VehicleTierCard(
                      tier: tier,
                      isSelected: tier.type == selectedTierType,
                      localeCode: localeCode,
                      onTap: () => onTierSelected(tier.type),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 8),

            // Yandex Quick Options (Payment method & Wishes in slim row)
            Row(
              children: [
                // Payment method chip
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E1E26)
                          : const Color(0xFFF4F5F8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF2B2B34)
                            : const Color(0xFFE2E4E9),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.payments_rounded,
                            size: 14, color: AppColors.yandexGreen),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            isRu ? 'Наличные' : 'Naqd pul',
                            style: AppTypography.labelSmall.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 6),

                // Comments / Wishes chip
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E1E26)
                          : const Color(0xFFF4F5F8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF2B2B34)
                            : const Color(0xFFE2E4E9),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 13,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            isRu ? 'Пожелания' : 'Izoh / Tilak',
                            style: AppTypography.labelSmall.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Big Yellow Taxi CTA Button
            AppButton(
              text: orderButtonText,
              variant: AppButtonVariant.taxi,
              isLoading: isLoading,
              height: 46,
              leadingIcon: const Icon(Icons.local_taxi_rounded, size: 19),
              onPressed: onOrderTaxi,
            ),
          ],
        ),
      ),
    );
  }
}
