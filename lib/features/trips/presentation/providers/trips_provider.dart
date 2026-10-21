import 'package:yol_yolakay_driver/features/trips/domain/entities/trip_entity.dart';

class TripsState {
  const TripsState({
    this.upcomingTrips = const [],
    this.activeTrips = const [],
    this.completedTrips = const [],
    this.cancelledTrips = const [],
    this.isLoading = false,
  });

  final List<TripEntity> upcomingTrips;
  final List<TripEntity> activeTrips;
  final List<TripEntity> completedTrips;
  final List<TripEntity> cancelledTrips;
  final bool isLoading;

  TripsState copyWith({
    List<TripEntity>? upcomingTrips,
    List<TripEntity>? activeTrips,
    List<TripEntity>? completedTrips,
    List<TripEntity>? cancelledTrips,
    bool? isLoading,
  }) {
    return TripsState(
      upcomingTrips: upcomingTrips ?? this.upcomingTrips,
      activeTrips: activeTrips ?? this.activeTrips,
      completedTrips: completedTrips ?? this.completedTrips,
      cancelledTrips: cancelledTrips ?? this.cancelledTrips,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
