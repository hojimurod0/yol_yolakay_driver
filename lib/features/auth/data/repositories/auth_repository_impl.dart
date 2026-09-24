import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/driver_user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required SecureStorageService secureStorage,
  })  : _remoteDataSource = remoteDataSource,
        _secureStorage = secureStorage;

  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _secureStorage;

  @override
  Future<OtpSessionEntity> sendOtp(String phone) {
    return _remoteDataSource.sendOtp(phone);
  }

  @override
  Future<DriverAuthEntity> verifyOtp({
    required String phone,
    required String sessionId,
    required String code,
  }) async {
    final authResult = await _remoteDataSource.verifyOtp(
      phone: phone,
      sessionId: sessionId,
      code: code,
    );

    // Save tokens securely
    await _secureStorage.saveTokens(
      accessToken: authResult.tokens.accessToken,
      refreshToken: authResult.tokens.refreshToken,
      driverId: authResult.driver.id,
    );

    return authResult;
  }

  @override
  Future<DriverTokensEntity> refreshToken(String refreshToken) async {
    final tokens = await _remoteDataSource.refreshToken(refreshToken);
    await _secureStorage.saveTokenPair(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    return tokens;
  }

  @override
  Future<void> logout({String? fcmToken}) async {
    try {
      await _remoteDataSource.logout(fcmToken: fcmToken);
    } finally {
      await _secureStorage.clearTokens();
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await _secureStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<String?> getSavedAccessToken() => _secureStorage.getAccessToken();

  @override
  Future<String?> getSavedDriverId() => _secureStorage.getDriverId();
}
