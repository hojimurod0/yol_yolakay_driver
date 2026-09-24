import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yol_yolakay_driver/features/auth/domain/entities/user_entity.dart';
import 'package:yol_yolakay_driver/features/profile/domain/entities/saved_place_entity.dart';
import 'package:yol_yolakay_driver/features/profile/domain/repositories/user_repository.dart';

class ProfileState {
  const ProfileState({
    this.user,
    this.savedPlaces = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
  });

  final UserEntity? user;
  final List<SavedPlaceEntity> savedPlaces;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;

  ProfileState copyWith({
    UserEntity? user,
    List<SavedPlaceEntity>? savedPlaces,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
  }) {
    return ProfileState(
      user: user ?? this.user,
      savedPlaces: savedPlaces ?? this.savedPlaces,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier(this._userRepository) : super(const ProfileState()) {
    loadProfile();
  }

  final UserRepository _userRepository;

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true);
    final user = await _userRepository.getProfile();
    final places = await _userRepository.getSavedPlaces();
    state = state.copyWith(
      user: user,
      savedPlaces: places,
      isLoading: false,
    );
  }

  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    String? email,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      final updated = await _userRepository.updateProfile(
        firstName: firstName,
        lastName: lastName,
        email: email,
      );
      state = state.copyWith(user: updated, isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> addSavedPlace(SavedPlaceEntity place) async {
    await _userRepository.addSavedPlace(place);
    await loadProfile();
  }

  Future<void> deleteSavedPlace(String id) async {
    await _userRepository.deleteSavedPlace(id);
    await loadProfile();
  }
}

final profileNotifierProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final repo = ref.watch(userRepositoryProvider);
  return ProfileNotifier(repo);
});
