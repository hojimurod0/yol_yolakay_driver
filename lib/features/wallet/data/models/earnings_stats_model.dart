import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/earnings_stats_entity.dart';

part 'earnings_stats_model.g.dart';

@JsonSerializable()
class EarningsChartPointModel {
  @JsonKey(name: 'date')
  final String date;
  @JsonKey(name: 'day')
  final String day;
  @JsonKey(name: 'earnings', defaultValue: 0)
  final int earnings;
  @JsonKey(name: 'trips', defaultValue: 0)
  final int trips;

  const EarningsChartPointModel({
    required this.date,
    required this.day,
    required this.earnings,
    required this.trips,
  });

  factory EarningsChartPointModel.fromJson(Map<String, dynamic> json) =>
      _$EarningsChartPointModelFromJson(json);

  Map<String, dynamic> toJson() => _$EarningsChartPointModelToJson(this);

  EarningsChartPointEntity toEntity() {
    return EarningsChartPointEntity(
      date: date,
      day: day,
      earnings: earnings,
      trips: trips,
    );
  }
}

@JsonSerializable(explicitToJson: true)
class EarningsStatsModel {
  @JsonKey(name: 'period', defaultValue: 'weekly')
  final String period;
  @JsonKey(name: 'total_earnings', defaultValue: 0)
  final int totalEarnings;
  @JsonKey(name: 'total_trips', defaultValue: 0)
  final int totalTrips;
  @JsonKey(name: 'total_distance_km', defaultValue: 0.0)
  final double totalDistanceKm;
  @JsonKey(name: 'total_online_hours', defaultValue: 0.0)
  final double totalOnlineHours;
  @JsonKey(name: 'chart_data', defaultValue: [])
  final List<EarningsChartPointModel> chartData;

  const EarningsStatsModel({
    required this.period,
    required this.totalEarnings,
    required this.totalTrips,
    required this.totalDistanceKm,
    required this.totalOnlineHours,
    required this.chartData,
  });

  factory EarningsStatsModel.fromJson(Map<String, dynamic> json) =>
      _$EarningsStatsModelFromJson(json);

  Map<String, dynamic> toJson() => _$EarningsStatsModelToJson(this);

  EarningsStatsEntity toEntity() {
    return EarningsStatsEntity(
      period: period,
      totalEarnings: totalEarnings,
      totalTrips: totalTrips,
      totalDistanceKm: totalDistanceKm,
      totalOnlineHours: totalOnlineHours,
      chartData: chartData.map((e) => e.toEntity()).toList(),
    );
  }
}
