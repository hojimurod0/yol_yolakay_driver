import 'package:equatable/equatable.dart';

class DriverNotificationEntity extends Equatable {
  final String id;
  final String title;
  final String body;
  final String
      type; // e.g. "new_booking_request", "order_status", "system", "warning"
  final Map<String, dynamic> payload;
  final bool isRead;
  final DateTime createdAt;

  const DriverNotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.payload,
    required this.isRead,
    required this.createdAt,
  });

  DriverNotificationEntity copyWith({
    bool? isRead,
  }) {
    return DriverNotificationEntity(
      id: id,
      title: title,
      body: body,
      type: type,
      payload: payload,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, title, body, type, payload, isRead, createdAt];
}

class DriverNotificationsResultEntity extends Equatable {
  final int unreadCount;
  final List<DriverNotificationEntity> items;

  const DriverNotificationsResultEntity({
    required this.unreadCount,
    required this.items,
  });

  @override
  List<Object?> get props => [unreadCount, items];
}
