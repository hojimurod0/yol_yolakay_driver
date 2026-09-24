import 'package:equatable/equatable.dart';

abstract class ReviewsEvent extends Equatable {
  const ReviewsEvent();

  @override
  List<Object?> get props => [];
}

class LoadReviewsEvent extends WalletReviewsEvent {
  final bool refresh;
  const LoadReviewsEvent({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}

class LoadMoreReviewsEvent extends WalletReviewsEvent {
  const LoadMoreReviewsEvent();
}

class SubmitPassengerRatingEvent extends WalletReviewsEvent {
  final String tripId;
  final String passengerId;
  final int rating;
  final String? comment;

  const SubmitPassengerRatingEvent({
    required this.tripId,
    required this.passengerId,
    required this.rating,
    this.comment,
  });

  @override
  List<Object?> get props => [tripId, passengerId, rating, comment];
}

// Typed alias to avoid naming collisions
typedef WalletReviewsEvent = ReviewsEvent;
