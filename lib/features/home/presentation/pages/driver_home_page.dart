import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_responsive.dart';
import '../../../../core/theme/app_text_sizes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/battery_optimization_guide_dialog.dart';
import '../../../../core/widgets/no_internet_widget.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/home_dashboard_entity.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../../../../core/config/app_config.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  HomeDashboardEntity? _cachedDashboard;

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const LoadHomeDashboardEvent());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final hPad = AppResponsive.horizontalPadding(context);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: hPad,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.taxiYellow.withValues(alpha: 0.22),
              ),
              child: const Icon(
                Icons.local_taxi_rounded,
                size: 20,
                color: AppColors.taxiYellowDark,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Yo‘l-Yo‘lakay',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: AppTextSizes.base,
                    color: isDark ? Colors.white : AppColors.charcoalBlack,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Haydovchi boshqaruvi',
                  style: TextStyle(
                    fontSize: AppTextSizes.xs,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              BatteryOptimizationGuideDialog.show(context);
            },
            icon: const Icon(
              Icons.battery_charging_full_rounded,
              color: Color(0xFF10B981),
              size: 22,
            ),
            tooltip: 'Fonda ishlash sozlamasi (Xiaomi / Samsung)',
          ),
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              context.read<HomeBloc>().add(const LoadHomeDashboardEvent());
            },
            icon: const Icon(Icons.refresh_rounded, size: 22),
            tooltip: l10n.refresh,
          ),
          SizedBox(width: hPad / 2),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: isDark ? AppColors.borderDark : const Color(0xFFE5E7EB),
            height: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state is HomeError && !state.isNoInternet) {
              AppSnackBar.showError(context, state.message);
            }
          },
          builder: (context, state) {
            if (state is HomeLoading && _cachedDashboard == null) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppResponsive.maxContentWidth,
                  ),
                  child: ListView(
                    padding: EdgeInsets.all(hPad),
                    children: const [
                      AppSkeletonDriverTripCard(),
                      SizedBox(height: 14),
                      AppSkeletonNotificationCard(),
                    ],
                  ),
                ),
              );
            }

            if (state is HomeError) {
              if (state.isNoInternet) {
                return NoInternetWidget(
                  onRetry: () {
                    context
                        .read<HomeBloc>()
                        .add(const LoadHomeDashboardEvent());
                  },
                );
              }
              if (_cachedDashboard == null) {
                return AppErrorState(
                  message: state.message,
                  onRetry: () {
                    context
                        .read<HomeBloc>()
                        .add(const LoadHomeDashboardEvent());
                  },
                );
              }
            }

            bool isToggling = false;
            if (state is HomeLoaded) {
              _cachedDashboard = state.dashboard;
            } else if (state is ShiftTogglingState) {
              isToggling = true;
            }

            final dashboard = _cachedDashboard;
            if (dashboard == null) return const SizedBox.shrink();

            final isOnline = dashboard.isOnline;
            final stats = dashboard.dailyStats;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppResponsive.maxContentWidth,
                ),
                child: RefreshIndicator(
                  color: AppColors.taxiYellowDark,
                  backgroundColor:
                      isDark ? AppColors.surfaceDark : Colors.white,
                  onRefresh: () async {
                    context
                        .read<HomeBloc>()
                        .add(const LoadHomeDashboardEvent());
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.fromLTRB(hPad, 14, hPad, 120),
                    children: [
                      // 1. Verification Alert (faqat rad etilgan holatda ko'rsatiladi)
                      if (dashboard.verificationStatus == 'rejected' ||
                          dashboard.verificationStatus == 'action_required')
                        _buildVerificationAlertBanner(
                          context,
                          dashboard.verificationStatus,
                          isDark,
                          l10n,
                        ),

                      // 2. Hero Shift Cockpit Controller (Central Glanceable Element)
                      _buildHeroShiftCard(
                        context,
                        isOnline: isOnline,
                        isToggling: isToggling,
                        isDark: isDark,
                        verificationStatus: dashboard.verificationStatus,
                        walletBalance: dashboard.walletBalance,
                        l10n: l10n,
                      ),
                      const SizedBox(height: 16),

                      // 3. Active in-flight Orders or Trips Alert (High Priority)
                      if (dashboard.activeTaxiOrder != null) ...[
                        _buildActiveTaxiAlert(
                            context, dashboard.activeTaxiOrder!, isDark, l10n),
                        const SizedBox(height: 16),
                      ] else if (dashboard.activeIntercityTrip != null) ...[
                        _buildActiveTripAlert(context,
                            dashboard.activeIntercityTrip!, isDark, l10n),
                        const SizedBox(height: 16),
                      ],

                      // 4. Primary Operations (2 Large Action Tiles)
                      _buildPrimaryOperationsGrid(
                        context,
                        isDark: isDark,
                        verificationStatus: dashboard.verificationStatus,
                        l10n: l10n,
                      ),
                      const SizedBox(height: 18),

                      // 5. Bugungi Sof Daromad & Safarlar (Executive Summary Card)
                      _buildExecutiveFinancialCard(
                        context,
                        stats: stats,
                        walletBalance: dashboard.walletBalance,
                        isDark: isDark,
                        l10n: l10n,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Modern Hero Shift Card: Full tactile control for Driver Online / Offline state.
  Widget _buildHeroShiftCard(
    BuildContext context, {
    required bool isOnline,
    required bool isToggling,
    required bool isDark,
    required String verificationStatus,
    required int walletBalance,
    required AppLocalizations l10n,
  }) {
    // Online: Rich dark emerald with soft green glow
    // Offline: Deep sleek charcoal with amber accent
    final cardBg = isOnline
        ? (isDark ? const Color(0xFF062319) : const Color(0xFFE8F5E9))
        : (isDark ? const Color(0xFF13151D) : Colors.white);

    final borderCol = isOnline
        ? const Color(0xFF10B981)
        : (isDark ? const Color(0xFF232733) : const Color(0xFFE5E7EB));

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderCol,
          width: isOnline ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: (isOnline ? const Color(0xFF10B981) : Colors.black)
                .withValues(
                    alpha: isOnline
                        ? (isDark ? 0.25 : 0.12)
                        : (isDark ? 0.25 : 0.04)),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Indicator Row
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOnline
                      ? const Color(0xFF10B981)
                      : const Color(0xFF9CA3AF),
                  boxShadow: [
                    if (isOnline)
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.6),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                isOnline ? 'SIZ LINIYADASIZ' : 'HOZIRDA OFLAYNSIZ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: isOnline
                      ? const Color(0xFF10B981)
                      : (isDark ? Colors.white60 : const Color(0xFF6B7280)),
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              if (isOnline)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.wifi_rounded,
                          size: 13, color: Color(0xFF10B981)),
                      SizedBox(width: 4),
                      Text(
                        'GPS Faol',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Main Glanceable Title
          Text(
            isOnline
                ? 'Yangi buyurtmalar qidirilmoqda...'
                : 'Buyurtmalarni qabul qilish uchun liniyaga chiqing',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              height: 1.25,
              color: isDark ? Colors.white : AppColors.charcoalBlack,
            ),
          ),
          const SizedBox(height: 16),

          // Primary Shift Switch Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: isToggling
                ? Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1F2937)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.taxiYellowDark,
                      ),
                    ),
                  )
                : ElevatedButton(
                    onPressed: () {
                      _handleShiftToggle(
                        context,
                        isOnline: !isOnline,
                        verificationStatus: verificationStatus,
                        walletBalance: walletBalance,
                        l10n: l10n,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isOnline
                          ? (isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFE2E8F0))
                          : AppColors.taxiYellow,
                      foregroundColor: isOnline
                          ? (isDark ? Colors.white : AppColors.charcoalBlack)
                          : AppColors.charcoalBlack,
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: isOnline
                            ? BorderSide(
                                color: isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFCBD5E1),
                                width: 1.2,
                              )
                            : BorderSide.none,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isOnline
                              ? Icons.power_settings_new_rounded
                              : Icons.bolt_rounded,
                          size: 22,
                          color: isOnline
                              ? Colors.redAccent
                              : AppColors.charcoalBlack,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isOnline ? 'Liniyani to‘xtatish' : 'Liniyaga chiqish',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: isOnline
                                ? (isDark
                                    ? Colors.white
                                    : AppColors.charcoalBlack)
                                : AppColors.charcoalBlack,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _handleShiftToggle(
    BuildContext context, {
    required bool isOnline,
    required String verificationStatus,
    required int walletBalance,
    required AppLocalizations l10n,
  }) {
    if (verificationStatus != 'approved' &&
        verificationStatus != 'under_review') {
      HapticFeedback.heavyImpact();
      AppSnackBar.showWarning(context, l10n.verificationRequiredMessage);
      context.push('/verification');
      return;
    }
    if (isOnline && walletBalance < 0) {
      HapticFeedback.heavyImpact();
      _showLowBalanceDialog(context, walletBalance);
      return;
    }
    HapticFeedback.mediumImpact();
    context.read<HomeBloc>().add(ToggleShiftEvent(isOnline));
  }

  /// Primary Operations Grid: Two Large High-Contrast Tiles (Taksi Radari & Shaharlararo Qatnov)
  Widget _buildPrimaryOperationsGrid(
    BuildContext context, {
    required bool isDark,
    required String verificationStatus,
    required AppLocalizations l10n,
  }) {
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final borderCol = isDark ? AppColors.borderDark : const Color(0xFFE5E7EB);

    return Row(
      children: [
        // 1. Taksi Radari
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (verificationStatus != 'approved' &&
                    verificationStatus != 'under_review') {
                  HapticFeedback.heavyImpact();
                  AppSnackBar.showWarning(
                      context, l10n.verificationRequiredMessage);
                  context.push('/verification');
                  return;
                }
                HapticFeedback.selectionClick();
                context.push('/driver/radar');
              },
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderCol, width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.taxiYellow.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.radar_rounded,
                            color: AppColors.taxiYellowDark,
                            size: 24,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.taxiYellow.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'JONLI ⚡',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: AppColors.taxiYellowDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Taksi Radari',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.charcoalBlack,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Atrofdagi yo‘lovchilar',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),

        // 2. Shaharlararo Qatnov E'lon Qilish
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (verificationStatus != 'approved' &&
                    verificationStatus != 'under_review') {
                  HapticFeedback.heavyImpact();
                  AppSnackBar.showWarning(
                      context, l10n.verificationRequiredMessage);
                  context.push('/verification');
                  return;
                }
                HapticFeedback.selectionClick();
                context.push('/driver/create-trip');
              },
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderCol, width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF3B82F6).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.add_road_rounded,
                            color: Color(0xFF2563EB),
                            size: 24,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF3B82F6).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            '+ E’LON',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Shaharlararo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.charcoalBlack,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Qatnov e’lon qilish',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Executive Financial & Shift Summary Card: Bugungi tushum + Safarlar ko'rsatkichlari + Hamyon
  Widget _buildExecutiveFinancialCard(
    BuildContext context, {
    required DailyStatsEntity stats,
    required int walletBalance,
    required bool isDark,
    required AppLocalizations l10n,
  }) {
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final borderCol = isDark ? AppColors.borderDark : const Color(0xFFE5E7EB);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderCol, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Row: Bugungi Sof Tushum + Hamyon Balansi
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'BUGUNGI DAROMAD',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.verified_rounded,
                              size: 14, color: AppColors.success),
                        ],
                      ),
                      const SizedBox(height: 6),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppCurrencyFormatter.format(stats.todayEarnings),
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color:
                                isDark ? Colors.white : AppColors.charcoalBlack,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Compact Wallet Chip with Direct Tap
                InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.push('/driver/wallet');
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.taxiYellow.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.taxiYellowDark.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppConfig.commissionEnabled
                                  ? 'Hamyon'
                                  : 'Daromad',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.taxiYellowDark,
                              ),
                            ),
                            SizedBox(width: 3),
                            Icon(Icons.chevron_right_rounded,
                                size: 14, color: AppColors.taxiYellowDark),
                          ],
                        ),
                        if (AppConfig.commissionEnabled) ...[
                          const SizedBox(height: 2),
                          Text(
                            AppCurrencyFormatter.format(walletBalance),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: AppColors.charcoalBlack,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(
            height: 1,
            thickness: 1,
            color: isDark ? AppColors.borderDark : const Color(0xFFF3F4F6),
          ),

          // Bottom 3 Quick Metrics Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    label: 'Safarlar',
                    value: '${stats.todayTripsCount} ta',
                    icon: Icons.route_rounded,
                    iconColor: AppColors.taxiYellowDark,
                    isDark: isDark,
                  ),
                ),
                Container(
                  height: 28,
                  width: 1,
                  color:
                      isDark ? AppColors.borderDark : const Color(0xFFE5E7EB),
                ),
                Expanded(
                  child: _buildMetricItem(
                    label: 'Onlayn vaqt',
                    value: '${stats.onlineHours.toStringAsFixed(1)} soat',
                    icon: Icons.access_time_rounded,
                    iconColor: const Color(0xFF3B82F6),
                    isDark: isDark,
                  ),
                ),
                Container(
                  height: 28,
                  width: 1,
                  color:
                      isDark ? AppColors.borderDark : const Color(0xFFE5E7EB),
                ),
                Expanded(
                  child: _buildMetricItem(
                    label: 'Qabul qilish',
                    value: '${(stats.acceptanceRate * 100).toInt()}%',
                    icon: Icons.check_circle_outline_rounded,
                    iconColor: const Color(0xFF10B981),
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppColors.charcoalBlack,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveTaxiAlert(
    BuildContext context,
    Map<String, dynamic> order,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/driver/radar'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.taxiYellow.withValues(alpha: isDark ? 0.20 : 0.14),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.taxiYellowDark, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.taxiYellow,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.navigation_rounded,
                    color: AppColors.charcoalBlack, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.activeTaxiOrderAlert,
                      style: const TextStyle(
                        fontSize: AppTextSizes.md,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.activeTaxiOrderDesc,
                      style: const TextStyle(fontSize: AppTextSizes.sm),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 15),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTripAlert(
    BuildContext context,
    Map<String, dynamic> trip,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/driver/trips'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                const Color(0xFF3B82F6).withValues(alpha: isDark ? 0.20 : 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF3B82F6), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF3B82F6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.alt_route_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.activeIntercityTripAlert,
                      style: const TextStyle(
                        fontSize: AppTextSizes.md,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.activeIntercityTripDesc,
                      style: const TextStyle(fontSize: AppTextSizes.sm),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 15),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationAlertBanner(
    BuildContext context,
    String status,
    bool isDark,
    AppLocalizations l10n,
  ) {
    Color bg;
    Color border;
    IconData icon;
    String title;
    String subtitle;
    String buttonText;

    switch (status) {
      case 'under_review':
        bg = isDark
            ? AppColors.warning.withValues(alpha: 0.15)
            : const Color(0xFFFEF3C7);
        border = AppColors.warning.withValues(alpha: 0.5);
        icon = Icons.schedule_rounded;
        title = l10n.verificationUnderReviewTitle;
        subtitle = l10n.verificationUnderReviewSubtitle;
        buttonText = 'Holatni ko\'rish';
        break;
      case 'rejected':
        bg = isDark ? AppColors.errorDarkBg : AppColors.errorLight;
        border = AppColors.error.withValues(alpha: 0.5);
        icon = Icons.cancel_outlined;
        title = l10n.verificationRejectedTitle;
        subtitle = l10n.verificationRejectedSubtitle;
        buttonText = 'Hujjatlarni qayta yuborish';
        break;
      default:
        bg = isDark
            ? AppColors.warning.withValues(alpha: 0.15)
            : const Color(0xFFFEF3C7);
        border = AppColors.taxiYellowDark.withValues(alpha: 0.5);
        icon = Icons.assignment_late_outlined;
        title = l10n.verificationMissingTitle;
        subtitle = l10n.verificationMissingSubtitle;
        buttonText = 'Verifikatsiyadan o\'tish';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: border, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: AppTextSizes.base,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.charcoalBlack,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: AppTextSizes.compact,
                        height: 1.35,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppButton(
            text: buttonText,
            onPressed: () {
              HapticFeedback.selectionClick();
              context.push('/verification');
            },
            variant: AppButtonVariant.taxi,
            height: 44,
          ),
        ],
      ),
    );
  }

  void _showLowBalanceDialog(BuildContext context, int balance) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF191B24) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded,
                        color: AppColors.error, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Balansingiz yetarli emas',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Liniyaga chiqish va yangi buyurtmalarni qabul qilish uchun hisobingiz musbat bo\'lishi kerak. Hozirgi balans: ${AppCurrencyFormatter.format(balance)}',
                style: TextStyle(
                  fontSize: 13.5,
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.push('/driver/wallet');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.taxiYellow,
                    foregroundColor: AppColors.charcoalBlack,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('To\'ldirish (Click/Payme)',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
