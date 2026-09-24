import '../../domain/entities/driver_review_entity.dart';
import '../../domain/repositories/reviews_repository.dart';
import '../datasources/reviews_remote_data_source.dart';

class ReviewsRepositoryImpl implements ReviewsRepository {
  final ReviewsRemoteDataSource _remoteDataSource;

  ReviewsRepositoryImpl(this._remoteDataSource);

  @override
  Future<DriverReviewsSummaryEntity> getDriverReviews(
      {int page = 1, int limit = 20}) async {
    final model =
        await _remoteDataSource.getDriverReviews(page: page, limit: limit);
    return model.toEntity();
  }

  @override
  Future<void> ratePassenger({
    required String tripId,
    required String passengerId,
    required int rating,
    String? comment,
  }) {
    return _remoteDataSource.ratePassenger(
      tripId: tripId,
      passengerId: passengerId,
      rating: rating,
      comment: comment,
    );
  }
}
