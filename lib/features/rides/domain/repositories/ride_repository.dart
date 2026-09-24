import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/mock_ride_repository.dart';
import '../entities/ride_entity.dart';

class RideSearchParams {
  const RideSearchParams({
    required this.departureCityId,
    required this.destinationCityId,
    required this.date,
    this.passengerCount = 1,
    this.maxPrice,
    this.minRating,
    this.hasAc,
  });

  final String departureCityId;
  final String destinationCityId;
  final DateTime date;
  final int passengerCount;
  final int? maxPrice;
  final double? minRating;
  final bool? hasAc;
}

/// Repository contract for searching intercity rides and fetching ride details.
abstract class RideRepository {
  Future<List<RideEntity>> searchRides(RideSearchParams params);
  Future<RideEntity> getRideDetails(String rideId);
  Future<List<RideEntity>> getPopularRides();
}

final rideRepositoryProvider =
    Provider<RideRepository>((ref) => MockRideRepository());
