import '../entities/earnings_stats_entity.dart';
import '../entities/wallet_history_entity.dart';

abstract class WalletRepository {
  Future<WalletHistoryEntity> getWalletHistory({int page = 1, int limit = 20});
  Future<DepositInvoiceEntity> deposit(
      {required int amount, required String paymentSystem});
  Future<EarningsStatsEntity> getEarningsStats({required String period});
}
