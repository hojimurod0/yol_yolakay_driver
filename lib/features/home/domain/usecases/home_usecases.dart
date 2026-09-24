import '../entities/home_dashboard_entity.dart';
import '../repositories/home_repository.dart';

class GetHomeDashboardUseCase {
  const GetHomeDashboardUseCase(this._repository);
  final HomeRepository _repository;

  Future<HomeDashboardEntity> call() => _repository.getHomeDashboard();
}

class ToggleShiftUseCase {
  const ToggleShiftUseCase(this._repository);
  final HomeRepository _repository;

  Future<bool> call({required bool isOnline, double? lat, double? lng}) =>
      _repository.toggleShift(isOnline: isOnline, lat: lat, lng: lng);
}

class UpdateLocationUseCase {
  const UpdateLocationUseCase(this._repository);
  final HomeRepository _repository;

  Future<void> call({
    required double lat,
    required double lng,
    double? bearing,
    double? speed,
    double? accuracy,
  }) =>
      _repository.updateLocation(
        lat: lat,
        lng: lng,
        bearing: bearing,
        speed: speed,
        accuracy: accuracy,
      );
}
