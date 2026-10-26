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

  Future<void> markPickedUp(String bookingId);

  Future<void> startRide(String rideId);

  Future<void> completeRide(String rideId);

  Future<void> updateRide({
    required String rideId,
    required Map<String, dynamic> rideData,
  });

  Future<void> deleteRide({
    required String rideId,
    String? reason,
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
        const PaginatedResponse(
          items: [],
          pagination: PaginationModel(
              page: 1, limit: 15, totalItems: 0, totalPages: 1),
        );
  }

  @override
  Future<String> createRide(Map<String, dynamic> rideData) async {
    final response = await _apiClient.post(
      ApiEndpoints.rides,
      idempotencyKey: 'ride-create-${DateTime.now().millisecondsSinceEpoch}',
      data: rideData,
      fromData: (data) {
        if (data is Map<String, dynamic>) {
          return data['id']?.toString() ??
              data['ride_id']?.toString() ??
              data['_id']?.toString() ??
              'created';
        }
        if (data != null) return data.toString();
        return 'created';
      },
    );
    return response.data ?? 'created';
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

  @override
  Future<void> markPickedUp(String bookingId) async {
    await _apiClient.post(
      ApiEndpoints.pickedUpBooking(bookingId),
      idempotencyKey: 'booking-picked-up-$bookingId',
    );
  }

  @override
  Future<void> startRide(String rideId) async {
    await _apiClient.post(
      ApiEndpoints.startRide(rideId),
      idempotencyKey: 'ride-start-$rideId',
    );
  }

  @override
  Future<void> completeRide(String rideId) async {
    await _apiClient.post(
      ApiEndpoints.completeRide(rideId),
      idempotencyKey: 'ride-complete-$rideId',
    );
  }

  @override
  Future<void> updateRide({
    required String rideId,
    required Map<String, dynamic> rideData,
  }) async {
    try {
      await _apiClient.put(
        ApiEndpoints.rideDetails(rideId),
        idempotencyKey:
            'ride-update-$rideId-${DateTime.now().millisecondsSinceEpoch}',
        data: rideData,
      );
    } catch (_) {
      await _apiClient.patch(
        ApiEndpoints.rideDetails(rideId),
        idempotencyKey:
            'ride-update-patch-$rideId-${DateTime.now().millisecondsSinceEpoch}',
        data: rideData,
      );
    }
  }

  @override
  Future<void> deleteRide({
    required String rideId,
    String? reason,
  }) async {
    try {
      await _apiClient.delete(
        ApiEndpoints.rideDetails(rideId),
      );
    } catch (_) {
      await updateRideStatus(
        rideId: rideId,
        status: 'cancelled',
        cancelReason: reason ?? 'Haydovchi tomonidan bekor qilindi',
      );
    }
  }
}
