import 'package:equatable/equatable.dart';

class RidePassengerEntity extends Equatable {
  const RidePassengerEntity({
    required this.bookingId,
    required this.seatsCount,
    required this.totalPrice,
    required this.status, // "pending" | "confirmed" | "completed" | "cancelled"
    required this.passengerId,
    required this.passengerName,
    required this.passengerPhone,
    this.pickupLat,
    this.pickupLng,
    this.pickupAddress,
    this.answerBy,
  });

  final String bookingId;
  final int seatsCount;
  final int totalPrice;
  final String status;
  final String passengerId;
  final String passengerName;
  final String passengerPhone;

  /// Where the passenger asked to be picked up (door-to-door pilot).
  final double? pickupLat;
  final double? pickupLng;
  final String? pickupAddress;

  /// When a pending request expires on the server (`expires_at`, or two
  /// minutes after `created_at`). Null when the server sends neither.
  final DateTime? answerBy;

  bool get isPending => status == 'pending';
  bool get isPickedUp =>
      status == 'picked_up' || status == 'active' || status == 'in_progress';
  /// Closed without a ride: declined, cancelled, or expired unanswered.
  bool get isRejectedOrCancelled =>
      status == 'rejected' || status == 'cancelled' || status == 'expired';

  @override
  List<Object?> get props => [
        answerBy,
        pickupLat,
        pickupLng,
        pickupAddress,
        bookingId,
        seatsCount,
        totalPrice,
        status,
        passengerId,
        passengerName,
        passengerPhone,
      ];
}

class IntercityRideEntity extends Equatable {
  const IntercityRideEntity({
    required this.id,
    required this.fromCity,
    required this.toCity,
    required this.departureTime,
    required this.pricePerSeat,
    required this.totalSeats,
    required this.bookedSeats,
    required this.availableSeats,
    required this.status, // "active" | "completed" | "cancelled"
    this.hasAc = true,
    this.allowLuggage = true,
    this.allowSmoking = false,
    this.allowPets = false,
    this.womenOnly = false,
    this.comment,
    this.passengers = const [],
  });

  final String id;
  final String fromCity;
  final String toCity;
  final DateTime departureTime;
  final int pricePerSeat;
  final int totalSeats;
  final int bookedSeats;
  final int availableSeats;
  final String status;
  final bool hasAc;
  final bool allowLuggage;
  final bool allowSmoking;
  final bool allowPets;
  final bool womenOnly;
  final String? comment;
  final List<RidePassengerEntity> passengers;

  bool get isActive => status == 'active' || status == 'started';
  bool get isStarted => status == 'started';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  @override
  List<Object?> get props => [
        id,
        fromCity,
        toCity,
        departureTime,
        pricePerSeat,
        totalSeats,
        bookedSeats,
        availableSeats,
        status,
        hasAc,
        allowLuggage,
        allowSmoking,
        allowPets,
        womenOnly,
        comment,
        passengers,
      ];
}
