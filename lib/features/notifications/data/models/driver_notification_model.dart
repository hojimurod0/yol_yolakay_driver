import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/driver_notification_entity.dart';

part 'driver_notification_model.g.dart';

@JsonSerializable()
class DriverNotificationModel {
  @JsonKey(name: 'id')
  final String id;
  @JsonKey(name: 'title', defaultValue: '')
  final String title;
  @JsonKey(name: 'body', defaultValue: '')
  final String body;
  @JsonKey(name: 'type', defaultValue: 'system')
  final String type;
  @JsonKey(name: 'payload', defaultValue: {})
  final Map<String, dynamic> payload;
  @JsonKey(name: 'is_read', defaultValue: false)
  final bool isRead;
  @JsonKey(name: 'created_at', defaultValue: '')
  final String createdAt;

  const DriverNotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.payload,
    required this.isRead,
    required this.createdAt,
  });

  factory DriverNotificationModel.fromJson(Map<String, dynamic> json) =>
      _$DriverNotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$DriverNotificationModelToJson(this);

  DriverNotificationEntity toEntity() {
    return DriverNotificationEntity(
      id: id,
      title: title,
      body: body,
      type: type,
      payload: payload,
      isRead: isRead,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class DriverNotificationsResultModel {
  @JsonKey(name: 'unread_count', defaultValue: 0)
  final int unreadCount;
  @JsonKey(name: 'items', defaultValue: [])
  final List<DriverNotificationModel> items;

  const DriverNotificationsResultModel({
    required this.unreadCount,
    required this.items,
  });

  factory DriverNotificationsResultModel.fromJson(Map<String, dynamic> json) =>
      _$DriverNotificationsResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$DriverNotificationsResultModelToJson(this);

  DriverNotificationsResultEntity toEntity() {
    return DriverNotificationsResultEntity(
      unreadCount: unreadCount,
      items: items.map((e) => e.toEntity()).toList(),
    );
  }
}
