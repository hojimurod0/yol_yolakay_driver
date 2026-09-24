import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
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

  @override
  Future<List<CityModel>> getCities() async {
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
    return response.data ?? [];
  }

  @override
  Future<DriverApplicationResponseModel> submitApplication({
    required Map<String, dynamic> textFields,
    required Map<String, String> photoFiles,
  }) async {
    final map = Map<String, dynamic>.from(textFields);

    // Attach multipart file streams
    for (final entry in photoFiles.entries) {
      if (entry.value.isNotEmpty) {
        map[entry.key] = await MultipartFile.fromFile(
          entry.value,
          filename: '${entry.key}.jpg',
        );
      }
    }

    final formData = FormData.fromMap(map);

    final response = await _apiClient.post(
      ApiEndpoints.verifyApplication,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
      fromData: (data) =>
          DriverApplicationResponseModel.fromJson(data as Map<String, dynamic>),
    );

    return response.data!;
  }
}
