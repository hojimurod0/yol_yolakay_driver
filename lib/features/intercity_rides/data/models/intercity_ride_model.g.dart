// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intercity_ride_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RidePassengerModel _$RidePassengerModelFromJson(Map<String, dynamic> json) =>
    RidePassengerModel(
      bookingId: json['booking_id'] as String,
      seatsCount: (json['seats_count'] as num?)?.toInt() ?? 1,
      totalPrice: (json['total_price'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'pending',
      passengerId: json['passenger_id'] as String,
      passengerName: json['passenger_name'] as String? ?? 'Yo\'lovchi',
      passengerPhone: json['passenger_phone'] as String? ?? '',
    );

Map<String, dynamic> _$RidePassengerModelToJson(RidePassengerModel instance) =>
    <String, dynamic>{
      'booking_id': instance.bookingId,
      'seats_count': instance.seatsCount,
      'total_price': instance.totalPrice,
      'status': instance.status,
      'passenger_id': instance.passengerId,
      'passenger_name': instance.passengerName,
      'passenger_phone': instance.passengerPhone,
    };

IntercityRideModel _$IntercityRideModelFromJson(Map<String, dynamic> json) =>
    IntercityRideModel(
      id: json['id'] as String,
      fromCity: json['from_city'] as String,
      toCity: json['to_city'] as String,
      departureTime: DateTime.parse(json['departure_time'] as String),
      pricePerSeat: (json['price_per_seat'] as num?)?.toInt() ?? 0,
      totalSeats: (json['total_seats'] as num?)?.toInt() ?? 4,
      bookedSeats: (json['booked_seats'] as num?)?.toInt() ?? 0,
      availableSeats: (json['available_seats'] as num?)?.toInt() ?? 4,
      status: json['status'] as String? ?? 'active',
      hasAc: json['has_ac'] as bool? ?? false,
      allowLuggage: json['allow_luggage'] as bool? ?? true,
      allowSmoking: json['allow_smoking'] as bool? ?? false,
      allowPets: json['allow_pets'] as bool? ?? false,
      womenOnly: json['women_only'] as bool? ?? false,
      comment: json['comment'] as String?,
      passengers: (json['passengers'] as List<dynamic>?)
              ?.map((e) =>
                  RidePassengerModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$IntercityRideModelToJson(IntercityRideModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'from_city': instance.fromCity,
      'to_city': instance.toCity,
      'departure_time': instance.departureTime.toIso8601String(),
      'price_per_seat': instance.pricePerSeat,
      'total_seats': instance.totalSeats,
      'booked_seats': instance.bookedSeats,
      'available_seats': instance.availableSeats,
      'status': instance.status,
      'has_ac': instance.hasAc,
      'allow_luggage': instance.allowLuggage,
      'allowSmoking': instance.allowSmoking,
      'allowPets': instance.allowPets,
      'womenOnly': instance.womenOnly,
      'comment': instance.comment,
      'passengers': instance.passengers
          .map((e) => e is RidePassengerModel
              ? e.toJson()
              : {
                  'booking_id': e.bookingId,
                  'seats_count': e.seatsCount,
                  'total_price': e.totalPrice,
                  'status': e.status,
                  'passenger_id': e.passengerId,
                  'passenger_name': e.passengerName,
                  'passenger_phone': e.passengerPhone,
                })
          .toList(),
    };
