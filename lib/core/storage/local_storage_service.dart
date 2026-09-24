import 'package:shared_preferences/shared_preferences.dart';

/// Centralized Local Storage Service wrapping SharedPreferences for persistent app data.
class LocalStorageService {
  LocalStorageService(this._preferences);

  final SharedPreferences _preferences;

  static const String _keyOnboardingCompleted = 'onboarding_completed';
  static const String _keyLocale = 'app_locale';
  static const String _keyThemeMode = 'theme_mode';

  // Onboarding
  bool isOnboardingCompleted() =>
      _preferences.getBool(_keyOnboardingCompleted) ?? false;

  Future<bool> setOnboardingCompleted(bool value) =>
      _preferences.setBool(_keyOnboardingCompleted, value);

  // Locale
  String getLocale() => _preferences.getString(_keyLocale) ?? 'uz';

  Future<bool> setLocale(String languageCode) =>
      _preferences.setString(_keyLocale, languageCode);

  // Theme Mode
  String getThemeMode() => _preferences.getString(_keyThemeMode) ?? 'system';

  Future<bool> setThemeMode(String mode) =>
      _preferences.setString(_keyThemeMode, mode);

  // Clear
  Future<bool> clearAll() => _preferences.clear();
}
