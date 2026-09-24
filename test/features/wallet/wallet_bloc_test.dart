import 'package:flutter_test/flutter_test.dart';
import 'package:yol_yolakay_driver/core/network/api_response.dart';
import 'package:yol_yolakay_driver/features/wallet/domain/entities/earnings_stats_entity.dart';
import 'package:yol_yolakay_driver/features/wallet/domain/entities/wallet_history_entity.dart';
import 'package:yol_yolakay_driver/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:yol_yolakay_driver/features/wallet/domain/usecases/wallet_usecases.dart';
import 'package:yol_yolakay_driver/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:yol_yolakay_driver/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:yol_yolakay_driver/features/wallet/presentation/bloc/wallet_state.dart';

class FakeWalletRepository implements WalletRepository {
  @override
  Future<WalletHistoryEntity> getWalletHistory(
      {int page = 1, int limit = 20}) async {
    return WalletHistoryEntity(
      balance: 150000,
      currency: 'UZS',
      minBalanceThreshold: 20000,
      transactions: [
        TransactionEntity(
          id: 'tx-1',
          type: TransactionType.deposit,
          amount: 50000,
          description: 'Hamyon to\'ldirish',
          createdAt: DateTime(2026, 9, 21, 10, 0),
        ),
      ],
      pagination: const PaginationModel(
        page: 1,
        limit: 20,
        totalItems: 1,
        totalPages: 1,
      ),
    );
  }

  @override
  Future<DepositInvoiceEntity> deposit({
    required int amount,
    required String paymentSystem,
  }) async {
    return const DepositInvoiceEntity(
      invoiceId: 'inv-123',
      paymentUrl: 'https://checkout.payme.uz/inv-123',
    );
  }

  @override
  Future<EarningsStatsEntity> getEarningsStats({required String period}) async {
    return const EarningsStatsEntity(
      period: 'today',
      totalEarnings: 250000,
      totalTrips: 5,
      totalDistanceKm: 85.0,
      totalOnlineHours: 4.5,
      chartData: [],
    );
  }
}

void main() {
  late FakeWalletRepository fakeRepo;
  late WalletBloc walletBloc;

  setUp(() {
    fakeRepo = FakeWalletRepository();
    walletBloc = WalletBloc(
      getWalletHistoryUseCase: GetWalletHistoryUseCase(fakeRepo),
      depositWalletUseCase: DepositWalletUseCase(fakeRepo),
      getEarningsStatsUseCase: GetEarningsStatsUseCase(fakeRepo),
    );
  });

  tearDown(() {
    walletBloc.close();
  });

  group('WalletBloc Tests', () {
    test('initial state has initial status and empty values', () {
      expect(walletBloc.state.status, WalletStatus.initial);
      expect(walletBloc.state.wallet, isNull);
      expect(walletBloc.state.transactions, isEmpty);
      expect(walletBloc.state.isDepositing, isFalse);
    });

    test(
        'LoadWalletDataEvent emits [loading, loaded] with fetched history and stats',
        () async {
      walletBloc.add(const LoadWalletDataEvent(refresh: true));

      await expectLater(
        walletBloc.stream,
        emitsInOrder([
          predicate<WalletState>((s) =>
              s.status == WalletStatus.loaded && s.wallet?.balance == 150000),
        ]),
      );
    });

    test('DepositRequestedEvent creates invoice URL and updates state',
        () async {
      walletBloc.add(
          const DepositRequestedEvent(amount: 50000, paymentSystem: 'payme'));

      await expectLater(
        walletBloc.stream,
        emitsInOrder([
          predicate<WalletState>((s) => s.isDepositing == true),
          predicate<WalletState>((s) =>
              s.isDepositing == false &&
              s.depositInvoice?.invoiceId == 'inv-123' &&
              s.depositInvoice?.paymentUrl.contains('payme.uz') == true),
        ]),
      );
    });

    test(
        'ClearDepositInvoiceEvent clears active invoice and resets verification',
        () async {
      walletBloc.add(const ClearDepositInvoiceEvent());

      await expectLater(
        walletBloc.stream,
        emits(
          predicate<WalletState>((s) =>
              s.depositInvoice == null &&
              s.paymentVerificationStatus == PaymentVerificationStatus.none),
        ),
      );
    });
  });
}
