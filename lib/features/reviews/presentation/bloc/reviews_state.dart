import 'package:equatable/equatable.dart';
import '../../domain/entities/driver_review_entity.dart';

enum ReviewsStatus { initial, loading, loaded, error }

class ReviewsState extends Equatable {
  final ReviewsStatus status;
  final DriverReviewsSummaryEntity? summary;
  final List<ReviewItemEntity> reviews;
  final bool isLoadingMore;
  final bool isSubmittingRating;
  final bool ratingSubmittedSuccess;
  final String? errorMessage;
  final String? ratingError;

  const ReviewsState({
    this.status = ReviewsStatus.initial,
    this.summary,
    this.reviews = const [],
    this.isLoadingMore = false,
    this.isSubmittingRating = false,
    this.ratingSubmittedSuccess = false,
    this.errorMessage,
    this.ratingError,
  });

  ReviewsState copyWith({
    ReviewsStatus? status,
    DriverReviewsSummaryEntity? summary,
    List<ReviewItemEntity>? reviews,
    bool? isLoadingMore,
    bool? isSubmittingRating,
    bool? ratingSubmittedSuccess,
    String? errorMessage,
    String? ratingError,
  }) {
    return ReviewsState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      reviews: reviews ?? this.reviews,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSubmittingRating: isSubmittingRating ?? this.isSubmittingRating,
      ratingSubmittedSuccess: ratingSubmittedSuccess ?? false,
      errorMessage: errorMessage ?? this.errorMessage,
      ratingError: ratingError ?? this.ratingError,
    );
  }

  @override
  List<Object?> get props => [
        status,
        summary,
        reviews,
        isLoadingMore,
        isSubmittingRating,
        ratingSubmittedSuccess,
        errorMessage,
        ratingError,
      ];
}
