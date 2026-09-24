import 'dart:math' as math;

/// Utility class for calculating geographic distance and realistic pricing
/// between Andijon and Fergana cities and districts.
class DistanceCalculator {
  const DistanceCalculator._();

  /// Calculates geodesic distance between two GPS coordinates in Kilometers using the Haversine formula.
  static double calculateDistanceKm({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    const double earthRadiusKm = 6371.0;

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final double distance = earthRadiusKm * c;

    // Return realistic road distance factor (approx 1.25x of straight geodesic line)
    return (distance * 1.25).clamp(3.0, 200.0);
  }

  /// Calculates price per seat in UZS based on distance:
  /// Strictly constrained between 5,000 UZS and 100,000 UZS.
  static int calculatePricePerSeat(double distanceKm,
      {double vehicleTierMultiplier = 1.0}) {
    // Base formula: 5,000 base + 700-900 UZS per km
    double basePrice = 5000.0 + (distanceKm * 750.0 * vehicleTierMultiplier);

    // Round to nearest 1,000 UZS
    int rounded = ((basePrice / 1000).round() * 1000);

    // Ensure within 5,000 and 100,000 UZS
    return rounded.clamp(5000, 100000);
  }

  /// Estimates travel duration in minutes based on distance
  static int estimateDurationMinutes(double distanceKm) {
    // Approx average speed 50-60 km/h in Fergana Valley roads
    final double hours = distanceKm / 55.0;
    return (hours * 60).round().clamp(10, 240);
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }
}
