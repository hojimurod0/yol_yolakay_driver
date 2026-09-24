import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/entities/support_entities.dart';
import '../../domain/repositories/support_repository.dart';

class SupportState {
  const SupportState({
    this.faqs = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.isSubmitted = false,
  });

  final List<FaqItemEntity> faqs;
  final bool isLoading;
  final bool isSubmitting;
  final bool isSubmitted;

  SupportState copyWith({
    List<FaqItemEntity>? faqs,
    bool? isLoading,
    bool? isSubmitting,
    bool? isSubmitted,
  }) {
    return SupportState(
      faqs: faqs ?? this.faqs,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSubmitted: isSubmitted ?? this.isSubmitted,
    );
  }
}

class SupportNotifier extends StateNotifier<SupportState> {
  SupportNotifier(this._supportRepository) : super(const SupportState()) {
    loadFaqs();
  }

  final SupportRepository _supportRepository;

  Future<void> loadFaqs() async {
    state = state.copyWith(isLoading: true);
    try {
      final faqs = await _supportRepository.getFaqs();
      state = state.copyWith(faqs: faqs, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> submitProblemReport({
    required String category,
    required String description,
    String? tripId,
  }) async {
    state = state.copyWith(isSubmitting: true, isSubmitted: false);
    try {
      await _supportRepository.submitTicket(
        subject: category,
        message: description,
        orderId: tripId,
      );
      state = state.copyWith(isSubmitting: false, isSubmitted: true);
      return true;
    } catch (_) {
      state = state.copyWith(isSubmitting: false);
      return false;
    }
  }
}

final supportNotifierProvider =
    StateNotifierProvider<SupportNotifier, SupportState>((ref) {
  final repo = ref.watch(supportRepositoryProvider);
  return SupportNotifier(repo);
});
