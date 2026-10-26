import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/earnings_stats_model.dart';
import '../models/wallet_history_model.dart';

abstract class WalletRemoteDataSource {
  Future<WalletHistoryModel> getWalletHistory({int page = 1, int limit = 20});
  Future<DepositInvoiceModel> deposit({
    required int amount,
    required String paymentSystem,
    required String idempotencyKey,
  });
  Future<EarningsStatsModel> getEarningsStats({required String period});
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final ApiClient _apiClient;

  WalletRemoteDataSourceImpl(this._apiClient);

  @override
  Future<WalletHistoryModel> getWalletHistory(
      {int page = 1, int limit = 20}) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.walletHistory,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    if (response.data != null) {
      return WalletHistoryModel.fromJson(response.data!);
    } else {
      throw Exception('Failed to parse wallet history');
    }
  }

  @override
  Future<DepositInvoiceModel> deposit({
    required int amount,
    required String paymentSystem,
    required String idempotencyKey,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.walletDeposit,
      idempotencyKey: idempotencyKey,
      data: {
        'amount': amount,
        'payment_system': paymentSystem,
      },
    );

    if (response.data != null) {
      return DepositInvoiceModel.fromJson(response.data!);
    } else {
      throw Exception('Failed to parse deposit invoice response');
    }
  }

  @override
  Future<EarningsStatsModel> getEarningsStats({required String period}) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.earningsStats,
      queryParameters: {
        'period': period,
      },
    );

    if (response.data != null) {
      return EarningsStatsModel.fromJson(response.data!);
    } else {
      throw Exception('Failed to parse earnings statistics');
    }
  }
}
