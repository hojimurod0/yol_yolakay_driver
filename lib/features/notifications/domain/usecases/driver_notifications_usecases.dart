import '../entities/driver_notification_entity.dart';
import '../repositories/driver_notifications_repository.dart';

class GetDriverNotificationsUseCase {
  final DriverNotificationsRepository _repository;
  GetDriverNotificationsUseCase(this._repository);

  Future<DriverNotificationsResultEntity> call({int page = 1, int limit = 20}) {
    return _repository.getNotifications(page: page, limit: limit);
  }
}

class MarkNotificationAsReadUseCase {
  final DriverNotificationsRepository _repository;
  MarkNotificationAsReadUseCase(this._repository);

  Future<void> call(String id) {
    return _repository.markAsRead(id);
  }
}

class MarkAllNotificationsAsReadUseCase {
  final DriverNotificationsRepository _repository;
  MarkAllNotificationsAsReadUseCase(this._repository);

  Future<void> call() {
    return _repository.markAllAsRead();
  }
}
