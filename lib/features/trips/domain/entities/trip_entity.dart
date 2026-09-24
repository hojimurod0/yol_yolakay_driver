import 'package:yol_yolakay_driver/features/booking/domain/entities/booking_entity.dart';

enum TripProgressStatus {
  bookingConfirmed,
  driverPreparing,
  driverArrived,
  passengerPickedUp,
  tripStarted,
  nearDestination,
  tripCompleted,
}

/// Domain entity representing real-time trip tracking progress and status.
class TripEntity {
  const TripEntity({
    required this.id,
    required this.booking,
    required this.progressStatus,
    required this.currentDriverLat,
    required this.currentDriverLng,
    this.estimatedArrivalRemainingMinutes = 45,
    this.hasRated = false,
    this.rating,
    this.reviewFeedback,
  });

  final String id;
  final BookingEntity booking;
  final TripProgressStatus progressStatus;
  final double currentDriverLat;
  final double currentDriverLng;
  final int estimatedArrivalRemainingMinutes;
  final bool hasRated;
  final int? rating;
  final String? reviewFeedback;

  TripEntity copyWith({
    String? id,
    BookingEntity? booking,
    TripProgressStatus? progressStatus,
    double? currentDriverLat,
    double? currentDriverLng,
    int? estimatedArrivalRemainingMinutes,
    bool? hasRated,
    int? rating,
    String? reviewFeedback,
  }) {
    return TripEntity(
      id: id ?? this.id,
      booking: booking ?? this.booking,
      progressStatus: progressStatus ?? this.progressStatus,
      currentDriverLat: currentDriverLat ?? this.currentDriverLat,
      currentDriverLng: currentDriverLng ?? this.currentDriverLng,
      estimatedArrivalRemainingMinutes: estimatedArrivalRemainingMinutes ??
          this.estimatedArrivalRemainingMinutes,
      hasRated: hasRated ?? this.hasRated,
      rating: rating ?? this.rating,
      reviewFeedback: reviewFeedback ?? this.reviewFeedback,
    );
  }
}
