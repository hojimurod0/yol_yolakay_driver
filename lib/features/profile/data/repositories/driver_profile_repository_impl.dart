import 'dart:io';
import '../../domain/entities/driver_profile_entity.dart';
import '../../domain/repositories/driver_profile_repository.dart';
import '../datasources/driver_profile_remote_data_source.dart';

class DriverProfileRepositoryImpl implements DriverProfileRepository {
  final DriverProfileRemoteDataSource _remoteDataSource;

  DriverProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<DriverProfileEntity> getProfile() async {
    final model = await _remoteDataSource.getProfile();
    return model.toEntity();
  }

  @override
  Future<String> uploadAvatar(File file) {
    return _remoteDataSource.uploadAvatar(file);
  }

  @override
  Future<void> updateFcmToken(String token) {
    return _remoteDataSource.updateFcmToken(token);
  }
}
