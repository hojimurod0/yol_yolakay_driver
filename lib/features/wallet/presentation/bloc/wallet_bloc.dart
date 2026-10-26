import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/utils/bloc_transformers.dart';
import '../../domain/entities/wallet_history_entity.dart';
import '../../domain/usecases/wallet_usecases.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final GetWalletHistoryUseCase _getWalletHistoryUseCase;
  final DepositWalletUseCase _depositWalletUseCase;

  /// Idempotency key for the deposit the driver is trying to make. Kept across
  /// retries of the same amount/provider (e.g. after a timeout where the server
  /// may already have created the invoice) and dropped once an invoice arrives.
  String? _pendingDepositKey;
  String? _pendingDepositSignature;
  final GetEarningsStatsUseCase _getEarningsStatsUseCase;

  int _currentPage = 1;

  WalletBloc({
    required GetWalletHistoryUseCase getWalletHistoryUseCase,
    required DepositWalletUseCase depositWalletUseCase,
    required GetEarningsStatsUseCase getEarningsStatsUseCase,
  })  : _getWalletHistoryUseCase = getWalletHistoryUseCase,
        _depositWalletUseCase = depositWalletUseCase,
        _getEarningsStatsUseCase = getEarningsStatsUseCase,
        super(const WalletState()) {
    on<LoadWalletDataEvent>(_onLoadWalletData);
    on<LoadMoreTransactionsEvent>(_onLoadMoreTransactions);
    on<ChangeEarningsPeriodEvent>(_onChangeEarningsPeriod);
    on<DepositRequestedEvent>(_onDepositRequested,
        transformer: droppableTransformer());
    on<VerifyPaymentEvent>(_onVerifyPayment,
        transformer: droppableTransformer());
    on<ClearDepositInvoiceEvent>(_onClearDepositInvoice);
  }

  Future<void> _onLoadWalletData(
    LoadWalletDataEvent event,
    Emitter<WalletState> emit,
  ) async {
    if (!event.refresh && state.status == WalletStatus.loaded) return;

    if (!event.refresh) {
      emit(state.copyWith(status: WalletStatus.loading, errorMessage: null));
    }

    try {
      _currentPage = 1;
      final results = await Future.wait([
        _getWalletHistoryUseCase(page: 1, limit: 20),
        _getEarningsStatsUseCase(period: state.selectedPeriod),
      ]);

      final walletHistory = results[0] as WalletHistoryEntity;
      final earningsStats = results[1] as dynamic;

      emit(state.copyWith(
        status: WalletStatus.loaded,
        wallet: walletHistory,
        transactions: walletHistory.transactions,
        earnings: earningsStats,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: WalletStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onLoadMoreTransactions(
    LoadMoreTransactionsEvent event,
    Emitter<WalletState> emit,
  ) async {
    if (state.isLoadingMore || state.wallet == null) return;
    if (!state.wallet!.pagination.hasNextPage) return;

    emit(state.copyWith(isLoadingMore: true));

    try {
      final nextPage = _currentPage + 1;
      final nextHistory =
          await _getWalletHistoryUseCase(page: nextPage, limit: 20);

      _currentPage = nextPage;
      final updatedList = List<TransactionEntity>.from(state.transactions)
        ..addAll(nextHistory.transactions);

      emit(state.copyWith(
        isLoadingMore: false,
        wallet: nextHistory,
        transactions: updatedList,
      ));
    } catch (_) {
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onChangeEarningsPeriod(
    ChangeEarningsPeriodEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(state.copyWith(selectedPeriod: event.period));

    try {
      final stats = await _getEarningsStatsUseCase(period: event.period);
      emit(state.copyWith(earnings: stats));
    } catch (_) {
      // Keep existing stats on failure
    }
  }

  Future<void> _onDepositRequested(
    DepositRequestedEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(state.copyWith(
      isDepositing: true,
      depositError: null,
      clearDepositInvoice: true,
    ));

    final signature = '${event.paymentSystem}:${event.amount}';
    if (_pendingDepositSignature != signature) {
      _pendingDepositSignature = signature;
      _pendingDepositKey = 'deposit-${const Uuid().v4()}';
    }

    try {
      final invoice = await _depositWalletUseCase(
        amount: event.amount,
        paymentSystem: event.paymentSystem,
        idempotencyKey: _pendingDepositKey!,
      );
      _pendingDepositKey = null;
      _pendingDepositSignature = null;

      emit(state.copyWith(
        isDepositing: false,
        depositInvoice: invoice,
      ));
    } catch (e) {
      emit(state.copyWith(
        isDepositing: false,
        depositError: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onVerifyPayment(
    VerifyPaymentEvent event,
    Emitter<WalletState> emit,
  ) async {
    // Protection against duplicate resume events or duplicate verify requests
    if (state.isVerifyingPayment) return;

    emit(state.copyWith(
      isVerifyingPayment: true,
      paymentVerificationStatus: PaymentVerificationStatus.verifying,
    ));

    try {
      final results = await Future.wait([
        _getWalletHistoryUseCase(page: 1, limit: 20),
        _getEarningsStatsUseCase(period: state.selectedPeriod),
      ]);

      final updatedWallet = results[0] as WalletHistoryEntity;
      final updatedEarnings = results[1] as dynamic;

      emit(state.copyWith(
        status: WalletStatus.loaded,
        wallet: updatedWallet,
        transactions: updatedWallet.transactions,
        earnings: updatedEarnings,
        isVerifyingPayment: false,
        paymentVerificationStatus: PaymentVerificationStatus.verified,
        clearDepositInvoice: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isVerifyingPayment: false,
        paymentVerificationStatus: PaymentVerificationStatus.failed,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  void _onClearDepositInvoice(
    ClearDepositInvoiceEvent event,
    Emitter<WalletState> emit,
  ) {
    emit(state.copyWith(
      clearDepositInvoice: true,
      paymentVerificationStatus: PaymentVerificationStatus.none,
    ));
  }
}
