import '../../../../core/utils/cyrillic_converter.dart';

/// Immutable domain entity representing a registered passenger.
class UserEntity {
  const UserEntity({
    required this.id,
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    this.email,
    required this.createdAt,
    this.isProfileComplete = true,
  });

  final String id;
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final String? email;
  final DateTime createdAt;
  final bool isProfileComplete;

  String localizedFullName(String languageCode) {
    final full = '$firstName $lastName'.trim();
    return CyrillicConverter.maybeConvert(full, languageCode);
  }

  String get fullName => '$firstName $lastName'.trim();

  UserEntity copyWith({
    String? id,
    String? phoneNumber,
    String? firstName,
    String? lastName,
    String? email,
    DateTime? createdAt,
    bool? isProfileComplete,
  }) {
    return UserEntity(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }
}
