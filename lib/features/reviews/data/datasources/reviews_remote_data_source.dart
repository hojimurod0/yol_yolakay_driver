import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/driver_review_model.dart';

abstract class ReviewsRemoteDataSource {
  Future<DriverReviewsSummaryModel> getDriverReviews(
      {int page = 1, int limit = 20});
  Future<void> ratePassenger({
    required String tripId,
    required String passengerId,
    required int rating,
    String? comment,
  });
}

class ReviewsRemoteDataSourceImpl implements ReviewsRemoteDataSource {
  final ApiClient _apiClient;

  ReviewsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<DriverReviewsSummaryModel> getDriverReviews({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.reviews,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    if (response.data != null) {
      return DriverReviewsSummaryModel.fromJson(response.data!);
    } else {
      throw Exception('Sharhlarni yuklashda xatolik yuz berdi');
    }
  }

  @override
  Future<void> ratePassenger({
    required String tripId,
    required String passengerId,
    required int rating,
    String? comment,
  }) async {
    await _apiClient.post(
      ApiEndpoints.ratePassenger(tripId),
      data: {
        'passenger_id': passengerId,
        'rating': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      },
    );
  }
}
