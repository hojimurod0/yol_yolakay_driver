import '../entities/support_entities.dart';

abstract class SupportRepository {
  Future<List<FaqItemEntity>> getFaqs();
  Future<void> submitTicket({
    required String subject,
    required String message,
    String? orderId,
  });
}
