import 'package:equatable/equatable.dart';
import '../../domain/entities/driver_profile_entity.dart';

enum ProfileStatus { initial, loading, loaded, error }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final DriverProfileEntity? profile;
  final bool isUploadingAvatar;
  final String? errorMessage;
  final String? avatarSuccessUrl;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.isUploadingAvatar = false,
    this.errorMessage,
    this.avatarSuccessUrl,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    DriverProfileEntity? profile,
    bool? isUploadingAvatar,
    String? errorMessage,
    String? avatarSuccessUrl,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      isUploadingAvatar: isUploadingAvatar ?? this.isUploadingAvatar,
      errorMessage: errorMessage ?? this.errorMessage,
      avatarSuccessUrl: avatarSuccessUrl ?? this.avatarSuccessUrl,
    );
  }

  @override
  List<Object?> get props => [
        status,
        profile,
        isUploadingAvatar,
        errorMessage,
        avatarSuccessUrl,
      ];
}
