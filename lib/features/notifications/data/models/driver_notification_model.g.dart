// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverNotificationModel _$DriverNotificationModelFromJson(
        Map<String, dynamic> json) =>
    DriverNotificationModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      type: json['type'] as String? ?? 'system',
      payload: json['payload'] as Map<String, dynamic>? ?? {},
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] as String? ?? '',
    );

Map<String, dynamic> _$DriverNotificationModelToJson(
        DriverNotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'body': instance.body,
      'type': instance.type,
      'payload': instance.payload,
      'is_read': instance.isRead,
      'created_at': instance.createdAt,
    };

DriverNotificationsResultModel _$DriverNotificationsResultModelFromJson(
        Map<String, dynamic> json) =>
    DriverNotificationsResultModel(
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) =>
                  DriverNotificationModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$DriverNotificationsResultModelToJson(
        DriverNotificationsResultModel instance) =>
    <String, dynamic>{
      'unread_count': instance.unreadCount,
      'items': instance.items.map((e) => e.toJson()).toList(),
    };
