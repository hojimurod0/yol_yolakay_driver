import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/home_dashboard_entity.dart';

part 'home_dashboard_model.g.dart';

@JsonSerializable()
class DailyStatsModel extends DailyStatsEntity {
  const DailyStatsModel({
    @JsonKey(name: 'today_earnings', defaultValue: 0)
    required super.todayEarnings,
    @JsonKey(name: 'today_trips_count', defaultValue: 0)
    required super.todayTripsCount,
    @JsonKey(name: 'online_hours', defaultValue: 0.0)
    required super.onlineHours,
    @JsonKey(name: 'acceptance_rate', defaultValue: 100.0)
    required super.acceptanceRate,
  });

  factory DailyStatsModel.fromJson(Map<String, dynamic> json) =>
      _$DailyStatsModelFromJson(json);

  Map<String, dynamic> toJson() => _$DailyStatsModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class HomeDashboardModel extends HomeDashboardEntity {
  const HomeDashboardModel({
    @JsonKey(name: 'is_online', defaultValue: false) required super.isOnline,
    @JsonKey(name: 'verification_status', defaultValue: 'approved')
    required super.verificationStatus,
    @JsonKey(name: 'daily_stats') required DailyStatsModel super.dailyStats,
    @JsonKey(name: 'wallet_balance', defaultValue: 0)
    required super.walletBalance,
    @JsonKey(name: 'active_taxi_order') super.activeTaxiOrder,
    @JsonKey(name: 'active_intercity_trip') super.activeIntercityTrip,
    @JsonKey(name: 'system_alerts') super.systemAlerts,
  });

  factory HomeDashboardModel.fromJson(Map<String, dynamic> json) =>
      _$HomeDashboardModelFromJson(json);

  Map<String, dynamic> toJson() => _$HomeDashboardModelToJson(this);
}
