import '../../domain/entities/earnings_stats_entity.dart';
import '../../domain/entities/wallet_history_entity.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_remote_data_source.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource _remoteDataSource;

  WalletRepositoryImpl(this._remoteDataSource);

  @override
  Future<WalletHistoryEntity> getWalletHistory(
      {int page = 1, int limit = 20}) async {
    final model =
        await _remoteDataSource.getWalletHistory(page: page, limit: limit);
    return model.toEntity();
  }

  @override
  Future<DepositInvoiceEntity> deposit({
    required int amount,
    required String paymentSystem,
    required String idempotencyKey,
  }) async {
    final model = await _remoteDataSource.deposit(
        amount: amount,
        paymentSystem: paymentSystem,
        idempotencyKey: idempotencyKey);
    return model.toEntity();
  }

  @override
  Future<EarningsStatsEntity> getEarningsStats({required String period}) async {
    final model = await _remoteDataSource.getEarningsStats(period: period);
    return model.toEntity();
  }
}
