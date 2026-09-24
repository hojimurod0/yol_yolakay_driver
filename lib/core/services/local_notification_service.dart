import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../utils/app_logger.dart';
import 'notification_payload.dart';

/// Service responsible for managing in-app and foreground system notifications
/// via flutter_local_notifications.
class LocalNotificationService {
  LocalNotificationService({
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  static const String channelId = 'driver_urgent_notifications';
  static const String channelName = 'Haydovchi bildirishnomalari';
  static const String channelDescription =
      'Yangi buyurtmalar, qatnovlar va favqulodda haydovchi yangiliklari';

  final _tapController = StreamController<NotificationPayload>.broadcast();

  /// Stream emitting NotificationPayload when user taps a local notification
  Stream<NotificationPayload> get onNotificationTapped => _tapController.stream;

  bool _isInitialized = false;

  /// Initializes the local notification plugin and channel settings.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );

      await _plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
      );

      // Create Android Notification Channel
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        const channel = AndroidNotificationChannel(
          channelId,
          channelName,
          description: channelDescription,
          importance: Importance.max,
          enableVibration: true,
          playSound: true,
        );
        await androidPlugin.createNotificationChannel(channel);
      }

      // Check if launched from notification tap
      final details = await _plugin.getNotificationAppLaunchDetails();
      if (details != null && details.didNotificationLaunchApp) {
        final payloadStr = details.notificationResponse?.payload;
        final payload = NotificationPayload.fromJsonString(payloadStr);
        if (payload != null) {
          _tapController.add(payload);
        }
      }

      _isInitialized = true;
      AppLogger.info('LocalNotificationService initialized successfully.',
          module: LogModule.system);
    } catch (e) {
      AppLogger.warning('LocalNotificationService initialization error: $e',
          module: LogModule.system);
    }
  }

  void _onNotificationResponse(NotificationResponse response) {
    try {
      final payloadStr = response.payload;
      final payload = NotificationPayload.fromJsonString(payloadStr);
      if (payload != null) {
        _tapController.add(payload);
      }
    } catch (e) {
      AppLogger.warning('Error handling notification tap response: $e',
          module: LogModule.system);
    }
  }

  /// Displays an urgent high-priority local notification banner.
  Future<void> showNotification(
    NotificationPayload payload, {
    int? notificationId,
  }) async {
    try {
      final id = notificationId ??
          DateTime.now().millisecondsSinceEpoch.remainder(100000);

      const androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'Yangi bildirishnoma',
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        playSound: true,
      );

      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      );

      await _plugin.show(
        id,
        payload.title,
        payload.body,
        notificationDetails,
        payload: payload.toJsonString(),
      );
    } catch (e) {
      AppLogger.warning('Failed to show local notification: $e',
          module: LogModule.system);
    }
  }

  /// Cancels all active notifications
  Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }

  void dispose() {
    _tapController.close();
  }
}
