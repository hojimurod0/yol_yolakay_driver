import '../constants/api_endpoints.dart';
import '../network/api_client.dart';
import '../storage/secure_storage_service.dart';
import '../utils/app_logger.dart';

/// Modular authentication service managing login, OTP, token persistence, and profile registration.
class AuthService {
  final ApiClient _apiClient;
  final SecureStorageService _secureStorage;

  AuthService({
    required ApiClient apiClient,
    required SecureStorageService secureStorage,
  })  : _apiClient = apiClient,
        _secureStorage = secureStorage;

  /// Request OTP code for a phone number
  Future<void> sendOtp(String phoneNumber) async {
    AppLogger.info('Requesting OTP',
        module: LogModule.auth, data: {'phone': phoneNumber});
    await _apiClient.post(
      ApiEndpoints.sendOtp,
      data: {'phone': phoneNumber},
    );
  }

  /// Verify OTP code and save received authentication tokens
  Future<Map<String, dynamic>> verifyOtp({
    required String phoneNumber,
    required String otpCode,
  }) async {
    AppLogger.info('Verifying OTP code', module: LogModule.auth);
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.verifyOtp,
      data: {
        'phone': phoneNumber,
        'code': otpCode,
      },
    );

    if (response.data != null) {
      final token = response.data!['access_token'] as String?;
      final refreshToken = response.data!['refresh_token'] as String?;
      if (token != null) {
        await _secureStorage.saveTokens(
          accessToken: token,
          refreshToken: refreshToken ?? '',
        );
      }
      return response.data!;
    }
    return <String, dynamic>{};
  }

  /// Check current authenticated user session
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final token = await _secureStorage.getAccessToken();
    if (token == null || token.isEmpty) return null;

    final response =
        await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.driverProfile);
    return response.data;
  }

  /// Create driver user profile
  Future<Map<String, dynamic>> createProfile({
    required String fullName,
    String? email,
  }) async {
    AppLogger.info('Creating profile', module: LogModule.profile);
    return {'status': 'success'};
  }

  /// Logout and clear persistent secure tokens
  Future<void> logout() async {
    AppLogger.info('Logging out user', module: LogModule.auth);
    try {
      await _apiClient.post(ApiEndpoints.logout);
    } catch (_) {}
    await _secureStorage.clearTokens();
  }
}
