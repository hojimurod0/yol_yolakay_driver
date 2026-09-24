// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionModel _$TransactionModelFromJson(Map<String, dynamic> json) =>
    TransactionModel(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'unknown',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      description: json['description'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
    );

Map<String, dynamic> _$TransactionModelToJson(TransactionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'amount': instance.amount,
      'description': instance.description,
      'created_at': instance.createdAt,
    };

WalletHistoryModel _$WalletHistoryModelFromJson(Map<String, dynamic> json) =>
    WalletHistoryModel(
      balance: (json['balance'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'UZS',
      minBalanceThreshold:
          (json['min_balance_threshold'] as num?)?.toInt() ?? 20000,
      transactions: (json['transactions'] as List<dynamic>?)
              ?.map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pagination: json['pagination'] == null
          ? const PaginationModel(
              page: 1, limit: 20, totalItems: 0, totalPages: 1)
          : PaginationModel.fromJson(
              json['pagination'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WalletHistoryModelToJson(WalletHistoryModel instance) =>
    <String, dynamic>{
      'balance': instance.balance,
      'currency': instance.currency,
      'min_balance_threshold': instance.minBalanceThreshold,
      'transactions': instance.transactions.map((e) => e.toJson()).toList(),
      'pagination': instance.pagination.toJson(),
    };

DepositInvoiceModel _$DepositInvoiceModelFromJson(Map<String, dynamic> json) =>
    DepositInvoiceModel(
      invoiceId: json['invoice_id'] as String,
      paymentUrl: json['payment_url'] as String,
    );

Map<String, dynamic> _$DepositInvoiceModelToJson(
        DepositInvoiceModel instance) =>
    <String, dynamic>{
      'invoice_id': instance.invoiceId,
      'payment_url': instance.paymentUrl,
    };
