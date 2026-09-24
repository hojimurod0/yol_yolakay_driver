import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yol_yolakay_driver/core/network/api_client.dart';
import 'package:yol_yolakay_driver/core/network/api_response.dart';
import 'package:yol_yolakay_driver/core/services/local_notification_service.dart';
import 'package:yol_yolakay_driver/core/services/notification_payload.dart';
import 'package:yol_yolakay_driver/core/services/push_notification_service.dart';

class FakeApiClient extends Fake implements ApiClient {
  String? lastRegisteredToken;
  bool lastDeleted = false;

  @override
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    String? idempotencyKey,
    T Function(dynamic dataJson)? fromData,
  }) async {
    lastRegisteredToken = (data as Map<String, dynamic>?)?['token'] as String?;
    return ApiResponse<T>(
      success: true,
      message: 'OK',
      data: null,
    );
  }

  @override
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    String? idempotencyKey,
    T Function(dynamic dataJson)? fromData,
  }) async {
    lastDeleted = true;
    return ApiResponse<T>(
      success: true,
      message: 'OK',
      data: null,
    );
  }
}

class FakeLocalNotificationService extends Fake implements LocalNotificationService {
  final _tapController = StreamController<NotificationPayload>.broadcast();
  NotificationPayload? lastShownPayload;
  bool initialized = false;

  @override
  Stream<NotificationPayload> get onNotificationTapped => _tapController.stream;

  @override
  Future<void> initialize() async {
    initialized = true;
  }

  @override
  Future<void> showNotification(
    NotificationPayload payload, {
    int? notificationId,
  }) async {
    lastShownPayload = payload;
  }

  void simulateTap(NotificationPayload payload) {
    _tapController.add(payload);
  }

  @override
  void dispose() {
    _tapController.close();
  }
}

void main() {
  late PushNotificationService pushService;
  late FakeApiClient fakeApiClient;
  late FakeLocalNotificationService fakeLocalService;

  setUp(() {
    fakeApiClient = FakeApiClient();
    fakeLocalService = FakeLocalNotificationService();
    pushService = PushNotificationService(
      apiClient: fakeApiClient,
      localNotificationService: fakeLocalService,
    );
  });

  group('NotificationPayload Unit Tests', () {
    test('parses from Map with custom title, body, and fields', () {
      final payload = NotificationPayload.fromMap({
        'title': 'Yangi Buyurtma',
        'body': 'Toshkent - Samarqand',
        'type': 'taxi_order',
        'order_id': 'ord-123',
      });

      expect(payload.title, 'Yangi Buyurtma');
      expect(payload.body, 'Toshkent - Samarqand');
      expect(payload.type, 'taxi_order');
      expect(payload.orderId, 'ord-123');
      expect(payload.effectiveId, 'ord-123');
      expect(payload.resolveRoute(), '/driver/radar');
    });

    test('serializes to JSON string and parses back losslessly', () {
      const original = NotificationPayload(
        title: 'Depozit tushdi',
        body: '50,000 so\'m',
        type: 'wallet',
        id: 'tx-999',
      );

      final jsonStr = original.toJsonString();
      final parsed = NotificationPayload.fromJsonString(jsonStr);

      expect(parsed, isNotNull);
      expect(parsed!.title, original.title);
      expect(parsed.body, original.body);
      expect(parsed.type, original.type);
      expect(parsed.id, original.id);
      expect(parsed.resolveRoute(), '/driver/wallet');
    });

    test('safe parsing handles null or empty json string', () {
      expect(NotificationPayload.fromJsonString(null), isNull);
      expect(NotificationPayload.fromJsonString(''), isNull);
      expect(NotificationPayload.fromJsonString('   '), isNull);
      expect(NotificationPayload.fromJsonString('invalid json {['), isNull);
    });

    test('resolves trips route with tripId', () {
      final payload = NotificationPayload.fromMap({
        'type': 'booking',
        'trip_id': 'trip-777',
      });
      expect(payload.resolveRoute(), '/driver/trips/trip-777');
    });

    test('resolves trips route without id to base list', () {
      final payload = NotificationPayload.fromMap({
        'type': 'booking',
      });
      expect(payload.resolveRoute(), '/driver/trips');
    });

    test('allows whitelisted driver routes provided explicitly', () {
      final payload = NotificationPayload.fromMap({
        'route': '/driver/profile/edit',
      });
      expect(payload.resolveRoute(), '/driver/profile/edit');
    });

    test('blocks unwhitelisted arbitrary routes and falls back to home', () {
      final maliciousVectors = [
        'https://evil.com',
        '/admin',
        '/admin/users',
        '/login',
        'javascript:alert(1)',
        '../',
        '../../etc/passwd',
      ];

      for (final maliciousRoute in maliciousVectors) {
        final payload = NotificationPayload.fromMap({
          'route': maliciousRoute,
        });
        expect(
          payload.resolveRoute(),
          '/driver/home',
          reason: 'Failed to reject malicious route: $maliciousRoute',
        );
      }
    });
  });

  group('PushNotificationService Route Resolution Tests', () {
    test('routes taxi orders and radar notifications to /driver/radar', () {
      expect(
        pushService.resolveNotificationRoute({'type': 'taxi_order'}),
        '/driver/radar',
      );
      expect(
        pushService.resolveNotificationRoute({'type': 'radar'}),
        '/driver/radar',
      );
    });

    test('routes intercity booking notifications to /driver/trips/:id', () {
      expect(
        pushService.resolveNotificationRoute({
          'type': 'booking',
          'id': 'trip-456',
        }),
        '/driver/trips/trip-456',
      );
    });

    test('routes wallet notifications to /driver/wallet', () {
      expect(
        pushService.resolveNotificationRoute({'type': 'wallet'}),
        '/driver/wallet',
      );
      expect(
        pushService.resolveNotificationRoute({'type': 'deposit'}),
        '/driver/wallet',
      );
    });

    test('routes verification notifications to /verification', () {
      expect(
        pushService.resolveNotificationRoute({'type': 'verification'}),
        '/verification',
      );
    });

    test('routes default/unknown notifications to /driver/home', () {
      expect(
        pushService.resolveNotificationRoute({'type': 'unknown_type'}),
        '/driver/home',
      );
    });

    test('strictly rejects arbitrary route injection from remote payload', () {
      final maliciousPayload = {
        'route': '/system/private_keys',
        'type': 'exploit',
        'id': '../../../root',
      };
      expect(
        pushService.resolveNotificationRoute(maliciousPayload),
        '/driver/home',
      );
    });

    test(
        'safely handles empty or completely malformed payload without throwing',
        () {
      expect(pushService.resolveNotificationRoute({}), '/driver/home');
      expect(
        pushService.resolveNotificationRoute({'random_garbage': 12345}),
        '/driver/home',
      );
    });

    test('handleNotificationTap emits resolved route on stream', () async {
      expectLater(
        pushService.onNotificationTapped,
        emits('/driver/wallet'),
      );

      pushService.handleNotificationTap({'type': 'wallet'});
    });

    test('registerDevicePushToken posts token to backend API', () async {
      final success =
          await pushService.registerDevicePushToken('fcm-test-token-123');
      expect(success, isTrue);
      expect(fakeApiClient.lastRegisteredToken, 'fcm-test-token-123');
      expect(pushService.currentPushToken, 'fcm-test-token-123');
    });

    test('unregisterTokenOnLogout deletes token from backend API', () async {
      await pushService.registerDevicePushToken('fcm-test-token-123');
      await pushService.unregisterTokenOnLogout();
      expect(fakeApiClient.lastDeleted, isTrue);
      expect(pushService.currentPushToken, isNull);
    });

    test('LocalNotificationService tap emits resolved route through PushNotificationService', () async {
      await pushService.initialize();
      expect(fakeLocalService.initialized, isTrue);

      expectLater(
        pushService.onNotificationTapped,
        emits('/driver/radar'),
      );

      fakeLocalService.simulateTap(
        const NotificationPayload(
          title: 'Buyurtma',
          body: 'Yangi',
          type: 'taxi_order',
        ),
      );
    });
  });
}
