import '../../../../core/network/api_response.dart';
import '../../domain/entities/intercity_ride_entity.dart';
import '../../domain/repositories/intercity_rides_repository.dart';
import '../datasources/intercity_rides_remote_data_source.dart';

class IntercityRidesRepositoryImpl implements IntercityRidesRepository {
  IntercityRidesRepositoryImpl(this._remoteDataSource);

  final IntercityRidesRemoteDataSource _remoteDataSource;

  @override
  Future<PaginatedResponse<IntercityRideEntity>> getRides({
    String status = 'active',
    int page = 1,
    int limit = 15,
  }) {
    return _remoteDataSource.getRides(status: status, page: page, limit: limit);
  }

  @override
  Future<String> createRide(Map<String, dynamic> rideData) {
    return _remoteDataSource.createRide(rideData);
  }

  @override
  Future<IntercityRideEntity> getRideDetails(String rideId) {
    return _remoteDataSource.getRideDetails(rideId);
  }

  @override
  Future<void> updateRideStatus({
    required String rideId,
    required String status,
    String? cancelReason,
  }) {
    return _remoteDataSource.updateRideStatus(
      rideId: rideId,
      status: status,
      cancelReason: cancelReason,
    );
  }

  @override
  Future<void> handleBookingAction({
    required String bookingId,
    required String action,
    String? rejectReason,
  }) {
    return _remoteDataSource.handleBookingAction(
      bookingId: bookingId,
      action: action,
      rejectReason: rejectReason,
    );
  }

  @override
  Future<void> cancelBooking({
    required String bookingId,
    required String reason,
  }) {
    return _remoteDataSource.cancelBooking(
      bookingId: bookingId,
      reason: reason,
    );
  }
}
