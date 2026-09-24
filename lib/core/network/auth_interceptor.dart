import 'dart:async';
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../constants/api_endpoints.dart';
import '../storage/secure_storage_service.dart';
import '../utils/app_logger.dart';

/// Production-grade Dio interceptor managing Bearer token injection,
/// race-condition-free concurrent token refresh, and safe retry execution.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(
    this._secureStorage, {
    this.onSessionExpired,
  });

  final SecureStorageService _secureStorage;
  final VoidCallback? onSessionExpired;

  bool _isRefreshing = false;
  bool _hasNotifiedExpiration = false;
  final List<Completer<String?>> _refreshQueue = [];

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
        path.contains(ApiEndpoints.sendOtp);

    // Only intercept 401 on non-authentication endpoints to prevent infinite refresh loops
    if (err.response?.statusCode == 401 && !isAuthEndpoint) {
      AppLogger.warning(
        '401 Unauthorized received on $path. Attempting token refresh...',
        module: LogModule.api,
      );

      // Check if token was already refreshed by another concurrent request
      final currentStoredToken = await _secureStorage.getAccessToken();
      final requestAuth =
          err.requestOptions.headers['Authorization']?.toString();
      final requestToken = requestAuth?.replaceFirst('Bearer ', '').trim();

      String? newAccessToken;
      if (currentStoredToken != null &&
          currentStoredToken.isNotEmpty &&
          requestToken != null &&
          requestToken != currentStoredToken) {
        // Token was already refreshed concurrently, retry immediately with new token
        AppLogger.info(
          'Token already refreshed concurrently. Retrying with latest token.',
          module: LogModule.api,
        );
        newAccessToken = currentStoredToken;
      } else {
        newAccessToken = await _performTokenRefresh();
      }

      if (newAccessToken != null && newAccessToken.isNotEmpty) {
        _hasNotifiedExpiration = false;
        final retryOptions = err.requestOptions;
        retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';

        // Clone FormData if present to allow stream re-read
        dynamic retryData = retryOptions.data;
        if (retryData is FormData) {
          try {
            retryData = retryData.clone();
            retryOptions.data = retryData;
          } catch (_) {}
        }

        try {
          final client = Dio(BaseOptions(
            baseUrl: AppConfig.activeBaseUrl,
            connectTimeout:
                const Duration(milliseconds: AppConfig.connectTimeout),
            receiveTimeout:
                const Duration(milliseconds: AppConfig.receiveTimeout),
            sendTimeout: const Duration(milliseconds: AppConfig.sendTimeout),
          ));
          final retryResponse = await client.fetch(retryOptions);
          return handler.resolve(retryResponse);
        } catch (e) {
          return handler.next(err);
        }
      } else {
        // Refresh token failed -> notify session expiration once
        if (!_hasNotifiedExpiration) {
          _hasNotifiedExpiration = true;
          AppLogger.error(
            'Refresh token failed. Session fully expired, clearing tokens.',
            module: LogModule.api,
          );
          await _secureStorage.clearTokens();
          onSessionExpired?.call();
        }
        return handler.next(err);
      }
    }

    handler.next(err);
  }

  /// Thread-safe queued token refresh mutex.
  Future<String?> _performTokenRefresh() async {
    if (_isRefreshing) {
      final completer = Completer<String?>();
      _refreshQueue.add(completer);
      return completer.future;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        _drainQueue(null);
        return null;
      }

      // Standalone clean Dio instance without interceptors to prevent circular loops
      final refreshClient = Dio(BaseOptions(
        baseUrl: AppConfig.activeBaseUrl,
        connectTimeout: const Duration(milliseconds: AppConfig.connectTimeout),
        receiveTimeout: const Duration(milliseconds: AppConfig.receiveTimeout),
        sendTimeout: const Duration(milliseconds: AppConfig.sendTimeout),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ));

      final response = await refreshClient.post(
        ApiEndpoints.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        final tokens = data?['tokens'];
        if (tokens != null) {
          final String newAccessToken =
              tokens['access_token']?.toString() ?? '';
          final String newRefreshToken =
              tokens['refresh_token']?.toString() ?? '';

          if (newAccessToken.isNotEmpty) {
            await _secureStorage.saveTokenPair(
              accessToken: newAccessToken,
              refreshToken:
                  newRefreshToken.isNotEmpty ? newRefreshToken : refreshToken,
            );
            _drainQueue(newAccessToken);
            return newAccessToken;
          }
        }
      }

      _drainQueue(null);
      return null;
    } catch (e) {
      AppLogger.error('Failed refreshing token: $e',
          module: LogModule.api, error: e);
      _drainQueue(null);
      return null;
    } finally {
      _isRefreshing = false;
    }
  }

  void _drainQueue(String? newToken) {
    for (final completer in _refreshQueue) {
      if (!completer.isCompleted) {
        completer.complete(newToken);
      }
    }
    _refreshQueue.clear();
  }
}

typedef VoidCallback = void Function();
