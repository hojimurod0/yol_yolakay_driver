import '../../../rides/domain/entities/vehicle_entity.dart';

enum DriverOnlineStatus { online, offline, onTrip }

/// Domain entity representing a driver's profile, vehicle information, and driving statistics.
class DriverProfileEntity {
  const DriverProfileEntity({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.vehicle,
    this.avatarUrl,
    this.telegramHandle,
    this.rating = 4.9,
    this.ratingCount = 128,
    this.completedTripsCount = 246,
    this.status = DriverOnlineStatus.online,
    this.todayEarnings = 420000,
    this.isVerified = true,
    this.licenseNumber = 'AB 7654321',
    this.experienceYears = 6,
    this.isAcceptingParcels = true,
  });

  final String id;
  final String fullName;
  final String phoneNumber;
  final VehicleEntity vehicle;
  final String? avatarUrl;
  final String? telegramHandle;
  final double rating;
  final int ratingCount;
  final int completedTripsCount;
  final DriverOnlineStatus status;
  final int todayEarnings;
  final bool isVerified;
  final String licenseNumber;
  final int experienceYears;
  final bool isAcceptingParcels;

  DriverProfileEntity copyWith({
    String? id,
    String? fullName,
    String? phoneNumber,
    VehicleEntity? vehicle,
    String? avatarUrl,
    String? telegramHandle,
    double? rating,
    int? ratingCount,
    int? completedTripsCount,
    DriverOnlineStatus? status,
    int? todayEarnings,
    bool? isVerified,
    String? licenseNumber,
    int? experienceYears,
    bool? isAcceptingParcels,
  }) {
    return DriverProfileEntity(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      vehicle: vehicle ?? this.vehicle,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      telegramHandle: telegramHandle ?? this.telegramHandle,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      completedTripsCount: completedTripsCount ?? this.completedTripsCount,
      status: status ?? this.status,
      todayEarnings: todayEarnings ?? this.todayEarnings,
      isVerified: isVerified ?? this.isVerified,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      experienceYears: experienceYears ?? this.experienceYears,
      isAcceptingParcels: isAcceptingParcels ?? this.isAcceptingParcels,
    );
  }
}
