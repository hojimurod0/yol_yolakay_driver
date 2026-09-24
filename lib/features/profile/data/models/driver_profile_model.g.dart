// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverVehicleModel _$DriverVehicleModelFromJson(Map<String, dynamic> json) =>
    DriverVehicleModel(
      make: json['make'] as String? ?? '',
      model: json['model'] as String? ?? '',
      color: json['color'] as String? ?? '',
      licensePlate: json['license_plate'] as String? ?? '',
      year: (json['year'] as num?)?.toInt() ?? 2020,
      comfortClass: json['comfort_class'] as String? ?? 'standard',
    );

Map<String, dynamic> _$DriverVehicleModelToJson(DriverVehicleModel instance) =>
    <String, dynamic>{
      'make': instance.make,
      'model': instance.model,
      'color': instance.color,
      'license_plate': instance.licensePlate,
      'year': instance.year,
      'comfort_class': instance.comfortClass,
    };

DriverProfileModel _$DriverProfileModelFromJson(Map<String, dynamic> json) =>
    DriverProfileModel(
      id: json['id'] as String,
      phone: json['phone'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      totalTrips: (json['total_trips'] as num?)?.toInt() ?? 0,
      verificationStatus:
          json['verification_status'] as String? ?? 'pending_submission',
      rejectionReason: json['rejection_reason'] as String?,
      vehicle: json['vehicle'] == null
          ? null
          : DriverVehicleModel.fromJson(
              json['vehicle'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DriverProfileModelToJson(DriverProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'phone': instance.phone,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'avatar_url': instance.avatarUrl,
      'rating': instance.rating,
      'total_trips': instance.totalTrips,
      'verification_status': instance.verificationStatus,
      'rejection_reason': instance.rejectionReason,
      'vehicle': instance.vehicle?.toJson(),
    };
