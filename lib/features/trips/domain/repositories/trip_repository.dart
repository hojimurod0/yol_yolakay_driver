import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/mock_trip_repository.dart';
import '../entities/trip_entity.dart';

/// Repository contract for trips history, real-time tracking, and post-trip ratings.
abstract class TripRepository {
  Future<List<TripEntity>> getUpcomingTrips();
  Future<List<TripEntity>> getActiveTrips();
  Future<List<TripEntity>> getCompletedTrips();
  Future<List<TripEntity>> getCancelledTrips();
  Future<TripEntity> getTripDetails(String tripId);
  Stream<TripEntity> trackTrip(String tripId);
  Future<void> rateTrip({
    required String tripId,
    required int rating,
    required String feedback,
    List<String>? tags,
  });
}

final tripRepositoryProvider =
    Provider<TripRepository>((ref) => MockTripRepository());
