import '../constants/api_endpoints.dart';
import '../network/api_client.dart';
import '../utils/app_logger.dart';

/// Driver taxi service managing radar and orders.
class TaxiService {
  final ApiClient _apiClient;

  TaxiService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<dynamic>> getNearbyDrivers({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
  }) async {
    return [];
  }

  Future<Map<String, dynamic>?> getFareEstimate({
    required double pickupLat,
    required double pickupLng,
    required double dropoffLat,
    required double dropoffLng,
  }) async {
    return null;
  }

  Future<Map<String, dynamic>?> createOrder({
    required String pickupAddress,
    required double pickupLat,
    required double pickupLng,
    required String destinationAddress,
    required double destLat,
    required double destLng,
    required String tariffType,
  }) async {
    return null;
  }

  Future<void> cancelOrder(String orderId) async {
    AppLogger.info('Cancelling taxi order: $orderId', module: LogModule.taxi);
    await _apiClient.post(ApiEndpoints.taxiCancelOrder(orderId),
        data: {'reason': 'Driver cancelled'});
  }
}
