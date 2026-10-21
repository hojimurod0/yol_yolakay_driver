import 'package:equatable/equatable.dart';

class CityEntity extends Equatable {
  const CityEntity({
    required this.id,
    required this.name,
    required this.region,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String name;
  final String region;
  final double? latitude;
  final double? longitude;

  @override
  List<Object?> get props => [id, name, region, latitude, longitude];
}

class DriverApplicationResponseEntity extends Equatable {
  const DriverApplicationResponseEntity({
    required this.applicationId,
    required this.verificationStatus,
    required this.message,
  });

  final String applicationId;
  final String verificationStatus; // 'under_review' | 'approved' | 'rejected'
  final String message;

  @override
  List<Object?> get props => [applicationId, verificationStatus, message];
}
