import '../entities/verification_entities.dart';

abstract class VerificationRepository {
  Future<List<CityEntity>> getCities();
  Future<DriverApplicationResponseEntity> submitApplication({
    required Map<String, dynamic> textFields,
    required Map<String, String> photoFiles,
  });
}
