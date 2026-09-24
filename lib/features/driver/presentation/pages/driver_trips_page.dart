import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../rides/domain/entities/ride_entity.dart';
import '../providers/driver_provider.dart';

class DriverTripsPage extends ConsumerStatefulWidget {
  const DriverTripsPage({super.key});

  @override
  ConsumerState<DriverTripsPage> createState() => _DriverTripsPageState();
}

class _DriverTripsPageState extends ConsumerState<DriverTripsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final NumberFormat _currencyFormat = NumberFormat('#,###', 'uz_UZ');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = ref.watch(localeNotifierProvider);
    final isRu = locale.languageCode == 'ru';
    final driverState = ref.watch(driverNotifierProvider);
    final allRides = driverState.driverRides;

    final activeRides = allRides
        .where(
            (r) => r.status == RideStatus.active || r.status == RideStatus.full)
        .toList();
    final completedRides =
        allRides.where((r) => r.status == RideStatus.completed).toList();

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          isRu ? 'Мои маршруты и поездки' : 'Mening qatnovlarim',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: isDark ? Colors.white : AppColors.charcoalBlack,
          ),
        ),
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              ref.read(driverNotifierProvider.notifier).refreshAll();
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: isRu ? 'Обновить' : 'Yangilash',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.taxiYellowDark,
                indicatorWeight: 2.5,
                labelColor:
                    isDark ? AppColors.taxiYellow : AppColors.charcoalBlack,
                unselectedLabelColor:
                    isDark ? Colors.white54 : AppColors.textSecondary,
                labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13.5),
                tabs: [
                  Tab(
                      text: isRu
                          ? 'Активные (${activeRides.length})'
                          : 'Faol (${activeRides.length})'),
                  Tab(
                      text: isRu
                          ? 'Завершенные (${completedRides.length})'
                          : 'Tugallangan (${completedRides.length})'),
                ],
              ),
              Container(
                  color:
                      isDark ? AppColors.cardBorderDark : AppColors.cardBorder,
                  height: 1),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            // Active Tab
            _buildRidesList(activeRides,
                isLoading: driverState.isLoading,
                isActiveTab: true,
                isDark: isDark,
                isRu: isRu),
            // Completed Tab
            _buildRidesList(completedRides,
                isLoading: driverState.isLoading,
                isActiveTab: false,
                isDark: isDark,
                isRu: isRu),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/driver/create-trip'),
        backgroundColor: AppColors.taxiYellow,
        foregroundColor: AppColors.charcoalBlack,
        elevation: 2,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: Text(
          isRu ? 'Создать поездку' : 'Yangi qatnov',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildRidesList(
    List<RideEntity> rides, {
    required bool isLoading,
    required bool isActiveTab,
    required bool isDark,
    required bool isRu,
  }) {
    if (isLoading) {
      return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.md, AppSpacing.md, 100),
        itemCount: 3,
        itemBuilder: (_, __) => const AppSkeletonDriverTripCard(),
      );
    }

    if (rides.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.route_rounded,
                size: 48, color: isDark ? Colors.white24 : AppColors.gray400),
            const SizedBox(height: 10),
            Text(
              isActiveTab
                  ? (isRu ? 'Нет активных поездок' : 'Faol qatnov yo\'q')
                  : (isRu
                      ? 'Нет завершенных поездок'
                      : 'Tugallangan qatnovlar yo\'q'),
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
            ),
            const SizedBox(height: 4),
            Text(
              isActiveTab
                  ? (isRu
                      ? 'Опубликуйте новую поездку с помощью кнопки ниже'
                      : 'Pastdagi tugma orqali yangi qatnov e\'lon qiling')
                  : '',
              style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.md, AppSpacing.md, 100),
      itemCount: rides.length,
      itemBuilder: (context, index) {
        final ride = rides[index];
        return _buildTripCard(ride,
            isActiveTab: isActiveTab, isDark: isDark, isRu: isRu);
      },
    );
  }

  Widget _buildTripCard(RideEntity ride,
      {required bool isActiveTab, required bool isDark, required bool isRu}) {
    final lang = isRu ? 'ru' : 'uz';
    final bookedSeats = ride.totalSeats - ride.availableSeats;
    final totalExpectedIncome = bookedSeats * ride.pricePerSeat;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE2E4E8),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Route & Status Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${ride.departureCity.localizedName(lang)} ➔ ${ride.destinationCity.localizedName(lang)}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: isDark ? Colors.white : AppColors.charcoalBlack,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: (isActiveTab ? AppColors.success : AppColors.gray400)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isActiveTab
                      ? (isRu ? 'АКТИВЕН' : 'FAOL')
                      : (isRu ? 'ЗАВЕРШЕН' : 'TUGALLANGAN'),
                  style: TextStyle(
                    color: isActiveTab
                        ? AppColors.success
                        : AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Date & Time
          Row(
            children: [
              Icon(Icons.access_time_rounded,
                  size: 14,
                  color: isDark ? Colors.white60 : AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                DateFormat('dd MMM • HH:mm', isRu ? 'ru' : 'uz')
                    .format(ride.departureTime),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Seats progress container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.gray800 : AppColors.gray100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isRu ? 'Занято мест' : 'Band qilingan',
                      style: TextStyle(
                          fontSize: 10.5,
                          color:
                              isDark ? Colors.white54 : AppColors.textSecondary,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '$bookedSeats / ${ride.totalSeats} ta joy',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isRu ? 'Ожидаемый доход' : 'Kutilayotgan daromad',
                      style: TextStyle(
                          fontSize: 10.5,
                          color:
                              isDark ? Colors.white54 : AppColors.textSecondary,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '${_currencyFormat.format(totalExpectedIncome)} UZS',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (isActiveTab) ...[
            const SizedBox(height: 10),
            // View orders for this route
            SizedBox(
              width: double.infinity,
              height: 38,
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  ref
                      .read(driverNotifierProvider.notifier)
                      .selectPlannedRide(ride.id);
                  context.go('/driver/home');
                },
                icon: const Icon(Icons.inbox_rounded, size: 16),
                label: Text(
                  isRu
                      ? 'Посмотреть заказы пассажиров'
                      : 'Yo‘lovchilar buyurtmalarini ko‘rish',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 12.5),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.taxiYellow,
                  foregroundColor: AppColors.charcoalBlack,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // Cancel ride
                SizedBox(
                  height: 36,
                  child: OutlinedButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      ref
                          .read(driverNotifierProvider.notifier)
                          .cancelRide(ride.id);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(
                          color: AppColors.error.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(isRu ? 'Отменить' : 'Bekor qilish',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 8),

                // Complete ride
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: OutlinedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        ref
                            .read(driverNotifierProvider.notifier)
                            .completeRide(ride.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Safar yakunlandi!')),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            isDark ? Colors.white70 : AppColors.charcoalBlack,
                        side: BorderSide(
                            color: isDark
                                ? const Color(0xFF3C3C48)
                                : const Color(0xFFD1D5DB)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        isRu ? 'Завершить поездку' : 'Safarni yakunlash',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
