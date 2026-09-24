import '../constants/api_endpoints.dart';
import '../network/api_client.dart';
import '../utils/app_logger.dart';

/// Modular trip tracking and history service for driver.
class TripService {
  final ApiClient _apiClient;

  TripService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<dynamic>> getActiveTrips() async {
    final response = await _apiClient.get<List<dynamic>>(
      ApiEndpoints.rides,
      queryParameters: {'status': 'active'},
    );
    return response.data ?? [];
  }

  Future<List<dynamic>> getTripHistory() async {
    final response = await _apiClient.get<List<dynamic>>(
      ApiEndpoints.rides,
      queryParameters: {'status': 'completed'},
    );
    return response.data ?? [];
  }

  Future<Map<String, dynamic>?> getTripTracking(String tripId) async {
    return null;
  }

  Future<void> rateTrip({
    required String tripId,
    required double rating,
    String? comment,
  }) async {
    AppLogger.info('Rating trip: $tripId ($rating stars)',
        module: LogModule.booking);
  }
}
