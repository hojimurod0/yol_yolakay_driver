import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/driver_notification_model.dart';

abstract class DriverNotificationsRemoteDataSource {
  Future<DriverNotificationsResultModel> getNotifications(
      {int page = 1, int limit = 20});
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
}

class DriverNotificationsRemoteDataSourceImpl
    implements DriverNotificationsRemoteDataSource {
  final ApiClient _apiClient;

  DriverNotificationsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<DriverNotificationsResultModel> getNotifications(
      {int page = 1, int limit = 20}) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.notifications,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    if (response.data != null) {
      return DriverNotificationsResultModel.fromJson(response.data!);
    } else {
      throw Exception('Bildirishnomalarni yuklashda xatolik yuz berdi');
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    await _apiClient.patch(ApiEndpoints.readNotification(id));
  }

  @override
  Future<void> markAllAsRead() async {
    await _apiClient.post(ApiEndpoints.readAllNotifications);
  }
}
