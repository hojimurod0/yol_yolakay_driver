import '../../../../core/utils/cyrillic_converter.dart';

enum SavedPlaceType { home, work, other }

/// Domain entity representing a passenger's saved location shortcut.
class SavedPlaceEntity {
  const SavedPlaceEntity({
    required this.id,
    required this.title,
    required this.address,
    required this.type,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String title;
  final String address;
  final SavedPlaceType type;
  final double latitude;
  final double longitude;

  String localizedTitle(String languageCode) =>
      CyrillicConverter.maybeConvert(title, languageCode);

  String localizedAddress(String languageCode) =>
      CyrillicConverter.maybeConvert(address, languageCode);
}
