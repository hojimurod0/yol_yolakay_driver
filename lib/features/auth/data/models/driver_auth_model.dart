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

@JsonSerializable(createFactory: false)
class DriverTokensModel extends DriverTokensEntity {
  const DriverTokensModel({
    @JsonKey(name: 'access_token') required super.accessToken,
    @JsonKey(name: 'refresh_token') required super.refreshToken,
    @JsonKey(name: 'expires_in', defaultValue: 86400) required super.expiresIn,
  });

  factory DriverTokensModel.fromJson(Map<String, dynamic> json) =>
      DriverTokensModel(
        accessToken: (json['access_token'] ?? '').toString(),
        refreshToken: (json['refresh_token'] ?? '').toString(),
        expiresIn: (json['expires_in'] as num?)?.toInt() ?? 86400,
      );

  Map<String, dynamic> toJson() => _$DriverTokensModelToJson(this);
}

@JsonSerializable(createFactory: false)
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
      DriverUserModel(
        id: (json['id'] ?? '').toString(),
        phone: (json['phone'] ?? '').toString(),
        firstName: (json['first_name'] ?? '').toString(),
        lastName: (json['last_name'] ?? '').toString(),
        avatarUrl: json['avatar_url'] as String?,
        rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
        totalTrips: (json['total_trips'] as num?)?.toInt() ?? 0,
        balance: (json['balance'] as num?)?.toInt() ?? 0,
        isOnline: json['is_online'] as bool? ?? false,
        role: (json['role'] ?? 'driver').toString(),
      );

  Map<String, dynamic> toJson() => _$DriverUserModelToJson(this);
}

@JsonSerializable(createFactory: false, explicitToJson: true)
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

  factory DriverAuthModel.fromJson(Map<String, dynamic> json) {
    final driverMap = (json['driver'] ?? json['user']) as Map<String, dynamic>? ?? {};
    final bool isReg = json['is_registered'] as bool? ??
        (json.containsKey('is_new_user') ? !(json['is_new_user'] as bool) : false);

    return DriverAuthModel(
      isRegistered: isReg,
      verificationStatus:
          json['verification_status'] as String? ?? 'pending_submission',
      rejectionReason: json['rejection_reason'] as String?,
      tokens: DriverTokensModel.fromJson(
          (json['tokens'] as Map<String, dynamic>?) ?? {}),
      driver: DriverUserModel.fromJson(driverMap),
    );
  }

  Map<String, dynamic> toJson() => _$DriverAuthModelToJson(this);
}
