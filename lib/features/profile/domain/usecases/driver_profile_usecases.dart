import 'dart:io';
import '../entities/driver_profile_entity.dart';
import '../repositories/driver_profile_repository.dart';

class GetDriverProfileUseCase {
  final DriverProfileRepository _repository;
  GetDriverProfileUseCase(this._repository);

  Future<DriverProfileEntity> call() {
    return _repository.getProfile();
  }
}

class UploadDriverAvatarUseCase {
  final DriverProfileRepository _repository;
  UploadDriverAvatarUseCase(this._repository);

  Future<String> call(File file) {
    return _repository.uploadAvatar(file);
  }
}

class UpdateFcmTokenUseCase {
  final DriverProfileRepository _repository;
  UpdateFcmTokenUseCase(this._repository);

  Future<void> call(String token) {
    return _repository.updateFcmToken(token);
  }
}
