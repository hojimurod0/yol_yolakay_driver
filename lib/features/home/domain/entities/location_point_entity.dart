import '../../../../core/utils/cyrillic_converter.dart';

/// Domain entity representing a pickup or drop-off location point.
class LocationPointEntity {
  const LocationPointEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.isCustom = false,
  });

  final String id;
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final bool isCustom;

  String localizedTitle(String languageCode) =>
      CyrillicConverter.maybeConvert(title, languageCode);

  String localizedDescription(String languageCode) =>
      CyrillicConverter.maybeConvert(description, languageCode);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationPointEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
