// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verification_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CityModel _$CityModelFromJson(Map<String, dynamic> json) => CityModel(
      id: json['id'] as String,
      name: json['name'] as String,
      region: json['region'] as String,
    );

Map<String, dynamic> _$CityModelToJson(CityModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'region': instance.region,
    };

DriverApplicationResponseModel _$DriverApplicationResponseModelFromJson(
        Map<String, dynamic> json) =>
    DriverApplicationResponseModel(
      applicationId: json['application_id'] as String,
      verificationStatus:
          json['verification_status'] as String? ?? 'under_review',
      message: json['message'] as String? ??
          "Hujjatlaringiz qabul qilindi. Moderatsiya 24 soat ichida ko'rib chiqadi.",
    );

Map<String, dynamic> _$DriverApplicationResponseModelToJson(
        DriverApplicationResponseModel instance) =>
    <String, dynamic>{
      'application_id': instance.applicationId,
      'verification_status': instance.verificationStatus,
      'message': instance.message,
    };
