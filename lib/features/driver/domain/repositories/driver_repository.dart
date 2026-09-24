import '../entities/driver_profile_entity.dart';
import '../entities/driver_incoming_request_entity.dart';
import '../../../rides/domain/entities/ride_entity.dart';

abstract class DriverRepository {
  Future<DriverProfileEntity> getDriverProfile();
  Future<DriverProfileEntity> updateDriverProfile(DriverProfileEntity profile);
  Future<void> setOnlineStatus(DriverOnlineStatus status);
  Future<List<RideEntity>> getDriverRides();
  Future<RideEntity> publishRide(RideEntity ride);
  Future<void> cancelRide(String rideId);
  Future<void> completeRide(String rideId);
  Future<List<DriverIncomingRequestEntity>> getIncomingRequests();
  Future<void> acceptRequest(String requestId);
  Future<void> rejectRequest(String requestId);
}
