import 'dart:async';
import '../storage/secure_storage_service.dart';
import '../utils/app_logger.dart';
import 'location_service.dart';
import 'websocket_service.dart';

import 'push_notification_service.dart';

/// Centralized coordinator for Driver authentication session lifecycle.
/// Ensures all background tasks, sockets, and streams cleanly terminate when session ends.
class SessionManager {
  SessionManager({
    required SecureStorageService secureStorage,
    required WebSocketService webSocketService,
    required LocationService locationService,
    PushNotificationService? pushNotificationService,
  })  : _secureStorage = secureStorage,
        _webSocketService = webSocketService,
        _locationService = locationService,
        _pushNotificationService = pushNotificationService;

  final SecureStorageService _secureStorage;
  final WebSocketService _webSocketService;
  final LocationService _locationService;
  final PushNotificationService? _pushNotificationService;

  final _sessionExpiredController = StreamController<void>.broadcast();

  /// Stream notifying the app router when the session is completely expired.
  Stream<void> get onSessionExpired => _sessionExpiredController.stream;

  bool _isTerminating = false;

  /// Handles 401 refresh token expiration or explicit user logout.
  Future<void> handleSessionExpired({String reason = 'Session expired'}) async {
    if (_isTerminating) return;
    _isTerminating = true;

    AppLogger.warning(
      'SessionManager: Terminating session ($reason)...',
      module: LogModule.auth,
    );

    try {
      // 1. Terminate background location updates
      _locationService.stopLocationTracking();

      // 2. Disconnect real-time WebSocket connection
      _webSocketService.disconnect();

      // 3. Clear encrypted tokens from storage
      await _secureStorage.clearTokens();

      // 4. Unregister device push notification token
      await _pushNotificationService?.unregisterTokenOnLogout();

      // 5. Notify app listeners and navigation router
      _sessionExpiredController.add(null);
    } catch (e, stack) {
      AppLogger.error(
        'SessionManager: Error during session termination: $e',
        module: LogModule.auth,
        error: e,
        stackTrace: stack,
      );
    } finally {
      _isTerminating = false;
    }
  }

  void dispose() {
    _sessionExpiredController.close();
  }
}
