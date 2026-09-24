import 'package:equatable/equatable.dart';

/// Driver User Entity representing the authenticated driver.
class DriverUserEntity extends Equatable {
  const DriverUserEntity({
    required this.id,
    required this.phone,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
    required this.rating,
    required this.totalTrips,
    required this.balance,
    required this.isOnline,
    this.role = 'driver',
  });

  final String id;
  final String phone;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final double rating;
  final int totalTrips;
  final int balance;
  final bool isOnline;
  final String role;

  String get fullName => '$firstName $lastName'.trim();

  DriverUserEntity copyWith({
    String? id,
    String? phone,
    String? firstName,
    String? lastName,
    String? avatarUrl,
    double? rating,
    int? totalTrips,
    int? balance,
    bool? isOnline,
    String? role,
  }) {
    return DriverUserEntity(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rating: rating ?? this.rating,
      totalTrips: totalTrips ?? this.totalTrips,
      balance: balance ?? this.balance,
      isOnline: isOnline ?? this.isOnline,
      role: role ?? this.role,
    );
  }

  @override
  List<Object?> get props => [
        id,
        phone,
        firstName,
        lastName,
        avatarUrl,
        rating,
        totalTrips,
        balance,
        isOnline,
        role,
      ];
}

/// Authentication Tokens Entity.
class DriverTokensEntity extends Equatable {
  const DriverTokensEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  @override
  List<Object?> get props => [accessToken, refreshToken, expiresIn];
}

/// OTP Session details for resend cooldown and expiry.
class OtpSessionEntity extends Equatable {
  const OtpSessionEntity({
    required this.sessionId,
    required this.expiresIn,
    required this.resendInterval,
  });

  final String sessionId;
  final int expiresIn;
  final int resendInterval;

  @override
  List<Object?> get props => [sessionId, expiresIn, resendInterval];
}

/// Driver Auth Result from verify-otp.
class DriverAuthEntity extends Equatable {
  const DriverAuthEntity({
    required this.isRegistered,
    required this.verificationStatus,
    this.rejectionReason,
    required this.tokens,
    required this.driver,
  });

  final bool isRegistered;
  final String
      verificationStatus; // 'pending_submission' | 'under_review' | 'approved' | 'rejected'
  final String? rejectionReason;
  final DriverTokensEntity tokens;
  final DriverUserEntity driver;

  bool get isApproved => verificationStatus == 'approved';
  bool get isPendingOrRejected =>
      verificationStatus == 'pending_submission' ||
      verificationStatus == 'rejected';
  bool get isUnderReview => verificationStatus == 'under_review';

  @override
  List<Object?> get props => [
        isRegistered,
        verificationStatus,
        rejectionReason,
        tokens,
        driver,
      ];
}
