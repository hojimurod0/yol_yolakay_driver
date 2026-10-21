import '../../../../core/network/api_response.dart';
import '../entities/intercity_ride_entity.dart';

abstract class IntercityRidesRepository {
  Future<PaginatedResponse<IntercityRideEntity>> getRides({
    String status = 'active',
    int page = 1,
    int limit = 15,
  });

  Future<String> createRide(Map<String, dynamic> rideData);

  Future<IntercityRideEntity> getRideDetails(String rideId);

  Future<void> updateRideStatus({
    required String rideId,
    required String status,
    String? cancelReason,
  });

  Future<void> handleBookingAction({
    required String bookingId,
    required String action, // "accept" | "reject"
    String? rejectReason,
  });

  Future<void> cancelBooking({
    required String bookingId,
    required String reason,
  });

  Future<void> updateRide({
    required String rideId,
    required Map<String, dynamic> rideData,
  });

  Future<void> deleteRide({
    required String rideId,
    String? reason,
  });
}
