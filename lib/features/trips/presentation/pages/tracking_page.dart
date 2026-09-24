import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations_helper.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/direct_contact_launcher.dart';
import '../../../../core/widgets/app_avatar_initials.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/uzbek_license_plate.dart';
import '../../domain/entities/trip_entity.dart';
import '../providers/trips_provider.dart';
import '../widgets/map_widget.dart';
import '../widgets/route_timeline_widget.dart';

class TrackingPage extends ConsumerWidget {
  const TrackingPage({
    super.key,
    required this.tripId,
    this.initialTrip,
  });

  final String tripId;
  final TripEntity? initialTrip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;
    final locale = ref.watch(localeNotifierProvider);
    final localeCode = locale.languageCode;
    final stream = ref.watch(activeTripTrackingStreamProvider(tripId));

    final trip = stream.value ?? initialTrip;

    if (trip == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.trackingTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final booking = trip.booking;
    final ride = booking.ride;
    final driverName = ride.driver.localizedName(localeCode);
    final carTitle = ride.vehicle.localizedFullName(localeCode);
    final carPlate = ride.vehicle.localizedLicensePlate(localeCode);
    final pickupTitle = booking.pickupPoint.localizedTitle(localeCode);
    final destTitle = ride.destinationCity.localizedName(localeCode);

    final tripProgressHeader = localeCode == 'ru'
        ? 'Статус поездки'
        : (localeCode == 'en' ? 'Trip Progress' : 'Safar holati');

    final linkSharedMsg = localeCode == 'ru'
        ? 'Ссылка на поездку отправлена близким'
        : (localeCode == 'en'
            ? 'Trip link shared with your contacts'
            : 'Safar havolasi yaqinlaringizga yuborildi');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.trackingTitle,
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: Column(
        children: [
          // Live Map Area
          MapWidget(
            driverLat: trip.currentDriverLat,
            driverLng: trip.currentDriverLng,
            pickupTitle: pickupTitle,
            destinationTitle: destTitle,
            remainingMinutes: trip.estimatedArrivalRemainingMinutes,
            height: 260,
          ),

          // Scrollable Trip Progress Sheet
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                // Driver Quick Call Bar
                AppCard(
                  child: Row(
                    children: [
                      AppAvatarInitials(
                        name: driverName,
                        size: AppDimensions.avatarMd,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              driverName,
                              style: AppTypography.titleSmall.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              carTitle,
                              style: AppTypography.bodySmall.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                            const SizedBox(height: 2),
                            UzbekLicensePlate(
                              plateNumber: carPlate,
                              height: 18,
                            ),
                          ],
                        ),
                      ),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                        ),
                        onPressed: () {
                          DirectContactLauncher.makePhoneCall(
                            context,
                            ride.driver.phoneNumber,
                          );
                        },
                        icon: const Icon(Icons.phone_rounded,
                            color: Colors.white),
                      ),
                      if (ride.driver.telegramHandle != null) ...[
                        const SizedBox(width: 6),
                        IconButton.filled(
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF0088CC),
                          ),
                          onPressed: () {
                            DirectContactLauncher.openTelegram(
                              context,
                              ride.driver.telegramHandle!,
                            );
                          },
                          icon: const Icon(Icons.send_rounded,
                              color: Colors.white, size: 18),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                Text(
                  tripProgressHeader,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // 7-Stage Status Timeline
                RouteTimelineWidget(currentStatus: trip.progressStatus),

                const SizedBox(height: AppSpacing.lg),

                // Share Trip CTA
                AppButton(
                  text: l10n.shareTrip,
                  variant: AppButtonVariant.secondary,
                  leadingIcon: const Icon(Icons.share_rounded, size: 20),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(linkSharedMsg),
                      ),
                    );
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
