import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/mock_notification_repository.dart';
import '../entities/notification_entity.dart';

/// Repository contract for fetching and managing user notifications.
abstract class NotificationRepository {
  Future<List<NotificationEntity>> getNotifications();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
}

final passengerNotificationRepositoryProvider =
    Provider<NotificationRepository>((ref) => MockNotificationRepository());
