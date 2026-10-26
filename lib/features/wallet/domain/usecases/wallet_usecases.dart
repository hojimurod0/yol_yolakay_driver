import '../entities/earnings_stats_entity.dart';
import '../entities/wallet_history_entity.dart';
import '../repositories/wallet_repository.dart';

class GetWalletHistoryUseCase {
  final WalletRepository _repository;
  GetWalletHistoryUseCase(this._repository);

  Future<WalletHistoryEntity> call({int page = 1, int limit = 20}) {
    return _repository.getWalletHistory(page: page, limit: limit);
  }
}

class DepositWalletUseCase {
  final WalletRepository _repository;
  DepositWalletUseCase(this._repository);

  Future<DepositInvoiceEntity> call({
    required int amount,
    required String paymentSystem,
    required String idempotencyKey,
  }) {
    return _repository.deposit(
      amount: amount,
      paymentSystem: paymentSystem,
      idempotencyKey: idempotencyKey,
    );
  }
}

class GetEarningsStatsUseCase {
  final WalletRepository _repository;
  GetEarningsStatsUseCase(this._repository);

  Future<EarningsStatsEntity> call({required String period}) {
    return _repository.getEarningsStats(period: period);
  }
}
