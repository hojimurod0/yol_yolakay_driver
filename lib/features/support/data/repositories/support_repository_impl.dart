import '../../domain/entities/support_entities.dart';
import '../../domain/repositories/support_repository.dart';
import '../datasources/support_remote_data_source.dart';

class SupportRepositoryImpl implements SupportRepository {
  final SupportRemoteDataSource _remoteDataSource;

  SupportRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<FaqItemEntity>> getFaqs() async {
    final models = await _remoteDataSource.getFaqs();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> submitTicket({
    required String subject,
    required String message,
    String? orderId,
  }) {
    return _remoteDataSource.submitTicket(
      subject: subject,
      message: message,
      orderId: orderId,
    );
  }
}
