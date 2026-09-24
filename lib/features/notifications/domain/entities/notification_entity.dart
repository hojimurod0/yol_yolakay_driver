import '../../../../core/utils/cyrillic_converter.dart';

enum NotificationCategory { booking, trip, promo, system }

/// Domain entity representing a passenger notification item.
class NotificationEntity {
  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.createdAt,
    this.isRead = false,
    this.tripId,
  });

  final String id;
  final String title;
  final String body;
  final NotificationCategory category;
  final DateTime createdAt;
  final bool isRead;
  final String? tripId;

  String localizedTitle(String languageCode) =>
      CyrillicConverter.maybeConvert(title, languageCode);

  String localizedBody(String languageCode) =>
      CyrillicConverter.maybeConvert(body, languageCode);

  NotificationEntity copyWith({
    String? id,
    String? title,
    String? body,
    NotificationCategory? category,
    DateTime? createdAt,
    bool? isRead,
    String? tripId,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      tripId: tripId ?? this.tripId,
    );
  }
}
