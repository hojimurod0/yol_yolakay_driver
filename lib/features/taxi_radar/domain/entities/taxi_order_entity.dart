import 'package:equatable/equatable.dart';

class LocationAddressEntity extends Equatable {
  const LocationAddressEntity({
    required this.address,
    required this.lat,
    required this.lng,
  });

  final String address;
  final double lat;
  final double lng;

  @override
  List<Object?> get props => [address, lat, lng];
}

class PassengerProfileEntity extends Equatable {
  const PassengerProfileEntity({
    required this.id,
    required this.name,
    required this.phone,
    this.avatarUrl,
    required this.rating,
  });

  final String id;
  final String name;
  final String phone;
  final String? avatarUrl;
  final double rating;

  @override
  List<Object?> get props => [id, name, phone, avatarUrl, rating];
}

class TaxiOrderOfferEntity extends Equatable {
  const TaxiOrderOfferEntity({
    required this.orderId,
    required this.tier,
    required this.estimatedPrice,
    required this.distanceToPickupKm,
    required this.pickup,
    required this.destination,
    required this.paymentType,
    required this.createdAt,
    required this.timeoutSeconds,
  });

  final String orderId;
  final String tier; // "standard" | "comfort" | "business"
  final int estimatedPrice;
  final double distanceToPickupKm;
  final LocationAddressEntity pickup;
  final LocationAddressEntity destination;
  final String paymentType; // "cash" | "card"
  final DateTime createdAt;
  final int timeoutSeconds;

  @override
  List<Object?> get props => [
        orderId,
        tier,
        estimatedPrice,
        distanceToPickupKm,
        pickup,
        destination,
        paymentType,
        createdAt,
        timeoutSeconds,
      ];
}

class ActiveTaxiOrderEntity extends Equatable {
  const ActiveTaxiOrderEntity({
    required this.orderId,
    required this.status, // "driver_assigned" | "arrived" | "in_progress" | "completed" | "cancelled"
    required this.tier,
    required this.passenger,
    required this.pickup,
    required this.destination,
    required this.price,
    required this.commissionAmount,
    required this.paymentType,
    this.acceptedAt,
  });

  final String orderId;
  final String status;
  final String tier;
  final PassengerProfileEntity passenger;
  final LocationAddressEntity pickup;
  final LocationAddressEntity destination;
  final int price;
  final int commissionAmount;
  final String paymentType;
  final DateTime? acceptedAt;

  bool get isAssigned => status == 'driver_assigned';
  bool get isArrived => status == 'arrived';
  bool get isInProgress => status == 'in_progress';

  ActiveTaxiOrderEntity copyWith({
    String? status,
    int? price,
  }) {
    return ActiveTaxiOrderEntity(
      orderId: orderId,
      status: status ?? this.status,
      tier: tier,
      passenger: passenger,
      pickup: pickup,
      destination: destination,
      price: price ?? this.price,
      commissionAmount: commissionAmount,
      paymentType: paymentType,
      acceptedAt: acceptedAt,
    );
  }

  @override
  List<Object?> get props => [
        orderId,
        status,
        tier,
        passenger,
        pickup,
        destination,
        price,
        commissionAmount,
        paymentType,
        acceptedAt,
      ];
}

class TaxiCompletionResultEntity extends Equatable {
  const TaxiCompletionResultEntity({
    required this.orderId,
    required this.status,
    required this.earnings,
    required this.commissionDeducted,
    required this.newWalletBalance,
    required this.message,
  });

  final String orderId;
  final String status;
  final int earnings;
  final int commissionDeducted;
  final int newWalletBalance;
  final String message;

  @override
  List<Object?> get props => [
        orderId,
        status,
        earnings,
        commissionDeducted,
        newWalletBalance,
        message,
      ];
}
