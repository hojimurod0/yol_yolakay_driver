import 'package:yol_yolakay_driver/features/home/domain/entities/location_point_entity.dart';
import 'package:yol_yolakay_driver/features/rides/domain/entities/ride_entity.dart';

enum BookingStatus { confirmed, active, completed, cancelled }

enum PaymentType { cash, click, payme, uzum }

/// Domain entity representing a passenger's confirmed seat reservation.
class BookingEntity {
  const BookingEntity({
    required this.id,
    required this.ride,
    required this.passengerId,
    required this.passengerName,
    required this.passengerPhone,
    required this.seatCount,
    required this.pickupPoint,
    required this.totalPrice,
    required this.status,
    required this.paymentType,
    required this.createdAt,
    this.cancellationReason,
  });

  final String id;
  final RideEntity ride;
  final String passengerId;
  final String passengerName;
  final String passengerPhone;
  final int seatCount;
  final LocationPointEntity pickupPoint;
  final int totalPrice;
  final BookingStatus status;
  final PaymentType paymentType;
  final DateTime createdAt;
  final String? cancellationReason;

  BookingEntity copyWith({
    String? id,
    RideEntity? ride,
    String? passengerId,
    String? passengerName,
    String? passengerPhone,
    int? seatCount,
    LocationPointEntity? pickupPoint,
    int? totalPrice,
    BookingStatus? status,
    PaymentType? paymentType,
    DateTime? createdAt,
    String? cancellationReason,
  }) {
    return BookingEntity(
      id: id ?? this.id,
      ride: ride ?? this.ride,
      passengerId: passengerId ?? this.passengerId,
      passengerName: passengerName ?? this.passengerName,
      passengerPhone: passengerPhone ?? this.passengerPhone,
      seatCount: seatCount ?? this.seatCount,
      pickupPoint: pickupPoint ?? this.pickupPoint,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      paymentType: paymentType ?? this.paymentType,
      createdAt: createdAt ?? this.createdAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }
}
