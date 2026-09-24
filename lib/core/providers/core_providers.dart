import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/api_client.dart';
import '../di/injection_container.dart';
import '../storage/local_storage_service.dart';
import '../storage/secure_storage_service.dart';

import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/home/data/repositories/city_repository_impl.dart';
import '../../features/home/domain/repositories/city_repository.dart';
import '../../features/notifications/domain/repositories/driver_notifications_repository.dart';
import '../../features/profile/domain/repositories/driver_profile_repository.dart';
import '../../features/support/domain/repositories/support_repository.dart';

import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/taxi_service.dart';
import '../services/ride_service.dart';
import '../services/booking_service.dart';
import '../services/trip_service.dart';
import '../services/notification_service.dart';
import '../services/location_service.dart';

// --- Shared Preferences & Storage Services ---

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main()');
});

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalStorageService(prefs);
});

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return sl.apiClient;
});

// --- Backend-Ready Modular Services ---

final authServiceProvider = Provider<AuthService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return AuthService(apiClient: apiClient, secureStorage: secureStorage);
});

final userServiceProvider = Provider<UserService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return UserService(apiClient: apiClient);
});

final taxiServiceProvider = Provider<TaxiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TaxiService(apiClient: apiClient);
});

final rideServiceProvider = Provider<RideService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return RideService(apiClient: apiClient);
});

final bookingServiceProvider = Provider<BookingService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BookingService(apiClient: apiClient);
});

final tripServiceProvider = Provider<TripService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TripService(apiClient: apiClient);
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return NotificationService(apiClient: apiClient);
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return sl.locationService;
});

// --- Production Repository Providers (Connected to Real API via sl & ApiClient) ---

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return sl.authRepository;
});

final cityRepositoryProvider = Provider<CityRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CityRepositoryImpl(apiClient);
});

final notificationRepositoryProvider =
    Provider<DriverNotificationsRepository>((ref) {
  return sl.notificationsRepository;
});

final driverProfileRepositoryProvider =
    Provider<DriverProfileRepository>((ref) {
  return sl.profileRepository;
});

final supportRepositoryProvider = Provider<SupportRepository>((ref) {
  return sl.supportRepository;
});

// --- Theme Mode State Notifier ---

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier(this._localStorage) : super(_loadInitialMode(_localStorage));

  final LocalStorageService _localStorage;

  static ThemeMode _loadInitialMode(LocalStorageService storage) {
    final mode = storage.getThemeMode();
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    final modeString = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    _localStorage.setThemeMode(modeString);
  }
}

final themeNotifierProvider =
    StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return ThemeNotifier(storage);
});

// --- Locale State Notifier ---

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier(this._localStorage) : super(_loadInitialLocale(_localStorage));

  final LocalStorageService _localStorage;

  static Locale _loadInitialLocale(LocalStorageService storage) {
    final lang = storage.getLocale();
    return Locale(lang);
  }

  void setLocale(String languageCode) {
    state = Locale(languageCode);
    _localStorage.setLocale(languageCode);
  }
}

final localeNotifierProvider =
    StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return LocaleNotifier(storage);
});
