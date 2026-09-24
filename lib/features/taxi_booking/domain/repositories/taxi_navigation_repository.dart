import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../entities/map_location.dart';
import '../entities/nearby_driver.dart';
import '../entities/taxi_route.dart';
import '../entities/taxi_vehicle_tier.dart';

/// Repository contract for Google Maps navigation, Places autocomplete,
/// route computation, and live driver tracking.
abstract class TaxiNavigationRepository {
  /// Gets the user's current GPS location with high precision
  Future<MapLocation> getCurrentLocation();

  /// Searches for places/addresses using Google Places API / local geocoder
  Future<List<MapLocation>> searchPlaces(String query);

  /// Performs reverse geocoding to get address details from GPS coordinates
  Future<MapLocation> getAddressFromCoordinates(LatLng position);

  /// Calculates driving route and polyline coordinates between pickup and destination
  Future<TaxiRoute> calculateRoute({
    required MapLocation pickup,
    required MapLocation destination,
  });

  /// Computes estimated fares for all vehicle tiers (Economy, Comfort, Business)
  List<TaxiVehicleTier> computeVehicleTiers(double distanceKm);

  /// Retrieves nearby available drivers moving around the given center location
  Future<List<NearbyDriver>> getNearbyDrivers(LatLng center);
}
