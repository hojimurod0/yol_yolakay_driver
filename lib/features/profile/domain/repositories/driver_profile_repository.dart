import 'dart:io';
import '../entities/driver_profile_entity.dart';

abstract class DriverProfileRepository {
  Future<DriverProfileEntity> getProfile();
  Future<String> uploadAvatar(File file);
  Future<void> updateFcmToken(String token);
}
