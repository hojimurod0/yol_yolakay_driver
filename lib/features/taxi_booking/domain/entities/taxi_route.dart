import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'map_location.dart';

/// Represents a computed driving route between Pickup and Destination.
class TaxiRoute {
  const TaxiRoute({
    required this.pickup,
    required this.destination,
    required this.distanceKm,
    required this.durationMinutes,
    required this.polylinePoints,
    required this.summary,
    this.recommendedRoute = 'Tezkor yo\'nalish',
  });

  final MapLocation pickup;
  final MapLocation destination;
  final double distanceKm;
  final int durationMinutes;
  final List<LatLng> polylinePoints;
  final String summary;
  final String recommendedRoute;

  String get formattedDistance => distanceKm < 1.0
      ? '${(distanceKm * 1000).toInt()} m'
      : '${distanceKm.toStringAsFixed(1)} km';

  String get formattedDuration => durationMinutes < 60
      ? '$durationMinutes daq'
      : '${durationMinutes ~/ 60} soat ${durationMinutes % 60} daq';
}
