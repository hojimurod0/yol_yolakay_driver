import 'package:yol_yolakay_driver/features/booking/domain/entities/booking_entity.dart';
import 'package:yol_yolakay_driver/features/home/domain/entities/location_point_entity.dart';
import 'package:yol_yolakay_driver/features/rides/domain/entities/ride_entity.dart';

class BookingFlowState {
  const BookingFlowState({
    this.selectedRide,
    this.selectedSeats = 1,
    this.selectedSeatNumbers = const {1},
    this.occupiedSeatNumbers = const {3},
    this.selectedPickupPoint,
    this.passengerName = 'Rizo Karimov',
    this.passengerPhone = '+998 90 123 45 67',
    this.paymentType = PaymentType.cash,
    this.isBooking = false,
    this.confirmedBooking,
    this.errorMessage,
  });

  final RideEntity? selectedRide;
  final int selectedSeats;
  final Set<int> selectedSeatNumbers;
  final Set<int> occupiedSeatNumbers;
  final LocationPointEntity? selectedPickupPoint;
  final String passengerName;
  final String passengerPhone;
  final PaymentType paymentType;
  final bool isBooking;
  final BookingEntity? confirmedBooking;
  final String? errorMessage;

  int get effectiveSeatCount => selectedSeatNumbers.isNotEmpty
      ? selectedSeatNumbers.length
      : selectedSeats;
  int get totalPrice => (selectedRide?.pricePerSeat ?? 0) * effectiveSeatCount;
}
