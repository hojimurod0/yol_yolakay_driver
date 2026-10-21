import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/verification_entities.dart';

part 'verification_models.g.dart';

@JsonSerializable(createFactory: false)
class CityModel extends CityEntity {
  const CityModel({
    @JsonKey(name: 'id') required super.id,
    @JsonKey(name: 'name') required super.name,
    @JsonKey(name: 'region') required super.region,
    @JsonKey(name: 'latitude') super.latitude,
    @JsonKey(name: 'longitude') super.longitude,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) => CityModel(
        id: (json['id'] ?? json['_id'] ?? '').toString(),
        name: (json['name'] ?? json['name_uz'] ?? json['nameUz'] ?? '').toString(),
        region: (json['region'] ?? '').toString(),
        latitude: (json['lat'] ?? json['latitude'] as num?)?.toDouble(),
        longitude: (json['lng'] ?? json['longitude'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => _$CityModelToJson(this);
}

@JsonSerializable()
class DriverApplicationResponseModel extends DriverApplicationResponseEntity {
  const DriverApplicationResponseModel({
    @JsonKey(name: 'application_id') required super.applicationId,
    @JsonKey(name: 'verification_status', defaultValue: 'under_review')
    required super.verificationStatus,
    @JsonKey(
      name: 'message',
      defaultValue:
          'Hujjatlaringiz qabul qilindi. Moderatsiya 24 soat ichida ko\'rib chiqadi.',
    )
    required super.message,
  });

  factory DriverApplicationResponseModel.fromJson(Map<String, dynamic> json) =>
      _$DriverApplicationResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$DriverApplicationResponseModelToJson(this);
}
