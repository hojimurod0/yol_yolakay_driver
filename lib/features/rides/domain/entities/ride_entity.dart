import 'package:yol_yolakay_driver/features/home/domain/entities/city_entity.dart';
import 'package:yol_yolakay_driver/features/home/domain/entities/location_point_entity.dart';
import 'package:yol_yolakay_driver/features/rides/domain/entities/driver_entity.dart';
import 'package:yol_yolakay_driver/features/rides/domain/entities/vehicle_entity.dart';

enum RideStatus { active, full, completed, cancelled }

/// Domain entity representing a scheduled intercity ride.
class RideEntity {
  const RideEntity({
    required this.id,
    required this.departureCity,
    required this.destinationCity,
    required this.departureTime,
    required this.estimatedArrivalTime,
    required this.driver,
    required this.vehicle,
    required this.pricePerSeat,
    required this.totalSeats,
    required this.availableSeats,
    required this.pickupPoints,
    required this.dropoffPoints,
    this.status = RideStatus.active,
    this.cancellationPolicy =
        'Free cancellation up to 2 hours before scheduled departure.',
    int? customFullSalonPrice,
    int? customParcelPrice,
    this.isParcelAllowed = true,
  })  : _customFullSalonPrice = customFullSalonPrice,
        _customParcelPrice = customParcelPrice;

  final String id;
  final CityEntity departureCity;
  final CityEntity destinationCity;
  final DateTime departureTime;
  final DateTime estimatedArrivalTime;
  final DriverEntity driver;
  final VehicleEntity vehicle;
  final int pricePerSeat;
  final int totalSeats;
  final int availableSeats;
  final List<LocationPointEntity> pickupPoints;
  final List<LocationPointEntity> dropoffPoints;
  final RideStatus status;
  final String cancellationPolicy;
  final int? _customFullSalonPrice;
  final int? _customParcelPrice;
  final bool isParcelAllowed;

  int get fullSalonPrice =>
      _customFullSalonPrice ?? (pricePerSeat * totalSeats);
  int get parcelPrice =>
      _customParcelPrice ??
      ((pricePerSeat * 0.5) ~/ 5000 * 5000).clamp(30000, 100000);

  Duration get duration => estimatedArrivalTime.difference(departureTime);
}
