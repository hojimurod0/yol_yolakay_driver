import '../utils/app_logger.dart';

abstract class AnalyticsService {
  Future<void> logEvent(String name, [Map<String, dynamic>? parameters]);

  Future<void> logLoginSuccess(String driverId);
  Future<void> logLoginFailed(String reason);
  Future<void> logDriverOnline();
  Future<void> logDriverOffline();

  Future<void> logOrderReceived(String orderId);
  Future<void> logOrderAccepted(String orderId);
  Future<void> logOrderRejected(String orderId, [String? reason]);
  Future<void> logOrderExpired(String orderId);

  Future<void> logTripStarted(String tripId);
  Future<void> logTripCompleted(String tripId, [int? earnings]);
  Future<void> logTripCancelled(String tripId, [String? reason]);

  Future<void> logWalletOpened();
  Future<void> logTopupStarted(String paymentSystem, int amount);
  Future<void> logTopupVerified(String paymentSystem, int amount);
  Future<void> logTopupFailed(String paymentSystem, String reason);

  Future<void> logSocketConnected();
  Future<void> logSocketDisconnected();
}

class AnalyticsServiceImpl implements AnalyticsService {
  static const Set<String> _blockedKeys = {
    'token',
    'access_token',
    'refresh_token',
    'authorization',
    'bearer',
    'otp',
    'password',
    'card',
    'card_number',
    'cvv',
    'passport',
    'license',
    'document_url',
  };

  Map<String, dynamic> _sanitize(Map<String, dynamic>? params) {
    if (params == null || params.isEmpty) return {};
    final sanitized = <String, dynamic>{};
    for (final entry in params.entries) {
      final key = entry.key.toLowerCase();
      if (_blockedKeys.any((b) => key.contains(b))) {
        continue;
      }
      sanitized[entry.key] = entry.value;
    }
    return sanitized;
  }

  @override
  Future<void> logEvent(String name, [Map<String, dynamic>? parameters]) async {
    final sanitized = _sanitize(parameters);
    AppLogger.info('📊 [Analytics] $name: $sanitized',
        module: LogModule.system);
  }

  @override
  Future<void> logLoginSuccess(String driverId) =>
      logEvent('login_success', {'driver_id': driverId});

  @override
  Future<void> logLoginFailed(String reason) =>
      logEvent('login_failed', {'reason': reason});

  @override
  Future<void> logDriverOnline() => logEvent('driver_online');

  @override
  Future<void> logDriverOffline() => logEvent('driver_offline');

  @override
  Future<void> logOrderReceived(String orderId) =>
      logEvent('order_received', {'order_id': orderId});

  @override
  Future<void> logOrderAccepted(String orderId) =>
      logEvent('order_accepted', {'order_id': orderId});

  @override
  Future<void> logOrderRejected(String orderId, [String? reason]) => logEvent(
      'order_rejected',
      {'order_id': orderId, if (reason != null) 'reason': reason});

  @override
  Future<void> logOrderExpired(String orderId) =>
      logEvent('order_expired', {'order_id': orderId});

  @override
  Future<void> logTripStarted(String tripId) =>
      logEvent('trip_started', {'trip_id': tripId});

  @override
  Future<void> logTripCompleted(String tripId, [int? earnings]) => logEvent(
      'trip_completed',
      {'trip_id': tripId, if (earnings != null) 'earnings': earnings});

  @override
  Future<void> logTripCancelled(String tripId, [String? reason]) => logEvent(
      'trip_cancelled',
      {'trip_id': tripId, if (reason != null) 'reason': reason});

  @override
  Future<void> logWalletOpened() => logEvent('wallet_opened');

  @override
  Future<void> logTopupStarted(String paymentSystem, int amount) => logEvent(
      'topup_started', {'payment_system': paymentSystem, 'amount': amount});

  @override
  Future<void> logTopupVerified(String paymentSystem, int amount) => logEvent(
      'topup_verified', {'payment_system': paymentSystem, 'amount': amount});

  @override
  Future<void> logTopupFailed(String paymentSystem, String reason) => logEvent(
      'topup_failed', {'payment_system': paymentSystem, 'reason': reason});

  @override
  Future<void> logSocketConnected() => logEvent('socket_connected');

  @override
  Future<void> logSocketDisconnected() => logEvent('socket_disconnected');
}
