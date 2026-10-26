import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yol_yolakay_driver/core/network/auth_interceptor.dart';
import 'package:yol_yolakay_driver/core/network/token_refresh_coordinator.dart';
import 'package:yol_yolakay_driver/core/storage/secure_storage_service.dart';

class _MemoryStorage extends SecureStorageService {
  String? accessToken = 'expired_access_token';
  String? refreshToken = 'valid_refresh_token';

  @override
  Future<String?> getAccessToken() async => accessToken;

  @override
  Future<String?> getRefreshToken() async => refreshToken;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    String? driverId,
    String? verificationStatus,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }

  @override
  Future<void> clearTokens() async {
    accessToken = null;
    refreshToken = null;
  }
}

class _CapturingHandler extends ErrorInterceptorHandler {
  Response? resolved;
  DioException? passed;

  @override
  void resolve(Response response) => resolved = response;

  @override
  void next(DioException err) => passed = err;

  @override
  void reject(DioException err, [bool silent = false]) => passed = err;
}

void main() {
  late _MemoryStorage storage;
  late Dio refreshClient;
  late int refreshCalls;
  late int sessionExpiredCalls;
  late AuthInterceptor interceptor;

  /// [failRefresh] decides how POST /auth/refresh fails.
  void setUpInterceptor(DioException Function(RequestOptions) failRefresh) {
    storage = _MemoryStorage();
    refreshCalls = 0;
    sessionExpiredCalls = 0;
    refreshClient = Dio(BaseOptions(baseUrl: 'https://driver.test/api/v1'));
    refreshClient.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        refreshCalls++;
        await Future<void>.delayed(const Duration(milliseconds: 10));
        handler.reject(failRefresh(options));
      },
    ));
    final coordinator = TokenRefreshCoordinator(
      secureStorage: storage,
      onSessionExpired: () => sessionExpiredCalls++,
      refreshClient: refreshClient,
    );
    interceptor = AuthInterceptor(
      storage,
      onSessionExpired: () => sessionExpiredCalls++,
      coordinator: coordinator,
    );
  }

  Future<_CapturingHandler> send401(String path) async {
    final options = RequestOptions(
      path: path,
      headers: {'Authorization': 'Bearer expired_access_token'},
    );
    final handler = _CapturingHandler();
    await interceptor.onError(
      DioException(
        requestOptions: options,
        response: Response(requestOptions: options, statusCode: 401),
      ),
      handler,
    );
    return handler;
  }

  group('Token refresh failure handling', () {
    test('network error during refresh keeps the session', () async {
      setUpInterceptor((o) => DioException(
            requestOptions: o,
            type: DioExceptionType.connectionError,
          ));

      final handler = await send401('/driver/profile');

      expect(storage.accessToken, 'expired_access_token');
      expect(storage.refreshToken, 'valid_refresh_token');
      expect(sessionExpiredCalls, 0);
      expect(handler.passed?.type, DioExceptionType.connectionError);
      expect(handler.passed?.response, isNull);
      expect(handler.passed?.requestOptions.path, '/driver/profile');
    });

    test('5xx during refresh keeps the session and surfaces the server error',
        () async {
      setUpInterceptor((o) => DioException(
            requestOptions: o,
            type: DioExceptionType.badResponse,
            response: Response(requestOptions: o, statusCode: 503),
          ));

      final handler = await send401('/driver/rides');

      expect(storage.refreshToken, 'valid_refresh_token');
      expect(sessionExpiredCalls, 0);
      expect(handler.passed?.response?.statusCode, 503);
    });

    test('401 on refresh ends the session', () async {
      setUpInterceptor((o) => DioException(
            requestOptions: o,
            type: DioExceptionType.badResponse,
            response: Response(requestOptions: o, statusCode: 401),
          ));

      final handler = await send401('/driver/profile');

      expect(storage.accessToken, isNull);
      expect(storage.refreshToken, isNull);
      expect(sessionExpiredCalls, 1);
      expect(handler.passed?.response?.statusCode, 401);
    });

    test('expiry is reported again after logging in with new tokens',
        () async {
      setUpInterceptor((o) => DioException(
            requestOptions: o,
            type: DioExceptionType.badResponse,
            response: Response(requestOptions: o, statusCode: 401),
          ));

      await send401('/driver/profile');
      expect(sessionExpiredCalls, 1);

      // Driver logs in again and the new session later expires too.
      storage.accessToken = 'second_access_token';
      storage.refreshToken = 'second_refresh_token';
      await send401('/driver/profile');

      expect(sessionExpiredCalls, 2);
      expect(storage.refreshToken, isNull);
    });

    test('concurrent 401s share one refresh and all get the network error',
        () async {
      setUpInterceptor((o) => DioException(
            requestOptions: o,
            type: DioExceptionType.connectionTimeout,
          ));

      final handlers = await Future.wait([
        send401('/driver/profile'),
        send401('/driver/rides'),
        send401('/driver/wallet'),
      ]);

      expect(refreshCalls, 1);
      expect(sessionExpiredCalls, 0);
      expect(storage.refreshToken, 'valid_refresh_token');
      for (final h in handlers) {
        expect(h.passed?.type, DioExceptionType.connectionTimeout);
      }
    });
  });
}
