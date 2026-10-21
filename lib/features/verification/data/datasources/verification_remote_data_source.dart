import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/driver_verification_request_dto.dart';
import '../models/verification_models.dart';

abstract class VerificationRemoteDataSource {
  Future<List<CityModel>> getCities();
  Future<DriverApplicationResponseModel> submitApplication({
    required Map<String, dynamic> textFields,
    required Map<String, String> photoFiles,
  });
}

class VerificationRemoteDataSourceImpl implements VerificationRemoteDataSource {
  VerificationRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  static const List<CityModel> _fallbackCities = [
    CityModel(id: 'tashkent', name: 'Toshkent', region: 'Toshkent shahri'),
    CityModel(id: 'samarkand', name: 'Samarqand', region: 'Samarqand viloyati'),
    CityModel(id: 'bukhara', name: 'Buxoro', region: 'Buxoro viloyati'),
    CityModel(id: 'andijan', name: 'Andijon', region: 'Andijon viloyati'),
    CityModel(id: 'fergana', name: 'Farg\'ona', region: 'Farg\'ona viloyati'),
    CityModel(id: 'namangan', name: 'Namangan', region: 'Namangan viloyati'),
    CityModel(id: 'qarshi', name: 'Qarshi', region: 'Qashqadaryo viloyati'),
    CityModel(id: 'termez', name: 'Termiz', region: 'Surxondaryo viloyati'),
    CityModel(id: 'navoiy', name: 'Navoiy', region: 'Navoiy viloyati'),
    CityModel(id: 'jizzakh', name: 'Jizzax', region: 'Jizzax viloyati'),
    CityModel(id: 'gulistan', name: 'Guliston', region: 'Sirdaryo viloyati'),
    CityModel(id: 'urgench', name: 'Urganch', region: 'Xorazm viloyati'),
    CityModel(id: 'nukus', name: 'Nukus', region: 'Qoraqalpog\'iston'),
    CityModel(id: 'khiva', name: 'Xiva', region: 'Xorazm viloyati'),
    CityModel(id: 'kokand', name: 'Qo\'qon', region: 'Farg\'ona viloyati'),
    CityModel(id: 'shakhrisabz', name: 'Shahrisabz', region: 'Qashqadaryo viloyati'),
  ];

  @override
  Future<List<CityModel>> getCities() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.cities,
        fromData: (data) {
          final List<CityModel> list = [];
          if (data is List) {
            for (final item in data) {
              if (item is Map<String, dynamic>) {
                list.add(CityModel.fromJson(item));
              }
            }
          }
          return list;
        },
      );
      final cities = response.data;
      if (cities != null && cities.isNotEmpty) {
        return cities;
      }
    } catch (_) {}
    return _fallbackCities;
  }

  @override
  Future<DriverApplicationResponseModel> submitApplication({
    required Map<String, dynamic> textFields,
    required Map<String, String> photoFiles,
  }) async {
    final map = <String, dynamic>{};

    // 1. Only include backend-whitelisted text fields according to OpenAPI & TZ 2.3
    for (final entry in textFields.entries) {
      if (allowedVerificationTextFields.contains(entry.key)) {
        map[entry.key] = entry.value;
      }
    }

    // 2. Only attach the 6 files allowed by backend Multer FileFieldsInterceptor:
    // (driver_license_front, driver_license_back, tech_passport_front, tech_passport_back, car_front_photo, car_interior_photo)
    for (final entry in photoFiles.entries) {
      if (allowedVerificationFileFields.contains(entry.key) &&
          entry.value.isNotEmpty) {
        final ext = entry.value.split('.').last.toLowerCase();
        map[entry.key] = await MultipartFile.fromFile(
          entry.value,
          filename: '${entry.key}.${ext.isEmpty ? "jpg" : ext}',
        );
      }
    }

    final formData = FormData.fromMap(map);

    final response = await _apiClient.post(
      ApiEndpoints.verifyApplication,
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
        sendTimeout: const Duration(seconds: 90),
        receiveTimeout: const Duration(seconds: 90),
      ),
      fromData: (data) =>
          DriverApplicationResponseModel.fromJson(data as Map<String, dynamic>),
    );

    return response.data!;
  }
}
