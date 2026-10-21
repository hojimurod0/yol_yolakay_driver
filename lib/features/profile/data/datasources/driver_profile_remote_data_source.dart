import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/driver_profile_model.dart';

abstract class DriverProfileRemoteDataSource {
  Future<DriverProfileModel> getProfile();
  Future<String> uploadAvatar(File file);
  Future<void> updateFcmToken(String token);
}

class DriverProfileRemoteDataSourceImpl
    implements DriverProfileRemoteDataSource {
  final ApiClient _apiClient;

  DriverProfileRemoteDataSourceImpl(this._apiClient);

  @override
  Future<DriverProfileModel> getProfile() async {
    final response =
        await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.driverProfile);

    if (response.data != null) {
      return DriverProfileModel.fromJson(response.data!);
    } else {
      throw Exception('Profil ma\'lumotlarini yuklab bo\'lmadi');
    }
  }

  @override
  Future<String> uploadAvatar(File file) async {
    final fileName = file.path.split(Platform.pathSeparator).last;
    // OpenAPI UploadAvatarRequest requires binary field named 'file' (max 5120 KB)
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
    });

    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.uploadAvatar,
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );

    if (response.data != null && response.data!['avatar_url'] != null) {
      return response.data!['avatar_url'].toString();
    } else {
      throw Exception('Avatar yuklashda xatolik yuz berdi');
    }
  }

  @override
  Future<void> updateFcmToken(String token) async {
    final platform = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS
        ? 'ios'
        : 'android';
    await _apiClient.post(
      ApiEndpoints.fcmToken,
      data: {
        'fcm_token': token,
        'device_platform': platform,
      },
    );
  }
}
