import 'package:json_annotation/json_annotation.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/wallet_history_entity.dart';

part 'wallet_history_model.g.dart';

@JsonSerializable()
class TransactionModel {
  @JsonKey(name: 'id')
  final String id;
  @JsonKey(name: 'type', defaultValue: 'unknown')
  final String type;
  @JsonKey(name: 'amount', defaultValue: 0)
  final int amount;
  @JsonKey(name: 'description', defaultValue: '')
  final String description;
  @JsonKey(name: 'created_at', defaultValue: '')
  final String createdAt;

  const TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);

  TransactionEntity toEntity() {
    TransactionType txType;
    switch (type.toLowerCase()) {
      case 'commission':
        txType = TransactionType.commission;
        break;
      case 'deposit':
        txType = TransactionType.deposit;
        break;
      case 'bonus':
        txType = TransactionType.bonus;
        break;
      case 'cashback':
        txType = TransactionType.cashback;
        break;
      default:
        txType = TransactionType.unknown;
    }

    return TransactionEntity(
      id: id,
      type: txType,
      amount: amount,
      description: description,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class WalletHistoryModel {
  @JsonKey(name: 'balance', defaultValue: 0)
  final int balance;
  @JsonKey(name: 'currency', defaultValue: 'UZS')
  final String currency;
  @JsonKey(name: 'min_balance_threshold', defaultValue: 20000)
  final int minBalanceThreshold;
  @JsonKey(name: 'transactions', defaultValue: [])
  final List<TransactionModel> transactions;
  @JsonKey(name: 'pagination', defaultValue: PaginationModel(page: 1, limit: 20, totalItems: 0, totalPages: 1))
  final PaginationModel pagination;

  const WalletHistoryModel({
    required this.balance,
    required this.currency,
    required this.minBalanceThreshold,
    required this.transactions,
    required this.pagination,
  });

  factory WalletHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$WalletHistoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$WalletHistoryModelToJson(this);

  WalletHistoryEntity toEntity() {
    return WalletHistoryEntity(
      balance: balance,
      currency: currency,
      minBalanceThreshold: minBalanceThreshold,
      transactions: transactions.map((m) => m.toEntity()).toList(),
      pagination: pagination,
    );
  }
}

@JsonSerializable()
class DepositInvoiceModel {
  @JsonKey(name: 'invoice_id')
  final String invoiceId;
  @JsonKey(name: 'payment_url')
  final String paymentUrl;

  const DepositInvoiceModel({
    required this.invoiceId,
    required this.paymentUrl,
  });

  factory DepositInvoiceModel.fromJson(Map<String, dynamic> json) =>
      _$DepositInvoiceModelFromJson(json);

  Map<String, dynamic> toJson() => _$DepositInvoiceModelToJson(this);

  DepositInvoiceEntity toEntity() {
    return DepositInvoiceEntity(
      invoiceId: invoiceId,
      paymentUrl: paymentUrl,
    );
  }
}
