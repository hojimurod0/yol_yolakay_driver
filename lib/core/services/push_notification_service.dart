import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';
import '../constants/api_endpoints.dart';
import '../network/api_client.dart';
import '../storage/secure_storage_service.dart';
import '../utils/app_logger.dart';
import 'local_notification_service.dart';
import 'notification_payload.dart';

/// Top-level background message handler for FCM.
/// Must be an entry point for Dart background isolate execution.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (_) {
    // Graceful fallback if background options unavailable
  }
}

/// Centralized Push Notification Service.
/// Handles Firebase Messaging initialization, permissions, token registration with backend,
/// token refresh listener, unregistration on logout, foreground notifications, and deep-link routing.
class PushNotificationService {
  PushNotificationService({
    required ApiClient apiClient,
    LocalNotificationService? localNotificationService,
    SecureStorageService? secureStorage,
  })  : _apiClient = apiClient,
        _localNotificationService = localNotificationService,
        _secureStorage = secureStorage;

  final ApiClient _apiClient;
  final LocalNotificationService? _localNotificationService;
  final SecureStorageService? _secureStorage;

  String? _registeredPushToken;
  String? _pendingPushToken;
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<NotificationPayload>? _localTapSubscription;

  final _notificationNavigationController =
      StreamController<String>.broadcast();
  final _foregroundNotificationController =
      StreamController<RemoteMessage>.broadcast();

  /// Stream emitting target route path when a push notification is tapped
  Stream<String> get onNotificationTapped =>
      _notificationNavigationController.stream;

  /// Stream emitting incoming foreground notifications
  Stream<RemoteMessage> get onForegroundNotification =>
      _foregroundNotificationController.stream;

  /// Initializes Firebase Push Notifications and foreground Local Notifications.
  /// Gracefully detects whether Firebase is configured without crashing.
  Future<void> initialize() async {
    try {
      // 1. Initialize local notification display service
      final localService = _localNotificationService;
      if (localService != null) {
        await localService.initialize();
        _localTapSubscription =
            localService.onNotificationTapped.listen((payload) {
          final route = payload.resolveRoute();
          AppLogger.info(
            'Local notification tapped, routing to: $route',
            module: LogModule.navigation,
          );
          _notificationNavigationController.add(route);
        });
      }

      if (Firebase.apps.isEmpty) {
        AppLogger.info(
          'PushNotificationService: Firebase not yet initialized. Push notifications will activate once Firebase configuration is present.',
          module: LogModule.system,
        );
        return;
      }

      final messaging = FirebaseMessaging.instance;

      // 2. Request notification permissions (iOS & Android 13+)
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      AppLogger.info(
        'PushNotificationService: Permission status = ${settings.authorizationStatus}',
        module: LogModule.system,
      );

      // 3. Prevent duplicate notification banners on iOS when app is in foreground
      // (LocalNotificationService handles foreground display)
      await messaging.setForegroundNotificationPresentationOptions(
        alert: false,
        badge: true,
        sound: false,
      );

      // 4. Set background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 5. Foreground message listener -> triggers LocalNotificationService
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        AppLogger.info(
          'PushNotificationService: Foreground notification received: ${message.messageId}',
          module: LogModule.system,
        );
        _foregroundNotificationController.add(message);

        final payload = NotificationPayload.fromMap(
          message.data,
          fallbackTitle: message.notification?.title,
          fallbackBody: message.notification?.body,
        );

        _localNotificationService?.showNotification(payload);
      });

      // 6. Background notification tap listener (app was in background)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        AppLogger.info(
          'PushNotificationService: Background notification opened: ${message.messageId}',
          module: LogModule.navigation,
        );
        handleNotificationTap(message.data);
      });

      // 7. Check if app was opened from terminated state by a notification tap
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        AppLogger.info(
          'PushNotificationService: App opened from terminated state via notification: ${initialMessage.messageId}',
          module: LogModule.navigation,
        );
        handleNotificationTap(initialMessage.data);
      }

      // 8. Obtain initial FCM token and register with backend
      final token = await messaging.getToken();
      if (token != null && token.isNotEmpty) {
        await registerDevicePushToken(token);
      }

      // 9. Listen for token refresh and automatically sync with backend
      _tokenRefreshSubscription = messaging.onTokenRefresh.listen((newToken) {
        AppLogger.info(
          'PushNotificationService: FCM token refreshed, syncing with backend.',
          module: LogModule.system,
        );
        registerDevicePushToken(newToken);
      });
    } catch (e) {
      AppLogger.warning(
        'PushNotificationService: Firebase Messaging initialization error: $e',
        module: LogModule.system,
      );
    }
  }

  /// Registers the device push token with the backend API (/driver/fcm-token).
  /// If the driver is not authenticated yet, the token is cached and will be
  /// automatically synchronized once the session is active.
  Future<bool> registerDevicePushToken(String token) async {
    if (token.isEmpty) return false;
    _pendingPushToken = token;

    if (token == _registeredPushToken) return true;

    // Guard: Only register with backend if authenticated
    final storage = _secureStorage;
    if (storage != null) {
      final accessToken = await storage.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        AppLogger.info(
          'PushNotificationService: User not authenticated yet. FCM token cached for registration upon login.',
          module: LogModule.system,
        );
        return false;
      }
    }

    final platform = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS
        ? 'ios'
        : 'android';

    try {
      final response = await _apiClient.post(
        ApiEndpoints.fcmToken,
        data: {
          'fcm_token': token,
          'device_platform': platform,
        },
      );

      if (response.success) {
        _registeredPushToken = token;
        AppLogger.info(
            'Device push token registered successfully with backend.',
            module: LogModule.system);
        return true;
      }
      return false;
    } catch (e) {
      AppLogger.warning('Failed to register push token with backend: $e',
          module: LogModule.system);
      return false;
    }
  }

  /// Synchronizes any pending cached push token once the user logs in.
  Future<bool> syncPendingTokenAfterLogin() async {
    final pending = _pendingPushToken;
    if (pending != null && pending.isNotEmpty) {
      return registerDevicePushToken(pending);
    }
    return false;
  }

  /// Unregisters the push token on user logout.
  Future<void> unregisterTokenOnLogout() async {
    if (_registeredPushToken == null) return;
    try {
      await _apiClient.delete(
        ApiEndpoints.fcmToken,
        data: {'fcm_token': _registeredPushToken},
      );
      _registeredPushToken = null;
      AppLogger.info('Push token unregistered on logout.',
          module: LogModule.system);
    } catch (e) {
      _registeredPushToken = null;
      AppLogger.warning('Token unregistration skipped/failed: $e',
          module: LogModule.system);
    }
  }

  /// Returns the currently registered push token.
  String? get currentPushToken => _registeredPushToken;

  /// Parses incoming notification data payload and extracts deep link navigation target.
  String? resolveNotificationRoute(Map<String, dynamic> data) {
    final payload = NotificationPayload.fromMap(data);
    return payload.resolveRoute();
  }

  /// Called when user taps on a notification banner.
  void handleNotificationTap(Map<String, dynamic> payloadData) {
    final route = resolveNotificationRoute(payloadData);
    if (route != null && route.isNotEmpty) {
      AppLogger.info('Notification tapped, routing to: $route',
          module: LogModule.navigation);
      _notificationNavigationController.add(route);
    }
  }

  void dispose() {
    _tokenRefreshSubscription?.cancel();
    _localTapSubscription?.cancel();
    _notificationNavigationController.close();
    _foregroundNotificationController.close();
  }
}
