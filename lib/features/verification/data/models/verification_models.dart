import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/verification_entities.dart';

part 'verification_models.g.dart';

@JsonSerializable()
class CityModel extends CityEntity {
  const CityModel({
    @JsonKey(name: 'id') required super.id,
    @JsonKey(name: 'name') required super.name,
    @JsonKey(name: 'region') required super.region,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) =>
      _$CityModelFromJson(json);

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
