import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/intercity_ride_entity.dart';

part 'intercity_ride_model.g.dart';

@JsonSerializable()
class RidePassengerModel extends RidePassengerEntity {
  const RidePassengerModel({
    @JsonKey(name: 'booking_id') required super.bookingId,
    @JsonKey(name: 'seats_count', defaultValue: 1) required super.seatsCount,
    @JsonKey(name: 'total_price', defaultValue: 0) required super.totalPrice,
    @JsonKey(name: 'status', defaultValue: 'pending') required super.status,
    @JsonKey(name: 'passenger_id') required super.passengerId,
    @JsonKey(name: 'passenger_name', defaultValue: 'Yo\'lovchi')
    required super.passengerName,
    @JsonKey(name: 'passenger_phone', defaultValue: '')
    required super.passengerPhone,
  });

  factory RidePassengerModel.fromJson(Map<String, dynamic> json) {
    final passenger = json['passenger'] as Map<String, dynamic>?;
    if (passenger != null) {
      return RidePassengerModel(
        bookingId:
            json['booking_id']?.toString() ?? json['id']?.toString() ?? '',
        seatsCount: (json['seats_count'] as num?)?.toInt() ?? 1,
        totalPrice: (json['total_price'] as num?)?.toInt() ?? 0,
        status: json['status']?.toString() ?? 'pending',
        passengerId: passenger['id']?.toString() ?? '',
        passengerName: passenger['name']?.toString() ?? 'Yo\'lovchi',
        passengerPhone: passenger['phone']?.toString() ?? '',
      );
    }
    return _$RidePassengerModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$RidePassengerModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class IntercityRideModel extends IntercityRideEntity {
  const IntercityRideModel({
    @JsonKey(name: 'id') required super.id,
    @JsonKey(name: 'from_city') required super.fromCity,
    @JsonKey(name: 'to_city') required super.toCity,
    @JsonKey(name: 'departure_time') required super.departureTime,
    @JsonKey(name: 'price_per_seat', defaultValue: 0)
    required super.pricePerSeat,
    @JsonKey(name: 'total_seats', defaultValue: 4) required super.totalSeats,
    @JsonKey(name: 'booked_seats', defaultValue: 0) required super.bookedSeats,
    @JsonKey(name: 'available_seats', defaultValue: 4)
    required super.availableSeats,
    @JsonKey(name: 'status', defaultValue: 'active') required super.status,
    @JsonKey(name: 'has_ac', defaultValue: false) super.hasAc,
    @JsonKey(name: 'allow_luggage', defaultValue: true) super.allowLuggage,
    @JsonKey(name: 'allow_smoking', defaultValue: false) super.allowSmoking,
    @JsonKey(name: 'allow_pets', defaultValue: false) super.allowPets,
    @JsonKey(name: 'women_only', defaultValue: false) super.womenOnly,
    @JsonKey(name: 'comment') super.comment,
    @JsonKey(name: 'passengers', defaultValue: <RidePassengerModel>[])
    super.passengers = const [],
  });

  factory IntercityRideModel.fromJson(Map<String, dynamic> json) {
    String extractCity(dynamic cityVal) {
      if (cityVal is String) return cityVal;
      if (cityVal is Map<String, dynamic>) {
        return cityVal['name']?.toString() ??
            cityVal['name_uz']?.toString() ??
            '';
      }
      return '';
    }

    final copy = Map<String, dynamic>.from(json);
    if (copy['from_city'] != null) {
      copy['from_city'] = extractCity(copy['from_city']);
    } else if (copy['from_city_name'] != null) {
      copy['from_city'] = extractCity(copy['from_city_name']);
    } else {
      copy['from_city'] = '';
    }

    if (copy['to_city'] != null) {
      copy['to_city'] = extractCity(copy['to_city']);
    } else if (copy['to_city_name'] != null) {
      copy['to_city'] = extractCity(copy['to_city_name']);
    } else {
      copy['to_city'] = '';
    }

    return _$IntercityRideModelFromJson(copy);
  }

  Map<String, dynamic> toJson() => _$IntercityRideModelToJson(this);
}
