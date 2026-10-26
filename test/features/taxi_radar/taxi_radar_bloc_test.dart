import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yol_yolakay_driver/core/services/location_service.dart';
import 'package:yol_yolakay_driver/core/services/websocket_service.dart';
import 'package:yol_yolakay_driver/features/taxi_radar/domain/entities/taxi_order_entity.dart';
import 'package:yol_yolakay_driver/features/taxi_radar/domain/repositories/taxi_radar_repository.dart';
import 'package:yol_yolakay_driver/features/taxi_radar/domain/usecases/taxi_radar_usecases.dart';
import 'package:yol_yolakay_driver/features/taxi_radar/presentation/bloc/taxi_radar_bloc.dart';
import 'package:yol_yolakay_driver/features/taxi_radar/presentation/bloc/taxi_radar_event.dart';
import 'package:yol_yolakay_driver/features/taxi_radar/presentation/bloc/taxi_radar_state.dart';

TaxiOrderOfferEntity _offer(String id) => TaxiOrderOfferEntity(
      orderId: id,
      tier: 'standard',
      estimatedPrice: 30000,
      distanceToPickupKm: 2,
      pickup: const LocationAddressEntity(address: 'A', lat: 41.3, lng: 69.2),
      destination:
          const LocationAddressEntity(address: 'B', lat: 41.2, lng: 69.1),
      paymentType: 'cash',
      createdAt: DateTime(2026, 9, 21, 14, 5),
      timeoutSeconds: 30,
    );

class FakeTaxiRadarRepository implements TaxiRadarRepository {
  ActiveTaxiOrderEntity? activeOrder;
  int radarCalls = 0;
  bool serverKeepsDeclined = false;
  final List<TaxiOrderOfferEntity> offers = [
    TaxiOrderOfferEntity(
      orderId: 'order-1',
      tier: 'standard',
      estimatedPrice: 35000,
      distanceToPickupKm: 1.2,
      pickup: const LocationAddressEntity(
        address: 'Amir Temur ko\'chasi 15',
        lat: 41.311,
        lng: 69.240,
      ),
      destination: const LocationAddressEntity(
        address: 'Chilonzor 9-mavze',
        lat: 41.280,
        lng: 69.200,
      ),
      paymentType: 'cash',
      createdAt: DateTime(2026, 9, 21, 14, 0),
      timeoutSeconds: 30,
    ),
  ];

  @override
  Future<List<TaxiOrderOfferEntity>> getRadarOrders({
    required double lat,
    required double lng,
    double radiusKm = 5.0,
  }) async {
    radarCalls++;
    return List.of(offers);
  }

  @override
  Future<ActiveTaxiOrderEntity?> getActiveOrder() async => activeOrder;

  @override
  Future<ActiveTaxiOrderEntity> acceptOrder({
    required String orderId,
    required double lat,
    required double lng,
  }) async {
    activeOrder = const ActiveTaxiOrderEntity(
      orderId: 'order-1',
      status: 'driver_assigned',
      tier: 'standard',
      passenger: PassengerProfileEntity(
        id: 'p-1',
        name: 'Bobur',
        phone: '+998901234567',
        rating: 4.8,
      ),
      pickup: LocationAddressEntity(
        address: 'Amir Temur ko\'chasi 15',
        lat: 41.311,
        lng: 69.240,
      ),
      destination: LocationAddressEntity(
        address: 'Chilonzor 9-mavze',
        lat: 41.280,
        lng: 69.200,
      ),
      price: 35000,
      commissionAmount: 3500,
      paymentType: 'cash',
    );
    return activeOrder!;
  }

  @override
  Future<void> declineOrder(String orderId) async {
    if (serverKeepsDeclined) return;
    offers.removeWhere((o) => o.orderId == orderId);
  }

  @override
  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
    required double lat,
    required double lng,
  }) async {
    if (activeOrder != null) {
      activeOrder = activeOrder!.copyWith(status: status);
    }
  }

  @override
  Future<TaxiCompletionResultEntity> completeOrder({
    required String orderId,
    required int finalPrice,
    required bool paymentReceived,
  }) async {
    activeOrder = null;
    return TaxiCompletionResultEntity(
      orderId: orderId,
      status: 'completed',
      earnings: finalPrice - 3500,
      commissionDeducted: 3500,
      newWalletBalance: 150000,
      message: 'Buyurtma muvaffaqiyatli yakunlandi',
    );
  }

  @override
  Future<void> cancelOrder({
    required String orderId,
    required String reason,
  }) async {
    activeOrder = null;
  }
}

class FakeLocationService extends LocationService {
  @override
  Future<Position?> getCurrentPosition() async => null;
}

class FakeWebSocketService extends Fake implements WebSocketService {
  bool connected = false;

  @override
  bool get isConnected => connected;

  final _taxiOfferController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _orderStatusController =
      StreamController<Map<String, dynamic>>.broadcast();

  @override
  Stream<Map<String, dynamic>> get onTaxiOffer => _taxiOfferController.stream;

  @override
  Stream<Map<String, dynamic>> get onOrderStatusChanged =>
      _orderStatusController.stream;

  @override
  Future<void> subscribeToOrder(String orderId) async {}

  @override
  Future<void> unsubscribeFromOrder(String orderId) async {}
}

void main() {
  late FakeTaxiRadarRepository fakeRepo;
  late FakeLocationService fakeLocation;
  late FakeWebSocketService fakeWs;
  late TaxiRadarBloc radarBloc;
  late DateTime now;

  setUp(() {
    fakeRepo = FakeTaxiRadarRepository();
    fakeLocation = FakeLocationService();
    fakeWs = FakeWebSocketService();
    now = DateTime(2026, 10, 22, 12);
    radarBloc = TaxiRadarBloc(
      clock: () => now,
      getRadarOrdersUseCase: GetRadarOrdersUseCase(fakeRepo),
      getActiveTaxiOrderUseCase: GetActiveTaxiOrderUseCase(fakeRepo),
      acceptTaxiOrderUseCase: AcceptTaxiOrderUseCase(fakeRepo),
      declineTaxiOrderUseCase: DeclineTaxiOrderUseCase(fakeRepo),
      updateTaxiOrderStatusUseCase: UpdateTaxiOrderStatusUseCase(fakeRepo),
      completeTaxiOrderUseCase: CompleteTaxiOrderUseCase(fakeRepo),
      cancelTaxiOrderUseCase: CancelTaxiOrderUseCase(fakeRepo),
      locationService: fakeLocation,
      webSocketService: fakeWs,
    );
  });

  tearDown(() {
    radarBloc.close();
  });

  group('TaxiRadarBloc Tests', () {
    test('initial state is TaxiRadarInitial', () {
      expect(radarBloc.state, const TaxiRadarInitial());
    });

    test(
        'FetchRadarOrdersEvent emits [TaxiRadarLoading, RadarOrdersLoadedState]',
        () async {
      radarBloc.add(const FetchRadarOrdersEvent());

      await expectLater(
        radarBloc.stream,
        emitsInOrder([
          isA<TaxiRadarLoading>(),
          predicate<RadarOrdersLoadedState>((s) =>
              s.offers.length == 1 && s.offers.first.orderId == 'order-1'),
        ]),
      );
    });

    test(
        'AcceptOrderEvent emits [OrderProcessingState, ActiveOrderLoadedState]',
        () async {
      radarBloc.add(const AcceptOrderEvent('order-1'));

      await expectLater(
        radarBloc.stream,
        emitsInOrder([
          predicate<OrderProcessingState>((s) => s.action == 'accepting'),
          predicate<ActiveOrderLoadedState>(
              (s) => s.activeOrder.orderId == 'order-1'),
        ]),
      );
    });

    test('CompleteOrderEvent emits [OrderProcessingState, OrderCompletedState]',
        () async {
      radarBloc.add(const CompleteOrderEvent(
        orderId: 'order-1',
        finalPrice: 35000,
        paymentReceived: true,
      ));

      await expectLater(
        radarBloc.stream,
        emitsInOrder([
          predicate<OrderProcessingState>((s) => s.action == 'completing'),
          predicate<OrderCompletedState>((s) => s.result.earnings == 31500),
        ]),
      );
    });
  });

  group('TaxiRadarBloc polling fallback', () {
    Future<void> loadRadar() async {
      radarBloc.add(const FetchRadarOrdersEvent());
      await radarBloc.stream.firstWhere((s) => s is RadarOrdersLoadedState);
    }

    test('socket down: a poll brings in offers that arrived on the server',
        () async {
      await loadRadar();
      fakeRepo.offers.add(_offer('order-2'));

      radarBloc.add(const RadarPollTickEvent());
      final state = await radarBloc.stream.firstWhere((s) =>
          s is RadarOrdersLoadedState && s.offers.length == 2)
          as RadarOrdersLoadedState;

      expect(state.offers.map((o) => o.orderId), contains('order-2'));
    });

    test('socket up: polls only after the safety-net interval', () async {
      fakeWs.connected = true;
      await loadRadar();
      final callsAfterLoad = fakeRepo.radarCalls;

      now = now.add(const Duration(seconds: 10));
      radarBloc.add(const RadarPollTickEvent());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(fakeRepo.radarCalls, callsAfterLoad);

      now = now.add(const Duration(seconds: 25));
      radarBloc.add(const RadarPollTickEvent());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(fakeRepo.radarCalls, callsAfterLoad + 1);
    });

    test('a declined offer is not brought back by polling', () async {
      fakeRepo.serverKeepsDeclined = true;
      await loadRadar();
      radarBloc.add(const DeclineOrderEvent('order-1'));
      await radarBloc.stream.firstWhere(
          (s) => s is RadarOrdersLoadedState && s.offers.isEmpty);
      fakeRepo.offers.add(_offer('order-2'));

      radarBloc.add(const RadarPollTickEvent());
      final state = await radarBloc.stream.firstWhere((s) =>
          s is RadarOrdersLoadedState && s.offers.isNotEmpty)
          as RadarOrdersLoadedState;

      expect(state.offers.map((o) => o.orderId), ['order-2']);
    });

    test('socket down: passenger cancellation is detected by polling',
        () async {
      radarBloc.add(const AcceptOrderEvent('order-1'));
      await radarBloc.stream.firstWhere((s) => s is ActiveOrderLoadedState);
      fakeRepo.activeOrder = null; // cancelled on the server

      radarBloc.add(const RadarPollTickEvent());
      final state = await radarBloc.stream
          .firstWhere((s) => s is ActiveOrderLoadedState)
          as ActiveOrderLoadedState;

      expect(state.activeOrder.status, 'cancelled');
    });

    test('socket down: active order status changes are picked up', () async {
      radarBloc.add(const AcceptOrderEvent('order-1'));
      await radarBloc.stream.firstWhere((s) => s is ActiveOrderLoadedState);
      fakeRepo.activeOrder = fakeRepo.activeOrder!.copyWith(status: 'arrived');

      radarBloc.add(const RadarPollTickEvent());
      final state = await radarBloc.stream
          .firstWhere((s) => s is ActiveOrderLoadedState)
          as ActiveOrderLoadedState;

      expect(state.activeOrder.status, 'arrived');
    });
  });
}
