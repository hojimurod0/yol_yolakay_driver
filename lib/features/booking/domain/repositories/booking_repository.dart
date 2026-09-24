import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yol_yolakay_driver/features/home/domain/entities/location_point_entity.dart';
import 'package:yol_yolakay_driver/features/booking/domain/entities/booking_entity.dart';
import 'package:yol_yolakay_driver/features/rides/data/repositories/mock_ride_repository.dart';
import 'package:yol_yolakay_driver/features/rides/domain/repositories/ride_repository.dart';
import 'package:yol_yolakay_driver/features/booking/data/repositories/mock_booking_repository.dart';

class CreateBookingParams {
  const CreateBookingParams({
    required this.rideId,
    required this.seatCount,
    required this.pickupPoint,
    required this.passengerName,
    required this.passengerPhone,
    required this.paymentType,
  });

  final String rideId;
  final int seatCount;
  final LocationPointEntity pickupPoint;
  final String passengerName;
  final String passengerPhone;
  final PaymentType paymentType;
}

/// Repository contract for creating and managing bookings.
abstract class BookingRepository {
  Future<BookingEntity> createBooking(CreateBookingParams params);
  Future<BookingEntity> getBooking(String bookingId);
  Future<BookingEntity> cancelBooking(String bookingId, String reason);
}

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final rideRepo = ref.watch(rideRepositoryProvider) as MockRideRepository;
  return MockBookingRepository(rideRepo);
});
