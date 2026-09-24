import '../constants/api_endpoints.dart';
import '../network/api_client.dart';
import '../utils/app_logger.dart';

/// Modular ride service managing intercity rides search, details, and city lists.
class RideService {
  final ApiClient _apiClient;

  RideService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<dynamic>> searchRides({
    required String departureCityId,
    required String destinationCityId,
    required String dateIso,
    required int seats,
  }) async {
    AppLogger.info(
      'Searching intercity rides',
      module: LogModule.rides,
    );
    final response = await _apiClient.get<List<dynamic>>(
      ApiEndpoints.rides,
      queryParameters: {
        'from': departureCityId,
        'to': destinationCityId,
        'date': dateIso,
        'seats': seats,
      },
    );
    return response.data ?? [];
  }

  Future<Map<String, dynamic>?> getRideDetails(String id) async {
    final response = await _apiClient
        .get<Map<String, dynamic>>(ApiEndpoints.rideDetails(id));
    return response.data;
  }

  Future<List<dynamic>> getPopularRoutes() async {
    return [];
  }

  Future<List<dynamic>> getCities() async {
    final response = await _apiClient.get<List<dynamic>>(ApiEndpoints.cities);
    return response.data ?? [];
  }
}
