import 'package:equatable/equatable.dart';

class EarningsChartPointEntity extends Equatable {
  final String date;
  final String day;
  final int earnings;
  final int trips;

  const EarningsChartPointEntity({
    required this.date,
    required this.day,
    required this.earnings,
    required this.trips,
  });

  @override
  List<Object?> get props => [date, day, earnings, trips];
}

class EarningsStatsEntity extends Equatable {
  final String period; // "today" | "weekly" | "monthly"
  final int totalEarnings;
  final int totalTrips;
  final double totalDistanceKm;
  final double totalOnlineHours;
  final List<EarningsChartPointEntity> chartData;

  const EarningsStatsEntity({
    required this.period,
    required this.totalEarnings,
    required this.totalTrips,
    required this.totalDistanceKm,
    required this.totalOnlineHours,
    required this.chartData,
  });

  @override
  List<Object?> get props => [
        period,
        totalEarnings,
        totalTrips,
        totalDistanceKm,
        totalOnlineHours,
        chartData,
      ];
}
