/// Represents a geographic location point with address details for map navigation.
class MapLocation {
  const MapLocation({
    required this.id,
    required this.title,
    this.subtitle = '',
    required this.latitude,
    required this.longitude,
    this.isCurrentLocation = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final double latitude;
  final double longitude;
  final bool isCurrentLocation;

  String get fullAddress => subtitle.isNotEmpty ? '$title, $subtitle' : title;

  MapLocation copyWith({
    String? id,
    String? title,
    String? subtitle,
    double? latitude,
    double? longitude,
    bool? isCurrentLocation,
  }) {
    return MapLocation(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isCurrentLocation: isCurrentLocation ?? this.isCurrentLocation,
    );
  }
}
