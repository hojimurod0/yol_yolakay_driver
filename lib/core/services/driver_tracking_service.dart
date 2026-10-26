import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../features/home/domain/usecases/home_usecases.dart';
import '../utils/app_logger.dart';
import 'location_service.dart';
import 'websocket_service.dart';

/// Streams the on-shift driver's GPS position to the backend independently of
/// any page or bloc, so tracking survives navigation and screen rebuilds.
///
/// Positions go over the WebSocket when connected; HTTP is used whenever the
/// socket is down, and at least every [httpSyncInterval] to persist location.
class DriverTrackingService {
  DriverTrackingService({
    required LocationService locationService,
    required UpdateLocationUseCase updateLocationUseCase,
    WebSocketService? webSocketService,
    this.httpSyncInterval = const Duration(seconds: 15),
    DateTime Function()? clock,
  })  : _locationService = locationService,
        _updateLocationUseCase = updateLocationUseCase,
        _webSocketService = webSocketService,
        _clock = clock ?? DateTime.now;

  final LocationService _locationService;
  final UpdateLocationUseCase _updateLocationUseCase;
  final WebSocketService? _webSocketService;
  final Duration httpSyncInterval;
  final DateTime Function() _clock;

  bool _active = false;
  DateTime? _lastHttpSync;

  /// True while positions are being streamed. Also false once something else
  /// (e.g. session termination) stopped the underlying location stream.
  bool get isActive => _active && _locationService.isTracking;

  /// Starts streaming; a no-op if already running. Returns false when the
  /// location permission is missing.
  Future<bool> start() async {
    if (isActive) return true;
    // Drop a stream left by a previous owner so ours gets the callback.
    _locationService.stopLocationTracking();
    _lastHttpSync = null;
    final started = await _locationService.startLocationTracking(
      onPositionChanged: handlePosition,
    );
    _active = started;
    return started;
  }

  void stop() {
    _active = false;
    _locationService.stopLocationTracking();
  }

  @visibleForTesting
  Future<void> handlePosition(Position pos) async {
    final speedKmh = pos.speed >= 0 ? pos.speed * 3.6 : null;
    final socket = _webSocketService;
    final socketUp = socket != null && socket.isConnected;

    if (socketUp) {
      socket.sendLocationUpdate(
        lat: pos.latitude,
        lng: pos.longitude,
        bearing: pos.heading,
        speedKmh: speedKmh,
        accuracy: pos.accuracy,
      );
    }

    final now = _clock();
    final last = _lastHttpSync;
    if (socketUp && last != null && now.difference(last) < httpSyncInterval) {
      return;
    }
    _lastHttpSync = now;
    try {
      await _updateLocationUseCase(
        lat: pos.latitude,
        lng: pos.longitude,
        bearing: pos.heading,
        speed: speedKmh,
        accuracy: pos.accuracy,
      );
    } catch (e) {
      AppLogger.warning('DriverTrackingService: HTTP location sync failed: $e',
          module: LogModule.system);
    }
  }
}
