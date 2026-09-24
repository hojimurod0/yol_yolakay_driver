import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/city_entity.dart';

part 'city_model.g.dart';

@JsonSerializable()
class CityModel extends CityEntity {
  const CityModel({
    @JsonKey(name: 'id') required super.id,
    @JsonKey(name: 'name_uz') required super.nameUz,
    @JsonKey(name: 'name_ru') required super.nameRu,
    @JsonKey(name: 'name_en') required super.nameEn,
    @JsonKey(name: 'region') required super.region,
    @JsonKey(name: 'is_popular', defaultValue: false) super.isPopular = false,
    @JsonKey(name: 'latitude', defaultValue: 0.0) required super.latitude,
    @JsonKey(name: 'longitude', defaultValue: 0.0) required super.longitude,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) =>
      _$CityModelFromJson(json);

  Map<String, dynamic> toJson() => _$CityModelToJson(this);
}
