import '../../domain/entities/support_entities.dart';
import '../../domain/repositories/support_repository.dart';

class MockSupportRepository implements SupportRepository {
  @override
  Future<List<FaqItemEntity>> getFaqs() async {
    return [];
  }

  @override
  Future<void> submitTicket({
    required String subject,
    required String message,
    String? orderId,
  }) async {}
}
