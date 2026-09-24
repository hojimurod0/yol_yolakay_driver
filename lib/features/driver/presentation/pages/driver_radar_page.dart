import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_avatar_initials.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../rides/domain/entities/ride_entity.dart';
import '../../domain/entities/driver_incoming_request_entity.dart';
import '../providers/driver_provider.dart';

/// Clean, intuitive Passenger Booking Requests ("Buyurtmalar / Zayavkalar") page.
/// Displays incoming booking requests from passengers for the driver's planned route.
class DriverRadarPage extends ConsumerWidget {
  const DriverRadarPage({super.key});

  Future<void> _makePhoneCall(String phone) async {
    HapticFeedback.selectionClick();
    final Uri launchUri = Uri(scheme: 'tel', path: phone.replaceAll(' ', ''));
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = ref.watch(localeNotifierProvider);
    final isRu = locale.languageCode == 'ru';
    final driverState = ref.watch(driverNotifierProvider);

    final activePlannedRide = driverState.activePlannedRide;
    final activeRides = driverState.activeRides;
    final pendingRequests = driverState.activeRideIncomingRequests
        .where((r) => r.status == DriverRequestStatus.pending)
        .toList();

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
                color: AppColors.taxiYellow.withValues(alpha: 0.2),
              ),
              child: const Icon(
                Icons.inbox_rounded,
                size: 18,
                color: AppColors.taxiYellowDark,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              isRu ? 'Заказы пассажиров' : 'Yangi buyurtmalar',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: isDark ? Colors.white : AppColors.charcoalBlack,
              ),
            ),
            if (pendingRequests.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: const BoxDecoration(
                  color: AppColors.taxiYellow,
                  borderRadius: AppRadius.borderPill,
                ),
                child: Text(
                  '${pendingRequests.length}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: AppColors.charcoalBlack,
                  ),
                ),
              ),
            ],
          ],
        ),
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
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: isDark ? AppColors.cardBorderDark : AppColors.cardBorder,
            height: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.taxiYellowDark,
          backgroundColor:
              isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          onRefresh: () async {
            await ref.read(driverNotifierProvider.notifier).refreshAll();
          },
          child: driverState.isLoading
              ? ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, AppSpacing.md, AppSpacing.md, 100),
                  itemCount: 3,
                  itemBuilder: (_, __) => const AppSkeletonDriverTripCard(),
                )
              : ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics()),
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, AppSpacing.md, AppSpacing.md, 100),
                  children: [
                    // Case 1: Driver has NOT planned a trip yet
                    if (activePlannedRide == null) ...[
                      _buildNoRoutePlannedHeader(context, isDark, isRu),
                      _buildNoRouteEmptyState(context, isDark, isRu),
                    ] else ...[
                      // Case 2: Driver has an active planned trip
                      _buildActiveRouteBanner(context, ref, activePlannedRide,
                          activeRides, isDark, isRu),

                      const SizedBox(height: 16),

                      // Incoming Requests Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isRu
                                ? 'Заявки на вашу поездку'
                                : 'Qatnovingizga zayavkalar',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white70
                                  : AppColors.textSecondary,
                            ),
                          ),
                          if (pendingRequests.isNotEmpty)
                            Text(
                              isRu
                                  ? '${pendingRequests.length} ожидает'
                                  : '${pendingRequests.length} ta kutmoqda',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.taxiYellowDark,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Passenger Requests List OR Empty state for this route
                      if (pendingRequests.isEmpty)
                        _buildEmptyOrdersState(
                            context, activePlannedRide, isDark, isRu)
                      else
                        ...pendingRequests.map((req) => _buildOrderRequestCard(
                            context, ref, req, isDark, isRu)),
                    ],
                  ],
                ),
        ),
      ),
    );
  }

  /// Card shown when NO trip is planned yet
  Widget _buildNoRoutePlannedHeader(
      BuildContext context, bool isDark, bool isRu) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B1B22) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.taxiYellow.withValues(alpha: isDark ? 0.4 : 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.taxiYellow.withValues(alpha: isDark ? 0.15 : 0.1),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.taxiYellow
                      .withValues(alpha: isDark ? 0.25 : 0.18),
                ),
                child: const Icon(
                  Icons.alt_route_rounded,
                  size: 24,
                  color: AppColors.taxiYellowDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isRu
                          ? 'Маршрут не запланирован'
                          : 'Safar yo‘nalishini belgilang',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: isDark ? Colors.white : AppColors.charcoalBlack,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isRu
                          ? 'Укажите маршрут, чтобы получать заказы'
                          : 'Buyurtmalar olish uchun yo‘nalishni belgilang',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            isDark ? Colors.white60 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            isRu
                ? 'Чтобы видеть заказы пассажиров и посылок, сначала запланируйте поездку (откуда, куда, время выезда и цену).'
                : 'Yo‘lovchilar va posilka buyurtmalarini ko‘rish uchun avval qatnov yo‘nalishingiz (qayerdan, qayerga, soat nechi va narxi)ni rejalashtiring.',
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: isRu ? 'Запланировать поездку' : 'Safar rejalashtirish',
              variant: AppButtonVariant.taxi,
              height: 46,
              leadingIcon: const Icon(Icons.add_rounded, size: 20),
              onPressed: () {
                HapticFeedback.mediumImpact();
                context.push('/driver/create-trip');
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Empty illustration state when NO trip is planned
  Widget _buildNoRouteEmptyState(BuildContext context, bool isDark, bool isRu) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF18181E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF282832) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  AppColors.taxiYellow.withValues(alpha: isDark ? 0.2 : 0.12),
            ),
            child: const Icon(
              Icons.people_outline_rounded,
              size: 40,
              color: AppColors.taxiYellowDark,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isRu
                ? 'Здесь появятся пассажиры'
                : 'Yo‘lovchilar shu yerda chiqadi',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            isRu
                ? 'После того как вы укажете свой маршрут, сюда поступят заявки от людей, которые едут именно по вашему направлению.'
                : 'Qatnovingizni e’lon qilganingizdan so‘ng, aynan sizning yo‘lingiz bo‘yicha ketmoqchi bo‘lgan yo‘lovchilar zayavkalari shu yerda ko‘rinadi.',
            style: AppTypography.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              fontSize: 12.5,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Driver's Real Active Planned Route Card
  Widget _buildActiveRouteBanner(
    BuildContext context,
    WidgetRef ref,
    RideEntity ride,
    List<RideEntity> allActiveRides,
    bool isDark,
    bool isRu,
  ) {
    return RepaintBoundary(
      key: ValueKey('active_route_${ride.id}'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1B1B22) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? const Color(0xFF2C2C38) : const Color(0xFFE2E4E8),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // If driver has multiple active trips, allow switching between them
            if (allActiveRides.length > 1) ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: allActiveRides.map((r) {
                    final isSelected = r.id == ride.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                          '${r.departureCity.nameUz} ➔ ${r.destinationCity.nameUz}',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight:
                                isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected
                                ? AppColors.charcoalBlack
                                : (isDark
                                    ? Colors.white70
                                    : AppColors.charcoalBlack),
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.taxiYellow,
                        backgroundColor: isDark
                            ? const Color(0xFF282832)
                            : const Color(0xFFF3F4F6),
                        onSelected: (_) {
                          HapticFeedback.selectionClick();
                          ref
                              .read(driverNotifierProvider.notifier)
                              .selectPlannedRide(r.id);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Top Header: Label & Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.route_rounded,
                        size: 18, color: AppColors.taxiYellowDark),
                    const SizedBox(width: 8),
                    Text(
                      isRu
                          ? 'Ваш активный маршрут'
                          : 'Sizning faol yo‘nalishingiz',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                        color: isDark ? Colors.white : AppColors.charcoalBlack,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isRu ? 'АКТИВЕН' : 'FAOL QATNOV',
                    style: const TextStyle(
                      color: AppColors.success,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Route visualization (Origin ➔ Destination)
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: AppColors.success, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(
                  ride.departureCity.nameUz,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: isDark ? Colors.white : AppColors.charcoalBlack,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward_rounded,
                      size: 14, color: AppColors.gray400),
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: AppColors.error, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(
                  ride.destinationCity.nameUz,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: isDark ? Colors.white : AppColors.charcoalBlack,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Details row: Departure time, available seats, price
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _buildMetaChip(
                  icon: Icons.access_time_rounded,
                  text: DateFormat('dd MMM, HH:mm').format(ride.departureTime),
                  isDark: isDark,
                ),
                _buildMetaChip(
                  icon: Icons.event_seat_rounded,
                  text: '${ride.availableSeats} ta bo‘sh joy',
                  isDark: isDark,
                ),
                _buildMetaChip(
                  icon: Icons.payments_outlined,
                  text:
                      '${AppCurrencyFormatter.format(ride.pricePerSeat, locale: isRu ? 'ru' : 'uz')} / o‘rin',
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Action buttons: Cancel, New trip
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      _confirmCancelRide(context, ref, ride.id, isRu);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(
                          color: AppColors.error.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      minimumSize: Size.zero,
                    ),
                    child: Text(
                      isRu ? 'Отменить поездку' : 'Qatnovni bekor qilish',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      context.push('/driver/create-trip');
                    },
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: Text(
                      isRu ? 'Новая поездка' : 'Yangi qatnov',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.taxiYellow,
                      foregroundColor: AppColors.charcoalBlack,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      minimumSize: Size.zero,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaChip(
      {required IconData icon, required String text, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF242430) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.taxiYellowDark),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : AppColors.charcoalBlack,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmCancelRide(
      BuildContext context, WidgetRef ref, String rideId, bool isRu) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isRu ? 'Отменить поездку?' : 'Qatnovni bekor qilasizmi?',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        content: Text(
          isRu
              ? 'Маршрут и связанные с ним заявки будут удалены.'
              : 'Ushbu qatnov va unga bog‘liq barcha zayavkalar bekor qilinadi.',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(isRu ? 'Назад' : 'Ortga'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(isRu ? 'Да, отменить' : 'Ha, bekor qilish'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(driverNotifierProvider.notifier).cancelRide(rideId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(isRu ? 'Поездка отменена' : 'Qatnov bekor qilindi')),
        );
      }
    }
  }

  /// Empty State when active trip exists but no passengers have booked yet
  Widget _buildEmptyOrdersState(
      BuildContext context, RideEntity ride, bool isDark, bool isRu) {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF18181E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF282832) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  AppColors.taxiYellow.withValues(alpha: isDark ? 0.2 : 0.15),
            ),
            child: const Icon(
              Icons.hourglass_empty_rounded,
              size: 38,
              color: AppColors.taxiYellowDark,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            isRu ? 'Ожидание заявок' : 'Zayavkalar kutilmoqda',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            isRu
                ? 'Ваша поездка ${ride.departureCity.nameUz} ➔ ${ride.destinationCity.nameUz} опубликована. Пассажиры увидят её и отправят запрос на бронирование.'
                : 'Sizning ${ride.departureCity.nameUz} ➔ ${ride.destinationCity.nameUz} qatnovingiz e’lon qilindi. Yo‘lovchilar uni ko‘rib, joy band qilishganda bu yerda chiqadi.',
            style: AppTypography.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              fontSize: 12.5,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Simplified, clean initial Passenger Request Card
  Widget _buildOrderRequestCard(
    BuildContext context,
    WidgetRef ref,
    DriverIncomingRequestEntity req,
    bool isDark,
    bool isRu,
  ) {
    final isParcel = req.type == DriverRequestType.expressParcel;

    return RepaintBoundary(
      key: ValueKey('req_card_${req.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1B1B22) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF2C2C38) : const Color(0xFFE5E7EB),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () =>
                _showOrderDetailsBottomSheet(context, ref, req, isDark, isRu),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Top row: Avatar, Name, Rating, Seat / Parcel Tag & Price
                  Row(
                    children: [
                      AppAvatarInitials(
                          name: req.passengerName, size: 38, fontSize: 14),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              req.passengerName,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14.5,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.charcoalBlack,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded,
                                    size: 14, color: AppColors.starGold),
                                const SizedBox(width: 3),
                                Text(
                                  '${req.passengerRating}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: isParcel
                                        ? AppColors.warning
                                            .withValues(alpha: 0.15)
                                        : AppColors.taxiYellow
                                            .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isParcel
                                        ? (isRu ? 'Посылка' : 'Posilka')
                                        : (isRu
                                            ? '${req.seatsCount} место'
                                            : '${req.seatsCount} ta joy'),
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      color: isParcel
                                          ? AppColors.warning
                                          : AppColors.charcoalBlack,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            AppCurrencyFormatter.format(req.totalPrice,
                                locale: isRu ? 'ru' : 'uz'),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                              color: AppColors.taxiYellowDark,
                            ),
                          ),
                          Text(
                            isRu ? 'Подробнее ›' : 'Batafsil ›',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.white54
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // 2. Route Summary: Pickup -> Dropoff
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                            color: AppColors.success, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          req.pickupAddress,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white70
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(Icons.arrow_forward_rounded,
                            size: 12, color: AppColors.gray400),
                      ),
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                            color: AppColors.error, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          req.dropoffAddress,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white70
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Detailed Bottom Sheet with full info, Call, Chat, Map navigation, and Accept/Reject
  void _showOrderDetailsBottomSheet(
    BuildContext context,
    WidgetRef ref,
    DriverIncomingRequestEntity req,
    bool isDark,
    bool isRu,
  ) {
    HapticFeedback.selectionClick();
    final isParcel = req.type == DriverRequestType.expressParcel;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : AppColors.gray300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isRu ? 'Детали заказа' : 'Buyurtma to‘liq ma’lumoti',
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(bottomSheetContext),
                      icon: const Icon(Icons.close_rounded, size: 22),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Passenger profile info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF22222C)
                        : const Color(0xFFF7F8FA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      AppAvatarInitials(
                          name: req.passengerName, size: 48, fontSize: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              req.passengerName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 16),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded,
                                    size: 15, color: AppColors.starGold),
                                const SizedBox(width: 4),
                                Text(
                                  '${req.passengerRating}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12.5),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isParcel
                                      ? (isRu ? 'Посылка' : 'Posilka')
                                      : (isRu
                                          ? '${req.seatsCount} место'
                                          : '${req.seatsCount} ta o‘rindiq'),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.white70
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              req.passengerPhone,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white54
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Communication buttons: Call & Chat
                Row(
                  children: [
                    // Qo'ng'iroq (Call)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _makePhoneCall(req.passengerPhone),
                        icon: const Icon(Icons.phone_rounded, size: 18),
                        label: Text(
                          isRu ? 'Позвонить' : 'Qo‘ng‘iroq',
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Chat
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _openChatDialog(
                            bottomSheetContext, req, isDark, isRu),
                        icon: const Icon(Icons.chat_bubble_outline_rounded,
                            size: 18),
                        label: Text(
                          isRu ? 'Чат' : 'Chat',
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? const Color(0xFF2C2C3A)
                              : const Color(0xFFEAECEF),
                          foregroundColor:
                              isDark ? Colors.white : AppColors.charcoalBlack,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Detailed Addresses
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF22222C)
                        : const Color(0xFFF7F8FA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? AppColors.cardBorderDark
                          : AppColors.cardBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pickup
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 3),
                            child: Icon(Icons.circle,
                                size: 10, color: AppColors.success),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isRu
                                      ? 'Откуда (мижозни олиш жойи):'
                                      : 'Qayerdan (mijozni olish joyi):',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? Colors.white60
                                        : AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  req.pickupAddress,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(height: 1),
                      ),
                      // Dropoff
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 3),
                            child: Icon(Icons.location_on_rounded,
                                size: 14, color: AppColors.error),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isRu
                                      ? 'Куда (манзил):'
                                      : 'Qayerga (borish manzili):',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? Colors.white60
                                        : AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  req.dropoffAddress,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Passenger comment if present
                if (req.comment != null && req.comment!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.taxiYellow.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      isRu
                          ? 'Комментарий: "${req.comment}"'
                          : 'Mijoz izohi: "${req.comment}"',
                      style: const TextStyle(
                          fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // "Manzilni olish" / "Xaritada ko'rish" Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      Navigator.pop(bottomSheetContext); // close bottom sheet
                      context.push('/driver/map',
                          extra: req); // navigate directly to standalone map
                    },
                    icon: const Icon(Icons.map_rounded,
                        color: AppColors.taxiYellowDark, size: 20),
                    label: Text(
                      isRu
                          ? 'Получить адрес (Посмотреть на карте)'
                          : 'Manzilni olish (Xaritada ko‘rish)',
                      style: const TextStyle(
                        color: AppColors.taxiYellowDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: AppColors.taxiYellowDark, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Price Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isRu ? 'Сумма заказа:' : 'Buyurtma narxi:',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color:
                            isDark ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      AppCurrencyFormatter.format(req.totalPrice,
                          locale: isRu ? 'ru' : 'uz'),
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: AppColors.taxiYellowDark,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Accept & Reject Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          ref
                              .read(driverNotifierProvider.notifier)
                              .rejectRequest(req.id);
                          Navigator.pop(bottomSheetContext);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              isDark ? Colors.white70 : AppColors.textSecondary,
                          side: BorderSide(
                            color: isDark
                                ? const Color(0xFF33333E)
                                : const Color(0xFFD1D5DB),
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                        child: Text(
                          isRu ? 'Отклонить' : 'Rad etish',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13.5),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          ref
                              .read(driverNotifierProvider.notifier)
                              .acceptRequest(req.id);
                          Navigator.pop(bottomSheetContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isRu
                                    ? 'Заказ успешно принят!'
                                    : 'Buyurtma muvaffaqiyatli qabul qilindi!',
                              ),
                              backgroundColor: AppColors.success,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.taxiYellow,
                          foregroundColor: AppColors.charcoalBlack,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          elevation: 1,
                        ),
                        child: Text(
                          isRu ? 'Принять заказ' : 'Qabul qilish',
                          style: const TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Quick Chat Dialog for the Driver to communicate with the Passenger
  void _openChatDialog(
    BuildContext context,
    DriverIncomingRequestEntity req,
    bool isDark,
    bool isRu,
  ) {
    final textController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (chatCtx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
              18, 14, 18, MediaQuery.of(chatCtx).viewInsets.bottom + 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isRu
                        ? 'Чат с ${req.passengerName}'
                        : '${req.passengerName} bilan chat',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(chatCtx),
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Quick templates
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _quickMessageChip(chatCtx, textController,
                      isRu ? 'Уже подъезжаю' : 'Yetib boryapman'),
                  _quickMessageChip(chatCtx, textController,
                      isRu ? 'Я на месте' : 'Yetib keldim'),
                  _quickMessageChip(chatCtx, textController,
                      isRu ? 'Где именно стоите?' : 'Qayerdasiz?'),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: textController,
                      decoration: InputDecoration(
                        hintText:
                            isRu ? 'Напишите сообщение...' : 'Xabar yozing...',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white38 : AppColors.gray400,
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF22222C)
                            : const Color(0xFFF3F4F6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      final text = textController.text.trim();
                      if (text.isNotEmpty) {
                        Navigator.pop(chatCtx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isRu
                                  ? 'Сообщение отправлено пассажиру!'
                                  : 'Xabar mijozga jo‘natildi!',
                            ),
                            backgroundColor: AppColors.success,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.taxiYellow,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded,
                          size: 18, color: AppColors.charcoalBlack),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _quickMessageChip(
      BuildContext context, TextEditingController controller, String message) {
    return InkWell(
      onTap: () {
        controller.text = message;
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.taxiYellow.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: AppColors.taxiYellowDark,
          ),
        ),
      ),
    );
  }
}
