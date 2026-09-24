import '../entities/driver_user_entity.dart';

/// Clean Architecture domain contract for Driver Authentication.
abstract class AuthRepository {
  Future<OtpSessionEntity> sendOtp(String phone);

  Future<DriverAuthEntity> verifyOtp({
    required String phone,
    required String sessionId,
    required String code,
  });

  Future<DriverTokensEntity> refreshToken(String refreshToken);

  Future<void> logout({String? fcmToken});

  Future<bool> isAuthenticated();

  Future<String?> getSavedAccessToken();

  Future<String?> getSavedDriverId();
}
