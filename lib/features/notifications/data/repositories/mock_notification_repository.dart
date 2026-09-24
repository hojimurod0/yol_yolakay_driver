import 'package:yol_yolakay_driver/features/notifications/domain/entities/notification_entity.dart';
import 'package:yol_yolakay_driver/features/notifications/domain/repositories/notification_repository.dart';

/// Mock Notification Repository providing rich categorized notifications.
class MockNotificationRepository implements NotificationRepository {
  static final List<NotificationEntity> _notifications = [
    NotificationEntity(
      id: 'notif_01',
      title: 'Safar boshlandi!',
      body:
          'Haydovchi Azizbek Rahimov Samarqand yo\'nalishida safarni boshladi.',
      category: NotificationCategory.trip,
      createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
      isRead: false,
      tripId: 'trip_act_01',
    ),
    NotificationEntity(
      id: 'notif_02',
      title: 'Band qilish tasdiqlandi',
      body:
          'Buxoro yo\'nalishidagi joyingiz muvaffaqiyatli band qilindi. Buyurtma ID: YYK-UPK3301.',
      category: NotificationCategory.booking,
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      isRead: false,
    ),
    NotificationEntity(
      id: 'notif_03',
      title: 'Bahoriy chegirma!',
      body:
          'Toshkent — Farg\'ona yo\'nalishiga barcha qatnovlar uchun 10% chegirma taqdim etiladi.',
      category: NotificationCategory.promo,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
    ),
    NotificationEntity(
      id: 'notif_04',
      title: 'Safaringiz yakunlandi',
      body:
          'Samarqand — Toshkent safari muvaffaqiyatli yakunlandi. Xizmat sifatini baholang.',
      category: NotificationCategory.trip,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      isRead: true,
      tripId: 'trip_comp_01',
    ),
  ];

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_notifications);
  }

  @override
  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
  }
}
