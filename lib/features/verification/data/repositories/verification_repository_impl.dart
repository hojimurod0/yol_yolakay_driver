import '../../domain/entities/verification_entities.dart';
import '../../domain/repositories/verification_repository.dart';
import '../datasources/verification_remote_data_source.dart';

class VerificationRepositoryImpl implements VerificationRepository {
  VerificationRepositoryImpl(this._remoteDataSource);

  final VerificationRemoteDataSource _remoteDataSource;

  @override
  Future<List<CityEntity>> getCities() {
    return _remoteDataSource.getCities();
  }

  @override
  Future<DriverApplicationResponseEntity> submitApplication({
    required Map<String, dynamic> textFields,
    required Map<String, String> photoFiles,
  }) {
    return _remoteDataSource.submitApplication(
      textFields: textFields,
      photoFiles: photoFiles,
    );
  }
}
