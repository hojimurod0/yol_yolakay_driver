import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/config/google_maps_config.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_avatar_initials.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../rides/domain/entities/ride_entity.dart';
import '../../domain/entities/driver_incoming_request_entity.dart';
import '../providers/driver_provider.dart';

/// Clean Full-Screen Map Navigation for viewing destination or route.
class DriverHomePage extends ConsumerStatefulWidget {
  const DriverHomePage({super.key, this.activeRequest});

  final DriverIncomingRequestEntity? activeRequest;

  @override
  ConsumerState<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends ConsumerState<DriverHomePage> {
  GoogleMapController? _mapController;
  Timer? _orderSimulationTimer;
  Set<Marker> _cachedMarkers = const <Marker>{};
  String? _lastCachedOrderId;

  static const LatLng _tashkentCenter = LatLng(
    GoogleMapsConfig.defaultLat,
    GoogleMapsConfig.defaultLng,
  );

  @override
  void initState() {
    super.initState();
    // Relaxed periodic check (30s) to prevent UI thread stutter and GC pressure
    _orderSimulationTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      final state = ref.read(driverNotifierProvider);
      if (state.isOnline &&
          state.activeTripStep == DriverTripStep.idle &&
          state.incomingRequests.isNotEmpty) {
        ref.read(driverNotifierProvider.notifier).refreshAll();
      }
    });
  }

  @override
  void dispose() {
    _orderSimulationTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _makeCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = ref.watch(localeNotifierProvider);
    final isRu = locale.languageCode == 'ru';
    final driverState = ref.watch(driverNotifierProvider);
    final isOnline = driverState.isOnline;

    final activeRides = driverState.driverRides
        .where((r) => r.status == RideStatus.active)
        .toList();
    final pendingRequests = driverState.incomingRequests
        .where((r) => r.status == DriverRequestStatus.pending)
        .toList();

    final currentOrder = driverState.activeOrder ??
        (pendingRequests.isNotEmpty ? pendingRequests.first : null);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Stack(
        children: [
          // 1. Dominant Full-Screen Map
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _tashkentCenter,
              zoom: 14.8,
            ),
            onMapCreated: (controller) => _mapController = controller,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: false,
            mapToolbarEnabled: false,
            markers: _buildMapMarkers(driverState, isDark),
          ),

          // 2. Clean Integrated Top Bar & Central Contextual Cards
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top Bar (Car, Plate, Online/Offline, Mode switch)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xF018181E)
                            : Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF2C2C38)
                              : const Color(0xFFE2E4E8),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: isDark ? 0.35 : 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Back Button to Buyurtmalar
                          InkWell(
                            onTap: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go('/driver/home');
                              }
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF282832)
                                    : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 16),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Route / Destination Title
                          Expanded(
                            child: Text(
                              widget.activeRequest != null
                                  ? widget.activeRequest!.dropoffAddress
                                  : "Xarita va Navigatsiya",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // Online / Offline Switch
                          InkWell(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              ref
                                  .read(driverNotifierProvider.notifier)
                                  .toggleOnlineStatus();
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: isOnline
                                    ? AppColors.taxiYellow
                                    : (isDark
                                        ? const Color(0xFF2A2A34)
                                        : const Color(0xFFE5E7EB)),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isOnline
                                      ? AppColors.taxiYellowDark
                                      : (isDark
                                          ? const Color(0xFF383844)
                                          : const Color(0xFFD1D5DB)),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: isOnline
                                          ? AppColors.success
                                          : Colors.grey,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    isOnline
                                        ? (isRu ? "ОНЛАЙН" : "ONLAYN")
                                        : (isRu ? "OФЛАЙН" : "OFLAYN"),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: isOnline
                                          ? AppColors.charcoalBlack
                                          : (isDark
                                              ? Colors.white70
                                              : Colors.black87),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Card 1: Active Planned Route (Marshrut)
                    _buildActiveRouteCard(context, activeRides, isDark, isRu),

                    const SizedBox(height: 8),

                    // Card 2: Active or Incoming Order Request Card
                    if (currentOrder != null)
                      _buildIncomingOrderCard(context, ref, currentOrder,
                          driverState.activeTripStep, isDark, isRu)
                    else if (isOnline)
                      _buildWaitingOrdersPill(context, isDark, isRu)
                    else
                      _buildOfflineNoticeCard(context, ref, isDark, isRu),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Card 1: Driver's Active Route Banner
  Widget _buildActiveRouteCard(BuildContext context,
      List<RideEntity> activeRides, bool isDark, bool isRu) {
    final hasRoute = activeRides.isNotEmpty;
    final ride = hasRoute ? activeRides.first : null;

    final depCity = ride?.departureCity.nameUz ?? 'Toshkent';
    final destCity = ride?.destinationCity.nameUz ?? 'Samarqand';
    final bookedSeats =
        ride != null ? (ride.totalSeats - ride.availableSeats) : 3;
    final totalSeats = ride?.totalSeats ?? 4;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xF518181E)
            : Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2C2C38) : const Color(0xFFE2E4E8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.taxiYellow.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.route_rounded,
                size: 18, color: AppColors.taxiYellowDark),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "$depCity ➔ $destCity",
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 13.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  "Bugun 08:00 • $bookedSeats/$totalSeats joy band",
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white60 : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => context.push('/driver/create-trip'),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF262630) : const Color(0xFFF1F3F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                hasRoute ? (isRu ? 'Sozlash' : 'O‘zgartirish') : '+ Qatnov',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.taxiYellowDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Card 2: Interactive Order Request or Active Trip Card
  Widget _buildIncomingOrderCard(
    BuildContext context,
    WidgetRef ref,
    DriverIncomingRequestEntity order,
    DriverTripStep step,
    bool isDark,
    bool isRu,
  ) {
    String stepTitle;
    String buttonText;
    Color statusColor;
    VoidCallback onPrimaryAction;

    if (step == DriverTripStep.goingToPickup) {
      stepTitle = isRu ? "Едем к клиенту" : "Mijoz tomon yo‘lda";
      buttonText = isRu ? "Я на месте" : "Yetib keldim";
      statusColor = AppColors.warning;
      onPrimaryAction = () {
        HapticFeedback.mediumImpact();
        ref.read(driverNotifierProvider.notifier).markArrivedAtPickup();
      };
    } else if (step == DriverTripStep.arrived) {
      stepTitle = isRu ? "Ожидание пассажира" : "Mijoz kutilmoqda";
      buttonText = isRu ? "Начать поездку" : "Safarni boshlash";
      statusColor = AppColors.info;
      onPrimaryAction = () {
        HapticFeedback.mediumImpact();
        ref.read(driverNotifierProvider.notifier).startTrip();
      };
    } else if (step == DriverTripStep.inProgress) {
      stepTitle = isRu ? "Поездка в процессе" : "Safar davom etmoqda";
      buttonText = isRu ? "Завершить поездку" : "Safarni yakunlash";
      statusColor = AppColors.taxiYellow;
      onPrimaryAction = () {
        HapticFeedback.heavyImpact();
        ref.read(driverNotifierProvider.notifier).completeTrip();
      };
    } else if (step == DriverTripStep.completed) {
      stepTitle = isRu ? "Поездка завершена!" : "Safar yakunlandi!";
      buttonText = isRu ? "Готов к следующему" : "Tayyor (Keyingi buyurtma)";
      statusColor = AppColors.success;
      onPrimaryAction = () {
        HapticFeedback.mediumImpact();
        ref.read(driverNotifierProvider.notifier).finishCompletedTrip();
      };
    } else {
      // Pending request
      stepTitle =
          isRu ? "Новая заявка на поездку" : "Qatnovingizga yangi zayavka";
      buttonText = isRu ? "Принять заказ" : "Qabul qilish";
      statusColor = AppColors.taxiYellowDark;
      onPrimaryAction = () {
        HapticFeedback.mediumImpact();
        ref.read(driverNotifierProvider.notifier).acceptRequest(order.id);
      };
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xF8181820) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.taxiYellow.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Step pill + Fare
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: AppRadius.borderPill,
                ),
                child: Text(
                  stepTitle,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                AppCurrencyFormatter.format(order.totalPrice,
                    locale: isRu ? 'ru' : 'uz'),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: AppColors.taxiYellowDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Clickable Address Container with Pickup & Dropoff
          InkWell(
            onTap: () =>
                _showOrderDetailsModal(context, ref, order, step, isDark, isRu),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF22222C) : const Color(0xFFF6F7FA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.circle,
                          size: 8, color: AppColors.success),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          order.pickupAddress,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color:
                                isDark ? Colors.white : AppColors.charcoalBlack,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          size: 11, color: AppColors.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          order.dropoffAddress,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Passenger info & Call
          Row(
            children: [
              AppAvatarInitials(
                  name: order.passengerName, size: 34, fontSize: 13),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.passengerName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                    Text(
                      "⭐ ${order.passengerRating} • ${order.seatsCount} ta joy",
                      style: TextStyle(
                        fontSize: 11,
                        color:
                            isDark ? Colors.white60 : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _makeCall(order.passengerPhone),
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.phone_rounded,
                      color: AppColors.success, size: 16),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Actions
          if (step == DriverTripStep.idle) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      ref
                          .read(driverNotifierProvider.notifier)
                          .rejectRequest(order.id);
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
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      isRu ? "Отклонить" : "Rad etish",
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppButton(
                    text: buttonText,
                    variant: AppButtonVariant.taxi,
                    height: 40,
                    onPressed: onPrimaryAction,
                  ),
                ),
              ],
            ),
          ] else ...[
            AppButton(
              text: buttonText,
              variant: AppButtonVariant.taxi,
              height: 40,
              onPressed: onPrimaryAction,
            ),
          ],
        ],
      ),
    );
  }

  /// Small floating pill when driver is online and waiting for passengers
  Widget _buildWaitingOrdersPill(BuildContext context, bool isDark, bool isRu) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xF018181E)
            : Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF2C2C38) : const Color(0xFFE2E4E8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppColors.taxiYellowDark),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isRu
                ? "Ожидание заявок пассажиров..."
                : "Yo‘lovchilar zayavkalari kutilmoqda...",
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  /// Contextual offline notice card showing a single primary CTA to go online
  Widget _buildOfflineNoticeCard(
      BuildContext context, WidgetRef ref, bool isDark, bool isRu) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xF8181820) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2C2C38) : const Color(0xFFE2E4E8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.wifi_off_rounded,
                    size: 20, color: Colors.grey),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isRu ? "Вы находитесь оффлайн" : "Siz hozir oflaynsiz",
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 13.5),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isRu
                          ? "Включите онлайн, чтобы получать заказы"
                          : "Buyurtmalarni qabul qilish uchun onlayn bo‘ling",
                      style: TextStyle(
                        fontSize: 11.5,
                        color:
                            isDark ? Colors.white60 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: isRu ? "ВЫЙТИ В ОНЛАЙН" : "ONLAYN BO‘LISH",
              variant: AppButtonVariant.taxi,
              height: 42,
              onPressed: () {
                HapticFeedback.mediumImpact();
                ref.read(driverNotifierProvider.notifier).toggleOnlineStatus();
              },
            ),
          ),
        ],
      ),
    );
  }

  Set<Marker> _buildMapMarkers(DriverState state, bool isDark) {
    final order = widget.activeRequest ?? state.activeOrder;
    final currentOrderId = order?.id;

    if (currentOrderId == _lastCachedOrderId && _cachedMarkers.isNotEmpty) {
      return _cachedMarkers;
    }
    _lastCachedOrderId = currentOrderId;

    if (order == null) {
      _cachedMarkers = const <Marker>{};
      return _cachedMarkers;
    }

    final markers = <Marker>{};
    // Destination Marker
    markers.add(
      Marker(
        markerId: const MarkerId('order_dropoff_pos'),
        position: LatLng(
          _tashkentCenter.latitude + 0.012,
          _tashkentCenter.longitude + 0.012,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: order.dropoffAddress),
      ),
    );
    // Pickup Marker
    markers.add(
      Marker(
        markerId: const MarkerId('order_pickup_pos'),
        position: LatLng(
          _tashkentCenter.latitude + 0.004,
          _tashkentCenter.longitude + 0.004,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: order.pickupAddress),
      ),
    );

    _cachedMarkers = markers;
    return _cachedMarkers;
  }

  /// Full Details Modal BottomSheet when driver taps on passenger card
  void _showOrderDetailsModal(
    BuildContext context,
    WidgetRef ref,
    DriverIncomingRequestEntity order,
    DriverTripStep step,
    bool isDark,
    bool isRu,
  ) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : AppColors.gray300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isRu ? 'Детали заказа' : 'Buyurtma tafsilotlari',
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 17),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
                ],
              ),
              const Divider(height: 1),
              const SizedBox(height: 14),

              // Passenger info
              Row(
                children: [
                  AppAvatarInitials(
                      name: order.passengerName, size: 48, fontSize: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.passengerName,
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
                              '${order.passengerRating} • ${order.seatsCount} ta o‘rindiq',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 12.5),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => _makeCall(order.passengerPhone),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.phone_rounded,
                              color: AppColors.success, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            isRu ? 'Звонок' : 'Qo‘ng‘iroq',
                            style: const TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Detailed Route Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF22222C)
                      : const Color(0xFFF6F7FA),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: isDark
                          ? AppColors.cardBorderDark
                          : AppColors.cardBorder),
                ),
                child: Column(
                  children: [
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
                                    ? 'Откуда (мижозни олиш):'
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
                                order.pickupAddress,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(height: 1),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 3),
                          child: Icon(Icons.location_on_rounded,
                              size: 13, color: AppColors.error),
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
                                order.dropoffAddress,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Comment if present
              if (order.comment != null && order.comment!.isNotEmpty) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.taxiYellow.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "Izoh: \"${order.comment}\"",
                    style: const TextStyle(
                        fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isRu ? 'Сумма к оплате:' : 'To‘lov summasi:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    AppCurrencyFormatter.format(order.totalPrice,
                        locale: isRu ? 'ru' : 'uz'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.taxiYellowDark,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Action Buttons
              if (step == DriverTripStep.idle)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          ref
                              .read(driverNotifierProvider.notifier)
                              .rejectRequest(order.id);
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              isDark ? Colors.white70 : AppColors.textSecondary,
                          side: BorderSide(
                              color: isDark
                                  ? const Color(0xFF33333E)
                                  : const Color(0xFFD1D5DB)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          isRu ? 'Отклонить' : 'Rad etish',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          ref
                              .read(driverNotifierProvider.notifier)
                              .acceptRequest(order.id);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.taxiYellow,
                          foregroundColor: AppColors.charcoalBlack,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 1,
                        ),
                        child: Text(
                          isRu ? 'Принять заказ' : 'Qabul qilish',
                          style: const TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 13.5),
                        ),
                      ),
                    ),
                  ],
                )
              else
                AppButton(
                  text: isRu ? 'Закрыть' : 'Yopish',
                  variant: AppButtonVariant.outline,
                  onPressed: () => Navigator.pop(context),
                ),
            ],
          ),
        );
      },
    );
  }
}
