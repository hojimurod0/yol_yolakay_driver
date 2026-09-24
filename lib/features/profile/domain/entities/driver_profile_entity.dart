import 'package:equatable/equatable.dart';

class DriverVehicleEntity extends Equatable {
  final String make;
  final String model;
  final String color;
  final String licensePlate;
  final int year;
  final String comfortClass;

  const DriverVehicleEntity({
    required this.make,
    required this.model,
    required this.color,
    required this.licensePlate,
    required this.year,
    required this.comfortClass,
  });

  String get displayName => '$make $model ($color, $year)';

  @override
  List<Object?> get props =>
      [make, model, color, licensePlate, year, comfortClass];
}

class DriverProfileEntity extends Equatable {
  final String id;
  final String phone;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final double rating;
  final int totalTrips;
  final String
      verificationStatus; // "pending_submission" | "under_review" | "approved" | "rejected"
  final String? rejectionReason;
  final DriverVehicleEntity? vehicle;

  const DriverProfileEntity({
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

  String get fullName => '$firstName $lastName'.trim();
  bool get isApproved => verificationStatus == 'approved';

  DriverProfileEntity copyWith({
    String? avatarUrl,
    String? firstName,
    String? lastName,
    String? phone,
  }) {
    return DriverProfileEntity(
      id: id,
      phone: phone ?? this.phone,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rating: rating,
      totalTrips: totalTrips,
      verificationStatus: verificationStatus,
      rejectionReason: rejectionReason,
      vehicle: vehicle,
    );
  }

  @override
  List<Object?> get props => [
        id,
        phone,
        firstName,
        lastName,
        avatarUrl,
        rating,
        totalTrips,
        verificationStatus,
        rejectionReason,
        vehicle,
      ];
}
