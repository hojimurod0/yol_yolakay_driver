import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_responsive.dart';
import '../../../../core/theme/app_text_sizes.dart';
import '../../../../core/utils/app_date_formatter.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/status_localization_mapper.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/intercity_ride_entity.dart';
import '../bloc/intercity_rides_bloc.dart';
import '../bloc/intercity_rides_event.dart';
import '../bloc/intercity_rides_state.dart';
import '../../../../core/widgets/app_menu_drawer.dart';

class DriverTripsPage extends StatefulWidget {
  const DriverTripsPage({super.key});

  @override
  State<DriverTripsPage> createState() => _DriverTripsPageState();
}

class _DriverTripsPageState extends State<DriverTripsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const List<String> _statuses = ['active', 'completed', 'cancelled'];
  final Map<String, List<IntercityRideEntity>> _cachedRides = {};
  final Set<String> _loadingStatuses = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statuses.length, vsync: this);
    _tabController.addListener(_onTabChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadTab(0);
      _loadTab(1);
      _loadTab(2);
    });
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    HapticFeedback.selectionClick();
    if (mounted) setState(() {});
    _loadTab(_tabController.index);
  }

  void _loadTab(int index, {bool force = false}) {
    final status = _statuses[index];
    if (!force && _cachedRides.containsKey(status)) return;

    if (mounted) {
      setState(() {
        _loadingStatuses.add(status);
      });
    }

    context.read<IntercityRidesBloc>().add(
          LoadRidesEvent(status: status),
        );
  }

  void _refreshCurrentTab() {
    HapticFeedback.lightImpact();
    _loadTab(_tabController.index, force: true);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final currentLocale = Localizations.localeOf(context).languageCode;
    final hPad = AppResponsive.horizontalPadding(context);

    final cardBgColor = isDark ? AppColors.surfaceDark : Colors.white;
    final borderColor = isDark ? AppColors.borderDark : const Color(0xFFE5E7EB);

    final activeCount = _cachedRides['active']?.length ?? 0;
    final completedCount = _cachedRides['completed']?.length ?? 0;
    final cancelledCount = _cachedRides['cancelled']?.length ?? 0;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : const Color(0xFFF8F9FA),
      appBar: AppBar(
        leading: ShellBackButton(onPressed: () => context.go('/driver/home')),
        backgroundColor: cardBgColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: hPad,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Qatnovlar tarixi',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: AppTextSizes.lg,
                color: isDark ? Colors.white : AppColors.charcoalBlack,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              'Viloyatlararo qatnov va buyurtmalar',
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
        actions: [
          // Refresh trigger
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            tooltip: 'Yangilash',
            onPressed: _refreshCurrentTab,
          ),
          // Primary Action: Yangi Qatnov Qo'shish
          Padding(
            padding: EdgeInsets.only(right: hPad),
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                context.push('/driver/create-trip');
              },
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text(
                'Qatnov ochish',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.taxiYellow,
                foregroundColor: AppColors.charcoalBlack,
                elevation: 0,
                minimumSize: const Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 10),
            child: Container(
              height: 44,
              padding: const EdgeInsets.all(3.5),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: 0.8),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: isDark ? const Color(0xFF2A2D38) : Colors.white,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                onTap: (index) {
                  HapticFeedback.selectionClick();
                  setState(() {});
                },
                tabs: [
                  _buildTabItem(
                    label: l10n.tabActive,
                    count: activeCount,
                    isSelected: _tabController.index == 0,
                    isDark: isDark,
                    accentColor: AppColors.taxiYellow,
                  ),
                  _buildTabItem(
                    label: l10n.tabCompleted,
                    count: completedCount,
                    isSelected: _tabController.index == 1,
                    isDark: isDark,
                    accentColor: AppColors.success,
                  ),
                  _buildTabItem(
                    label: l10n.tabCancelled,
                    count: cancelledCount,
                    isSelected: _tabController.index == 2,
                    isDark: isDark,
                    accentColor: AppColors.error,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<IntercityRidesBloc, IntercityRidesState>(
          listener: (context, state) {
            if (state is IntercityRidesLoaded) {
              setState(() {
                _cachedRides[state.status] = state.rides;
                _loadingStatuses.remove(state.status);
              });
            } else if (state is IntercityRidesError) {
              setState(() {
                _loadingStatuses.clear();
              });
            }
          },
          builder: (context, state) {
            return TabBarView(
              controller: _tabController,
              physics: const BouncingScrollPhysics(),
              children: [
                _DriverTripTabListView(
                  key: const PageStorageKey<String>('driver_tab_active'),
                  status: 'active',
                  rides: _cachedRides['active'],
                  isLoading: _loadingStatuses.contains('active'),
                  isDark: isDark,
                  l10n: l10n,
                  currentLocale: currentLocale,
                  hPad: hPad,
                  onRefresh: () async => _loadTab(0, force: true),
                ),
                _DriverTripTabListView(
                  key: const PageStorageKey<String>('driver_tab_completed'),
                  status: 'completed',
                  rides: _cachedRides['completed'],
                  isLoading: _loadingStatuses.contains('completed'),
                  isDark: isDark,
                  l10n: l10n,
                  currentLocale: currentLocale,
                  hPad: hPad,
                  onRefresh: () async => _loadTab(1, force: true),
                ),
                _DriverTripTabListView(
                  key: const PageStorageKey<String>('driver_tab_cancelled'),
                  status: 'cancelled',
                  rides: _cachedRides['cancelled'],
                  isLoading: _loadingStatuses.contains('cancelled'),
                  isDark: isDark,
                  l10n: l10n,
                  currentLocale: currentLocale,
                  hPad: hPad,
                  onRefresh: () async => _loadTab(2, force: true),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required String label,
    required int count,
    required bool isSelected,
    required bool isDark,
    required Color accentColor,
  }) {
    return Tab(
      height: 38,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? (isDark ? Colors.white : AppColors.charcoalBlack)
                    : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (count > 0) ...[
            const SizedBox(width: 5),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 5.5, vertical: 1.5),
              decoration: BoxDecoration(
                color: isSelected
                    ? accentColor.withValues(alpha: 0.22)
                    : (isDark
                        ? const Color(0xFF22242D)
                        : const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isSelected
                      ? (isDark ? accentColor : const Color(0xFFB45309))
                      : (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Keep-Alive Tab ListView to Eliminate Reloading and Flickering on Tab Switch
class _DriverTripTabListView extends StatefulWidget {
  const _DriverTripTabListView({
    super.key,
    required this.status,
    required this.rides,
    required this.isLoading,
    required this.isDark,
    required this.l10n,
    required this.currentLocale,
    required this.hPad,
    required this.onRefresh,
  });

  final String status;
  final List<IntercityRideEntity>? rides;
  final bool isLoading;
  final bool isDark;
  final AppLocalizations l10n;
  final String currentLocale;
  final double hPad;
  final Future<void> Function() onRefresh;

  @override
  State<_DriverTripTabListView> createState() => _DriverTripTabListViewState();
}

class _DriverTripTabListViewState extends State<_DriverTripTabListView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.isLoading && widget.rides == null) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppResponsive.maxContentWidth,
          ),
          child: ListView(
            padding: EdgeInsets.fromLTRB(widget.hPad, 14, widget.hPad, 120),
            children: const [
              AppSkeletonRideCard(),
              SizedBox(height: 12),
              AppSkeletonRideCard(),
              SizedBox(height: 12),
              AppSkeletonRideCard(),
            ],
          ),
        ),
      );
    }

    final rides = widget.rides;
    if (rides == null || rides.isEmpty) {
      final isTabActive = widget.status == 'active';
      return RefreshIndicator(
        color: AppColors.taxiYellowDark,
        onRefresh: widget.onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.12),
            AppEmptyState(
              title: isTabActive
                  ? 'Faol qatnovlar yo‘q'
                  : widget.l10n.noTripsTitle,
              description: isTabActive
                  ? 'Hozirda sizda faol qatnov mavjud emas. Yangi qatnov e’lon qiling va yo‘lovchilarni qabul qiling.'
                  : widget.l10n.noTripsHistoryDesc,
              icon: isTabActive
                  ? Icons.add_road_rounded
                  : Icons.alt_route_rounded,
              actionText: isTabActive ? 'Qatnov ochish' : null,
              onAction: isTabActive
                  ? () {
                      HapticFeedback.lightImpact();
                      context.push('/driver/create-trip');
                    }
                  : null,
            ),
          ],
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppResponsive.maxContentWidth,
        ),
        child: RefreshIndicator(
          color: AppColors.taxiYellowDark,
          onRefresh: widget.onRefresh,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(widget.hPad, 14, widget.hPad, 120),
            itemCount: rides.length,
            itemBuilder: (ctx, index) {
              final ride = rides[index];
              return _ExecutiveRideCard(
                ride: ride,
                locale: widget.currentLocale,
                l10n: widget.l10n,
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push('/driver/trips/${ride.id}');
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Redesigned Executive Driver Ride Card with high-contrast route timeline,
/// passenger seat occupancy, revenue estimate, and quick management triggers.
class _ExecutiveRideCard extends StatelessWidget {
  const _ExecutiveRideCard({
    required this.ride,
    required this.locale,
    required this.l10n,
    required this.onTap,
  });

  final IntercityRideEntity ride;
  final String locale;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF10B981);
      case 'in_progress':
      case 'started':
        return AppColors.taxiYellowDark;
      case 'completed':
        return const Color(0xFF3B82F6);
      case 'cancelled':
        return AppColors.error;
      default:
        return const Color(0xFF10B981);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateStr =
        AppDateFormatter.formatDateTime(ride.departureTime, locale: locale);
    final statusColor = _getStatusColor(ride.status);

    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final borderCol = isDark ? AppColors.borderDark : const Color(0xFFE5E7EB);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderCol, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Departure DateTime & Modern Status Chip
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.taxiYellow.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.calendar_month_rounded,
                            size: 15,
                            color: AppColors.taxiYellowDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          dateStr,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color:
                                isDark ? Colors.white : AppColors.charcoalBlack,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        StatusLocalizationMapper.mapStatus(ride.status,
                                locale: locale)
                            .toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: statusColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Route Timeline with High Contrast Pins
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 3),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 2,
                          height: 24,
                          color:
                              isDark ? Colors.white24 : const Color(0xFFE5E7EB),
                        ),
                        const Icon(
                          Icons.location_on_rounded,
                          size: 15,
                          color: AppColors.taxiYellowDark,
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ride.fromCity,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.charcoalBlack,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            ride.toCity,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.charcoalBlack,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Price Tag Badge
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          AppCurrencyFormatter.format(ride.pricePerSeat),
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color:
                                isDark ? Colors.white : AppColors.charcoalBlack,
                          ),
                        ),
                        Text(
                          '1 joy uchun',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Divider
                Divider(
                  height: 1,
                  thickness: 1,
                  color:
                      isDark ? AppColors.borderDark : const Color(0xFFF3F4F6),
                ),
                const SizedBox(height: 12),

                // Bottom Strip: Occupied Seats + Amenities + Details Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E2330)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.people_alt_rounded,
                                size: 14,
                                color: AppColors.taxiYellowDark,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '${ride.bookedSeats}/${ride.totalSeats} yo‘lovchi',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.charcoalBlack,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (ride.hasAc) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.ac_unit_rounded,
                                    size: 12, color: Color(0xFF3B82F6)),
                                SizedBox(width: 3),
                                Text(
                                  'AC',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF3B82F6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const Row(
                      children: [
                        Text(
                          'Boshqarish',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.taxiYellowDark,
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: AppColors.taxiYellowDark,
                        ),
                      ],
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
