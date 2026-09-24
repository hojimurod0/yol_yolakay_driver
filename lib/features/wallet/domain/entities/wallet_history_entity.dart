import 'package:equatable/equatable.dart';
import '../../../../core/network/api_response.dart';

enum TransactionType {
  commission,
  deposit,
  bonus,
  cashback,
  unknown,
}

class TransactionEntity extends Equatable {
  final String id;
  final TransactionType type;
  final int amount; // in UZS (positive for credit, negative for debit)
  final String description;
  final DateTime createdAt;

  const TransactionEntity({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.createdAt,
  });

  bool get isIncome => amount > 0;

  @override
  List<Object?> get props => [id, type, amount, description, createdAt];
}

class WalletHistoryEntity extends Equatable {
  final int balance;
  final String currency;
  final int minBalanceThreshold;
  final List<TransactionEntity> transactions;
  final PaginationModel pagination;

  const WalletHistoryEntity({
    required this.balance,
    required this.currency,
    required this.minBalanceThreshold,
    required this.transactions,
    required this.pagination,
  });

  bool get isBalanceLow => balance < minBalanceThreshold;

  @override
  List<Object?> get props =>
      [balance, currency, minBalanceThreshold, transactions, pagination];
}

class DepositInvoiceEntity extends Equatable {
  final String invoiceId;
  final String paymentUrl;

  const DepositInvoiceEntity({
    required this.invoiceId,
    required this.paymentUrl,
  });

  @override
  List<Object?> get props => [invoiceId, paymentUrl];
}
