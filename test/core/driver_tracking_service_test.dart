import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yol_yolakay_driver/core/services/driver_tracking_service.dart';
import 'package:yol_yolakay_driver/core/services/location_service.dart';
import 'package:yol_yolakay_driver/core/services/websocket_service.dart';
import 'package:yol_yolakay_driver/core/storage/secure_storage_service.dart';
import 'package:yol_yolakay_driver/features/home/domain/entities/home_dashboard_entity.dart';
import 'package:yol_yolakay_driver/features/home/domain/repositories/home_repository.dart';
import 'package:yol_yolakay_driver/features/home/domain/usecases/home_usecases.dart';

class _Repo implements HomeRepository {
  final httpSpeeds = <double?>[];

  @override
  Future<void> updateLocation({
    required double lat,
    required double lng,
    double? bearing,
    double? speed,
    double? accuracy,
  }) async =>
      httpSpeeds.add(speed);

  @override
  Future<HomeDashboardEntity> getHomeDashboard() => throw UnimplementedError();

  @override
  Future<bool> toggleShift({required bool isOnline, double? lat, double? lng}) =>
      throw UnimplementedError();
}

class _Location extends LocationService {
  bool tracking = false;
  int starts = 0;
  void Function(Position)? callback;

  @override
  bool get isTracking => tracking;

  @override
  Future<bool> startLocationTracking({
    required void Function(Position position) onPositionChanged,
    int distanceFilter = 10,
    Duration interval = const Duration(seconds: 10),
  }) async {
    starts++;
    callback = onPositionChanged;
    return tracking = true;
  }

  @override
  void stopLocationTracking() => tracking = false;
}

class _Socket extends WebSocketService {
  _Socket() : super(secureStorage: SecureStorageService());

  bool connected = true;
  final wsSpeeds = <double?>[];

  @override
  bool get isConnected => connected;

  @override
  void sendLocationUpdate({
    required double lat,
    required double lng,
    double? bearing,
    double? speedKmh,
    double? accuracy,
  }) =>
      wsSpeeds.add(speedKmh);
}

Position _pos({double speedMs = 10}) => Position(
      latitude: 41.3,
      longitude: 69.2,
      timestamp: DateTime(2026),
      accuracy: 5,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 90,
      headingAccuracy: 0,
      speed: speedMs,
      speedAccuracy: 0,
    );

void main() {
  late _Repo repo;
  late _Location location;
  late _Socket socket;
  late DateTime now;
  late DriverTrackingService service;

  setUp(() {
    repo = _Repo();
    location = _Location();
    socket = _Socket();
    now = DateTime(2026, 10, 22, 12);
    service = DriverTrackingService(
      locationService: location,
      updateLocationUseCase: UpdateLocationUseCase(repo),
      webSocketService: socket,
      clock: () => now,
    );
  });

  test('start is idempotent while tracking runs', () async {
    await service.start();
    await service.start();

    expect(location.starts, 1);
    expect(service.isActive, isTrue);
  });

  test('restarts after something else stopped the location stream', () async {
    await service.start();
    location.stopLocationTracking(); // e.g. session termination
    expect(service.isActive, isFalse);

    await service.start();
    expect(location.starts, 2);
  });

  test('sends km/h over the socket and throttles HTTP to the sync interval',
      () async {
    await service.handlePosition(_pos(speedMs: 10));
    now = now.add(const Duration(seconds: 5));
    await service.handlePosition(_pos(speedMs: 10));
    now = now.add(const Duration(seconds: 11));
    await service.handlePosition(_pos(speedMs: 10));

    expect(socket.wsSpeeds, [36, 36, 36]);
    expect(repo.httpSpeeds, hasLength(2));
  });

  test('falls back to HTTP for every fix while the socket is down', () async {
    socket.connected = false;

    await service.handlePosition(_pos());
    await service.handlePosition(_pos());

    expect(socket.wsSpeeds, isEmpty);
    expect(repo.httpSpeeds, hasLength(2));
  });

  test('stop ends the location stream', () async {
    await service.start();
    service.stop();

    expect(location.tracking, isFalse);
    expect(service.isActive, isFalse);
  });
}
