import '../entities/driver_review_entity.dart';
import '../repositories/reviews_repository.dart';

class GetDriverReviewsUseCase {
  final ReviewsRepository _repository;
  GetDriverReviewsUseCase(this._repository);

  Future<DriverReviewsSummaryEntity> call({int page = 1, int limit = 20}) {
    return _repository.getDriverReviews(page: page, limit: limit);
  }
}

class RatePassengerUseCase {
  final ReviewsRepository _repository;
  RatePassengerUseCase(this._repository);

  Future<void> call({
    required String tripId,
    required String passengerId,
    required int rating,
    String? comment,
  }) {
    return _repository.ratePassenger(
      tripId: tripId,
      passengerId: passengerId,
      rating: rating,
      comment: comment,
    );
  }
}
