import '../entities/support_entities.dart';
import '../repositories/support_repository.dart';

class GetFaqsUseCase {
  final SupportRepository _repository;
  GetFaqsUseCase(this._repository);

  Future<List<FaqItemEntity>> call() {
    return _repository.getFaqs();
  }
}

class SubmitSupportTicketUseCase {
  final SupportRepository _repository;
  SubmitSupportTicketUseCase(this._repository);

  Future<void> call({
    required String subject,
    required String message,
    String? orderId,
  }) {
    return _repository.submitTicket(
      subject: subject,
      message: message,
      orderId: orderId,
    );
  }
}
