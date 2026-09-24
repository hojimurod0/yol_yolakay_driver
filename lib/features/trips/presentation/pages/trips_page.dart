import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yol_yolakay_driver/core/localization/app_localizations_helper.dart';
import 'package:yol_yolakay_driver/core/theme/app_colors.dart';
import 'package:yol_yolakay_driver/core/theme/app_radius.dart';
import 'package:yol_yolakay_driver/core/theme/app_shadows.dart';
import 'package:yol_yolakay_driver/core/theme/app_spacing.dart';
import 'package:yol_yolakay_driver/core/theme/app_typography.dart';
import 'package:yol_yolakay_driver/core/utils/currency_formatter.dart';
import 'package:yol_yolakay_driver/core/utils/cyrillic_converter.dart';
import 'package:yol_yolakay_driver/core/utils/date_time_formatter.dart';
import 'package:yol_yolakay_driver/core/widgets/app_avatar_initials.dart';
import 'package:yol_yolakay_driver/core/widgets/app_empty_state.dart';
import 'package:yol_yolakay_driver/core/widgets/app_loading.dart';
import 'package:yol_yolakay_driver/core/widgets/status_badge.dart';
import 'package:yol_yolakay_driver/features/booking/domain/entities/booking_entity.dart';
import 'package:yol_yolakay_driver/features/trips/domain/entities/trip_entity.dart';
import 'package:yol_yolakay_driver/features/trips/presentation/providers/trips_provider.dart';

class TripsPage extends ConsumerWidget {
  const TripsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;
    final tripsState = ref.watch(tripsNotifierProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor:
              isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          elevation: 0,
          title: Text(
            l10n.navTrips,
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.w800,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Yangilash',
              onPressed: () {
                ref.read(tripsNotifierProvider.notifier).loadAllTrips();
              },
            ),
          ],
          bottom: TabBar(
            isScrollable: false,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelColor: AppColors.primary,
            unselectedLabelColor: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
            labelStyle: AppTypography.titleSmall.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 13.5,
            ),
            unselectedLabelStyle: AppTypography.titleSmall.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
            ),
            tabs: [
              Tab(text: l10n.tabActive),
              Tab(text: l10n.tabCompleted),
              Tab(text: l10n.tabCancelled),
            ],
          ),
        ),
        body: tripsState.isLoading
            ? ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.xl,
                ),
                itemCount: 4,
                itemBuilder: (_, __) => const AppSkeletonRideCard(),
              )
            : TabBarView(
                children: [
                  // 1. Active Trips (includes ongoing + confirmed)
                  _buildTripList(
                    context,
                    ref,
                    [...tripsState.activeTrips, ...tripsState.upcomingTrips],
                    l10n.noTripsTitle,
                    l10n.noTripsDesc,
                    true,
                  ),
                  // 2. Completed Trips
                  _buildTripList(
                    context,
                    ref,
                    tripsState.completedTrips,
                    l10n.noTripsTitle,
                    l10n.noTripsDesc,
                    false,
                  ),
                  // 3. Cancelled Trips
                  _buildTripList(
                    context,
                    ref,
                    tripsState.cancelledTrips,
                    l10n.noTripsTitle,
                    l10n.noTripsDesc,
                    false,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTripList(
    BuildContext context,
    WidgetRef ref,
    List<TripEntity> trips,
    String emptyTitle,
    String emptyDesc,
    bool isActiveTab,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (trips.isEmpty) {
      return AppEmptyState(
        icon: Icons.directions_car_outlined,
        title: emptyTitle,
        description: emptyDesc,
      );
    }

    final localeCode = Localizations.localeOf(context).languageCode;
    final isRu = localeCode == 'ru';

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        90,
      ),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final trip = trips[index];
        final booking = trip.booking;
        final ride = booking.ride;

        StatusBadgeType badgeType;
        switch (booking.status) {
          case BookingStatus.active:
            badgeType = StatusBadgeType.inProgress;
            break;
          case BookingStatus.confirmed:
            badgeType = StatusBadgeType.confirmed;
            break;
          case BookingStatus.completed:
            badgeType = StatusBadgeType.completed;
            break;
          case BookingStatus.cancelled:
            badgeType = StatusBadgeType.cancelled;
            break;
        }

        final badgeLabel = CyrillicConverter.localizedBookingStatus(
            booking.status, localeCode);
        final depCity = ride.departureCity.localizedName(localeCode);
        final destCity = ride.destinationCity.localizedName(localeCode);
        final driverName = ride.driver.localizedName(localeCode);
        final carTitle = ride.vehicle.localizedFullName(localeCode);

        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: AppRadius.borderLg,
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
            boxShadow: isDark ? AppShadows.darkSm : AppShadows.sm,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                context.push('/trip/${trip.id}', extra: trip);
              },
              borderRadius: AppRadius.borderLg,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Date & Status Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 14,
                              color: Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              AppDateTimeFormatter.formatDate(
                                  ride.departureTime),
                              style: AppTypography.labelMedium.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        StatusBadge(
                          type: badgeType,
                          label: badgeLabel,
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.sm + 4),

                    // Route: Departure -> Destination
                    Row(
                      children: [
                        // Vertical dot-line-dot indicator
                        Column(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Container(
                              width: 1.5,
                              height: 22,
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight,
                            ),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF59E0B),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: AppSpacing.sm + 4),

                        // City names and times
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      depCity,
                                      style: AppTypography.titleMedium.copyWith(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                        color: isDark
                                            ? AppColors.textPrimaryDark
                                            : AppColors.textPrimaryLight,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    AppDateTimeFormatter.formatTime(
                                        ride.departureTime),
                                    style: AppTypography.titleSmall.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      destCity,
                                      style: AppTypography.titleMedium.copyWith(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                        color: isDark
                                            ? AppColors.textPrimaryDark
                                            : AppColors.textPrimaryLight,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    AppDateTimeFormatter.formatTime(
                                        ride.estimatedArrivalTime),
                                    style: AppTypography.titleSmall.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.sm + 4),
                    Divider(
                      height: 1,
                      color:
                          isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                    const SizedBox(height: AppSpacing.sm + 2),

                    // Driver info and Total Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              AppAvatarInitials(
                                name: driverName,
                                size: 32,
                                fontSize: 12,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      driverName,
                                      style: AppTypography.titleSmall.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? AppColors.textPrimaryDark
                                            : AppColors.textPrimaryLight,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      carTitle,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondaryLight,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              AppCurrencyFormatter.format(booking.totalPrice,
                                  locale: localeCode),
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w900,
                                color: isDark
                                    ? AppColors.taxiYellow
                                    : AppColors.charcoalBlack,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              isRu
                                  ? '${booking.seatCount} места'
                                  : '${booking.seatCount} ta joy',
                              style: AppTypography.labelSmall.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Tracking CTA if trip is active
                    if (booking.status == BookingStatus.active) ...[
                      const SizedBox(height: AppSpacing.sm + 4),
                      SizedBox(
                        width: double.infinity,
                        height: 38,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            context.push('/trip/${trip.id}/tracking',
                                extra: trip);
                          },
                          icon: const Icon(
                            Icons.navigation_outlined,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          label: Text(
                            isRu ? 'Отследить на карте' : 'Xaritada kuzatish',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.primary,
                            ),
                            shape: const RoundedRectangleBorder(
                              borderRadius: AppRadius.borderMd,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
