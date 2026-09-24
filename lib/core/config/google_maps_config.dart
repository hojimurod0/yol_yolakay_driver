/// Google Maps Platform configuration and security management.
///
/// Securely retrieves Google Maps API Keys from environment variables
/// `--dart-define=GOOGLE_MAPS_API_KEY=YOUR_KEY` or custom runtime config.
class GoogleMapsConfig {
  GoogleMapsConfig._();

  /// Environment-defined Google Maps Web/Mobile API Key
  static const String apiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: 'AIzaSyBPgWwEUzyPmAd0mdd7SEfc022zSDbjmpw',
  );

  /// Default initial coordinates (Andijan / Fergana Center, Uzbekistan)
  static const double defaultLat = 40.7821;
  static const double defaultLng = 72.3442;
  static const double defaultZoom = 14.5;

  /// Returns true if a live Google Maps Platform API key is provided
  static bool get hasValidApiKey =>
      apiKey.isNotEmpty && !apiKey.startsWith('AIzaSyDummy');

  /// Required Google Cloud APIs:
  /// 1. Maps SDK for Android
  /// 2. Maps SDK for iOS
  /// 3. Places API (New) / Places API
  /// 4. Directions API / Routes API
  /// 5. Geocoding API
  static const List<String> requiredGoogleCloudApis = [
    'Maps SDK for Android',
    'Maps SDK for iOS',
    'Places API',
    'Directions API',
    'Geocoding API',
  ];
}
