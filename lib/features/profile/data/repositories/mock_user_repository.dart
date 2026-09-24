import 'package:yol_yolakay_driver/features/auth/domain/entities/user_entity.dart';
import 'package:yol_yolakay_driver/features/profile/domain/entities/saved_place_entity.dart';
import 'package:yol_yolakay_driver/features/profile/domain/repositories/user_repository.dart';

/// Mock User Repository managing passenger profile updates and saved location bookmarks.
class MockUserRepository implements UserRepository {
  UserEntity _user = UserEntity(
    id: 'usr_uz_default_01',
    phoneNumber: '+998 90 123 45 67',
    firstName: 'Rizo',
    lastName: 'Karimov',
    email: 'rizo.karimov@mail.uz',
    createdAt: DateTime.now().subtract(const Duration(days: 60)),
    isProfileComplete: true,
  );

  final List<SavedPlaceEntity> _places = [
    const SavedPlaceEntity(
      id: 'pl_01',
      title: 'Uy (Toshkent)',
      address: 'Chilonzor tumani, 9-mavze, 12-uy',
      type: SavedPlaceType.home,
      latitude: 41.2721,
      longitude: 69.2045,
    ),
    const SavedPlaceEntity(
      id: 'pl_02',
      title: 'Ishxona (Samarqand)',
      address: 'Registon ko\'chasi, 45-bino',
      type: SavedPlaceType.work,
      latitude: 39.6548,
      longitude: 66.9750,
    ),
  ];

  @override
  Future<UserEntity> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _user;
  }

  @override
  Future<UserEntity> updateProfile({
    required String firstName,
    required String lastName,
    String? email,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _user = _user.copyWith(
      firstName: firstName,
      lastName: lastName,
      email: email,
    );
    return _user;
  }

  @override
  Future<List<SavedPlaceEntity>> getSavedPlaces() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.from(_places);
  }

  @override
  Future<void> addSavedPlace(SavedPlaceEntity place) async {
    _places.add(place);
  }

  @override
  Future<void> deleteSavedPlace(String id) async {
    _places.removeWhere((p) => p.id == id);
  }
}
