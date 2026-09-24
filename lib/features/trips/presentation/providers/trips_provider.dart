import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yol_yolakay_driver/features/trips/domain/entities/trip_entity.dart';
import 'package:yol_yolakay_driver/features/trips/domain/repositories/trip_repository.dart';

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

class TripsNotifier extends StateNotifier<TripsState> {
  TripsNotifier(this._tripRepository) : super(const TripsState()) {
    loadAllTrips();
  }

  final TripRepository _tripRepository;

  Future<void> loadAllTrips() async {
    state = state.copyWith(isLoading: true);
    final results = await Future.wait([
      _tripRepository.getUpcomingTrips(),
      _tripRepository.getActiveTrips(),
      _tripRepository.getCompletedTrips(),
      _tripRepository.getCancelledTrips(),
    ]);

    state = state.copyWith(
      upcomingTrips: results[0],
      activeTrips: results[1],
      completedTrips: results[2],
      cancelledTrips: results[3],
      isLoading: false,
    );
  }

  Future<void> submitRating({
    required String tripId,
    required int rating,
    required String feedback,
    List<String>? tags,
  }) async {
    await _tripRepository.rateTrip(
      tripId: tripId,
      rating: rating,
      feedback: feedback,
      tags: tags,
    );
    await loadAllTrips();
  }
}

final tripsNotifierProvider =
    StateNotifierProvider<TripsNotifier, TripsState>((ref) {
  final repo = ref.watch(tripRepositoryProvider);
  return TripsNotifier(repo);
});

final activeTripTrackingStreamProvider =
    StreamProvider.family<TripEntity, String>((ref, tripId) {
  final repo = ref.watch(tripRepositoryProvider);
  return repo.trackTrip(tripId);
});
