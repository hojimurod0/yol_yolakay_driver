import '../entities/driver_review_entity.dart';

abstract class ReviewsRepository {
  Future<DriverReviewsSummaryEntity> getDriverReviews(
      {int page = 1, int limit = 20});
  Future<void> ratePassenger({
    required String tripId,
    required String passengerId,
    required int rating,
    String? comment,
  });
}
