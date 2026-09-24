import '../entities/verification_entities.dart';
import '../repositories/verification_repository.dart';

class GetCitiesUseCase {
  const GetCitiesUseCase(this._repository);
  final VerificationRepository _repository;

  Future<List<CityEntity>> call() => _repository.getCities();
}

class SubmitApplicationUseCase {
  const SubmitApplicationUseCase(this._repository);
  final VerificationRepository _repository;

  Future<DriverApplicationResponseEntity> call({
    required Map<String, dynamic> textFields,
    required Map<String, String> photoFiles,
  }) {
    return _repository.submitApplication(
      textFields: textFields,
      photoFiles: photoFiles,
    );
  }
}
