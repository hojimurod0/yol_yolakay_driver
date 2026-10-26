import 'package:google_maps_flutter/google_maps_flutter.dart';

/// The single pilot route: Jalaquduq ⇄ Andijan city centre.
/// City ids match `GET /location/cities` on the live backend.
abstract class PilotRoute {
  static const String districtCityId = 'city_and_jalaquduq';
  static const String centerCityId = 'city_and';

  static const LatLng districtLatLng = LatLng(40.7153, 72.6314);
  static const LatLng centerLatLng = LatLng(40.7821, 72.3442);

  /// How long the driver has to answer a request. The server owns this
  /// timer (BACKEND_TZ_PILOT.md, section 2); the app falls back to it only
  /// when a booking carries no `expires_at`.
  static const Duration answerWindow = Duration(minutes: 2);

  /// Price per seat on the pilot route stays inside this band.
  static const List<int> seatPrices = [20000, 25000, 30000];

  /// Pilot cars always carry four passengers.
  static const int seats = 4;

  static const Map<String, String> _names = {
    'city_and_jalaquduq': 'Jalaquduq',
    'city_and': 'Andijon',
    'andijan': 'Andijon',
  };

  /// Display name for a city id saved by the create-trip page.
  static String cityName(String id) {
    final known = _names[id];
    if (known != null) return known;
    final bare = id.replaceFirst(RegExp(r'^city_(and_)?'), '');
    return bare.isEmpty ? id : bare[0].toUpperCase() + bare.substring(1);
  }
}

/// Google Maps night style used when the app is in dark mode.
const String darkMapStyle = '''
[
  {"elementType":"geometry","stylers":[{"color":"#1f2937"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#9ca3af"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#111827"}]},
  {"featureType":"poi","stylers":[{"visibility":"off"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#374151"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#4b5563"}]},
  {"featureType":"transit","stylers":[{"visibility":"off"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#0f172a"}]}
]
''';
