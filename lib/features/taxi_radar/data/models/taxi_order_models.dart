import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/taxi_order_entity.dart';

part 'taxi_order_models.g.dart';

@JsonSerializable()
class LocationAddressModel extends LocationAddressEntity {
  const LocationAddressModel({
    @JsonKey(name: 'address') required super.address,
    @JsonKey(name: 'lat', defaultValue: 0.0) required super.lat,
    @JsonKey(name: 'lng', defaultValue: 0.0) required super.lng,
  });

  factory LocationAddressModel.fromJson(Map<String, dynamic> json) =>
      _$LocationAddressModelFromJson(json);

  Map<String, dynamic> toJson() => _$LocationAddressModelToJson(this);
}

@JsonSerializable()
class PassengerProfileModel extends PassengerProfileEntity {
  const PassengerProfileModel({
    @JsonKey(name: 'id') required super.id,
    @JsonKey(name: 'name') required super.name,
    @JsonKey(name: 'phone') required super.phone,
    @JsonKey(name: 'avatar_url') super.avatarUrl,
    @JsonKey(name: 'rating', defaultValue: 5.0) required super.rating,
  });

  factory PassengerProfileModel.fromJson(Map<String, dynamic> json) =>
      _$PassengerProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$PassengerProfileModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TaxiOrderOfferModel extends TaxiOrderOfferEntity {
  const TaxiOrderOfferModel({
    @JsonKey(name: 'order_id') required super.orderId,
    @JsonKey(name: 'tier', defaultValue: 'standard') required super.tier,
    @JsonKey(name: 'estimated_price', defaultValue: 0)
    required super.estimatedPrice,
    @JsonKey(name: 'distance_to_pickup_km', defaultValue: 0.0)
    required super.distanceToPickupKm,
    @JsonKey(name: 'pickup') required LocationAddressModel super.pickup,
    @JsonKey(name: 'destination') required LocationAddressModel super.destination,
    @JsonKey(name: 'payment_type', defaultValue: 'cash')
    required super.paymentType,
    @JsonKey(name: 'created_at') required super.createdAt,
    @JsonKey(name: 'timeout_seconds', defaultValue: 25)
    required super.timeoutSeconds,
  });

  factory TaxiOrderOfferModel.fromJson(Map<String, dynamic> json) =>
      _$TaxiOrderOfferModelFromJson(json);

  Map<String, dynamic> toJson() => _$TaxiOrderOfferModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ActiveTaxiOrderModel extends ActiveTaxiOrderEntity {
  const ActiveTaxiOrderModel({
    @JsonKey(name: 'order_id') required super.orderId,
    @JsonKey(name: 'status', defaultValue: 'driver_assigned')
    required super.status,
    @JsonKey(name: 'tier', defaultValue: 'standard') required super.tier,
    @JsonKey(name: 'passenger') required PassengerProfileModel super.passenger,
    @JsonKey(name: 'pickup') required LocationAddressModel super.pickup,
    @JsonKey(name: 'destination') required LocationAddressModel super.destination,
    @JsonKey(name: 'price', defaultValue: 0) required super.price,
    @JsonKey(name: 'commission_amount', defaultValue: 0)
    required super.commissionAmount,
    @JsonKey(name: 'payment_type', defaultValue: 'cash')
    required super.paymentType,
    @JsonKey(name: 'accepted_at') super.acceptedAt,
  });

  factory ActiveTaxiOrderModel.fromJson(Map<String, dynamic> json) =>
      _$ActiveTaxiOrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$ActiveTaxiOrderModelToJson(this);
}

@JsonSerializable()
class TaxiCompletionResultModel extends TaxiCompletionResultEntity {
  const TaxiCompletionResultModel({
    @JsonKey(name: 'order_id') required super.orderId,
    @JsonKey(name: 'status', defaultValue: 'completed') required super.status,
    @JsonKey(name: 'earnings', defaultValue: 0) required super.earnings,
    @JsonKey(name: 'commission_deducted', defaultValue: 0)
    required super.commissionDeducted,
    @JsonKey(name: 'new_wallet_balance', defaultValue: 0)
    required super.newWalletBalance,
    @JsonKey(name: 'message', defaultValue: 'Safar muvaffaqiyatli yakunlandi')
    required super.message,
  });

  factory TaxiCompletionResultModel.fromJson(Map<String, dynamic> json) =>
      _$TaxiCompletionResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$TaxiCompletionResultModelToJson(this);
}
