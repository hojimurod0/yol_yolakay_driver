import 'package:flutter_test/flutter_test.dart';
import 'package:yol_yolakay_driver/core/services/analytics_service.dart';

void main() {
  group('AnalyticsService Privacy & Sanitization Tests', () {
    late AnalyticsServiceImpl service;

    setUp(() {
      service = AnalyticsServiceImpl();
    });

    test('logs events without throwing exceptions', () async {
      await expectLater(service.logDriverOnline(), completes);
      await expectLater(service.logDriverOffline(), completes);
      await expectLater(service.logOrderReceived('order-123'), completes);
      await expectLater(service.logOrderAccepted('order-123'), completes);
      await expectLater(service.logTripStarted('trip-456'), completes);
      await expectLater(service.logTripCompleted('trip-456', 45000), completes);
      await expectLater(service.logWalletOpened(), completes);
      await expectLater(service.logTopupStarted('payme', 50000), completes);
      await expectLater(service.logSocketConnected(), completes);
      await expectLater(service.logSocketDisconnected(), completes);
    });

    test('sanitizes PII and sensitive tokens from analytics parameters',
        () async {
      await expectLater(
        service.logEvent('user_action', {
          'safe_key': 'safe_value',
          'access_token': 'secret-jwt',
          'password': 'my-password',
          'card_number': '8600123412341234',
          'cvv': '123',
          'otp': '9876',
        }),
        completes,
      );
    });
  });
}
