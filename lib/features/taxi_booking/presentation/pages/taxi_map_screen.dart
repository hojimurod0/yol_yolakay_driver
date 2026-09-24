import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/config/google_maps_config.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/map_location.dart';
import '../providers/taxi_booking_provider.dart';
import '../widgets/driver_searching_dialog.dart';
import '../widgets/taxi_bottom_sheet.dart';
import '../widgets/tezkor_taksi_coming_soon_modal.dart';

/// Full-Screen Interactive Yandex Go style Taxi Navigation & Booking Screen.
class TaxiMapScreen extends ConsumerStatefulWidget {
  const TaxiMapScreen({super.key});

  @override
  ConsumerState<TaxiMapScreen> createState() => _TaxiMapScreenState();
}

class _TaxiMapScreenState extends ConsumerState<TaxiMapScreen> {
  GoogleMapController? _mapController;
  final MapType _currentMapType = MapType.normal;

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(GoogleMapsConfig.defaultLat, GoogleMapsConfig.defaultLng),
    zoom: 15.5,
  );

  @override
  void initState() {
    super.initState();
    // Auto-detect and set current GPS location immediately on entering
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(taxiBookingNotifierProvider.notifier);
      notifier.initializeMap();
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    final state = ref.read(taxiBookingNotifierProvider);
    if (state.pickupLocation != null) {
      _animateToLocation(
        LatLng(state.pickupLocation!.latitude, state.pickupLocation!.longitude),
        zoom: 15.8,
      );
    }
  }

  void _animateToLocation(LatLng target, {double zoom = 15.8}) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: zoom),
      ),
    );
  }

  void _fitRouteBounds(List<LatLng> points) {
    if (points.isEmpty || _mapController == null || !mounted) return;

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (var p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    if ((maxLat - minLat).abs() < 0.001) {
      minLat -= 0.01;
      maxLat += 0.01;
    }
    if ((maxLng - minLng).abs() < 0.001) {
      minLng -= 0.01;
      maxLng += 0.01;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    try {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 45),
      );
    } catch (_) {
      // Fallback in case map view size isn't fully calculated
      final centerLat = (minLat + maxLat) / 2;
      final centerLng = (minLng + maxLng) / 2;
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(centerLat, centerLng), 13.0),
      );
    }
  }

  Set<Marker> _buildMarkers(TaxiBookingState state, String localeCode) {
    final Set<Marker> markers = {};

    // 1. Pickup Location Marker (Glowing neon purple / Yandex pin with tooltip)
    if (state.pickupLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('pickup_marker'),
          position: LatLng(
            state.pickupLocation!.latitude,
            state.pickupLocation!.longitude,
          ),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
          infoWindow: InfoWindow(
            title: localeCode == 'ru'
                ? 'Посадка через 5 мин'
                : 'Jo\'nash 3-5 daqiqada',
            snippet: state.pickupLocation!.title,
          ),
        ),
      );
    }

    // 2. Destination Marker (Red Pin)
    if (state.destinationLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('destination_marker'),
          position: LatLng(
            state.destinationLocation!.latitude,
            state.destinationLocation!.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: localeCode == 'ru' ? 'Куда' : 'Borish joyi',
            snippet: state.destinationLocation!.title,
          ),
        ),
      );
    }

    // 3. Nearby Moving Drivers Markers (Yellow/Orange Taxi Cars)
    for (var driver in state.nearbyDrivers) {
      markers.add(
        Marker(
          markerId: MarkerId(driver.id),
          position: LatLng(driver.latitude, driver.longitude),
          rotation: driver.heading,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
          infoWindow: InfoWindow(
            title: '${driver.name} (${driver.carModel})',
            snippet: '★ ${driver.rating} • ${driver.licensePlate}',
          ),
        ),
      );
    }

    return markers;
  }

  Set<Polyline> _buildPolylines(TaxiBookingState state) {
    final Set<Polyline> polylines = {};
    if (state.route != null && state.route!.polylinePoints.isNotEmpty) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('driving_route_polyline'),
          points: state.route!.polylinePoints,
          color: AppColors.yandexYellow,
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
        ),
      );
    }
    return polylines;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = ref.watch(localeNotifierProvider);
    final localeCode = locale.languageCode;
    final isRu = localeCode == 'ru';
    final state = ref.watch(taxiBookingNotifierProvider);
    final notifier = ref.read(taxiBookingNotifierProvider.notifier);

    // Auto-fit route bounds when a route becomes available
    ref.listen<TaxiBookingState>(taxiBookingNotifierProvider, (previous, next) {
      if (next.route != null && previous?.route != next.route) {
        _fitRouteBounds(next.route!.polylinePoints);
      }
    });

    final currentPickupTitle =
        state.pickupLocation?.title ?? (isRu ? 'Ташкент' : 'Toshkent');

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121216) : Colors.white,
      body: Stack(
        children: [
          // 1. Google Maps View occupying full screen
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            mapType: _currentMapType,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: false,
            padding: EdgeInsets.only(
              bottom: state.status == TaxiBookingStatus.routeReady
                  ? 280
                  : (state.status == TaxiBookingStatus.searchingDriver ||
                          state.status == TaxiBookingStatus.driverAssigned
                      ? 260
                      : 290),
              top: 70,
            ),
            markers: _buildMarkers(state, localeCode),
            polylines: _buildPolylines(state),
            onMapCreated: _onMapCreated,
            onTap: (LatLng tappedPoint) async {
              final repo = ref.read(taxiNavigationRepositoryProvider);
              final address = await repo.getAddressFromCoordinates(tappedPoint);
              if (state.destinationLocation == null) {
                notifier.setDestinationLocation(address);
              } else {
                notifier.setPickupLocation(address);
              }
            },
          ),

          // 2. Center Live Pickup Tooltip Indicator
          if (state.status == TaxiBookingStatus.idle ||
              state.status == TaxiBookingStatus.selectingPickup ||
              state.status == TaxiBookingStatus.selectingDestination)
            Positioned(
              left: 0,
              right: 0,
              top: MediaQuery.of(context).size.height * 0.30,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tooltip Speech Bubble
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: (isDark ? const Color(0xFF1E1E26) : Colors.white)
                            .withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: isDark ? 0.35 : 0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : const Color(0xFFE2E4E8),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isRu
                                ? 'Посадка через 3-5 мин'
                                : 'Jo\'nash 3-5 daqiqada',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.taxiYellow
                                  : AppColors.taxiYellowDark,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            currentPickupTitle,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : AppColors.charcoalBlack,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Glowing Taxi Yellow Map Pin
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.taxiYellow,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.taxiYellow.withValues(alpha: 0.6),
                            blurRadius: 16,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.charcoalBlack,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 3. Top Navigation Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Circular Translucent Menu / Reset Button
                  InkWell(
                    onTap: () {
                      if (state.status == TaxiBookingStatus.routeReady) {
                        notifier.resetSearch();
                      } else {
                        // Switch to Home tab if back is tapped
                        context.go('/home');
                      }
                    },
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: (isDark ? const Color(0xFF1E1E26) : Colors.white)
                            .withValues(alpha: 0.92),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF2C2C36)
                              : const Color(0xFFE2E4E8),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: isDark ? 0.25 : 0.08),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          state.status == TaxiBookingStatus.routeReady
                              ? Icons.arrow_back_rounded
                              : Icons.menu_rounded,
                          color:
                              isDark ? Colors.white : AppColors.charcoalBlack,
                          size: 22,
                        ),
                      ),
                    ),
                  ),

                  // Points / Bonus Pill (e.g. "5392 🟢")
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: (isDark ? const Color(0xFF1E1E26) : Colors.white)
                          .withValues(alpha: 0.92),
                      borderRadius: AppRadius.borderPill,
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF2C2C36)
                            : const Color(0xFFE2E4E8),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: isDark ? 0.25 : 0.08),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '5 392',
                          style: TextStyle(
                            color:
                                isDark ? Colors.white : AppColors.charcoalBlack,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 14,
                          height: 14,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF00B956),
                          ),
                          child: const Icon(
                            Icons.eco_rounded,
                            color: Colors.white,
                            size: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Floating GPS Re-Center Navigation Arrow
          Positioned(
            right: 16,
            bottom: state.status == TaxiBookingStatus.routeReady
                ? 290
                : (state.status == TaxiBookingStatus.searchingDriver ||
                        state.status == TaxiBookingStatus.driverAssigned
                    ? 270
                    : 300),
            child: Material(
              color: (isDark ? const Color(0xFF1E1E26) : Colors.white)
                  .withValues(alpha: 0.95),
              shape: const CircleBorder(),
              elevation: 4,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  if (state.currentGpsLocation != null) {
                    _animateToLocation(
                      LatLng(
                        state.currentGpsLocation!.latitude,
                        state.currentGpsLocation!.longitude,
                      ),
                      zoom: 16.0,
                    );
                  } else {
                    notifier.initializeMap();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.navigation_rounded,
                    color: isDark ? Colors.white : AppColors.charcoalBlack,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),

          // 5. Main Interactive Bottom Sheet
          if (state.status != TaxiBookingStatus.routeReady &&
              state.status != TaxiBookingStatus.searchingDriver &&
              state.status != TaxiBookingStatus.driverAssigned)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildDefaultTaxiPanel(
                context: context,
                isDark: isDark,
                isRu: isRu,
                notifier: notifier,
                state: state,
              ),
            ),

          // 6. Route Ready Vehicle Tiers Panel
          if (state.status == TaxiBookingStatus.routeReady &&
              state.route != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 74),
                child: TaxiBottomSheet(
                  route: state.route!,
                  vehicleTiers: state.vehicleTiers,
                  selectedTierType: state.selectedTierType,
                  localeCode: localeCode,
                  isLoading: state.isLoading,
                  onTierSelected: notifier.selectVehicleTier,
                  onOrderTaxi: notifier.requestTaxiOrder,
                ),
              ),
            ),

          // 7. Driver Searching / Assigned Modal
          if (state.status == TaxiBookingStatus.searchingDriver ||
              state.status == TaxiBookingStatus.driverAssigned)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 74),
                child: DriverSearchingDialog(
                  isAssigned: state.status == TaxiBookingStatus.driverAssigned,
                  driver: state.assignedDriver,
                  onCancel: notifier.cancelOrder,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Exact Bottom Sheet layout from the reference image, styled for Light & Dark mode
  Widget _buildDefaultTaxiPanel({
    required BuildContext context,
    required bool isDark,
    required bool isRu,
    required TaxiBookingNotifier notifier,
    required TaxiBookingState state,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          16, 10, 16, 88), // 88px clearance for bottom navigation tab bar
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF18181E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF282834) : const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle pill
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF383842) : const Color(0xFFD4D4D8),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Tez kunda informational banner
          InkWell(
            onTap: () => showTezkorTaksiModal(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.taxiYellow
                    .withValues(alpha: isDark ? 0.16 : 0.14),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.taxiYellowDark.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.taxiYellowDark, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isRu
                          ? 'Сервис городского такси запускается скоро! Нажмите для подробностей'
                          : 'Shahar ichi taksi xizmati tez kunda ishga tushadi! Batafsil bilish',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.taxiYellow
                            : AppColors.charcoalBlack,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 1. Big "Where are you going?" Search Bar
          InkWell(
            onTap: () => showTezkorTaksiModal(context),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF22222A) : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.taxiYellow
                      .withValues(alpha: isDark ? 0.35 : 0.6),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search_rounded,
                    color: AppColors.taxiYellowDark,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isRu ? 'Куда едем?' : 'Qayerga borasiz?',
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFFD4D4D8)
                          : AppColors.charcoalBlack,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 2. Recent Destinations Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildRecentChip(
                  label: isRu ? 'Объект, Ташкент' : 'Obyekt, Toshkent',
                  isDark: isDark,
                  onTap: () {
                    final place = MapLocation(
                      id: 'rec_1',
                      title: isRu ? 'Объект, Ташкент' : 'Obyekt, Toshkent',
                      subtitle:
                          isRu ? 'ул. Амира Темура' : 'Amir Temur ko\'chasi',
                      latitude: 41.3111,
                      longitude: 69.2797,
                    );
                    notifier.setDestinationLocation(place);
                  },
                ),
                const SizedBox(width: 8),
                _buildRecentChip(
                  label:
                      isRu ? 'Чинабад, 6в, Ташкент' : 'Chinobod, 6v, Toshkent',
                  isDark: isDark,
                  onTap: () {
                    final place = MapLocation(
                      id: 'rec_2',
                      title: isRu ? 'Чинабад, 6в' : 'Chinobod, 6v',
                      subtitle:
                          isRu ? 'Юнусабадский район' : 'Yunusobod tumani',
                      latitude: 41.3500,
                      longitude: 69.2880,
                    );
                    notifier.setDestinationLocation(place);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 3. Feature Cards (To multiple addresses & Ride request for a friend)
          Row(
            children: [
              // Card 1: To multiple addresses
              Expanded(
                child: Container(
                  height: 110,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF22222A)
                        : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF2E2E38)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.directions_car_filled_rounded,
                              color: AppColors.taxiYellowDark, size: 24),
                          const SizedBox(width: 6),
                          Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.taxiYellow,
                            ),
                            child: const Icon(Icons.location_on,
                                size: 10, color: AppColors.charcoalBlack),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isRu ? 'Несколько адресов' : 'Bir nechta manzil',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : AppColors.charcoalBlack,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isRu ? 'Одна поездка' : 'Bitta qatnovda',
                            style: TextStyle(
                              color: isDark
                                  ? const Color(0xFF8E8E98)
                                  : AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Card 2: Ride request for a friend
              Expanded(
                child: Container(
                  height: 110,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF22222A)
                        : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF2E2E38)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.people_alt_rounded,
                          color: Color(0xFF708090), size: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isRu ? 'Заказ для друга' : 'Do\'st uchun buyurtma',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : AppColors.charcoalBlack,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isRu ? 'Или для семьи' : 'Yoki yaqinlar uchun',
                            style: TextStyle(
                              color: isDark
                                  ? const Color(0xFF8E8E98)
                                  : AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentChip(
      {required String label,
      required bool isDark,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF22222A) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? const Color(0xFF2E2E38) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.access_time_filled_rounded,
                size: 14, color: AppColors.taxiYellowDark),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color:
                    isDark ? const Color(0xFFD4D4D8) : AppColors.charcoalBlack,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
