import 'package:equatable/equatable.dart';
import '../../domain/entities/earnings_stats_entity.dart';
import '../../domain/entities/wallet_history_entity.dart';

enum WalletStatus { initial, loading, loaded, error }

enum PaymentVerificationStatus { none, verifying, verified, failed }

class WalletState extends Equatable {
  final WalletStatus status;
  final WalletHistoryEntity? wallet;
  final List<TransactionEntity> transactions;
  final EarningsStatsEntity? earnings;
  final String selectedPeriod;
  final bool isLoadingMore;
  final bool isDepositing;
  final DepositInvoiceEntity? depositInvoice;
  final bool isVerifyingPayment;
  final PaymentVerificationStatus paymentVerificationStatus;
  final String? errorMessage;
  final String? depositError;

  const WalletState({
    this.status = WalletStatus.initial,
    this.wallet,
    this.transactions = const [],
    this.earnings,
    this.selectedPeriod = 'weekly',
    this.isLoadingMore = false,
    this.isDepositing = false,
    this.depositInvoice,
    this.isVerifyingPayment = false,
    this.paymentVerificationStatus = PaymentVerificationStatus.none,
    this.errorMessage,
    this.depositError,
  });

  WalletState copyWith({
    WalletStatus? status,
    WalletHistoryEntity? wallet,
    List<TransactionEntity>? transactions,
    EarningsStatsEntity? earnings,
    String? selectedPeriod,
    bool? isLoadingMore,
    bool? isDepositing,
    DepositInvoiceEntity? depositInvoice,
    bool? isVerifyingPayment,
    PaymentVerificationStatus? paymentVerificationStatus,
    String? errorMessage,
    String? depositError,
    bool clearDepositInvoice = false,
  }) {
    return WalletState(
      status: status ?? this.status,
      wallet: wallet ?? this.wallet,
      transactions: transactions ?? this.transactions,
      earnings: earnings ?? this.earnings,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isDepositing: isDepositing ?? this.isDepositing,
      depositInvoice:
          clearDepositInvoice ? null : (depositInvoice ?? this.depositInvoice),
      isVerifyingPayment: isVerifyingPayment ?? this.isVerifyingPayment,
      paymentVerificationStatus:
          paymentVerificationStatus ?? this.paymentVerificationStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      depositError: depositError ?? this.depositError,
    );
  }

  @override
  List<Object?> get props => [
        status,
        wallet,
        transactions,
        earnings,
        selectedPeriod,
        isLoadingMore,
        isDepositing,
        depositInvoice,
        isVerifyingPayment,
        paymentVerificationStatus,
        errorMessage,
        depositError,
      ];
}
