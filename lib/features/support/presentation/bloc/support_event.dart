import 'package:equatable/equatable.dart';

abstract class SupportEvent extends Equatable {
  const SupportEvent();

  @override
  List<Object?> get props => [];
}

class LoadFaqsEvent extends SupportEvent {
  const LoadFaqsEvent();
}

class SubmitTicketEvent extends SupportEvent {
  final String subject;
  final String message;
  final String? orderId;

  const SubmitTicketEvent({
    required this.subject,
    required this.message,
    this.orderId,
  });

  @override
  List<Object?> get props => [subject, message, orderId];
}
