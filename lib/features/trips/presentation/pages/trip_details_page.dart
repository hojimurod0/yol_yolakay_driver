import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yol_yolakay_driver/core/localization/app_localizations_helper.dart';
import 'package:yol_yolakay_driver/core/providers/core_providers.dart';
import 'package:yol_yolakay_driver/core/theme/app_colors.dart';
import 'package:yol_yolakay_driver/core/theme/app_dimensions.dart';
import 'package:yol_yolakay_driver/core/theme/app_radius.dart';
import 'package:yol_yolakay_driver/core/theme/app_spacing.dart';
import 'package:yol_yolakay_driver/core/theme/app_typography.dart';
import 'package:yol_yolakay_driver/core/utils/currency_formatter.dart';
import 'package:yol_yolakay_driver/core/utils/cyrillic_converter.dart';
import 'package:yol_yolakay_driver/core/utils/date_time_formatter.dart';
import 'package:yol_yolakay_driver/core/utils/direct_contact_launcher.dart';
import 'package:yol_yolakay_driver/core/widgets/app_avatar_initials.dart';
import 'package:yol_yolakay_driver/core/widgets/app_button.dart';
import 'package:yol_yolakay_driver/core/widgets/app_card.dart';
import 'package:yol_yolakay_driver/core/widgets/status_badge.dart';
import 'package:yol_yolakay_driver/core/widgets/uzbek_license_plate.dart';
import 'package:yol_yolakay_driver/features/booking/domain/entities/booking_entity.dart';
import 'package:yol_yolakay_driver/features/booking/domain/repositories/booking_repository.dart';
import 'package:yol_yolakay_driver/features/trips/domain/entities/trip_entity.dart';
import 'package:yol_yolakay_driver/features/trips/presentation/providers/trips_provider.dart';
import '../widgets/cancel_dialog.dart';
import '../widgets/rating_modal.dart';

class TripDetailsPage extends ConsumerWidget {
  const TripDetailsPage({
    super.key,
    required this.trip,
  });

  final TripEntity trip;

  void _showCancelDialog(
      BuildContext context, WidgetRef ref, String localeCode) {
    showDialog(
      context: context,
      builder: (context) {
        return CancelTripDialog(
          onConfirmCancel: (reason) async {
            final bookingRepo = ref.read(bookingRepositoryProvider);
            await bookingRepo.cancelBooking(trip.booking.id, reason);
            await ref.read(tripsNotifierProvider.notifier).loadAllTrips();
            if (context.mounted) {
              final cancelMsg = localeCode == 'ru'
                  ? 'Поездка успешно отменена'
                  : 'Safar muvaffaqiyatli bekor qilindi';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(cancelMsg)),
              );
              context.pop();
            }
          },
        );
      },
    );
  }

  void _showRatingModal(
      BuildContext context, WidgetRef ref, String localeCode) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return RatingModal(
          tripId: trip.id,
          driverName: trip.booking.ride.driver.localizedName(localeCode),
          onSubmit: (rating, feedback, tags) async {
            await ref.read(tripsNotifierProvider.notifier).submitRating(
                  tripId: trip.id,
                  rating: rating,
                  feedback: feedback,
                  tags: tags,
                );
            if (context.mounted) {
              final thanksMsg = localeCode == 'ru'
                  ? 'Спасибо за ваш отзыв!'
                  : 'Fikringiz uchun rahmat!';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(thanksMsg)),
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;
    final locale = ref.watch(localeNotifierProvider);
    final localeCode = locale.languageCode;
    final booking = trip.booking;
    final ride = booking.ride;

    final depCityName = ride.departureCity.localizedName(localeCode);
    final destCityName = ride.destinationCity.localizedName(localeCode);
    final driverName = ride.driver.localizedName(localeCode);
    final carTitle = ride.vehicle.localizedFullName(localeCode);
    final carPlate = ride.vehicle.localizedLicensePlate(localeCode);
    final badgeLabel =
        CyrillicConverter.localizedBookingStatus(booking.status, localeCode);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.tripDetails,
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Booking ID & Status Card
          AppCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.bookingId,
                      style: AppTypography.labelSmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    Text(
                      booking.id,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                StatusBadge(
                  label: badgeLabel,
                  type: booking.status == BookingStatus.confirmed
                      ? StatusBadgeType.confirmed
                      : (booking.status == BookingStatus.completed
                          ? StatusBadgeType.completed
                          : (booking.status == BookingStatus.active
                              ? StatusBadgeType.inProgress
                              : StatusBadgeType.cancelled)),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Route Details Card
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$depCityName → $destCityName',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      AppCurrencyFormatter.format(booking.totalPrice,
                          locale: localeCode),
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${AppDateTimeFormatter.formatDate(ride.departureTime, locale: localeCode)} • ${AppDateTimeFormatter.formatTime(ride.departureTime)}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Divider(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        booking.pickupPoint.localizedTitle(localeCode),
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Driver & Vehicle Card
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
                      const SizedBox(height: 3),
                      UzbekLicensePlate(
                        plateNumber: carPlate,
                        height: 20,
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () {
                    DirectContactLauncher.makePhoneCall(
                      context,
                      ride.driver.phoneNumber,
                    );
                  },
                  icon:
                      const Icon(Icons.phone_rounded, color: Color(0xFF10B981)),
                  style: IconButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF10B981).withValues(alpha: 0.15),
                  ),
                ),
                if (ride.driver.telegramHandle != null) ...[
                  const SizedBox(width: 6),
                  IconButton.filledTonal(
                    onPressed: () {
                      DirectContactLauncher.openTelegram(
                        context,
                        ride.driver.telegramHandle!,
                      );
                    },
                    icon: const Icon(Icons.send_rounded,
                        color: Color(0xFF0088CC), size: 18),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF0088CC).withValues(alpha: 0.15),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Action Buttons
          if (booking.status == BookingStatus.confirmed) ...[
            AppButton(
              text: localeCode == 'ru'
                  ? 'Отслеживать на карте'
                  : 'Xaritada kuzatish',
              onPressed: () =>
                  context.push('/tracking/${trip.id}', extra: trip),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              text: l10n.cancel,
              variant: AppButtonVariant.outline,
              onPressed: () => _showCancelDialog(context, ref, localeCode),
            ),
          ],

          if (booking.status == BookingStatus.completed) ...[
            if (!trip.hasRated)
              AppButton(
                text:
                    localeCode == 'ru' ? 'Оценить поездку' : 'Safarni baholash',
                onPressed: () => _showRatingModal(context, ref, localeCode),
              )
            else
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceSubtleDark
                      : AppColors.successLight,
                  borderRadius: AppRadius.borderMd,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: AppColors.starGold),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        localeCode == 'ru'
                            ? 'Вы оценили эту поездку (${trip.rating} ★)'
                            : 'Siz ushbu safarni baholadingiz (${trip.rating} yulduz)',
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
