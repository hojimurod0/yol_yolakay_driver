import '../entities/driver_notification_entity.dart';

abstract class DriverNotificationsRepository {
  Future<DriverNotificationsResultEntity> getNotifications(
      {int page = 1, int limit = 20});
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
}
