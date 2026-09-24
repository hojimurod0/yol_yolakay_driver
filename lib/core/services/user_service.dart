import '../constants/api_endpoints.dart';
import '../network/api_client.dart';
import '../utils/app_logger.dart';

/// Driver user service handling profile.
class UserService {
  final ApiClient _apiClient;

  UserService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<Map<String, dynamic>> getProfile() async {
    AppLogger.info('Fetching user profile', module: LogModule.profile);
    final response =
        await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.driverProfile);
    return response.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> updateProfile({
    required String firstName,
    required String lastName,
    String? email,
  }) async {
    AppLogger.info('Updating user profile', module: LogModule.profile);
    return <String, dynamic>{'status': 'success'};
  }

  Future<List<dynamic>> getSavedPlaces() async {
    return [];
  }

  Future<void> addSavedPlace(Map<String, dynamic> place) async {}

  Future<void> deleteSavedPlace(String id) async {}
}
