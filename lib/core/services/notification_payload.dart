import 'dart:convert';

/// Represents a strongly typed notification payload parsed from FCM or Local Notification.
class NotificationPayload {
  const NotificationPayload({
    required this.title,
    required this.body,
    this.type = '',
    this.id,
    this.orderId,
    this.tripId,
    this.route,
    this.data = const {},
  });

  final String title;
  final String body;
  final String type;
  final String? id;
  final String? orderId;
  final String? tripId;
  final String? route;
  final Map<String, dynamic> data;

  /// Effective entity identifier (tripId, orderId, or id)
  String? get effectiveId => tripId ?? orderId ?? id;

  /// Factory constructor to parse payload safely from FCM RemoteMessage data or custom map.
  factory NotificationPayload.fromMap(
    Map<String, dynamic> map, {
    String? fallbackTitle,
    String? fallbackBody,
  }) {
    final title = map['title']?.toString() ??
        map['notification_title']?.toString() ??
        fallbackTitle ??
        'Yo\'l-Yo\'lakay Haydovchi';

    final body = map['body']?.toString() ??
        map['notification_body']?.toString() ??
        map['message']?.toString() ??
        fallbackBody ??
        '';

    final type = (map['type'] ?? map['event_type'] ?? '').toString().toLowerCase();
    final id = map['id']?.toString();
    final orderId = map['order_id']?.toString() ?? map['orderId']?.toString();
    final tripId = map['trip_id']?.toString() ?? map['tripId']?.toString();
    final route = map['route']?.toString();

    return NotificationPayload(
      title: title,
      body: body,
      type: type,
      id: id,
      orderId: orderId,
      tripId: tripId,
      route: route,
      data: Map<String, dynamic>.from(map),
    );
  }

  static const List<String> _allowedRoutePrefixes = [
    '/driver/',
    '/verification',
  ];

  /// Resolves the in-app GoRouter navigation destination based on payload attributes.
  String resolveRoute() {
    if (route != null && route!.isNotEmpty) {
      final isAllowed = _allowedRoutePrefixes.any(
        (prefix) => route == prefix || route!.startsWith(prefix),
      );
      if (isAllowed) {
        return route!;
      }
    }

    final targetId = effectiveId;

    switch (type) {
      case 'taxi_order':
      case 'new_order':
      case 'radar':
      case 'order_assigned':
        return '/driver/radar';

      case 'booking':
      case 'booking_update':
      case 'intercity_trip':
      case 'trip_update':
        return (targetId != null && targetId.isNotEmpty)
            ? '/driver/trips/$targetId'
            : '/driver/trips';

      case 'verification':
      case 'verification_status':
      case 'verification_approved':
      case 'verification_rejected':
        return '/verification';

      case 'wallet':
      case 'deposit':
      case 'payout':
      case 'balance_update':
        return '/driver/wallet';

      case 'reviews':
      case 'review':
      case 'rating':
        return '/driver/reviews';

      case 'home':
      default:
        return '/driver/home';
    }
  }

  /// Converts payload to JSON-compatible map for notification serialization.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'type': type,
      if (id != null) 'id': id,
      if (orderId != null) 'order_id': orderId,
      if (tripId != null) 'trip_id': tripId,
      if (route != null) 'route': route,
      'data': data,
    };
  }

  /// Safely encodes to JSON string.
  String toJsonString() => jsonEncode(toMap());

  /// Safely decodes from JSON string.
  static NotificationPayload? fromJsonString(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return NotificationPayload.fromMap(decoded);
      }
    } catch (_) {}
    return null;
  }
}
