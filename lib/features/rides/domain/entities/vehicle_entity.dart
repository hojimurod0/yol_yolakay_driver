import '../../../../core/utils/cyrillic_converter.dart';

/// Vehicle models and features common on Uzbekistan intercity routes.
enum VehicleType { sedan, crossover, minivan }

class VehicleEntity {
  const VehicleEntity({
    required this.id,
    required this.make,
    required this.model,
    required this.color,
    required this.licensePlate,
    required this.type,
    this.hasAc = true,
    this.hasSpaciousTrunk = true,
    this.hasWifi = false,
    this.isSmokingAllowed = false,
  });

  final String id;
  final String make;
  final String model;
  final String color;
  final String licensePlate;
  final VehicleType type;
  final bool hasAc;
  final bool hasSpaciousTrunk;
  final bool hasWifi;
  final bool isSmokingAllowed;

  String localizedMake(String languageCode) =>
      CyrillicConverter.maybeConvert(make, languageCode);

  String localizedModel(String languageCode) =>
      CyrillicConverter.maybeConvert(model, languageCode);

  String localizedColor(String languageCode) =>
      CyrillicConverter.maybeConvert(color, languageCode);

  String localizedLicensePlate(String languageCode) =>
      CyrillicConverter.maybeConvert(licensePlate, languageCode);

  String localizedFullName(String languageCode) =>
      '${localizedMake(languageCode)} ${localizedModel(languageCode)}';

  String localizedDisplayName(String languageCode) =>
      '${localizedMake(languageCode)} ${localizedModel(languageCode)} (${localizedColor(languageCode)})';

  String get displayName => '$make $model ($color)';
}
