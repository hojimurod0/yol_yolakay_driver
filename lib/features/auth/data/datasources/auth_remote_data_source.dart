import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/driver_auth_model.dart';

abstract class AuthRemoteDataSource {
  Future<OtpSessionModel> sendOtp(String phone);
  Future<DriverAuthModel> loginWithPassword({
    required String phone,
    required String password,
  });
  Future<void> setPassword(String newPassword);
  Future<DriverAuthModel> verifyOtp({
    required String phone,
    required String sessionId,
    required String code,
  });
  Future<DriverTokensModel> refreshToken(String refreshToken);
  Future<void> logout({String? fcmToken});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<OtpSessionModel> sendOtp(String phone) async {
    final response = await _apiClient.post(
      ApiEndpoints.sendOtp,
      data: {'phone': phone},
      fromData: (data) =>
          OtpSessionModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<DriverAuthModel> loginWithPassword({
    required String phone,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {
        'phone': phone,
        'password': password,
      },
      fromData: (data) =>
          DriverAuthModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<void> setPassword(String newPassword) async {
    await _apiClient.post(
      ApiEndpoints.setPassword,
      data: {'password': newPassword},
    );
  }

  @override
  Future<DriverAuthModel> verifyOtp({
    required String phone,
    required String sessionId,
    required String code,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.verifyOtp,
      data: {
        'phone': phone,
        'session_id': sessionId,
        'code': code,
      },
      fromData: (data) =>
          DriverAuthModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<DriverTokensModel> refreshToken(String refreshToken) async {
    final response = await _apiClient.post(
      ApiEndpoints.refreshToken,
      data: {'refresh_token': refreshToken},
      fromData: (data) {
        final tokensJson =
            (data as Map<String, dynamic>)['tokens'] as Map<String, dynamic>;
        return DriverTokensModel.fromJson(tokensJson);
      },
    );
    return response.data!;
  }

  @override
  Future<void> logout({String? fcmToken}) async {
    await _apiClient.post(
      ApiEndpoints.logout,
      data: {'fcm_token': fcmToken},
    );
  }
}
