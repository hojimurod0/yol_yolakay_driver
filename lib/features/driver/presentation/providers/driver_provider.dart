import '../../domain/entities/driver_incoming_request_entity.dart';
import '../../domain/entities/driver_profile_entity.dart';
import '../../../rides/domain/entities/ride_entity.dart';

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
    this.role = AppUserRole.driver,
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
