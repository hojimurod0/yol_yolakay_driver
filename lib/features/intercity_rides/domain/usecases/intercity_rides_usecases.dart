import '../../../../core/network/api_response.dart';
import '../entities/intercity_ride_entity.dart';
import '../repositories/intercity_rides_repository.dart';

class GetRidesUseCase {
  const GetRidesUseCase(this._repository);
  final IntercityRidesRepository _repository;

  Future<PaginatedResponse<IntercityRideEntity>> call({
    String status = 'active',
    int page = 1,
    int limit = 15,
  }) =>
      _repository.getRides(status: status, page: page, limit: limit);
}

class CreateRideUseCase {
  const CreateRideUseCase(this._repository);
  final IntercityRidesRepository _repository;

  Future<String> call(Map<String, dynamic> rideData) =>
      _repository.createRide(rideData);
}

class GetRideDetailsUseCase {
  const GetRideDetailsUseCase(this._repository);
  final IntercityRidesRepository _repository;

  Future<IntercityRideEntity> call(String rideId) =>
      _repository.getRideDetails(rideId);
}

class UpdateRideStatusUseCase {
  const UpdateRideStatusUseCase(this._repository);
  final IntercityRidesRepository _repository;

  Future<void> call({
    required String rideId,
    required String status,
    String? cancelReason,
  }) =>
      _repository.updateRideStatus(
        rideId: rideId,
        status: status,
        cancelReason: cancelReason,
      );
}

class HandleBookingActionUseCase {
  const HandleBookingActionUseCase(this._repository);
  final IntercityRidesRepository _repository;

  Future<void> call({
    required String bookingId,
    required String action,
    String? rejectReason,
  }) =>
      _repository.handleBookingAction(
        bookingId: bookingId,
        action: action,
        rejectReason: rejectReason,
      );
}

class CancelBookingUseCase {
  const CancelBookingUseCase(this._repository);
  final IntercityRidesRepository _repository;

  Future<void> call({required String bookingId, required String reason}) =>
      _repository.cancelBooking(bookingId: bookingId, reason: reason);
}
