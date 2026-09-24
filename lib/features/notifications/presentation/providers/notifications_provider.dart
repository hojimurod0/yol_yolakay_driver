import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yol_yolakay_driver/features/notifications/domain/entities/notification_entity.dart';
import 'package:yol_yolakay_driver/features/notifications/domain/repositories/notification_repository.dart';

class NotificationsState {
  const NotificationsState({
    this.notifications = const [],
    this.isLoading = false,
  });

  final List<NotificationEntity> notifications;
  final bool isLoading;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  NotificationsState copyWith({
    List<NotificationEntity>? notifications,
    bool? isLoading,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  NotificationsNotifier(this._notificationRepository)
      : super(const NotificationsState()) {
    loadNotifications();
  }

  final NotificationRepository _notificationRepository;

  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true);
    final list = await _notificationRepository.getNotifications();
    state = state.copyWith(notifications: list, isLoading: false);
  }

  Future<void> markAsRead(String id) async {
    await _notificationRepository.markAsRead(id);
    final updated = state.notifications.map((n) {
      return n.id == id ? n.copyWith(isRead: true) : n;
    }).toList();
    state = state.copyWith(notifications: updated);
  }

  Future<void> markAllAsRead() async {
    await _notificationRepository.markAllAsRead();
    final updated =
        state.notifications.map((n) => n.copyWith(isRead: true)).toList();
    state = state.copyWith(notifications: updated);
  }
}

final notificationsNotifierProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  final repo = ref.watch(passengerNotificationRepositoryProvider);
  return NotificationsNotifier(repo);
});
