import '../../../../core/utils/cyrillic_converter.dart';

/// Domain entity representing a city or major transport hub in Uzbekistan.
class CityEntity {
  const CityEntity({
    required this.id,
    required this.nameUz,
    required this.nameRu,
    required this.nameEn,
    required this.region,
    this.isPopular = false,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String nameUz;
  final String nameRu;
  final String nameEn;
  final String region;
  final bool isPopular;
  final double latitude;
  final double longitude;

  String localizedName(String languageCode) {
    switch (languageCode) {
      case 'ru':
        return nameRu;
      case 'en':
        return nameEn;
      case 'uz':
      default:
        return nameUz;
    }
  }

  String localizedRegion(String languageCode) {
    if (languageCode == 'ru') {
      return CyrillicConverter.toCyrillic(region);
    }
    return region;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CityEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
