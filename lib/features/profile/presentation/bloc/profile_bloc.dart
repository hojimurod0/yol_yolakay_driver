import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/driver_profile_usecases.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetDriverProfileUseCase _getProfileUseCase;
  final UploadDriverAvatarUseCase _uploadAvatarUseCase;
  final UpdateFcmTokenUseCase _updateFcmTokenUseCase;

  ProfileBloc({
    required GetDriverProfileUseCase getProfileUseCase,
    required UploadDriverAvatarUseCase uploadAvatarUseCase,
    required UpdateFcmTokenUseCase updateFcmTokenUseCase,
  })  : _getProfileUseCase = getProfileUseCase,
        _uploadAvatarUseCase = uploadAvatarUseCase,
        _updateFcmTokenUseCase = updateFcmTokenUseCase,
        super(const ProfileState()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UploadAvatarEvent>(_onUploadAvatar);
    on<UpdateFcmTokenEvent>(_onUpdateFcmToken);
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (!event.refresh && state.status == ProfileStatus.loaded) return;

    if (!event.refresh) {
      emit(state.copyWith(status: ProfileStatus.loading, errorMessage: null));
    }

    try {
      final profile = await _getProfileUseCase();
      emit(state.copyWith(
        status: ProfileStatus.loaded,
        profile: profile,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onUploadAvatar(
    UploadAvatarEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isUploadingAvatar: true, errorMessage: null));

    try {
      final url = await _uploadAvatarUseCase(event.file);
      final updatedProfile = state.profile?.copyWith(avatarUrl: url);

      emit(state.copyWith(
        isUploadingAvatar: false,
        profile: updatedProfile,
        avatarSuccessUrl: url,
      ));
    } catch (e) {
      emit(state.copyWith(
        isUploadingAvatar: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onUpdateFcmToken(
    UpdateFcmTokenEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await _updateFcmTokenUseCase(event.token);
    } catch (_) {
      // Background task
    }
  }
}
