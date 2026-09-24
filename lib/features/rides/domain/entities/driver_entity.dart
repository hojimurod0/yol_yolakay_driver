import '../../../../core/utils/cyrillic_converter.dart';

/// Domain entity representing a verified intercity driver.
class DriverEntity {
  const DriverEntity({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.rating,
    required this.completedTrips,
    this.isVerified = true,
    this.avatarUrl,
    this.telegramHandle,
    this.experienceYears = 5,
    this.bio,
  });

  final String id;
  final String name;
  final String phoneNumber;
  final double rating;
  final int completedTrips;
  final bool isVerified;
  final String? avatarUrl;
  final String? telegramHandle;
  final int experienceYears;
  final String? bio;

  String localizedName(String languageCode) =>
      CyrillicConverter.maybeConvert(name, languageCode);
}
