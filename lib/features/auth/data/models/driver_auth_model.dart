import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/driver_user_entity.dart';

part 'driver_auth_model.g.dart';

@JsonSerializable()
class OtpSessionModel extends OtpSessionEntity {
  const OtpSessionModel({
    @JsonKey(name: 'session_id') required super.sessionId,
    @JsonKey(name: 'expires_in', defaultValue: 120) required super.expiresIn,
    @JsonKey(name: 'resend_interval', defaultValue: 60)
    required super.resendInterval,
  });

  factory OtpSessionModel.fromJson(Map<String, dynamic> json) =>
      _$OtpSessionModelFromJson(json);

  Map<String, dynamic> toJson() => _$OtpSessionModelToJson(this);
}

@JsonSerializable()
class DriverTokensModel extends DriverTokensEntity {
  const DriverTokensModel({
    @JsonKey(name: 'access_token') required super.accessToken,
    @JsonKey(name: 'refresh_token') required super.refreshToken,
    @JsonKey(name: 'expires_in', defaultValue: 86400) required super.expiresIn,
  });

  factory DriverTokensModel.fromJson(Map<String, dynamic> json) =>
      _$DriverTokensModelFromJson(json);

  Map<String, dynamic> toJson() => _$DriverTokensModelToJson(this);
}

@JsonSerializable()
class DriverUserModel extends DriverUserEntity {
  const DriverUserModel({
    @JsonKey(name: 'id') required super.id,
    @JsonKey(name: 'phone') required super.phone,
    @JsonKey(name: 'first_name') required super.firstName,
    @JsonKey(name: 'last_name') required super.lastName,
    @JsonKey(name: 'avatar_url') super.avatarUrl,
    @JsonKey(name: 'rating', defaultValue: 5.0) required super.rating,
    @JsonKey(name: 'total_trips', defaultValue: 0) required super.totalTrips,
    @JsonKey(name: 'balance', defaultValue: 0) required super.balance,
    @JsonKey(name: 'is_online', defaultValue: false) required super.isOnline,
    @JsonKey(name: 'role', defaultValue: 'driver') super.role,
  });

  factory DriverUserModel.fromJson(Map<String, dynamic> json) =>
      _$DriverUserModelFromJson(json);

  Map<String, dynamic> toJson() => _$DriverUserModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class DriverAuthModel extends DriverAuthEntity {
  const DriverAuthModel({
    @JsonKey(name: 'is_registered', defaultValue: false)
    required super.isRegistered,
    @JsonKey(name: 'verification_status', defaultValue: 'pending_submission')
    required super.verificationStatus,
    @JsonKey(name: 'rejection_reason') super.rejectionReason,
    @JsonKey(name: 'tokens') required DriverTokensModel super.tokens,
    @JsonKey(name: 'driver') required DriverUserModel super.driver,
  });

  factory DriverAuthModel.fromJson(Map<String, dynamic> json) =>
      _$DriverAuthModelFromJson(json);

  Map<String, dynamic> toJson() => _$DriverAuthModelToJson(this);
}
