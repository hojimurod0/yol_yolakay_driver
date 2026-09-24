import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/reviews_usecases.dart';
import 'reviews_event.dart';
import 'reviews_state.dart';

class ReviewsBloc extends Bloc<ReviewsEvent, ReviewsState> {
  final GetDriverReviewsUseCase _getDriverReviewsUseCase;
  final RatePassengerUseCase _ratePassengerUseCase;

  int _currentPage = 1;

  ReviewsBloc({
    required GetDriverReviewsUseCase getDriverReviewsUseCase,
    required RatePassengerUseCase ratePassengerUseCase,
  })  : _getDriverReviewsUseCase = getDriverReviewsUseCase,
        _ratePassengerUseCase = ratePassengerUseCase,
        super(const ReviewsState()) {
    on<LoadReviewsEvent>(_onLoadReviews);
    on<LoadMoreReviewsEvent>(_onLoadMoreReviews);
    on<SubmitPassengerRatingEvent>(_onSubmitPassengerRating);
  }

  Future<void> _onLoadReviews(
    LoadReviewsEvent event,
    Emitter<ReviewsState> emit,
  ) async {
    if (!event.refresh && state.status == ReviewsStatus.loaded) return;

    if (!event.refresh) {
      emit(state.copyWith(status: ReviewsStatus.loading, errorMessage: null));
    }

    try {
      _currentPage = 1;
      final summary = await _getDriverReviewsUseCase(page: 1, limit: 20);

      emit(state.copyWith(
        status: ReviewsStatus.loaded,
        summary: summary,
        reviews: summary.items,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ReviewsStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onLoadMoreReviews(
    LoadMoreReviewsEvent event,
    Emitter<ReviewsState> emit,
  ) async {
    if (state.isLoadingMore || state.summary == null) return;
    if (!state.summary!.pagination.hasNextPage) return;

    emit(state.copyWith(isLoadingMore: true));

    try {
      final nextPage = _currentPage + 1;
      final nextSummary =
          await _getDriverReviewsUseCase(page: nextPage, limit: 20);

      _currentPage = nextPage;
      final updatedList = List.of(state.reviews)..addAll(nextSummary.items);

      emit(state.copyWith(
        isLoadingMore: false,
        summary: nextSummary,
        reviews: updatedList,
      ));
    } catch (_) {
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onSubmitPassengerRating(
    SubmitPassengerRatingEvent event,
    Emitter<ReviewsState> emit,
  ) async {
    emit(state.copyWith(
      isSubmittingRating: true,
      ratingError: null,
      ratingSubmittedSuccess: false,
    ));

    try {
      await _ratePassengerUseCase(
        tripId: event.tripId,
        passengerId: event.passengerId,
        rating: event.rating,
        comment: event.comment,
      );

      emit(state.copyWith(
        isSubmittingRating: false,
        ratingSubmittedSuccess: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmittingRating: false,
        ratingError: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}
