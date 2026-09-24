// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_review_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewItemModel _$ReviewItemModelFromJson(Map<String, dynamic> json) =>
    ReviewItemModel(
      id: json['id'] as String,
      passengerName: json['passenger_name'] as String? ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 5,
      comment: json['comment'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: json['created_at'] as String? ?? '',
    );

Map<String, dynamic> _$ReviewItemModelToJson(ReviewItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'passenger_name': instance.passengerName,
      'rating': instance.rating,
      'comment': instance.comment,
      'tags': instance.tags,
      'created_at': instance.createdAt,
    };
Map<String, dynamic> _$DriverReviewsSummaryModelToJson(
        DriverReviewsSummaryModel instance) =>
    <String, dynamic>{
      'overall_rating': instance.overallRating,
      'rating_counts':
          instance.ratingCounts.map((k, e) => MapEntry(k.toString(), e)),
      'items': instance.items.map((e) => e.toJson()).toList(),
      'pagination': instance.pagination.toJson(),
    };
