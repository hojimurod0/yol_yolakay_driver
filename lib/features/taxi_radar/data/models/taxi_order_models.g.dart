// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'taxi_order_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocationAddressModel _$LocationAddressModelFromJson(
        Map<String, dynamic> json) =>
    LocationAddressModel(
      address: json['address'] as String,
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$LocationAddressModelToJson(
        LocationAddressModel instance) =>
    <String, dynamic>{
      'address': instance.address,
      'lat': instance.lat,
      'lng': instance.lng,
    };

PassengerProfileModel _$PassengerProfileModelFromJson(
        Map<String, dynamic> json) =>
    PassengerProfileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      avatarUrl: json['avatar_url'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
    );

Map<String, dynamic> _$PassengerProfileModelToJson(
        PassengerProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'avatar_url': instance.avatarUrl,
      'rating': instance.rating,
    };

TaxiOrderOfferModel _$TaxiOrderOfferModelFromJson(Map<String, dynamic> json) =>
    TaxiOrderOfferModel(
      orderId: json['order_id'] as String,
      tier: json['tier'] as String? ?? 'standard',
      estimatedPrice: (json['estimated_price'] as num?)?.toInt() ?? 0,
      distanceToPickupKm:
          (json['distance_to_pickup_km'] as num?)?.toDouble() ?? 0.0,
      pickup: LocationAddressModel.fromJson(
          json['pickup'] as Map<String, dynamic>),
      destination: LocationAddressModel.fromJson(
          json['destination'] as Map<String, dynamic>),
      paymentType: json['payment_type'] as String? ?? 'cash',
      createdAt: DateTime.parse(json['created_at'] as String),
      timeoutSeconds: (json['timeout_seconds'] as num?)?.toInt() ?? 25,
    );

Map<String, dynamic> _$TaxiOrderOfferModelToJson(
        TaxiOrderOfferModel instance) =>
    <String, dynamic>{
      'order_id': instance.orderId,
      'tier': instance.tier,
      'estimated_price': instance.estimatedPrice,
      'distance_to_pickup_km': instance.distanceToPickupKm,
      'pickup': instance.pickup is LocationAddressModel
          ? (instance.pickup as LocationAddressModel).toJson()
          : {
              'address': instance.pickup.address,
              'lat': instance.pickup.lat,
              'lng': instance.pickup.lng,
            },
      'destination': instance.destination is LocationAddressModel
          ? (instance.destination as LocationAddressModel).toJson()
          : {
              'address': instance.destination.address,
              'lat': instance.destination.lat,
              'lng': instance.destination.lng,
            },
      'payment_type': instance.paymentType,
      'created_at': instance.createdAt.toIso8601String(),
      'timeout_seconds': instance.timeoutSeconds,
    };

ActiveTaxiOrderModel _$ActiveTaxiOrderModelFromJson(
        Map<String, dynamic> json) =>
    ActiveTaxiOrderModel(
      orderId: json['order_id'] as String,
      status: json['status'] as String? ?? 'driver_assigned',
      tier: json['tier'] as String? ?? 'standard',
      passenger: PassengerProfileModel.fromJson(
          json['passenger'] as Map<String, dynamic>),
      pickup: LocationAddressModel.fromJson(
          json['pickup'] as Map<String, dynamic>),
      destination: LocationAddressModel.fromJson(
          json['destination'] as Map<String, dynamic>),
      price: (json['price'] as num?)?.toInt() ?? 0,
      commissionAmount: (json['commission_amount'] as num?)?.toInt() ?? 0,
      paymentType: json['payment_type'] as String? ?? 'cash',
      acceptedAt: json['accepted_at'] == null
          ? null
          : DateTime.parse(json['accepted_at'] as String),
    );

Map<String, dynamic> _$ActiveTaxiOrderModelToJson(
        ActiveTaxiOrderModel instance) =>
    <String, dynamic>{
      'order_id': instance.orderId,
      'status': instance.status,
      'tier': instance.tier,
      'passenger': instance.passenger is PassengerProfileModel
          ? (instance.passenger as PassengerProfileModel).toJson()
          : {
              'id': instance.passenger.id,
              'name': instance.passenger.name,
              'phone': instance.passenger.phone,
              'avatar_url': instance.passenger.avatarUrl,
              'rating': instance.passenger.rating,
            },
      'pickup': instance.pickup is LocationAddressModel
          ? (instance.pickup as LocationAddressModel).toJson()
          : {
              'address': instance.pickup.address,
              'lat': instance.pickup.lat,
              'lng': instance.pickup.lng,
            },
      'destination': instance.destination is LocationAddressModel
          ? (instance.destination as LocationAddressModel).toJson()
          : {
              'address': instance.destination.address,
              'lat': instance.destination.lat,
              'lng': instance.destination.lng,
            },
      'price': instance.price,
      'commission_amount': instance.commissionAmount,
      'payment_type': instance.paymentType,
      'accepted_at': instance.acceptedAt?.toIso8601String(),
    };

TaxiCompletionResultModel _$TaxiCompletionResultModelFromJson(
        Map<String, dynamic> json) =>
    TaxiCompletionResultModel(
      orderId: json['order_id'] as String,
      status: json['status'] as String? ?? 'completed',
      earnings: (json['earnings'] as num?)?.toInt() ?? 0,
      commissionDeducted: (json['commission_deducted'] as num?)?.toInt() ?? 0,
      newWalletBalance: (json['new_wallet_balance'] as num?)?.toInt() ?? 0,
      message: json['message'] as String? ??
          'Safar muvaffaqiyatli yakunlandi',
    );

Map<String, dynamic> _$TaxiCompletionResultModelToJson(
        TaxiCompletionResultModel instance) =>
    <String, dynamic>{
      'order_id': instance.orderId,
      'status': instance.status,
      'earnings': instance.earnings,
      'commission_deducted': instance.commissionDeducted,
      'new_wallet_balance': instance.newWalletBalance,
      'message': instance.message,
    };
