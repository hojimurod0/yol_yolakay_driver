import 'package:equatable/equatable.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class LoadWalletDataEvent extends WalletEvent {
  final bool refresh;
  const LoadWalletDataEvent({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}

class LoadMoreTransactionsEvent extends WalletEvent {
  const LoadMoreTransactionsEvent();
}

class ChangeEarningsPeriodEvent extends WalletEvent {
  final String period; // "today" | "weekly" | "monthly"
  const ChangeEarningsPeriodEvent({required this.period});

  @override
  List<Object?> get props => [period];
}

class DepositRequestedEvent extends WalletEvent {
  final int amount;
  final String paymentSystem; // "payme" | "click" | "uzum"

  const DepositRequestedEvent({
    required this.amount,
    required this.paymentSystem,
  });

  @override
  List<Object?> get props => [amount, paymentSystem];
}

class VerifyPaymentEvent extends WalletEvent {
  final String? invoiceId;
  const VerifyPaymentEvent({this.invoiceId});

  @override
  List<Object?> get props => [invoiceId];
}

class ClearDepositInvoiceEvent extends WalletEvent {
  const ClearDepositInvoiceEvent();
}
