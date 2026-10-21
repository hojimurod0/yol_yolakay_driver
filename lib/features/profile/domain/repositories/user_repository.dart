import 'package:yol_yolakay_driver/features/auth/domain/entities/user_entity.dart';
import 'package:yol_yolakay_driver/features/profile/domain/entities/saved_place_entity.dart';

/// Repository contract for passenger profile and address bookmarks.
abstract class UserRepository {
  Future<UserEntity> getProfile();
  Future<UserEntity> updateProfile({
    required String firstName,
    required String lastName,
    String? email,
  });
  Future<List<SavedPlaceEntity>> getSavedPlaces();
  Future<void> addSavedPlace(SavedPlaceEntity place);
  Future<void> deleteSavedPlace(String id);
}
