import '../../domain/entities/driver_user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Future<OtpSessionEntity> sendOtp(String phone) async {
    return const OtpSessionEntity(
      sessionId: 'ses_mock',
      expiresIn: 120,
      resendInterval: 60,
    );
  }

  @override
  Future<DriverAuthEntity> loginWithPassword({
    required String phone,
    required String password,
  }) async {
    return const DriverAuthEntity(
      isRegistered: true,
      verificationStatus: 'approved',
      tokens: DriverTokensEntity(
        accessToken: 'mock_token',
        refreshToken: 'mock_refresh',
        expiresIn: 3600,
      ),
      driver: DriverUserEntity(
        id: 'drv_mock',
        phone: '+998901234567',
        firstName: 'Haydovchi',
        lastName: '',
        rating: 5.0,
        totalTrips: 0,
        balance: 0,
        isOnline: false,
      ),
    );
  }

  @override
  Future<void> setPassword({required String newPassword}) async {}

  @override
  Future<DriverAuthEntity> verifyOtp({
    required String phone,
    required String sessionId,
    required String code,
  }) async {
    return const DriverAuthEntity(
      isRegistered: true,
      verificationStatus: 'approved',
      tokens: DriverTokensEntity(
        accessToken: 'mock_token',
        refreshToken: 'mock_refresh',
        expiresIn: 3600,
      ),
      driver: DriverUserEntity(
        id: 'drv_mock',
        phone: '+998901234567',
        firstName: 'Haydovchi',
        lastName: '',
        rating: 5.0,
        totalTrips: 0,
        balance: 0,
        isOnline: false,
      ),
    );
  }

  @override
  Future<void> logout({String? fcmToken}) async {}

  @override
  Future<bool> isAuthenticated() async => false;

  @override
  Future<String?> getSavedAccessToken() async => null;

  @override
  Future<String?> getSavedDriverId() async => null;

  @override
  Future<String?> getSavedVerificationStatus() async => null;

  @override
  Future<DriverTokensEntity> refreshToken(String refreshToken) async {
    return const DriverTokensEntity(
      accessToken: 'mock_refreshed_token',
      refreshToken: 'mock_refreshed_refresh',
      expiresIn: 3600,
    );
  }
}
