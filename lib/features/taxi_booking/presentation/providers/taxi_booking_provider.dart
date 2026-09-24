import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/repositories/taxi_navigation_repository_impl.dart';
import '../../domain/entities/map_location.dart';
import '../../domain/entities/nearby_driver.dart';
import '../../domain/entities/taxi_route.dart';
import '../../domain/entities/taxi_vehicle_tier.dart';
import '../../domain/repositories/taxi_navigation_repository.dart';

final taxiNavigationRepositoryProvider =
    Provider<TaxiNavigationRepository>((ref) {
  return TaxiNavigationRepositoryImpl();
});

enum TaxiBookingStatus {
  idle,
  selectingPickup,
  selectingDestination,
  routeReady,
  searchingDriver,
  driverAssigned,
  driverArrived,
  tripInProgress,
}

class TaxiBookingState {
  const TaxiBookingState({
    this.currentGpsLocation,
    this.pickupLocation,
    this.destinationLocation,
    this.route,
    this.vehicleTiers = const [],
    this.selectedTierType = VehicleTierType.economy,
    this.nearbyDrivers = const [],
    this.assignedDriver,
    this.searchResults = const [],
    this.status = TaxiBookingStatus.idle,
    this.isLoading = false,
    this.isMapMoving = false,
    this.errorMessage,
  });

  final MapLocation? currentGpsLocation;
  final MapLocation? pickupLocation;
  final MapLocation? destinationLocation;
  final TaxiRoute? route;
  final List<TaxiVehicleTier> vehicleTiers;
  final VehicleTierType selectedTierType;
  final List<NearbyDriver> nearbyDrivers;
  final NearbyDriver? assignedDriver;
  final List<MapLocation> searchResults;
  final TaxiBookingStatus status;
  final bool isLoading;
  final bool isMapMoving;
  final String? errorMessage;

  TaxiVehicleTier? get selectedTier {
    if (vehicleTiers.isEmpty) return null;
    return vehicleTiers.firstWhere(
      (t) => t.type == selectedTierType,
      orElse: () => vehicleTiers.first,
    );
  }

  TaxiBookingState copyWith({
    MapLocation? currentGpsLocation,
    MapLocation? pickupLocation,
    MapLocation? destinationLocation,
    TaxiRoute? route,
    List<TaxiVehicleTier>? vehicleTiers,
    VehicleTierType? selectedTierType,
    List<NearbyDriver>? nearbyDrivers,
    NearbyDriver? assignedDriver,
    List<MapLocation>? searchResults,
    TaxiBookingStatus? status,
    bool? isLoading,
    bool? isMapMoving,
    String? errorMessage,
    bool clearRoute = false,
    bool clearDestination = false,
    bool clearAssignedDriver = false,
  }) {
    return TaxiBookingState(
      currentGpsLocation: currentGpsLocation ?? this.currentGpsLocation,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      destinationLocation: clearDestination
          ? null
          : (destinationLocation ?? this.destinationLocation),
      route: clearRoute ? null : (route ?? this.route),
      vehicleTiers: vehicleTiers ?? this.vehicleTiers,
      selectedTierType: selectedTierType ?? this.selectedTierType,
      nearbyDrivers: nearbyDrivers ?? this.nearbyDrivers,
      assignedDriver:
          clearAssignedDriver ? null : (assignedDriver ?? this.assignedDriver),
      searchResults: searchResults ?? this.searchResults,
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      isMapMoving: isMapMoving ?? this.isMapMoving,
      errorMessage: errorMessage,
    );
  }
}

class TaxiBookingNotifier extends StateNotifier<TaxiBookingState> {
  TaxiBookingNotifier(this._repository) : super(const TaxiBookingState()) {
    initializeMap();
  }

  final TaxiNavigationRepository _repository;
  Timer? _driverSimulationTimer;

  Future<void> initializeMap() async {
    state = state.copyWith(isLoading: true);
    try {
      final gpsLoc = await _repository.getCurrentLocation();
      final center = LatLng(gpsLoc.latitude, gpsLoc.longitude);
      final drivers = await _repository.getNearbyDrivers(center);
      final initialTiers = _repository.computeVehicleTiers(5.0);

      state = state.copyWith(
        currentGpsLocation: gpsLoc,
        pickupLocation: gpsLoc,
        nearbyDrivers: drivers,
        vehicleTiers: initialTiers,
        status: TaxiBookingStatus.idle,
        isLoading: false,
      );

      _startDriverMovementSimulation();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void _startDriverMovementSimulation() {
    _driverSimulationTimer?.cancel();
    _driverSimulationTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (!mounted || state.nearbyDrivers.isEmpty) return;

      final updated = state.nearbyDrivers.map((driver) {
        final double deltaLat = (Random().nextDouble() - 0.5) * 0.0004;
        final double deltaLng = (Random().nextDouble() - 0.5) * 0.0004;
        final double newHeading =
            (driver.heading + (Random().nextDouble() * 20 - 10)) % 360;

        return driver.copyWith(
          latitude: driver.latitude + deltaLat,
          longitude: driver.longitude + deltaLng,
          heading: newHeading,
        );
      }).toList();

      state = state.copyWith(nearbyDrivers: updated);
    });
  }

  Future<void> searchPlaces(String query) async {
    final results = await _repository.searchPlaces(query);
    state = state.copyWith(searchResults: results);
  }

  void clearSearchResults() {
    state = state.copyWith(searchResults: []);
  }

  Future<void> setPickupLocation(MapLocation location) async {
    state = state.copyWith(pickupLocation: location);
    if (state.destinationLocation != null) {
      await calculateRoute();
    }
  }

  Future<void> setDestinationLocation(MapLocation location) async {
    state = state.copyWith(
      destinationLocation: location,
      status: TaxiBookingStatus.routeReady,
    );
    await calculateRoute();
  }

  Future<void> calculateRoute() async {
    final pickup = state.pickupLocation;
    final destination = state.destinationLocation;
    if (pickup == null || destination == null) return;

    state = state.copyWith(isLoading: true);
    try {
      final route = await _repository.calculateRoute(
        pickup: pickup,
        destination: destination,
      );
      final tiers = _repository.computeVehicleTiers(route.distanceKm);

      state = state.copyWith(
        route: route,
        vehicleTiers: tiers,
        status: TaxiBookingStatus.routeReady,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Marshrut hisoblashda xatolik yuz berdi: $e',
      );
    }
  }

  void selectVehicleTier(VehicleTierType type) {
    state = state.copyWith(selectedTierType: type);
  }

  Future<void> requestTaxiOrder() async {
    if (state.route == null) return;

    state = state.copyWith(status: TaxiBookingStatus.searchingDriver);

    // Simulate driver matching within 2.5 seconds
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    final selectedTier = state.selectedTierType;
    final matchedDriver = state.nearbyDrivers.firstWhere(
      (d) => d.tier == selectedTier,
      orElse: () => state.nearbyDrivers.first,
    );

    state = state.copyWith(
      status: TaxiBookingStatus.driverAssigned,
      assignedDriver: matchedDriver,
    );
  }

  void cancelOrder() {
    state = state.copyWith(
      status: state.route != null
          ? TaxiBookingStatus.routeReady
          : TaxiBookingStatus.idle,
      clearAssignedDriver: true,
    );
  }

  void resetSearch() {
    state = state.copyWith(
      clearRoute: true,
      clearDestination: true,
      clearAssignedDriver: true,
      status: TaxiBookingStatus.idle,
    );
  }

  @override
  void dispose() {
    _driverSimulationTimer?.cancel();
    super.dispose();
  }
}

final taxiBookingNotifierProvider =
    StateNotifierProvider.autoDispose<TaxiBookingNotifier, TaxiBookingState>(
        (ref) {
  final repo = ref.watch(taxiNavigationRepositoryProvider);
  return TaxiBookingNotifier(repo);
});
