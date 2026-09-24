import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yol_yolakay_driver/core/localization/app_localizations_helper.dart';
import 'package:yol_yolakay_driver/core/theme/app_colors.dart';
import 'package:yol_yolakay_driver/core/theme/app_radius.dart';
import 'package:yol_yolakay_driver/core/utils/currency_formatter.dart';
import 'package:yol_yolakay_driver/core/utils/date_time_formatter.dart';
import 'package:yol_yolakay_driver/core/widgets/app_avatar_initials.dart';
import '../../domain/entities/ride_entity.dart';

/// Clean, structured, highly-readable Ride Card with clear route, driver profile, and pricing.
class RideCard extends StatelessWidget {
  const RideCard({
    super.key,
    required this.ride,
    required this.onTap,
  });

  final RideEntity ride;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;
    final localeCode = Localizations.localeOf(context).languageCode;
    final isRu = localeCode == 'ru';

    final depCity = ride.departureCity.localizedName(localeCode);
    final destCity = ride.destinationCity.localizedName(localeCode);
    final driverName = ride.driver.localizedName(localeCode);
    final carTitle = ride.vehicle.localizedFullName(localeCode);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: isDark ? const Color(0xFF282834) : const Color(0xFFE2E4E8),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.borderLg,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header: Date Chip & Price per seat
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF242430)
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 13,
                            color: AppColors.taxiYellowDark,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            DateFormat('dd MMM, HH:mm', isRu ? 'ru' : 'uz')
                                .format(ride.departureTime),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white70
                                  : AppColors.charcoalBlack,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${AppCurrencyFormatter.format(ride.pricePerSeat, locale: localeCode)} / o‘rin',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900,
                        color: isDark
                            ? AppColors.taxiYellow
                            : AppColors.charcoalBlack,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // 2. Route Timeline (Clear Departure ➔ Destination)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dot-Line-Dot Indicator
                    Column(
                      children: [
                        const SizedBox(height: 3),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 2,
                          height: 26,
                          color: isDark ? Colors.white24 : Colors.black12,
                        ),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),

                    // City names & Time
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Departure Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  depCity,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.charcoalBlack,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                AppDateTimeFormatter.formatTime(
                                    ride.departureTime),
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: isDark
                                      ? Colors.white70
                                      : AppColors.charcoalBlack,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Destination Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  destCity,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.charcoalBlack,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                AppDateTimeFormatter.formatTime(
                                    ride.estimatedArrivalTime),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color:
                                      isDark ? Colors.white54 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Divider(
                  height: 1,
                  color: isDark
                      ? const Color(0xFF282834)
                      : const Color(0xFFE5E7EB),
                ),
                const SizedBox(height: 10),

                // 3. Driver Profile & Quick Contact Section
                Row(
                  children: [
                    // Driver Avatar
                    AppAvatarInitials(
                      name: driverName,
                      size: 34,
                      fontSize: 13,
                    ),
                    const SizedBox(width: 9),

                    // Driver Name & Car Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            driverName,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.charcoalBlack,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$carTitle • ${l10n.seatsAvailable(ride.availableSeats, ride.totalSeats)}',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white54
                                  : AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: isDark ? Colors.white38 : Colors.black26,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
