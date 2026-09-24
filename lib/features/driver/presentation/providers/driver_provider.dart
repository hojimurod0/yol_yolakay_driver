import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/driver_incoming_request_entity.dart';
import '../../domain/entities/driver_profile_entity.dart';
import '../../domain/repositories/driver_repository.dart';
import '../../data/repositories/mock_driver_repository.dart';
import '../../../rides/domain/entities/ride_entity.dart';
import '../../../../core/providers/core_providers.dart';

final driverRepositoryProvider = Provider<DriverRepository>((ref) {
  return MockDriverRepository();
});

enum AppUserRole { passenger, driver }

enum DriverTripStep {
  idle,
  newRequest,
  goingToPickup,
  arrived,
  inProgress,
  completed,
}

class DriverState {
  const DriverState({
    this.role = AppUserRole.passenger,
    this.profile,
    this.driverRides = const [],
    this.incomingRequests = const [],
    this.activeTripStep = DriverTripStep.idle,
    this.activeOrder,
    this.selectedRideId,
    this.isLoading = false,
    this.errorMessage,
  });

  final AppUserRole role;
  final DriverProfileEntity? profile;
  final List<RideEntity> driverRides;
  final List<DriverIncomingRequestEntity> incomingRequests;
  final DriverTripStep activeTripStep;
  final DriverIncomingRequestEntity? activeOrder;
  final String? selectedRideId;
  final bool isLoading;
  final String? errorMessage;

  bool get isOnline => profile?.status == DriverOnlineStatus.online;

  List<RideEntity> get activeRides => driverRides
      .where(
          (r) => r.status == RideStatus.active || r.status == RideStatus.full)
      .toList();

  RideEntity? get activePlannedRide {
    final active = activeRides;
    if (active.isEmpty) return null;
    if (selectedRideId != null) {
      return active.firstWhere(
        (r) => r.id == selectedRideId,
        orElse: () => active.first,
      );
    }
    return active.first;
  }

  List<DriverIncomingRequestEntity> get activeRideIncomingRequests {
    final planned = activePlannedRide;
    if (planned == null) return const [];
    return incomingRequests.where((r) => r.rideId == planned.id).toList();
  }

  DriverState copyWith({
    AppUserRole? role,
    DriverProfileEntity? profile,
    List<RideEntity>? driverRides,
    List<DriverIncomingRequestEntity>? incomingRequests,
    DriverTripStep? activeTripStep,
    DriverIncomingRequestEntity? activeOrder,
    String? selectedRideId,
    bool clearSelectedRide = false,
    bool clearActiveOrder = false,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DriverState(
      role: role ?? this.role,
      profile: profile ?? this.profile,
      driverRides: driverRides ?? this.driverRides,
      incomingRequests: incomingRequests ?? this.incomingRequests,
      activeTripStep: activeTripStep ?? this.activeTripStep,
      activeOrder: clearActiveOrder ? null : (activeOrder ?? this.activeOrder),
      selectedRideId:
          clearSelectedRide ? null : (selectedRideId ?? this.selectedRideId),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class DriverNotifier extends StateNotifier<DriverState> {
  DriverNotifier(this._repository, this._ref) : super(const DriverState()) {
    _loadInitialState();
  }

  final DriverRepository _repository;
  final Ref _ref;

  Future<void> _loadInitialState() async {
    final prefs = _ref.read(sharedPreferencesProvider);
    final savedRoleStr = prefs.getString('user_role');
    final role =
        savedRoleStr == 'driver' ? AppUserRole.driver : AppUserRole.passenger;

    state = state.copyWith(isLoading: true, role: role);
    try {
      final profile = await _repository.getDriverProfile();
      final rides = await _repository.getDriverRides();
      final requests = await _repository.getIncomingRequests();
      state = state.copyWith(
        profile: profile,
        driverRides: rides,
        incomingRequests: requests,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void switchRole(AppUserRole newRole) {
    state = state.copyWith(role: newRole);
    final prefs = _ref.read(sharedPreferencesProvider);
    prefs.setString(
        'user_role', newRole == AppUserRole.driver ? 'driver' : 'passenger');
  }

  void selectPlannedRide(String rideId) {
    state = state.copyWith(selectedRideId: rideId);
  }

  Future<void> toggleOnlineStatus() async {
    if (state.profile == null) return;
    final currentStatus = state.profile!.status;
    final newStatus = currentStatus == DriverOnlineStatus.online
        ? DriverOnlineStatus.offline
        : DriverOnlineStatus.online;

    await _repository.setOnlineStatus(newStatus);
    state = state.copyWith(
      profile: state.profile!.copyWith(status: newStatus),
      activeTripStep: newStatus == DriverOnlineStatus.offline
          ? DriverTripStep.idle
          : state.activeTripStep,
    );
  }

  Future<void> updateProfile(DriverProfileEntity profile) async {
    state = state.copyWith(isLoading: true);
    try {
      final updated = await _repository.updateDriverProfile(profile);
      state = state.copyWith(profile: updated, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> publishRide(RideEntity ride) async {
    state = state.copyWith(isLoading: true);
    try {
      final published = await _repository.publishRide(ride);
      final updatedRides = [published, ...state.driverRides];
      final requests = await _repository.getIncomingRequests();
      state = state.copyWith(
        driverRides: updatedRides,
        incomingRequests: requests,
        selectedRideId: published.id,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> completeRide(String rideId) async {
    try {
      await _repository.completeRide(rideId);
      final rides = await _repository.getDriverRides();
      final profile = await _repository.getDriverProfile();
      final requests = await _repository.getIncomingRequests();
      state = state.copyWith(
        driverRides: rides,
        profile: profile,
        incomingRequests: requests,
        clearSelectedRide: state.selectedRideId == rideId,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> cancelRide(String rideId) async {
    try {
      await _repository.cancelRide(rideId);
      final rides = await _repository.getDriverRides();
      final requests = await _repository.getIncomingRequests();
      state = state.copyWith(
        driverRides: rides,
        incomingRequests: requests,
        clearSelectedRide: state.selectedRideId == rideId,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> acceptRequest(String requestId) async {
    try {
      await _repository.acceptRequest(requestId);
      final requests = await _repository.getIncomingRequests();
      final rides = await _repository.getDriverRides();

      DriverIncomingRequestEntity? matchedOrder;
      try {
        matchedOrder = requests.firstWhere((r) => r.id == requestId);
      } catch (_) {
        if (state.incomingRequests.isNotEmpty) {
          matchedOrder = state.incomingRequests.first;
        }
      }

      state = state.copyWith(
        incomingRequests: requests,
        driverRides: rides,
        activeOrder: matchedOrder,
        activeTripStep: DriverTripStep.goingToPickup,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> rejectRequest(String requestId) async {
    try {
      await _repository.rejectRequest(requestId);
      final requests = await _repository.getIncomingRequests();
      state = state.copyWith(
        incomingRequests: requests,
        clearActiveOrder: state.activeOrder?.id == requestId,
        activeTripStep: DriverTripStep.idle,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  // --- Driver Active Trip State Machine Transitions ---

  void markArrivedAtPickup() {
    state = state.copyWith(activeTripStep: DriverTripStep.arrived);
  }

  void startTrip() {
    state = state.copyWith(activeTripStep: DriverTripStep.inProgress);
  }

  void completeTrip() {
    final currentEarnings = state.profile?.todayEarnings ?? 0;
    final fare = state.activeOrder?.totalPrice ?? 45000;
    final updatedProfile = state.profile?.copyWith(
      todayEarnings: currentEarnings + fare,
      completedTripsCount: (state.profile?.completedTripsCount ?? 0) + 1,
    );

    state = state.copyWith(
      profile: updatedProfile,
      activeTripStep: DriverTripStep.completed,
    );
  }

  void finishCompletedTrip() {
    state = state.copyWith(
      clearActiveOrder: true,
      activeTripStep: DriverTripStep.idle,
    );
  }

  Future<void> refreshAll() async {
    final profile = await _repository.getDriverProfile();
    final rides = await _repository.getDriverRides();
    final requests = await _repository.getIncomingRequests();
    state = state.copyWith(
      profile: profile,
      driverRides: rides,
      incomingRequests: requests,
    );
  }
}

final driverNotifierProvider =
    StateNotifierProvider<DriverNotifier, DriverState>((ref) {
  final repo = ref.watch(driverRepositoryProvider);
  return DriverNotifier(repo, ref);
});
