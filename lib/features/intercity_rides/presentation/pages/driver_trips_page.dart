import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_date_formatter.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/status_localization_mapper.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/intercity_ride_entity.dart';
import '../bloc/intercity_rides_bloc.dart';
import '../bloc/intercity_rides_event.dart';
import '../bloc/intercity_rides_state.dart';

class DriverTripsPage extends StatefulWidget {
  const DriverTripsPage({super.key});

  @override
  State<DriverTripsPage> createState() => _DriverTripsPageState();
}

class _DriverTripsPageState extends State<DriverTripsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _statuses = ['active', 'completed', 'cancelled'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _loadCurrentTab();
      }
    });
    _loadCurrentTab();
  }

  void _loadCurrentTab() {
    final status = _statuses[_tabController.index];
    context.read<IntercityRidesBloc>().add(LoadRidesEvent(status: status));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final currentLocale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          l10n.tripsPageTitle,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 17,
            color: isDark ? Colors.white : AppColors.charcoalBlack,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/driver/create-trip'),
            icon: const Icon(Icons.add_rounded,
                color: AppColors.taxiYellowDark, size: 26),
            tooltip: l10n.createTripAction,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.taxiYellowDark,
          unselectedLabelColor:
              isDark ? Colors.white60 : AppColors.textSecondary,
          indicatorColor: AppColors.taxiYellowDark,
          indicatorWeight: 3,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          tabs: [
            Tab(text: l10n.tabActive),
            Tab(text: l10n.tabCompleted),
            Tab(text: l10n.tabCancelled),
          ],
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<IntercityRidesBloc, IntercityRidesState>(
          listener: (context, state) {
            if (state is IntercityRidesError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error),
              );
            }
          },
          builder: (context, state) {
            if (state is IntercityRidesLoading) {
              return ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: 3,
                itemBuilder: (_, __) => const RideCardShimmer(),
              );
            }

            if (state is IntercityRidesLoaded) {
              final rides = state.rides;
              if (rides.isEmpty) {
                return RefreshIndicator(
                  color: AppColors.taxiYellowDark,
                  onRefresh: () async => _loadCurrentTab(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics()),
                    children: [
                      const SizedBox(height: 60),
                      EmptyStateWidget(
                        title: l10n.noTripsTitle,
                        description: _tabController.index == 0
                            ? l10n.noActiveTripsDesc
                            : l10n.noTripsHistoryDesc,
                        icon: Icons.alt_route_rounded,
                        actionText: _tabController.index == 0
                            ? l10n.createTripAction
                            : null,
                        onAction: _tabController.index == 0
                            ? () => context.push('/driver/create-trip')
                            : null,
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColors.taxiYellowDark,
                onRefresh: () async => _loadCurrentTab(),
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics()),
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 120),
                  itemCount: rides.length,
                  itemBuilder: (ctx, index) {
                    final ride = rides[index];
                    return _RideCard(
                      ride: ride,
                      locale: currentLocale,
                      l10n: l10n,
                      onTap: () =>
                          context.push('/driver/trip/${ride.id}', extra: ride),
                    );
                  },
                ),
              );
            }

            return const Center(
                child:
                    CircularProgressIndicator(color: AppColors.taxiYellowDark));
          },
        ),
      ),
    );
  }
}

class _RideCard extends StatelessWidget {
  const _RideCard({
    required this.ride,
    required this.locale,
    required this.l10n,
    required this.onTap,
  });

  final IntercityRideEntity ride;
  final String locale;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateStr =
        AppDateFormatter.formatDateTime(ride.departureTime, locale: locale);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Departure Time & Status Tag
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                            size: 16, color: AppColors.taxiYellowDark),
                        const SizedBox(width: 6),
                        Text(
                          dateStr,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white70
                                : AppColors.charcoalBlack,
                          ),
                        ),
                      ],
                    ),
                    AppStatusChip(
                      label: StatusLocalizationMapper.mapStatus(ride.status,
                          locale: locale),
                      variant: StatusLocalizationMapper.mapVariant(ride.status),
                      compact: true,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Origin -> Destination
                Row(
                  children: [
                    Text(
                      ride.fromCity,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.charcoalBlack,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.arrow_forward_rounded,
                          size: 16, color: AppColors.textTertiary),
                    ),
                    Text(
                      ride.toCity,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.charcoalBlack,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Meta Row: Available seats, Price per seat
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF282834)
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.event_seat_rounded,
                              size: 14, color: AppColors.taxiYellowDark),
                          const SizedBox(width: 4),
                          Text(
                            l10n.seatsAvailable(
                                ride.availableSeats, ride.totalSeats),
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
                      l10n.pricePerSeat(
                          AppCurrencyFormatter.format(ride.pricePerSeat)),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.taxiYellowDark,
                      ),
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
