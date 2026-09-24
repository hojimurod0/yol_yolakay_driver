import 'package:equatable/equatable.dart';
import '../../../../core/network/api_response.dart';

class ReviewItemEntity extends Equatable {
  final String id;
  final String passengerName;
  final int rating;
  final String comment;
  final List<String> tags;
  final DateTime createdAt;

  const ReviewItemEntity({
    required this.id,
    required this.passengerName,
    required this.rating,
    required this.comment,
    required this.tags,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, passengerName, rating, comment, tags, createdAt];
}

class DriverReviewsSummaryEntity extends Equatable {
  final double overallRating;
  final Map<int, int> ratingCounts; // e.g. {5: 190, 4: 15, 3: 3, 2: 1, 1: 1}
  final List<ReviewItemEntity> items;
  final PaginationModel pagination;

  const DriverReviewsSummaryEntity({
    required this.overallRating,
    required this.ratingCounts,
    required this.items,
    required this.pagination,
  });

  @override
  List<Object?> get props => [overallRating, ratingCounts, items, pagination];
}
