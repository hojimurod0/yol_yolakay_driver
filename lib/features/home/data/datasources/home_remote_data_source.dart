import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/home_dashboard_model.dart';

abstract class HomeRemoteDataSource {
  Future<HomeDashboardModel> getHomeDashboard();
  Future<bool> toggleShift({required bool isOnline, double? lat, double? lng});
  Future<void> updateLocation({
    required double lat,
    required double lng,
    double? bearing,
    double? speed,
    double? accuracy,
  });
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  HomeRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<HomeDashboardModel> getHomeDashboard() async {
    final response = await _apiClient.get(
      ApiEndpoints.driverHome,
      fromData: (data) =>
          HomeDashboardModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<bool> toggleShift(
      {required bool isOnline, double? lat, double? lng}) async {
    final response = await _apiClient.post(
      ApiEndpoints.toggleShift,
      data: {
        'is_online': isOnline,
        if (lat != null) 'current_lat': lat,
        if (lng != null) 'current_lng': lng,
      },
    );
    return response.data?['is_online'] == true;
  }

  @override
  Future<void> updateLocation({
    required double lat,
    required double lng,
    double? bearing,
    double? speed,
    double? accuracy,
  }) async {
    await _apiClient.post(
      ApiEndpoints.updateLocation,
      data: {
        'lat': lat,
        'lng': lng,
        if (bearing != null) 'bearing': bearing,
        if (speed != null) 'speed_kmh': speed,
        if (accuracy != null) 'accuracy': accuracy,
      },
    );
  }
}
