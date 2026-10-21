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
  }) : _secureStorage = secureStorage;

  final SecureStorageService _secureStorage;
  final void Function()? onSessionExpired;

  bool _isRefreshing = false;
  Completer<String?>? _currentRefreshCompleter;
  bool _hasNotifiedExpiration = false;

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
    _currentRefreshCompleter = Completer<String?>();

    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        _handleRefreshFailure('Refresh token missing from secure storage');
        _currentRefreshCompleter?.complete(null);
        return null;
      }

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

      _handleRefreshFailure('Invalid response structure on refresh');
      _currentRefreshCompleter?.complete(null);
      return null;
    } catch (e) {
      _handleRefreshFailure('Exception during token refresh: $e');
      _currentRefreshCompleter?.complete(null);
      return null;
    } finally {
      _isRefreshing = false;
      _currentRefreshCompleter = null;
    }
  }

  void _handleRefreshFailure(String reason) {
    if (!_hasNotifiedExpiration) {
      _hasNotifiedExpiration = true;
      AppLogger.error(
        'TokenRefreshCoordinator: Refresh failed ($reason). Clearing tokens and notifying session expired.',
        module: LogModule.api,
      );
      _secureStorage.clearTokens();
      onSessionExpired?.call();
    }
  }
}
