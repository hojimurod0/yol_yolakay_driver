import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/driver_profile_entity.dart';

part 'driver_profile_model.g.dart';

@JsonSerializable()
class DriverVehicleModel {
  @JsonKey(name: 'make', defaultValue: '')
  final String make;
  @JsonKey(name: 'model', defaultValue: '')
  final String model;
  @JsonKey(name: 'color', defaultValue: '')
  final String color;
  @JsonKey(name: 'license_plate', defaultValue: '')
  final String licensePlate;
  @JsonKey(name: 'year', defaultValue: 2020)
  final int year;
  @JsonKey(name: 'comfort_class', defaultValue: 'standard')
  final String comfortClass;

  const DriverVehicleModel({
    required this.make,
    required this.model,
    required this.color,
    required this.licensePlate,
    required this.year,
    required this.comfortClass,
  });

  factory DriverVehicleModel.fromJson(Map<String, dynamic> json) =>
      _$DriverVehicleModelFromJson(json);

  Map<String, dynamic> toJson() => _$DriverVehicleModelToJson(this);

  DriverVehicleEntity toEntity() {
    return DriverVehicleEntity(
      make: make,
      model: model,
      color: color,
      licensePlate: licensePlate,
      year: year,
      comfortClass: comfortClass,
    );
  }
}

@JsonSerializable(explicitToJson: true)
class DriverProfileModel {
  @JsonKey(name: 'id')
  final String id;
  @JsonKey(name: 'phone', defaultValue: '')
  final String phone;
  @JsonKey(name: 'first_name', defaultValue: '')
  final String firstName;
  @JsonKey(name: 'last_name', defaultValue: '')
  final String lastName;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  @JsonKey(name: 'rating', defaultValue: 5.0)
  final double rating;
  @JsonKey(name: 'total_trips', defaultValue: 0)
  final int totalTrips;
  @JsonKey(name: 'verification_status', defaultValue: 'pending_submission')
  final String verificationStatus;
  @JsonKey(name: 'rejection_reason')
  final String? rejectionReason;
  @JsonKey(name: 'vehicle')
  final DriverVehicleModel? vehicle;

  const DriverProfileModel({
    required this.id,
    required this.phone,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
    required this.rating,
    required this.totalTrips,
    required this.verificationStatus,
    this.rejectionReason,
    this.vehicle,
  });

  factory DriverProfileModel.fromJson(Map<String, dynamic> json) =>
      _$DriverProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$DriverProfileModelToJson(this);

  DriverProfileEntity toEntity() {
    return DriverProfileEntity(
      id: id,
      phone: phone,
      firstName: firstName,
      lastName: lastName,
      avatarUrl: avatarUrl,
      rating: rating,
      totalTrips: totalTrips,
      verificationStatus: verificationStatus,
      rejectionReason: rejectionReason,
      vehicle: vehicle?.toEntity(),
    );
  }
}
