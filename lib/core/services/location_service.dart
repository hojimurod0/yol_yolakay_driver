import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/app_logger.dart';

enum LocationPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  serviceDisabled,
}

/// Robust location service handling runtime GPS permissions, foreground service, and background updates.
class LocationService {
  StreamSubscription<Position>? _trackingSubscription;
  bool _isTracking = false;

  bool get isTracking => _isTracking;

  Future<LocationPermissionStatus> checkAndRequestPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionStatus.serviceDisabled;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return LocationPermissionStatus.denied;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationPermissionStatus.permanentlyDenied;
    }

    return LocationPermissionStatus.granted;
  }

  Future<Position?> getCurrentPosition() async {
    try {
      final status = await checkAndRequestPermission();
      if (status != LocationPermissionStatus.granted) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      // Validate accuracy to discard stale or jumping GPS points
      if (position.accuracy > 100) {
        AppLogger.warning(
          'Discarding inaccurate GPS position (accuracy: ${position.accuracy}m)',
          module: LogModule.system,
        );
        return null;
      }

      return position;
    } catch (e) {
      AppLogger.warning('Failed to obtain GPS position: $e',
          module: LogModule.system);
      return null;
    }
  }

  /// Builds platform-specific location settings with foreground notification on Android
  /// and background updates on iOS.
  LocationSettings _buildLocationSettings({
    int distanceFilter = 10,
    Duration interval = const Duration(seconds: 10),
  }) {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilter,
        intervalDuration: interval,
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: "Yol-Yolakay",
          notificationText: 'Marshrut va taksi radari faol',
          enableWakeLock: true,
        ),
      );
    } else if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilter,
        pauseLocationUpdatesAutomatically: false,
        allowBackgroundLocationUpdates: true,
        showBackgroundLocationIndicator: true,
      );
    }

    return LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: distanceFilter,
      timeLimit: interval,
    );
  }

  Stream<Position> getPositionStream({
    int distanceFilter = 10,
    Duration interval = const Duration(seconds: 10),
  }) {
    return Geolocator.getPositionStream(
      locationSettings: _buildLocationSettings(
        distanceFilter: distanceFilter,
        interval: interval,
      ),
    ).where((position) =>
        position.accuracy <= 50); // Filter out inaccurate GPS fixes
  }

  /// Starts managed location tracking stream when driver is on shift.
  Future<bool> startLocationTracking({
    required void Function(Position position) onPositionChanged,
    int distanceFilter = 10,
    Duration interval = const Duration(seconds: 10),
  }) async {
    if (_isTracking) {
      AppLogger.info('Location tracking is already running.',
          module: LogModule.system);
      return true;
    }

    final permissionStatus = await checkAndRequestPermission();
    if (permissionStatus != LocationPermissionStatus.granted) {
      AppLogger.warning('Cannot start tracking: Permission $permissionStatus',
          module: LogModule.system);
      return false;
    }

    try {
      _trackingSubscription = getPositionStream(
        distanceFilter: distanceFilter,
        interval: interval,
      ).listen(
        (position) {
          onPositionChanged(position);
        },
        onError: (err) {
          AppLogger.warning('Location tracking stream error: $err',
              module: LogModule.system);
        },
      );

      _isTracking = true;
      AppLogger.info('Location tracking started successfully.',
          module: LogModule.system);
      return true;
    } catch (e) {
      AppLogger.error('Failed to start location tracking: $e',
          module: LogModule.system, error: e);
      _isTracking = false;
      return false;
    }
  }

  /// Stops managed location tracking when driver goes offline, closes shift, or logs out.
  void stopLocationTracking() {
    if (_trackingSubscription != null || _isTracking) {
      _trackingSubscription?.cancel();
      _trackingSubscription = null;
      _isTracking = false;
      AppLogger.info('Location tracking stopped.', module: LogModule.system);
    }
  }

  double distanceBetween(
      double startLat, double startLng, double endLat, double endLng) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  Future<bool> openAppSettings() => Geolocator.openAppSettings();
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();
}
