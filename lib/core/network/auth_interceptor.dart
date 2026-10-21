import 'dart:async';
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../constants/api_endpoints.dart';
import '../storage/secure_storage_service.dart';
import '../utils/app_logger.dart';
import 'token_refresh_coordinator.dart';

/// Production-grade Dio interceptor managing Bearer token injection,
/// single-flight token refresh with TokenRefreshCoordinator, and safe request retry.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(
    this._secureStorage, {
    this.onSessionExpired,
    TokenRefreshCoordinator? coordinator,
  }) : _coordinator = coordinator ??
            TokenRefreshCoordinator(
              secureStorage: _secureStorage,
              onSessionExpired: onSessionExpired,
            );

  final SecureStorageService _secureStorage;
  final void Function()? onSessionExpired;
  final TokenRefreshCoordinator _coordinator;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Accept'] = 'application/json';
    if (!options.headers.containsKey('Content-Type')) {
      options.headers['Content-Type'] = 'application/json';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final path = err.requestOptions.path;
    final isAuthEndpoint = path.contains(ApiEndpoints.refreshToken) ||
        path.contains(ApiEndpoints.verifyOtp) ||
        path.contains(ApiEndpoints.sendOtp) ||
        path.contains(ApiEndpoints.login);

    final hadAuthHeader = err.requestOptions.headers.containsKey('Authorization') &&
        (err.requestOptions.headers['Authorization'] as String?)?.isNotEmpty == true;

    // Only intercept 401 on authenticated, non-auth requests to prevent infinite loops and false session expiration
    if (err.response?.statusCode == 401 && !isAuthEndpoint && hadAuthHeader) {
      AppLogger.warning(
        '401 Unauthorized received on $path. Triggering single-flight token refresh...',
        module: LogModule.api,
      );

      final newAccessToken = await _coordinator.refreshToken();

      if (newAccessToken != null && newAccessToken.isNotEmpty) {
        try {
          final response = await _replayRequest(err.requestOptions, newAccessToken);
          return handler.resolve(response);
        } catch (e) {
          return handler.next(err);
        }
      } else {
        return handler.next(err);
      }
    }

    handler.next(err);
  }

  /// Replays a failed request with the new access token.
  Future<Response<dynamic>> _replayRequest(
    RequestOptions requestOptions,
    String newAccessToken,
  ) async {
    final retryOptions = requestOptions;
    retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';

    // Clone FormData if present to allow stream re-read
    dynamic retryData = retryOptions.data;
    if (retryData is FormData) {
      try {
        retryData = retryData.clone();
        retryOptions.data = retryData;
      } catch (_) {}
    }

    final client = Dio(BaseOptions(
      baseUrl: AppConfig.activeBaseUrl,
      connectTimeout: const Duration(milliseconds: AppConfig.connectTimeout),
      receiveTimeout: const Duration(milliseconds: AppConfig.receiveTimeout),
      sendTimeout: const Duration(milliseconds: AppConfig.sendTimeout),
    ));

    return client.fetch(retryOptions);
  }
}
