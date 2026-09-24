import 'package:equatable/equatable.dart';

class DailyStatsEntity extends Equatable {
  const DailyStatsEntity({
    required this.todayEarnings,
    required this.todayTripsCount,
    required this.onlineHours,
    required this.acceptanceRate,
  });

  final int todayEarnings;
  final int todayTripsCount;
  final double onlineHours;
  final double acceptanceRate;

  @override
  List<Object?> get props => [
        todayEarnings,
        todayTripsCount,
        onlineHours,
        acceptanceRate,
      ];
}

class ActiveOrderSummaryEntity extends Equatable {
  const ActiveOrderSummaryEntity({
    required this.orderId,
    required this.status,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.price,
    this.passengerName,
    this.passengerPhone,
  });

  final String orderId;
  final String status;
  final String pickupAddress;
  final String destinationAddress;
  final int price;
  final String? passengerName;
  final String? passengerPhone;

  factory ActiveOrderSummaryEntity.fromDynamic(dynamic json) {
    if (json is Map<String, dynamic>) {
      return ActiveOrderSummaryEntity(
        orderId: (json['id'] ?? json['order_id'] ?? '').toString(),
        status: (json['status'] ?? 'assigned').toString(),
        pickupAddress:
            (json['pickup_address'] ?? json['pickup']?['address'] ?? '')
                .toString(),
        destinationAddress: (json['destination_address'] ??
                json['destination']?['address'] ??
                '')
            .toString(),
        price: (json['price'] is num)
            ? (json['price'] as num).toInt()
            : int.tryParse(json['price']?.toString() ?? '0') ?? 0,
        passengerName: json['passenger']?['name']?.toString() ??
            json['passenger_name']?.toString(),
        passengerPhone: json['passenger']?['phone']?.toString() ??
            json['passenger_phone']?.toString(),
      );
    }
    return const ActiveOrderSummaryEntity(
      orderId: '',
      status: '',
      pickupAddress: '',
      destinationAddress: '',
      price: 0,
    );
  }

  @override
  List<Object?> get props => [
        orderId,
        status,
        pickupAddress,
        destinationAddress,
        price,
        passengerName,
        passengerPhone,
      ];
}

class ActiveTripSummaryEntity extends Equatable {
  const ActiveTripSummaryEntity({
    required this.tripId,
    required this.fromCity,
    required this.toCity,
    required this.departureTime,
    required this.bookedSeats,
    required this.totalSeats,
    required this.status,
  });

  final String tripId;
  final String fromCity;
  final String toCity;
  final String departureTime;
  final int bookedSeats;
  final int totalSeats;
  final String status;

  factory ActiveTripSummaryEntity.fromDynamic(dynamic json) {
    if (json is Map<String, dynamic>) {
      return ActiveTripSummaryEntity(
        tripId: (json['id'] ?? json['trip_id'] ?? '').toString(),
        fromCity: (json['from_city'] ?? '').toString(),
        toCity: (json['to_city'] ?? '').toString(),
        departureTime: (json['departure_time'] ?? '').toString(),
        bookedSeats: (json['booked_seats'] as num?)?.toInt() ?? 0,
        totalSeats: (json['total_seats'] as num?)?.toInt() ?? 4,
        status: (json['status'] ?? 'active').toString(),
      );
    }
    return const ActiveTripSummaryEntity(
      tripId: '',
      fromCity: '',
      toCity: '',
      departureTime: '',
      bookedSeats: 0,
      totalSeats: 4,
      status: '',
    );
  }

  @override
  List<Object?> get props => [
        tripId,
        fromCity,
        toCity,
        departureTime,
        bookedSeats,
        totalSeats,
        status,
      ];
}

class HomeDashboardEntity extends Equatable {
  const HomeDashboardEntity({
    required this.isOnline,
    required this.verificationStatus,
    required this.dailyStats,
    required this.walletBalance,
    this.activeTaxiOrder,
    this.activeIntercityTrip,
    this.systemAlerts = const [],
  });

  final bool isOnline;
  final String verificationStatus;
  final DailyStatsEntity dailyStats;
  final int walletBalance;
  final Map<String, dynamic>? activeTaxiOrder;
  final Map<String, dynamic>? activeIntercityTrip;
  final List<dynamic> systemAlerts;

  ActiveOrderSummaryEntity? get activeTaxiOrderSummary =>
      activeTaxiOrder != null
          ? ActiveOrderSummaryEntity.fromDynamic(activeTaxiOrder)
          : null;

  ActiveTripSummaryEntity? get activeIntercityTripSummary =>
      activeIntercityTrip != null
          ? ActiveTripSummaryEntity.fromDynamic(activeIntercityTrip)
          : null;

  HomeDashboardEntity copyWith({
    bool? isOnline,
    String? verificationStatus,
    DailyStatsEntity? dailyStats,
    int? walletBalance,
    Map<String, dynamic>? activeTaxiOrder,
    Map<String, dynamic>? activeIntercityTrip,
    List<dynamic>? systemAlerts,
  }) {
    return HomeDashboardEntity(
      isOnline: isOnline ?? this.isOnline,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      dailyStats: dailyStats ?? this.dailyStats,
      walletBalance: walletBalance ?? this.walletBalance,
      activeTaxiOrder: activeTaxiOrder ?? this.activeTaxiOrder,
      activeIntercityTrip: activeIntercityTrip ?? this.activeIntercityTrip,
      systemAlerts: systemAlerts ?? this.systemAlerts,
    );
  }

  @override
  List<Object?> get props => [
        isOnline,
        verificationStatus,
        dailyStats,
        walletBalance,
        activeTaxiOrder,
        activeIntercityTrip,
        systemAlerts,
      ];
}
