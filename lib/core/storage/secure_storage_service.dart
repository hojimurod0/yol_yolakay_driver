import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage service managing encrypted authentication tokens.
class SecureStorageService {
  SecureStorageService([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  final FlutterSecureStorage _storage;

  static const String _keyAccessToken = 'auth_access_token';
  static const String _keyRefreshToken = 'auth_refresh_token';
  static const String _keyDriverId = 'auth_driver_id';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    String? driverId,
  }) async {
    await Future.wait([
      _storage.write(key: _keyAccessToken, value: accessToken),
      _storage.write(key: _keyRefreshToken, value: refreshToken),
      if (driverId != null) _storage.write(key: _keyDriverId, value: driverId),
    ]);
  }

  Future<void> saveTokenPair({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _keyAccessToken, value: accessToken),
      _storage.write(key: _keyRefreshToken, value: refreshToken),
    ]);
  }

  Future<void> saveDriverId(String driverId) =>
      _storage.write(key: _keyDriverId, value: driverId);

  Future<String?> getAccessToken() => _storage.read(key: _keyAccessToken);
  Future<String?> getRefreshToken() => _storage.read(key: _keyRefreshToken);
  Future<String?> getDriverId() => _storage.read(key: _keyDriverId);

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _keyAccessToken),
      _storage.delete(key: _keyRefreshToken),
      _storage.delete(key: _keyDriverId),
    ]);
  }
}
