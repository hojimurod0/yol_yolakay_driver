import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends ProfileEvent {
  final bool refresh;
  const LoadProfileEvent({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}

class UploadAvatarEvent extends ProfileEvent {
  final File file;
  const UploadAvatarEvent(this.file);

  @override
  List<Object?> get props => [file];
}

class UpdateFcmTokenEvent extends ProfileEvent {
  final String token;
  const UpdateFcmTokenEvent(this.token);

  @override
  List<Object?> get props => [token];
}
