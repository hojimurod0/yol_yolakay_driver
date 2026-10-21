import '../entities/notification_entity.dart';

/// Repository contract for fetching and managing user notifications.
abstract class NotificationRepository {
  Future<List<NotificationEntity>> getNotifications();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
}
