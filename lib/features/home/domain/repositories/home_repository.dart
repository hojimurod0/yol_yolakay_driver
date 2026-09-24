import '../entities/home_dashboard_entity.dart';

abstract class HomeRepository {
  Future<HomeDashboardEntity> getHomeDashboard();
  Future<bool> toggleShift({required bool isOnline, double? lat, double? lng});
  Future<void> updateLocation({
    required double lat,
    required double lng,
    double? bearing,
    double? speed,
    double? accuracy,
  });
}
