import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/support_usecases.dart';
import 'support_event.dart';
import 'support_state.dart';

class SupportBloc extends Bloc<SupportEvent, SupportState> {
  final GetFaqsUseCase _getFaqsUseCase;
  final SubmitSupportTicketUseCase _submitTicketUseCase;

  SupportBloc({
    required GetFaqsUseCase getFaqsUseCase,
    required SubmitSupportTicketUseCase submitTicketUseCase,
  })  : _getFaqsUseCase = getFaqsUseCase,
        _submitTicketUseCase = submitTicketUseCase,
        super(const SupportState()) {
    on<LoadFaqsEvent>(_onLoadFaqs);
    on<SubmitTicketEvent>(_onSubmitTicket);
  }

  Future<void> _onLoadFaqs(
    LoadFaqsEvent event,
    Emitter<SupportState> emit,
  ) async {
    emit(state.copyWith(status: SupportStatus.loading, errorMessage: null));

    try {
      final faqs = await _getFaqsUseCase();
      emit(state.copyWith(
        status: SupportStatus.loaded,
        faqs: faqs,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SupportStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onSubmitTicket(
    SubmitTicketEvent event,
    Emitter<SupportState> emit,
  ) async {
    emit(state.copyWith(
      isSubmittingTicket: true,
      ticketError: null,
      ticketSubmittedSuccess: false,
    ));

    try {
      await _submitTicketUseCase(
        subject: event.subject,
        message: event.message,
        orderId: event.orderId,
      );

      emit(state.copyWith(
        isSubmittingTicket: false,
        ticketSubmittedSuccess: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmittingTicket: false,
        ticketError: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}
