import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yol_yolakay_driver/core/services/driver_tracking_service.dart';
import 'package:yol_yolakay_driver/core/services/location_service.dart';
import 'package:yol_yolakay_driver/features/home/domain/entities/home_dashboard_entity.dart';
import 'package:yol_yolakay_driver/features/home/domain/repositories/home_repository.dart';
import 'package:yol_yolakay_driver/features/home/domain/usecases/home_usecases.dart';
import 'package:yol_yolakay_driver/features/home/presentation/bloc/home_bloc.dart';
import 'package:yol_yolakay_driver/features/home/presentation/bloc/home_event.dart';
import 'package:yol_yolakay_driver/features/home/presentation/bloc/home_state.dart';

class FakeHomeRepository implements HomeRepository {
  bool isOnline = false;

  @override
  Future<HomeDashboardEntity> getHomeDashboard() async {
    return HomeDashboardEntity(
      isOnline: isOnline,
      verificationStatus: 'approved',
      walletBalance: 120000,
      dailyStats: const DailyStatsEntity(
        todayEarnings: 200000,
        todayTripsCount: 4,
        onlineHours: 3.5,
        acceptanceRate: 98.0,
      ),
    );
  }

  @override
  Future<bool> toggleShift(
      {required bool isOnline, double? lat, double? lng}) async {
    this.isOnline = isOnline;
    return isOnline;
  }

  @override
  Future<void> updateLocation({
    required double lat,
    required double lng,
    double? bearing,
    double? speed,
    double? accuracy,
  }) async {}
}

class FakeLocationService extends LocationService {
  bool tracking = false;

  @override
  bool get isTracking => tracking;

  @override
  Future<bool> startLocationTracking({
    required void Function(Position position) onPositionChanged,
    int distanceFilter = 10,
    Duration interval = const Duration(seconds: 10),
  }) async =>
      tracking = true;

  @override
  void stopLocationTracking() => tracking = false;

  @override
  Future<Position?> getCurrentPosition() async => null;
}

void main() {
  late FakeHomeRepository fakeRepo;
  late FakeLocationService fakeLocationService;
  late HomeBloc homeBloc;

  setUp(() {
    fakeRepo = FakeHomeRepository();
    fakeLocationService = FakeLocationService();
    homeBloc = HomeBloc(
      getHomeDashboardUseCase: GetHomeDashboardUseCase(fakeRepo),
      toggleShiftUseCase: ToggleShiftUseCase(fakeRepo),
      locationService: fakeLocationService,
      trackingService: DriverTrackingService(
        locationService: fakeLocationService,
        updateLocationUseCase: UpdateLocationUseCase(fakeRepo),
      ),
    );
  });

  tearDown(() {
    homeBloc.close();
  });

  group('HomeBloc Tests', () {
    test('initial state is HomeInitial', () {
      expect(homeBloc.state, const HomeInitial());
    });

    test('LoadHomeDashboardEvent emits [HomeLoading, HomeLoaded]', () async {
      homeBloc.add(const LoadHomeDashboardEvent());

      await expectLater(
        homeBloc.stream,
        emitsInOrder([
          isA<HomeLoading>(),
          predicate<HomeLoaded>((s) =>
              s.dashboard.walletBalance == 120000 && !s.dashboard.isOnline),
        ]),
      );
    });

    test(
        'ToggleShiftEvent updates online status and emits ShiftTogglingState then HomeLoaded',
        () async {
      homeBloc.add(const LoadHomeDashboardEvent());
      await Future.delayed(const Duration(milliseconds: 50));

      homeBloc.add(const ToggleShiftEvent(true));

      await expectLater(
        homeBloc.stream,
        emitsInOrder([
          predicate<ShiftTogglingState>((s) => s.targetOnline == true),
          predicate<HomeLoaded>((s) => s.dashboard.isOnline == true),
        ]),
      );
      expect(fakeLocationService.tracking, isTrue);
    });

    test('tracking keeps running after the home page bloc is closed',
        () async {
      fakeRepo.isOnline = true;
      homeBloc.add(const LoadHomeDashboardEvent());
      await homeBloc.stream.firstWhere((s) => s is HomeLoaded);
      await homeBloc.close();

      expect(fakeLocationService.tracking, isTrue);
    });
  });
}
