// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_dashboard_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyStatsModel _$DailyStatsModelFromJson(Map<String, dynamic> json) =>
    DailyStatsModel(
      todayEarnings: (json['today_earnings'] as num?)?.toInt() ?? 0,
      todayTripsCount: (json['today_trips_count'] as num?)?.toInt() ?? 0,
      onlineHours: (json['online_hours'] as num?)?.toDouble() ?? 0.0,
      acceptanceRate: (json['acceptance_rate'] as num?)?.toDouble() ?? 100.0,
    );

Map<String, dynamic> _$DailyStatsModelToJson(DailyStatsModel instance) =>
    <String, dynamic>{
      'today_earnings': instance.todayEarnings,
      'today_trips_count': instance.todayTripsCount,
      'online_hours': instance.onlineHours,
      'acceptance_rate': instance.acceptanceRate,
    };

HomeDashboardModel _$HomeDashboardModelFromJson(Map<String, dynamic> json) =>
    HomeDashboardModel(
      isOnline: json['is_online'] as bool? ?? false,
      verificationStatus:
          json['verification_status'] as String? ?? 'approved',
      dailyStats: DailyStatsModel.fromJson(
          json['daily_stats'] as Map<String, dynamic>),
      walletBalance: (json['wallet_balance'] as num?)?.toInt() ?? 0,
      activeTaxiOrder: json['active_taxi_order'] as Map<String, dynamic>?,
      activeIntercityTrip:
          json['active_intercity_trip'] as Map<String, dynamic>?,
      systemAlerts:
          (json['system_alerts'] as List<dynamic>?) ?? const [],
    );

Map<String, dynamic> _$HomeDashboardModelToJson(HomeDashboardModel instance) =>
    <String, dynamic>{
      'is_online': instance.isOnline,
      'verification_status': instance.verificationStatus,
      'daily_stats': instance.dailyStats is DailyStatsModel
          ? (instance.dailyStats as DailyStatsModel).toJson()
          : {
              'today_earnings': instance.dailyStats.todayEarnings,
              'today_trips_count': instance.dailyStats.todayTripsCount,
              'online_hours': instance.dailyStats.onlineHours,
              'acceptance_rate': instance.dailyStats.acceptanceRate,
            },
      'wallet_balance': instance.walletBalance,
      'active_taxi_order': instance.activeTaxiOrder,
      'active_intercity_trip': instance.activeIntercityTrip,
      'system_alerts': instance.systemAlerts,
    };
