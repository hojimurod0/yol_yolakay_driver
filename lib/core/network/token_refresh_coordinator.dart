import 'dart:async';
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../constants/api_endpoints.dart';
import '../storage/secure_storage_service.dart';
import '../utils/app_logger.dart';

/// Single-flight concurrent token refresh coordinator.
/// Ensures only ONE token refresh request is sent to the server even if multiple
/// requests fail simultaneously with 401 Unauthorized.
class TokenRefreshCoordinator {
  TokenRefreshCoordinator({
    required SecureStorageService secureStorage,
    this.onSessionExpired,
    Dio? refreshClient,
  })  : _secureStorage = secureStorage,
        _refreshClient = refreshClient;

  final SecureStorageService _secureStorage;
  final Dio? _refreshClient;
  final void Function()? onSessionExpired;

  bool _isRefreshing = false;
  Completer<String?>? _currentRefreshCompleter;
  bool _hasNotifiedExpiration = false;

  /// Refresh token whose rejection last ended the session. A different token
  /// means the driver logged in again, so expiry must be reported again.
  String? _expiredRefreshToken;

  /// Set when the last refresh failed for a transient reason (no network,
  /// timeout, 5xx). Tokens are kept; callers surface this error instead of
  /// the original 401. Read after awaiting [refreshToken].
  DioException? get lastTransientError => _lastTransientError;
  DioException? _lastTransientError;

  /// Only an explicit rejection of the refresh token ends the session.
  static bool _isSessionRejected(Object error) {
    if (error is! DioException) return false;
    final status = error.response?.statusCode;
    return status == 401 || status == 403;
  }

  /// Returns true if a refresh operation is currently in flight.
  bool get isRefreshing => _isRefreshing;

  /// Initiates or joins an active token refresh operation.
  Future<String?> refreshToken() async {
    if (_isRefreshing && _currentRefreshCompleter != null) {
      AppLogger.info(
        'TokenRefreshCoordinator: Joining in-flight token refresh operation.',
        module: LogModule.api,
      );
      return _currentRefreshCompleter!.future;
    }

    _isRefreshing = true;
    _lastTransientError = null;
    _currentRefreshCompleter = Completer<String?>();

    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken != null &&
          refreshToken.isNotEmpty &&
          refreshToken != _expiredRefreshToken) {
        _hasNotifiedExpiration = false;
      }
      if (refreshToken == null || refreshToken.isEmpty) {
        await _handleRefreshFailure('Refresh token missing from secure storage');
        _currentRefreshCompleter?.complete(null);
        return null;
      }

      final refreshClient = _refreshClient ??
          Dio(BaseOptions(
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
            await _secureStorage.saveTokens(
              accessToken: newAccessToken,
              refreshToken:
                  newRefreshToken.isNotEmpty ? newRefreshToken : refreshToken,
            );
            _hasNotifiedExpiration = false;
            AppLogger.info(
              'TokenRefreshCoordinator: Token refresh succeeded single-flight.',
              module: LogModule.api,
            );
            _currentRefreshCompleter?.complete(newAccessToken);
            return newAccessToken;
          }
        }
      }

      await _handleRefreshFailure('Invalid response structure on refresh',
          refreshToken: refreshToken);
      _currentRefreshCompleter?.complete(null);
      return null;
    } catch (e) {
      if (_isSessionRejected(e)) {
        await _handleRefreshFailure('Refresh token rejected: $e',
            refreshToken: await _secureStorage.getRefreshToken());
      } else {
        AppLogger.warning(
          'TokenRefreshCoordinator: Refresh failed transiently, keeping session: $e',
          module: LogModule.api,
        );
        _lastTransientError = e is DioException
            ? e
            : DioException(
                requestOptions: RequestOptions(path: ApiEndpoints.refreshToken),
                type: DioExceptionType.unknown,
                error: e,
              );
      }
      _currentRefreshCompleter?.complete(null);
      return null;
    } finally {
      _isRefreshing = false;
      _currentRefreshCompleter = null;
    }
  }

  Future<void> _handleRefreshFailure(String reason,
      {String? refreshToken}) async {
    if (!_hasNotifiedExpiration) {
      _hasNotifiedExpiration = true;
      _expiredRefreshToken = refreshToken;
      AppLogger.error(
        'TokenRefreshCoordinator: Refresh failed ($reason). Clearing tokens and notifying session expired.',
        module: LogModule.api,
      );
      await _secureStorage.clearTokens();
      onSessionExpired?.call();
    }
  }
}
