import 'package:equatable/equatable.dart';
import '../../domain/entities/support_entities.dart';

enum SupportStatus { initial, loading, loaded, error }

class SupportState extends Equatable {
  final SupportStatus status;
  final List<FaqItemEntity> faqs;
  final bool isSubmittingTicket;
  final bool ticketSubmittedSuccess;
  final String? errorMessage;
  final String? ticketError;

  const SupportState({
    this.status = SupportStatus.initial,
    this.faqs = const [],
    this.isSubmittingTicket = false,
    this.ticketSubmittedSuccess = false,
    this.errorMessage,
    this.ticketError,
  });

  SupportState copyWith({
    SupportStatus? status,
    List<FaqItemEntity>? faqs,
    bool? isSubmittingTicket,
    bool? ticketSubmittedSuccess,
    String? errorMessage,
    String? ticketError,
  }) {
    return SupportState(
      status: status ?? this.status,
      faqs: faqs ?? this.faqs,
      isSubmittingTicket: isSubmittingTicket ?? this.isSubmittingTicket,
      ticketSubmittedSuccess: ticketSubmittedSuccess ?? false,
      errorMessage: errorMessage ?? this.errorMessage,
      ticketError: ticketError ?? this.ticketError,
    );
  }

  @override
  List<Object?> get props => [
        status,
        faqs,
        isSubmittingTicket,
        ticketSubmittedSuccess,
        errorMessage,
        ticketError,
      ];
}
