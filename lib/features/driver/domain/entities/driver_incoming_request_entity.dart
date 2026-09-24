enum DriverRequestType { passengerSeat, expressParcel, fullSalon }

enum DriverRequestStatus { pending, accepted, rejected, completed }

/// Incoming booking request from a passenger or parcel sender.
class DriverIncomingRequestEntity {
  const DriverIncomingRequestEntity({
    required this.id,
    required this.rideId,
    required this.passengerName,
    required this.passengerPhone,
    required this.passengerAvatar,
    required this.passengerRating,
    required this.departureCity,
    required this.destinationCity,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.departureTime,
    required this.seatsCount,
    required this.totalPrice,
    required this.type,
    this.status = DriverRequestStatus.pending,
    this.comment,
    this.telegramHandle,
  });

  final String id;
  final String rideId;
  final String passengerName;
  final String passengerPhone;
  final String? passengerAvatar;
  final double passengerRating;
  final String departureCity;
  final String destinationCity;
  final String pickupAddress;
  final String dropoffAddress;
  final DateTime departureTime;
  final int seatsCount;
  final int totalPrice;
  final DriverRequestType type;
  final DriverRequestStatus status;
  final String? comment;
  final String? telegramHandle;

  DriverIncomingRequestEntity copyWith({
    String? id,
    String? rideId,
    String? passengerName,
    String? passengerPhone,
    String? passengerAvatar,
    double? passengerRating,
    String? departureCity,
    String? destinationCity,
    String? pickupAddress,
    String? dropoffAddress,
    DateTime? departureTime,
    int? seatsCount,
    int? totalPrice,
    DriverRequestType? type,
    DriverRequestStatus? status,
    String? comment,
    String? telegramHandle,
  }) {
    return DriverIncomingRequestEntity(
      id: id ?? this.id,
      rideId: rideId ?? this.rideId,
      passengerName: passengerName ?? this.passengerName,
      passengerPhone: passengerPhone ?? this.passengerPhone,
      passengerAvatar: passengerAvatar ?? this.passengerAvatar,
      passengerRating: passengerRating ?? this.passengerRating,
      departureCity: departureCity ?? this.departureCity,
      destinationCity: destinationCity ?? this.destinationCity,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      departureTime: departureTime ?? this.departureTime,
      seatsCount: seatsCount ?? this.seatsCount,
      totalPrice: totalPrice ?? this.totalPrice,
      type: type ?? this.type,
      status: status ?? this.status,
      comment: comment ?? this.comment,
      telegramHandle: telegramHandle ?? this.telegramHandle,
    );
  }
}
