import '../../domain/entities/home_dashboard_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._remoteDataSource);

  final HomeRemoteDataSource _remoteDataSource;

  @override
  Future<HomeDashboardEntity> getHomeDashboard() {
    return _remoteDataSource.getHomeDashboard();
  }

  @override
  Future<bool> toggleShift({required bool isOnline, double? lat, double? lng}) {
    return _remoteDataSource.toggleShift(
      isOnline: isOnline,
      lat: lat,
      lng: lng,
    );
  }

  @override
  Future<void> updateLocation({
    required double lat,
    required double lng,
    double? bearing,
    double? speed,
    double? accuracy,
  }) {
    return _remoteDataSource.updateLocation(
      lat: lat,
      lng: lng,
      bearing: bearing,
      speed: speed,
      accuracy: accuracy,
    );
  }
}
