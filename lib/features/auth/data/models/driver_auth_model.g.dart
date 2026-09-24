// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_auth_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OtpSessionModel _$OtpSessionModelFromJson(Map<String, dynamic> json) =>
    OtpSessionModel(
      sessionId: json['session_id'] as String,
      expiresIn: (json['expires_in'] as num?)?.toInt() ?? 120,
      resendInterval: (json['resend_interval'] as num?)?.toInt() ?? 60,
    );

Map<String, dynamic> _$OtpSessionModelToJson(OtpSessionModel instance) =>
    <String, dynamic>{
      'session_id': instance.sessionId,
      'expires_in': instance.expiresIn,
      'resend_interval': instance.resendInterval,
    };

DriverTokensModel _$DriverTokensModelFromJson(Map<String, dynamic> json) =>
    DriverTokensModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresIn: (json['expires_in'] as num?)?.toInt() ?? 86400,
    );

Map<String, dynamic> _$DriverTokensModelToJson(DriverTokensModel instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'expires_in': instance.expiresIn,
    };

DriverUserModel _$DriverUserModelFromJson(Map<String, dynamic> json) =>
    DriverUserModel(
      id: json['id'] as String,
      phone: json['phone'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      totalTrips: (json['total_trips'] as num?)?.toInt() ?? 0,
      balance: (json['balance'] as num?)?.toInt() ?? 0,
      isOnline: json['is_online'] as bool? ?? false,
      role: json['role'] as String? ?? 'driver',
    );

Map<String, dynamic> _$DriverUserModelToJson(DriverUserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'phone': instance.phone,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'avatar_url': instance.avatarUrl,
      'rating': instance.rating,
      'total_trips': instance.totalTrips,
      'balance': instance.balance,
      'is_online': instance.isOnline,
      'role': instance.role,
    };

DriverAuthModel _$DriverAuthModelFromJson(Map<String, dynamic> json) =>
    DriverAuthModel(
      isRegistered: json['is_registered'] as bool? ?? false,
      verificationStatus:
          json['verification_status'] as String? ?? 'pending_submission',
      rejectionReason: json['rejection_reason'] as String?,
      tokens:
          DriverTokensModel.fromJson(json['tokens'] as Map<String, dynamic>),
      driver: DriverUserModel.fromJson(json['driver'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DriverAuthModelToJson(DriverAuthModel instance) =>
    <String, dynamic>{
      'is_registered': instance.isRegistered,
      'verification_status': instance.verificationStatus,
      'rejection_reason': instance.rejectionReason,
      'tokens': instance.tokens is DriverTokensModel
          ? (instance.tokens as DriverTokensModel).toJson()
          : {
              'access_token': instance.tokens.accessToken,
              'refresh_token': instance.tokens.refreshToken,
              'expires_in': instance.tokens.expiresIn,
            },
      'driver': instance.driver is DriverUserModel
          ? (instance.driver as DriverUserModel).toJson()
          : {
              'id': instance.driver.id,
              'phone': instance.driver.phone,
              'first_name': instance.driver.firstName,
              'last_name': instance.driver.lastName,
              'avatar_url': instance.driver.avatarUrl,
              'rating': instance.driver.rating,
              'total_trips': instance.driver.totalTrips,
              'balance': instance.driver.balance,
              'is_online': instance.driver.isOnline,
              'role': instance.driver.role,
            },
    };
