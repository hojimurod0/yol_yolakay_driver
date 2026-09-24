// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'earnings_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EarningsChartPointModel _$EarningsChartPointModelFromJson(
        Map<String, dynamic> json) =>
    EarningsChartPointModel(
      date: json['date'] as String,
      day: json['day'] as String,
      earnings: (json['earnings'] as num?)?.toInt() ?? 0,
      trips: (json['trips'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$EarningsChartPointModelToJson(
        EarningsChartPointModel instance) =>
    <String, dynamic>{
      'date': instance.date,
      'day': instance.day,
      'earnings': instance.earnings,
      'trips': instance.trips,
    };

EarningsStatsModel _$EarningsStatsModelFromJson(Map<String, dynamic> json) =>
    EarningsStatsModel(
      period: json['period'] as String? ?? 'weekly',
      totalEarnings: (json['total_earnings'] as num?)?.toInt() ?? 0,
      totalTrips: (json['total_trips'] as num?)?.toInt() ?? 0,
      totalDistanceKm: (json['total_distance_km'] as num?)?.toDouble() ?? 0.0,
      totalOnlineHours: (json['total_online_hours'] as num?)?.toDouble() ?? 0.0,
      chartData: (json['chart_data'] as List<dynamic>?)
              ?.map((e) =>
                  EarningsChartPointModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$EarningsStatsModelToJson(EarningsStatsModel instance) =>
    <String, dynamic>{
      'period': instance.period,
      'total_earnings': instance.totalEarnings,
      'total_trips': instance.totalTrips,
      'total_distance_km': instance.totalDistanceKm,
      'total_online_hours': instance.totalOnlineHours,
      'chart_data': instance.chartData.map((e) => e.toJson()).toList(),
    };
