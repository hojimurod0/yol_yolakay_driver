import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/support_models.dart';

abstract class SupportRemoteDataSource {
  Future<List<FaqItemModel>> getFaqs();
  Future<void> submitTicket({
    required String subject,
    required String message,
    String? orderId,
  });
}

class SupportRemoteDataSourceImpl implements SupportRemoteDataSource {
  final ApiClient _apiClient;

  SupportRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<FaqItemModel>> getFaqs() async {
    final response =
        await _apiClient.get<List<dynamic>>(ApiEndpoints.supportFaq);

    if (response.data != null) {
      return response.data!
          .map((item) => FaqItemModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      return [];
    }
  }

  @override
  Future<void> submitTicket({
    required String subject,
    required String message,
    String? orderId,
  }) async {
    await _apiClient.post(
      ApiEndpoints.supportTickets,
      data: {
        'subject': subject,
        'message': message,
        if (orderId != null && orderId.isNotEmpty) 'order_id': orderId,
      },
    );
  }
}
