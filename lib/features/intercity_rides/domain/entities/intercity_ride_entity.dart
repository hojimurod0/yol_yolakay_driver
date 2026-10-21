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
  });

  final String bookingId;
  final int seatsCount;
  final int totalPrice;
  final String status;
  final String passengerId;
  final String passengerName;
  final String passengerPhone;

  @override
  List<Object?> get props => [
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
