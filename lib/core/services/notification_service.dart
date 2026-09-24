import '../constants/api_endpoints.dart';
import '../network/api_client.dart';
import '../utils/app_logger.dart';

/// Modular notifications service for in-app and push updates.
class NotificationService {
  final ApiClient _apiClient;

  NotificationService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<dynamic>> getNotifications() async {
    final response =
        await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.notifications);
    if (response.data != null && response.data!['items'] is List) {
      return response.data!['items'] as List<dynamic>;
    }
    return [];
  }

  Future<void> markAsRead(String id) async {
    AppLogger.info('Marking notification read: $id', module: LogModule.system);
    await _apiClient.patch(ApiEndpoints.readNotification(id));
  }

  Future<void> markAllAsRead() async {
    await _apiClient.post(ApiEndpoints.readAllNotifications);
  }
}
