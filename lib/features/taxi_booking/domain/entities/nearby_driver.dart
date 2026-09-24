import 'taxi_vehicle_tier.dart';

/// Real-time Driver GPS Location and status on Google Map.
class NearbyDriver {
  const NearbyDriver({
    required this.id,
    required this.name,
    required this.carModel,
    required this.licensePlate,
    required this.latitude,
    required this.longitude,
    required this.heading,
    required this.rating,
    required this.tier,
    this.isAvailable = true,
  });

  final String id;
  final String name;
  final String carModel;
  final String licensePlate;
  final double latitude;
  final double longitude;
  final double heading; // 0..360 degrees for car icon rotation
  final double rating;
  final VehicleTierType tier;
  final bool isAvailable;

  NearbyDriver copyWith({
    double? latitude,
    double? longitude,
    double? heading,
    bool? isAvailable,
  }) {
    return NearbyDriver(
      id: id,
      name: name,
      carModel: carModel,
      licensePlate: licensePlate,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      heading: heading ?? this.heading,
      rating: rating,
      tier: tier,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
