import '../entities/driver_user_entity.dart';
import '../repositories/auth_repository.dart';

class SendOtpUseCase {
  const SendOtpUseCase(this._repository);
  final AuthRepository _repository;

  Future<OtpSessionEntity> call(String phone) {
    return _repository.sendOtp(phone);
  }
}

class VerifyOtpUseCase {
  const VerifyOtpUseCase(this._repository);
  final AuthRepository _repository;

  Future<DriverAuthEntity> call({
    required String phone,
    required String sessionId,
    required String code,
  }) {
    return _repository.verifyOtp(
        phone: phone, sessionId: sessionId, code: code);
  }
}

class LogoutUseCase {
  const LogoutUseCase(this._repository);
  final AuthRepository _repository;

  Future<void> call({String? fcmToken}) {
    return _repository.logout(fcmToken: fcmToken);
  }
}

class CheckAuthStatusUseCase {
  const CheckAuthStatusUseCase(this._repository);
  final AuthRepository _repository;

  Future<bool> call() {
    return _repository.isAuthenticated();
  }
}
