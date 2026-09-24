import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../models/intercity_ride_model.dart';

abstract class IntercityRidesRemoteDataSource {
  Future<PaginatedResponse<IntercityRideModel>> getRides({
    String status = 'active',
    int page = 1,
    int limit = 15,
  });

  Future<String> createRide(Map<String, dynamic> rideData);

  Future<IntercityRideModel> getRideDetails(String rideId);

  Future<void> updateRideStatus({
    required String rideId,
    required String status,
    String? cancelReason,
  });

  Future<void> handleBookingAction({
    required String bookingId,
    required String action,
    String? rejectReason,
  });

  Future<void> cancelBooking({
    required String bookingId,
    required String reason,
  });
}

class IntercityRidesRemoteDataSourceImpl
    implements IntercityRidesRemoteDataSource {
  IntercityRidesRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<PaginatedResponse<IntercityRideModel>> getRides({
    String status = 'active',
    int page = 1,
    int limit = 15,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.rides,
      queryParameters: {
        'status': status,
        'page': page,
        'limit': limit,
      },
      fromData: (data) => PaginatedResponse.fromJson(
        data as Map<String, dynamic>,
        (item) => IntercityRideModel.fromJson(item as Map<String, dynamic>),
      ),
    );
    return response.data ??
        PaginatedResponse(
          items: const [],
          pagination: const PaginationModel(
              page: 1, limit: 15, totalItems: 0, totalPages: 1),
        );
  }

  @override
  Future<String> createRide(Map<String, dynamic> rideData) async {
    final response = await _apiClient.post(
      ApiEndpoints.rides,
      idempotencyKey: 'ride-create-${DateTime.now().millisecondsSinceEpoch}',
      data: rideData,
    );
    return response.data?['ride_id']?.toString() ?? '';
  }

  @override
  Future<IntercityRideModel> getRideDetails(String rideId) async {
    final response = await _apiClient.get(
      ApiEndpoints.rideDetails(rideId),
      fromData: (data) {
        if (data is Map<String, dynamic>) {
          return IntercityRideModel.fromJson(data);
        }
        return null;
      },
    );
    return response.data!;
  }

  @override
  Future<void> updateRideStatus({
    required String rideId,
    required String status,
    String? cancelReason,
  }) async {
    await _apiClient.patch(
      ApiEndpoints.rideStatus(rideId),
      idempotencyKey:
          'ride-status-$rideId-$status-${DateTime.now().millisecondsSinceEpoch}',
      data: {
        'status': status,
        if (cancelReason != null) 'cancel_reason': cancelReason,
      },
    );
  }

  @override
  Future<void> handleBookingAction({
    required String bookingId,
    required String action,
    String? rejectReason,
  }) async {
    await _apiClient.post(
      ApiEndpoints.bookingAction(bookingId),
      idempotencyKey:
          'booking-$bookingId-$action-${DateTime.now().millisecondsSinceEpoch}',
      data: {
        'action': action,
        if (rejectReason != null) 'reject_reason': rejectReason,
      },
    );
  }

  @override
  Future<void> cancelBooking({
    required String bookingId,
    required String reason,
  }) async {
    await _apiClient.post(
      ApiEndpoints.cancelBooking(bookingId),
      idempotencyKey:
          'booking-cancel-$bookingId-${DateTime.now().millisecondsSinceEpoch}',
      data: {'reason': reason},
    );
  }
}
