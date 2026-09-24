import 'package:json_annotation/json_annotation.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/driver_review_entity.dart';

part 'driver_review_model.g.dart';

@JsonSerializable()
class ReviewItemModel {
  @JsonKey(name: 'id')
  final String id;
  @JsonKey(name: 'passenger_name', defaultValue: '')
  final String passengerName;
  @JsonKey(name: 'rating', defaultValue: 5)
  final int rating;
  @JsonKey(name: 'comment', defaultValue: '')
  final String comment;
  @JsonKey(name: 'tags', defaultValue: [])
  final List<String> tags;
  @JsonKey(name: 'created_at', defaultValue: '')
  final String createdAt;

  const ReviewItemModel({
    required this.id,
    required this.passengerName,
    required this.rating,
    required this.comment,
    required this.tags,
    required this.createdAt,
  });

  factory ReviewItemModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewItemModelToJson(this);

  ReviewItemEntity toEntity() {
    return ReviewItemEntity(
      id: id,
      passengerName: passengerName,
      rating: rating,
      comment: comment,
      tags: tags,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
    );
  }
}

@JsonSerializable(explicitToJson: true, createFactory: false)
class DriverReviewsSummaryModel {
  @JsonKey(name: 'overall_rating', defaultValue: 5.0)
  final double overallRating;
  @JsonKey(name: 'rating_counts', defaultValue: {})
  final Map<int, int> ratingCounts;
  @JsonKey(name: 'items', defaultValue: [])
  final List<ReviewItemModel> items;
  @JsonKey(name: 'pagination', defaultValue: PaginationModel(page: 1, limit: 20, totalItems: 0, totalPages: 1))
  final PaginationModel pagination;

  const DriverReviewsSummaryModel({
    required this.overallRating,
    required this.ratingCounts,
    required this.items,
    required this.pagination,
  });

  factory DriverReviewsSummaryModel.fromJson(Map<String, dynamic> json) {
    final countsRaw = json['rating_counts'] as Map<String, dynamic>?;
    final Map<int, int> counts = {};
    if (countsRaw != null) {
      countsRaw.forEach((key, value) {
        final star = int.tryParse(key);
        final count =
            (value is num) ? value.toInt() : int.tryParse(value.toString());
        if (star != null && count != null) {
          counts[star] = count;
        }
      });
    }

    final itemsList = (json['items'] as List<dynamic>?)
            ?.map((e) => ReviewItemModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final paginationJson = json['pagination'] as Map<String, dynamic>?;
    final pagination = paginationJson != null
        ? PaginationModel.fromJson(paginationJson)
        : const PaginationModel(
            page: 1, limit: 20, totalItems: 0, totalPages: 1);

    return DriverReviewsSummaryModel(
      overallRating: (json['overall_rating'] is num)
          ? (json['overall_rating'] as num).toDouble()
          : 5.0,
      ratingCounts: counts,
      items: itemsList,
      pagination: pagination,
    );
  }

  Map<String, dynamic> toJson() => _$DriverReviewsSummaryModelToJson(this);

  DriverReviewsSummaryEntity toEntity() {
    return DriverReviewsSummaryEntity(
      overallRating: overallRating,
      ratingCounts: ratingCounts,
      items: items.map((e) => e.toEntity()).toList(),
      pagination: pagination,
    );
  }
}
