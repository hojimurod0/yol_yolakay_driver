import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yol_yolakay_driver/features/booking/domain/entities/booking_entity.dart';
import 'package:yol_yolakay_driver/features/booking/domain/repositories/booking_repository.dart';
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

  BookingFlowState copyWith({
    RideEntity? selectedRide,
    int? selectedSeats,
    Set<int>? selectedSeatNumbers,
    Set<int>? occupiedSeatNumbers,
    LocationPointEntity? selectedPickupPoint,
    String? passengerName,
    String? passengerPhone,
    PaymentType? paymentType,
    bool? isBooking,
    BookingEntity? confirmedBooking,
    String? errorMessage,
  }) {
    return BookingFlowState(
      selectedRide: selectedRide ?? this.selectedRide,
      selectedSeats: selectedSeats ?? this.selectedSeats,
      selectedSeatNumbers: selectedSeatNumbers ?? this.selectedSeatNumbers,
      occupiedSeatNumbers: occupiedSeatNumbers ?? this.occupiedSeatNumbers,
      selectedPickupPoint: selectedPickupPoint ?? this.selectedPickupPoint,
      passengerName: passengerName ?? this.passengerName,
      passengerPhone: passengerPhone ?? this.passengerPhone,
      paymentType: paymentType ?? this.paymentType,
      isBooking: isBooking ?? this.isBooking,
      confirmedBooking: confirmedBooking ?? this.confirmedBooking,
      errorMessage: errorMessage,
    );
  }
}

class BookingFlowNotifier extends StateNotifier<BookingFlowState> {
  BookingFlowNotifier(this._bookingRepository)
      : super(const BookingFlowState());

  final BookingRepository _bookingRepository;

  void startBooking(RideEntity ride, {int initialSeats = 1}) {
    // Generate occupied seats deterministically based on total vs available
    final occupied = <int>{};
    final occupiedCount = ride.totalSeats - ride.availableSeats;
    for (int i = 0; i < occupiedCount && i < 4; i++) {
      occupied.add(i + 3 > 4 ? 2 : i + 3);
    }

    final initialSelected = <int>{};
    for (int s = 1; s <= 4; s++) {
      if (!occupied.contains(s) && initialSelected.length < initialSeats) {
        initialSelected.add(s);
      }
    }
    if (initialSelected.isEmpty) {
      initialSelected.add(1);
    }

    state = BookingFlowState(
      selectedRide: ride,
      selectedSeats: initialSelected.length,
      selectedSeatNumbers: initialSelected,
      occupiedSeatNumbers: occupied,
      selectedPickupPoint:
          ride.pickupPoints.isNotEmpty ? ride.pickupPoints.first : null,
    );
  }

  void setSeatNumbers(Set<int> seats) {
    if (state.selectedRide == null || seats.isEmpty) return;
    state = state.copyWith(
      selectedSeatNumbers: Set.from(seats),
      selectedSeats: seats.length,
    );
  }

  void toggleSeatNumber(int seatNumber) {
    if (state.occupiedSeatNumbers.contains(seatNumber)) return;

    final updated = Set<int>.from(state.selectedSeatNumbers);
    if (updated.contains(seatNumber)) {
      if (updated.length > 1) {
        updated.remove(seatNumber);
      }
    } else {
      final maxAvailable = state.selectedRide?.availableSeats ?? 4;
      if (updated.length < maxAvailable) {
        updated.add(seatNumber);
      }
    }
    state = state.copyWith(
      selectedSeatNumbers: updated,
      selectedSeats: updated.length,
    );
  }

  void setSeatCount(int count) {
    if (state.selectedRide == null) return;
    final clamped = count.clamp(1, state.selectedRide!.availableSeats);

    // Auto-select first N non-occupied seats
    final newSelected = <int>{};
    for (int s = 1; s <= 4 && newSelected.length < clamped; s++) {
      if (!state.occupiedSeatNumbers.contains(s)) {
        newSelected.add(s);
      }
    }

    state = state.copyWith(
      selectedSeats: clamped,
      selectedSeatNumbers: newSelected,
    );
  }

  void setPickupPoint(LocationPointEntity point) {
    state = state.copyWith(selectedPickupPoint: point);
  }

  void setPassengerDetails({required String name, required String phone}) {
    state = state.copyWith(passengerName: name, passengerPhone: phone);
  }

  void setPaymentType(PaymentType type) {
    state = state.copyWith(paymentType: type);
  }

  void markSeatAsOccupiedByRaceCondition(int seatNumber) {
    final updatedOccupied = Set<int>.from(state.occupiedSeatNumbers)
      ..add(seatNumber);
    final updatedSelected = Set<int>.from(state.selectedSeatNumbers)
      ..remove(seatNumber);
    final fallbackSeats = {1, 2, 3, 4}.difference(updatedOccupied);
    final finalSelected = updatedSelected.isNotEmpty
        ? updatedSelected
        : (fallbackSeats.isNotEmpty ? {fallbackSeats.first} : <int>{});

    state = state.copyWith(
      occupiedSeatNumbers: updatedOccupied,
      selectedSeatNumbers: finalSelected,
      selectedSeats: finalSelected.length,
      errorMessage:
          '№ $seatNumber joy hozirgina band qilindi. Joylar ro‘yxati yangilandi.',
    );
  }

  Future<BookingEntity?> confirmBooking() async {
    // 1. Guard against double-tap / concurrent submission
    if (state.selectedRide == null ||
        state.selectedPickupPoint == null ||
        state.isBooking) {
      return null;
    }

    // 2. Safety check: validate seats are still available
    for (final s in state.selectedSeatNumbers) {
      if (state.occupiedSeatNumbers.contains(s)) {
        state = state.copyWith(
          errorMessage:
              '№ $s joy hozirgina boshqa yo‘lovchi tomonidan band qilindi. Iltimos, boshqa joy tanlang.',
        );
        return null;
      }
    }

    state = state.copyWith(isBooking: true, errorMessage: null);

    try {
      final booking = await _bookingRepository.createBooking(
        CreateBookingParams(
          rideId: state.selectedRide!.id,
          seatCount: state.effectiveSeatCount,
          pickupPoint: state.selectedPickupPoint!,
          passengerName: state.passengerName,
          passengerPhone: state.passengerPhone,
          paymentType: state.paymentType,
        ),
      );

      state = state.copyWith(
        isBooking: false,
        confirmedBooking: booking,
      );
      return booking;
    } catch (e) {
      state = state.copyWith(
        isBooking: false,
        errorMessage: e.toString(),
      );
      return null;
    }
  }
}

final bookingFlowNotifierProvider =
    StateNotifierProvider<BookingFlowNotifier, BookingFlowState>((ref) {
  final repo = ref.watch(bookingRepositoryProvider);
  return BookingFlowNotifier(repo);
});
