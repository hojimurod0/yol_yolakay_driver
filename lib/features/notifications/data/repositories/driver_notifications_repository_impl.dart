import '../../domain/entities/driver_notification_entity.dart';
import '../../domain/repositories/driver_notifications_repository.dart';
import '../datasources/driver_notifications_remote_data_source.dart';

class DriverNotificationsRepositoryImpl
    implements DriverNotificationsRepository {
  final DriverNotificationsRemoteDataSource _remoteDataSource;

  DriverNotificationsRepositoryImpl(this._remoteDataSource);

  @override
  Future<DriverNotificationsResultEntity> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    final model =
        await _remoteDataSource.getNotifications(page: page, limit: limit);
    return model.toEntity();
  }

  @override
  Future<void> markAsRead(String id) {
    return _remoteDataSource.markAsRead(id);
  }

  @override
  Future<void> markAllAsRead() {
    return _remoteDataSource.markAllAsRead();
  }
}
