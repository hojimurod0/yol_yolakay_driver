import 'package:yol_yolakay_driver/features/home/domain/entities/location_point_entity.dart';
import 'package:yol_yolakay_driver/features/booking/domain/entities/booking_entity.dart';

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
