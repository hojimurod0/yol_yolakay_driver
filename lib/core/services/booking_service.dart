import '../constants/api_endpoints.dart';
import '../network/api_client.dart';
import '../utils/app_logger.dart';

/// Driver booking service managing seat reservations, status, and cancellations.
class BookingService {
  final ApiClient _apiClient;

  BookingService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<Map<String, dynamic>> createBooking(
      Map<String, dynamic> bookingData) async {
    AppLogger.info('Creating booking', module: LogModule.booking);
    return <String, dynamic>{'status': 'success'};
  }

  Future<void> cancelBooking(String bookingId) async {
    AppLogger.info('Cancelling booking $bookingId', module: LogModule.booking);
    await _apiClient.post(ApiEndpoints.cancelBooking(bookingId),
        data: {'reason': 'Cancelled'});
  }

  Future<List<dynamic>> getBookings() async {
    final response = await _apiClient.get<List<dynamic>>(ApiEndpoints.rides);
    return response.data ?? [];
  }
}
