import 'package:equatable/equatable.dart';

class FaqItemEntity extends Equatable {
  final String id;
  final String category;
  final String question;
  final String answer;

  const FaqItemEntity({
    required this.id,
    required this.category,
    required this.question,
    required this.answer,
  });

  @override
  List<Object?> get props => [id, category, question, answer];
}

class SupportTicketEntity extends Equatable {
  final String id;
  final String subject;
  final String message;
  final String? orderId;
  final String status; // "open" | "in_progress" | "resolved" | "closed"
  final DateTime createdAt;

  const SupportTicketEntity({
    required this.id,
    required this.subject,
    required this.message,
    this.orderId,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, subject, message, orderId, status, createdAt];
}
