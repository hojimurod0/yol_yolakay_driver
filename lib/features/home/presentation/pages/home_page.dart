import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';
import '../widgets/flippable_brand_header.dart';

import '../../../rides/domain/entities/ride_entity.dart';
import '../../../rides/presentation/providers/ride_search_provider.dart';
import '../../../rides/presentation/widgets/ride_card.dart';
import '../widgets/booking_search_card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _isRidesExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = ref.watch(localeNotifierProvider);
    final localeCode = locale.languageCode;
    final isRu = localeCode == 'ru';
    final popularRides = ref.watch(popularRidesProvider);
    final unreadNotifs = ref.watch(notificationsNotifierProvider).unreadCount;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.taxiYellowDark,
          backgroundColor:
              isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          strokeWidth: 2.8,
          displacement: 28.0,
          onRefresh: () async {
            ref.invalidate(popularRidesProvider);
            await Future.delayed(const Duration(milliseconds: 600));
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              100, // Bottom clearance for navigation
            ),
            children: [
              // 1. Top Header with "Yo'l-Yo'lakay TAXI" and Notification Bell
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FlippableBrandHeader(isDark: isDark),

                  // Notification Bell Button (Prominent & Clean)
                  InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.push('/notifications');
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                          width: 1.2,
                        ),
                        boxShadow: isDark ? AppShadows.darkSm : AppShadows.sm,
                      ),
                      child: Center(
                        child: Badge(
                          isLabelVisible: unreadNotifs > 0,
                          label: Text(
                            '$unreadNotifs',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.charcoalBlack,
                            ),
                          ),
                          backgroundColor: AppColors.taxiYellow,
                          textColor: AppColors.charcoalBlack,
                          child: Icon(
                            Icons.notifications_outlined,
                            size: 25,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 2. Search & Booking Card (Shaharlararo Qatnov & Pochta)
              const BookingSearchCard(),

              const SizedBox(height: 20),

              // 3. Available Rides Section (Reactive Live Rides / Popular Rides)
              ref.watch(rideSearchNotifierProvider).isLoading
                  ? const Column(
                      children: [
                        AppSkeletonRideCard(),
                        AppSkeletonRideCard(),
                        AppSkeletonRideCard(),
                      ],
                    )
                  : (ref
                          .watch(rideSearchNotifierProvider)
                          .filteredRides
                          .isNotEmpty
                      ? _buildRidesList(
                          title: isRu
                              ? 'Результаты поиска'
                              : 'Qidiruv natijalari (${ref.watch(rideSearchNotifierProvider).filteredRides.length} ta)',
                          rides: ref
                              .watch(rideSearchNotifierProvider)
                              .filteredRides,
                          isDark: isDark,
                          isRu: isRu,
                        )
                      : popularRides.when(
                          data: (rides) {
                            if (rides.isEmpty) return const SizedBox.shrink();
                            return _buildRidesList(
                              title: isRu
                                  ? 'Популярные поездки'
                                  : 'Bugungi qatnovlar',
                              rides: rides,
                              isDark: isDark,
                              isRu: isRu,
                            );
                          },
                          loading: () => const Column(
                            children: [
                              AppSkeletonRideCard(),
                              AppSkeletonRideCard(),
                            ],
                          ),
                          error: (_, __) => const SizedBox.shrink(),
                        )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRidesList({
    required String title,
    required List<RideEntity> rides,
    required bool isDark,
    required bool isRu,
  }) {
    final totalCount = rides.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
            if (totalCount > 1)
              InkWell(
                onTap: () {
                  setState(() {
                    _isRidesExpanded = !_isRidesExpanded;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Text(
                    _isRidesExpanded
                        ? (isRu ? 'Свернуть' : 'Yopish')
                        : (isRu
                            ? 'Все ($totalCount)'
                            : 'Barchasi ($totalCount)'),
                    style: AppTypography.labelMedium.copyWith(
                      color: isDark
                          ? AppColors.taxiYellow
                          : AppColors.charcoalBlack,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 14),

        // 1st Featured Ride (Always visible by default)
        RideCard(
          ride: rides.first,
          onTap: () =>
              context.push('/ride/${rides.first.id}', extra: rides.first),
        ),

        // Expandable remaining rides
        if (totalCount > 1) ...[
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 320),
            firstCurve: Curves.easeInOutCubic,
            secondCurve: Curves.easeInOutCubic,
            crossFadeState: _isRidesExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Column(
              children: rides.skip(1).map((ride) {
                return RideCard(
                  ride: ride,
                  onTap: () => context.push('/ride/${ride.id}', extra: ride),
                );
              }).toList(),
            ),
            secondChild: const SizedBox.shrink(),
          ),

          const SizedBox(height: 12),

          // Prominent Action Button
          InkWell(
            onTap: () {
              setState(() {
                _isRidesExpanded = !_isRidesExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isDark ? AppColors.cardBorderDark : AppColors.cardBorder,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isRidesExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: isDark ? Colors.white70 : AppColors.charcoalBlack,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isRidesExpanded
                        ? (isRu ? 'Qatnovlarni yopish' : 'Qatnovlarni yopish')
                        : (isRu
                            ? 'Показать все поездки ($totalCount)'
                            : 'Barcha qatnovlarni ko\'rish ($totalCount ta)'),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white70 : AppColors.charcoalBlack,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
