import 'package:equatable/equatable.dart';

abstract class IntercityRidesEvent extends Equatable {
  const IntercityRidesEvent();
  @override
  List<Object?> get props => [];
}

class LoadRidesEvent extends IntercityRidesEvent {
  const LoadRidesEvent({
    this.status = 'active',
    this.page = 1,
  });

  final String status;
  final int page;

  @override
  List<Object?> get props => [status, page];
}

class CreateRideEvent extends IntercityRidesEvent {
  const CreateRideEvent(this.rideData);
  final Map<String, dynamic> rideData;

  @override
  List<Object?> get props => [rideData];
}

class LoadRideDetailsEvent extends IntercityRidesEvent {
  const LoadRideDetailsEvent(this.rideId);
  final String rideId;

  @override
  List<Object?> get props => [rideId];
}

class UpdateRideStatusEvent extends IntercityRidesEvent {
  const UpdateRideStatusEvent({
    required this.rideId,
    required this.status,
    this.cancelReason,
  });

  final String rideId;
  final String status;
  final String? cancelReason;

  @override
  List<Object?> get props => [rideId, status, cancelReason];
}

class BookingActionEvent extends IntercityRidesEvent {
  const BookingActionEvent({
    required this.bookingId,
    required this.action,
    this.rideId,
    this.rejectReason,
  });

  final String bookingId;
  final String action;
  final String? rideId;
  final String? rejectReason;

  @override
  List<Object?> get props => [bookingId, action, rideId, rejectReason];
}

class CancelBookingEvent extends IntercityRidesEvent {
  const CancelBookingEvent({
    required this.bookingId,
    required this.reason,
    this.rideId,
  });

  final String bookingId;
  final String reason;
  final String? rideId;

  @override
  List<Object?> get props => [bookingId, reason, rideId];
}

class BookingUpdateReceivedEvent extends IntercityRidesEvent {
  const BookingUpdateReceivedEvent(this.data);
  final Map<String, dynamic> data;

  @override
  List<Object?> get props => [data];
}

