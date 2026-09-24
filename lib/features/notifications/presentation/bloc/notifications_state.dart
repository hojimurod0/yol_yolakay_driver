import 'package:equatable/equatable.dart';
import '../../domain/entities/driver_notification_entity.dart';

enum NotificationsStatus { initial, loading, loaded, error }

class NotificationsState extends Equatable {
  final NotificationsStatus status;
  final int unreadCount;
  final List<DriverNotificationEntity> notifications;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final String? errorMessage;

  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.unreadCount = 0,
    this.notifications = const [],
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.errorMessage,
  });

  NotificationsState copyWith({
    NotificationsStatus? status,
    int? unreadCount,
    List<DriverNotificationEntity>? notifications,
    bool? isLoadingMore,
    bool? hasReachedMax,
    String? errorMessage,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      unreadCount: unreadCount ?? this.unreadCount,
      notifications: notifications ?? this.notifications,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        unreadCount,
        notifications,
        isLoadingMore,
        hasReachedMax,
        errorMessage,
      ];
}
