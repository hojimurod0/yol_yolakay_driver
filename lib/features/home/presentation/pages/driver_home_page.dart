import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/no_internet_widget.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/home_dashboard_entity.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const LoadHomeDashboardEvent());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.taxiYellow.withOpacity(0.2),
              ),
              child: const Icon(
                Icons.local_taxi_rounded,
                size: 20,
                color: AppColors.taxiYellowDark,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              l10n.homeTitle,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 17,
                color: isDark ? Colors.white : AppColors.charcoalBlack,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              context.read<HomeBloc>().add(const LoadHomeDashboardEvent());
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: l10n.refresh,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: isDark ? const Color(0xFF2C2C38) : const Color(0xFFE5E7EB),
            height: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state is HomeError && !state.isNoInternet) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is HomeLoading) {
              return const Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: HomeStatsShimmer(),
              );
            }

            if (state is HomeError && state.isNoInternet) {
              return NoInternetWidget(
                onRetry: () {
                  context.read<HomeBloc>().add(const LoadHomeDashboardEvent());
                },
              );
            }

            HomeDashboardEntity? dashboard;
            bool isToggling = false;

            if (state is HomeLoaded) {
              dashboard = state.dashboard;
            } else if (state is ShiftTogglingState) {
              isToggling = true;
            }

            if (dashboard == null) {
              return const Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: HomeStatsShimmer(),
              );
            }

            final isOnline = dashboard.isOnline;
            final stats = dashboard.dailyStats;

            return RefreshIndicator(
              color: AppColors.taxiYellowDark,
              backgroundColor:
                  isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              onRefresh: () async {
                context.read<HomeBloc>().add(const LoadHomeDashboardEvent());
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 120),
                children: [
                  // 1. Shift Online / Offline Toggle Banner
                  _buildShiftBanner(
                      context, isOnline, isToggling, isDark, l10n),
                  const SizedBox(height: 16),

                  // 2. Quick Actions (Tezkor Taksi Radari & Qatnov E'lon Qilish)
                  _buildQuickActions(context, isDark, l10n),
                  const SizedBox(height: 16),

                  // 3. Active in-flight Orders or Trips Alert
                  if (dashboard.activeTaxiOrder != null) ...[
                    _buildActiveTaxiAlert(
                        context, dashboard.activeTaxiOrder!, isDark, l10n),
                    const SizedBox(height: 16),
                  ] else if (dashboard.activeIntercityTrip != null) ...[
                    _buildActiveTripAlert(
                        context, dashboard.activeIntercityTrip!, isDark, l10n),
                    const SizedBox(height: 16),
                  ],

                  // 3. Section Title: Bugungi statistika
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.todayStats,
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color:
                              isDark ? Colors.white : AppColors.charcoalBlack,
                        ),
                      ),
                      Text(
                        l10n.daily,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.taxiYellowDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 4. 2x2 Stats Grid
                  _buildStatsGrid(stats, isDark, l10n),
                  const SizedBox(height: 18),

                  // 5. Wallet Card
                  _buildWalletCard(
                      context, dashboard.walletBalance, isDark, l10n),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildShiftBanner(
    BuildContext context,
    bool isOnline,
    bool isToggling,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E26) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOnline
              ? AppColors.success.withOpacity(0.5)
              : (isDark ? const Color(0xFF2E2E3C) : const Color(0xFFE2E4E8)),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isOnline ? AppColors.success : Colors.black)
                .withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOnline ? AppColors.success : AppColors.textTertiary,
              boxShadow: [
                if (isOnline)
                  BoxShadow(
                    color: AppColors.success.withOpacity(0.6),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOnline ? l10n.shiftOnlineTitle : l10n.shiftOfflineTitle,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.charcoalBlack,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isOnline
                      ? l10n.shiftOnlineSubtitle
                      : l10n.shiftOfflineSubtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isToggling)
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                  strokeWidth: 2.5, color: AppColors.taxiYellowDark),
            )
          else
            Switch.adaptive(
              value: isOnline,
              activeColor: AppColors.success,
              onChanged: (val) {
                HapticFeedback.selectionClick();
                context.read<HomeBloc>().add(ToggleShiftEvent(val));
              },
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(
      BuildContext context, bool isDark, AppLocalizations l10n) {
    return Row(
      children: [
        // 1. Taxi Radar Quick Action Card
        Expanded(
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              context.push('/driver/radar');
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E26) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF2E2E3C)
                      : const Color(0xFFE2E4E8),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.taxiYellow.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.radar_rounded,
                      color: AppColors.taxiYellowDark,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.radarOrdersTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.charcoalBlack,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.activeTaxiOrderBanner,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark ? Colors.white60 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // 2. Create Trip Quick Action Card
        Expanded(
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              context.push('/driver/create-trip');
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E26) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF2E2E3C)
                      : const Color(0xFFE2E4E8),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.add_road_rounded,
                      color: AppColors.info,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.publishTripAction,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.charcoalBlack,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.tripsPageTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark ? Colors.white60 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveTaxiAlert(BuildContext context, Map<String, dynamic> order,
      bool isDark, AppLocalizations l10n) {
    return InkWell(
      onTap: () => context.push('/driver/radar'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.taxiYellow.withOpacity(isDark ? 0.2 : 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.taxiYellowDark, width: 1.5),
        ),
        child: Row(
          children: [
            const Icon(Icons.navigation_rounded,
                color: AppColors.taxiYellowDark, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.activeTaxiOrderAlert,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.activeTaxiOrderDesc,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTripAlert(BuildContext context, Map<String, dynamic> trip,
      bool isDark, AppLocalizations l10n) {
    return InkWell(
      onTap: () => context.push('/driver/trips'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.taxiYellow.withOpacity(isDark ? 0.2 : 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.taxiYellowDark, width: 1.5),
        ),
        child: Row(
          children: [
            const Icon(Icons.alt_route_rounded,
                color: AppColors.taxiYellowDark, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.activeIntercityTripAlert,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.activeIntercityTripDesc,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(
      DailyStatsEntity stats, bool isDark, AppLocalizations l10n) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.45,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          l10n.statEarnings,
          AppCurrencyFormatter.format(stats.todayEarnings),
          Icons.payments_outlined,
          AppColors.success,
          isDark,
        ),
        _buildStatCard(
          l10n.statTripsCount,
          l10n.tripsCountUnit(stats.todayTripsCount),
          Icons.route_outlined,
          AppColors.taxiYellowDark,
          isDark,
        ),
        _buildStatCard(
          l10n.statOnlineTime,
          l10n.hours(stats.onlineHours.round()),
          Icons.access_time_rounded,
          const Color(0xFF3B82F6),
          isDark,
        ),
        _buildStatCard(
          l10n.statAcceptanceRate,
          "${stats.acceptanceRate.toStringAsFixed(1)}%",
          Icons.verified_outlined,
          const Color(0xFF10B981),
          isDark,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E26) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2E2E3C) : const Color(0xFFE2E4E8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white60 : AppColors.textSecondary,
                ),
              ),
              Icon(icon, size: 18, color: color),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.charcoalBlack,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCard(
      BuildContext context, int balance, bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E26) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF2E2E3C) : const Color(0xFFE2E4E8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.walletBalance,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white60 : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppCurrencyFormatter.format(balance),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.charcoalBlack,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () => context.push('/driver/wallet'),
            icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
            label: Text(l10n.topUp,
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.taxiYellow,
              foregroundColor: AppColors.charcoalBlack,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}
