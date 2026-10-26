import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/services/audio_alert_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/websocket_service.dart';
import '../../../../core/utils/bloc_transformers.dart';
import '../../data/models/taxi_order_models.dart';
import '../../domain/entities/taxi_order_entity.dart';
import '../../domain/usecases/taxi_radar_usecases.dart';
import 'taxi_radar_event.dart';
import 'taxi_radar_state.dart';

class TaxiRadarBloc extends Bloc<TaxiRadarEvent, TaxiRadarState> {
  TaxiRadarBloc({
    required GetRadarOrdersUseCase getRadarOrdersUseCase,
    required GetActiveTaxiOrderUseCase getActiveTaxiOrderUseCase,
    required AcceptTaxiOrderUseCase acceptTaxiOrderUseCase,
    required DeclineTaxiOrderUseCase declineTaxiOrderUseCase,
    required UpdateTaxiOrderStatusUseCase updateTaxiOrderStatusUseCase,
    required CompleteTaxiOrderUseCase completeTaxiOrderUseCase,
    required CancelTaxiOrderUseCase cancelTaxiOrderUseCase,
    required LocationService locationService,
    required WebSocketService webSocketService,
    Duration pollTick = const Duration(seconds: 8),
    this.connectedPollInterval = const Duration(seconds: 30),
    DateTime Function()? clock,
  })  : _clock = clock ?? DateTime.now,
        _getRadarOrdersUseCase = getRadarOrdersUseCase,
        _getActiveTaxiOrderUseCase = getActiveTaxiOrderUseCase,
        _acceptTaxiOrderUseCase = acceptTaxiOrderUseCase,
        _declineTaxiOrderUseCase = declineTaxiOrderUseCase,
        _updateTaxiOrderStatusUseCase = updateTaxiOrderStatusUseCase,
        _completeTaxiOrderUseCase = completeTaxiOrderUseCase,
        _cancelTaxiOrderUseCase = cancelTaxiOrderUseCase,
        _locationService = locationService,
        _webSocketService = webSocketService,
        super(const TaxiRadarInitial()) {
    on<FetchRadarOrdersEvent>(_onFetchRadarOrders);
    on<CheckActiveTaxiOrderEvent>(_onCheckActiveTaxiOrder);
    on<AcceptOrderEvent>(_onAcceptOrder, transformer: droppableTransformer());
    on<DeclineOrderEvent>(_onDeclineOrder, transformer: droppableTransformer());
    on<UpdateOrderStatusEvent>(_onUpdateOrderStatus,
        transformer: droppableTransformer());
    on<CompleteOrderEvent>(_onCompleteOrder,
        transformer: droppableTransformer());
    on<CancelOrderEvent>(_onCancelOrder, transformer: droppableTransformer());
    on<NewOrderOfferReceivedEvent>(_onNewOrderOffer);
    on<OrderStatusChangedEvent>(_onOrderStatusChanged);
    on<RadarPollTickEvent>(_onPollTick, transformer: droppableTransformer());

    // Listen to WebSocket events with managed subscriptions
    _taxiOfferSubscription = _webSocketService.onTaxiOffer.listen((data) {
      add(NewOrderOfferReceivedEvent(data));
    });
    _orderStatusSubscription =
        _webSocketService.onOrderStatusChanged.listen((data) {
      add(OrderStatusChangedEvent(data));
    });
    _pollTimer = Timer.periodic(pollTick, (_) {
      if (!isClosed) add(const RadarPollTickEvent());
    });
  }

  /// While the socket is up it delivers offers; HTTP polling then only runs
  /// this often as a safety net. While it is down, every tick polls.
  final Duration connectedPollInterval;
  final DateTime Function() _clock;
  Timer? _pollTimer;
  DateTime? _lastServerSync;

  /// Offers the driver declined, so a poll does not bring them back.
  final Set<String> _declinedOfferIds = {};

  StreamSubscription? _taxiOfferSubscription;
  StreamSubscription? _orderStatusSubscription;

  final GetRadarOrdersUseCase _getRadarOrdersUseCase;
  final GetActiveTaxiOrderUseCase _getActiveTaxiOrderUseCase;
  final AcceptTaxiOrderUseCase _acceptTaxiOrderUseCase;
  final DeclineTaxiOrderUseCase _declineTaxiOrderUseCase;
  final UpdateTaxiOrderStatusUseCase _updateTaxiOrderStatusUseCase;
  final CompleteTaxiOrderUseCase _completeTaxiOrderUseCase;
  final CancelTaxiOrderUseCase _cancelTaxiOrderUseCase;
  final LocationService _locationService;
  final WebSocketService _webSocketService;

  List<TaxiOrderOfferEntity> _cachedOffers = [];
  ActiveTaxiOrderEntity? _currentActiveOrder;

  Future<void> _onCheckActiveTaxiOrder(
    CheckActiveTaxiOrderEvent event,
    Emitter<TaxiRadarState> emit,
  ) async {
    try {
      final active = await _getActiveTaxiOrderUseCase();
      if (active != null) {
        _currentActiveOrder = active;
        _webSocketService.subscribeToOrder(active.orderId);
        emit(ActiveOrderLoadedState(active));
      } else {
        add(const FetchRadarOrdersEvent());
      }
    } catch (_) {
      add(const FetchRadarOrdersEvent());
    }
  }

  Future<void> _onFetchRadarOrders(
    FetchRadarOrdersEvent event,
    Emitter<TaxiRadarState> emit,
  ) async {
    emit(const TaxiRadarLoading());
    try {
      final pos = await _locationService.getCurrentPosition();
      final lat = pos?.latitude ?? 41.311081;
      final lng = pos?.longitude ?? 69.240562;

      final offers = await _getRadarOrdersUseCase(lat: lat, lng: lng);
      _lastServerSync = _clock();
      _cachedOffers = offers
          .where((o) => !_declinedOfferIds.contains(o.orderId))
          .toList();
      emit(RadarOrdersLoadedState(
        offers: _cachedOffers,
        activeOrder: _currentActiveOrder,
      ));
    } on ApiException catch (e) {
      emit(TaxiRadarErrorState(e.message));
    } catch (e) {
      emit(TaxiRadarErrorState(e.toString()));
    }
  }

  Future<void> _onAcceptOrder(
    AcceptOrderEvent event,
    Emitter<TaxiRadarState> emit,
  ) async {
    emit(const OrderProcessingState('accepting'));
    try {
      final pos = await _locationService.getCurrentPosition();
      final lat = pos?.latitude ?? 41.311081;
      final lng = pos?.longitude ?? 69.240562;

      final assignedOrder = await _acceptTaxiOrderUseCase(
        orderId: event.orderId,
        lat: lat,
        lng: lng,
      );

      _currentActiveOrder = assignedOrder;
      _cachedOffers =
        _cachedOffers.where((o) => o.orderId != event.orderId).toList();
      _webSocketService.subscribeToOrder(assignedOrder.orderId);

      emit(ActiveOrderLoadedState(assignedOrder));
    } on ApiException catch (e) {
      emit(TaxiRadarErrorState(e.message));
      emit(RadarOrdersLoadedState(
        offers: _cachedOffers,
        activeOrder: _currentActiveOrder,
      ));
    } catch (e) {
      emit(TaxiRadarErrorState(e.toString()));
    }
  }

  Future<void> _onDeclineOrder(
    DeclineOrderEvent event,
    Emitter<TaxiRadarState> emit,
  ) async {
    _declinedOfferIds.add(event.orderId);
    _cachedOffers =
        _cachedOffers.where((o) => o.orderId != event.orderId).toList();
    emit(RadarOrdersLoadedState(
      offers: _cachedOffers,
      activeOrder: _currentActiveOrder,
    ));

    try {
      await _declineTaxiOrderUseCase(event.orderId);
    } catch (_) {}
  }

  Future<void> _onUpdateOrderStatus(
    UpdateOrderStatusEvent event,
    Emitter<TaxiRadarState> emit,
  ) async {
    if (_currentActiveOrder == null) return;
    emit(OrderProcessingState(event.status));

    try {
      final pos = await _locationService.getCurrentPosition();
      final lat = pos?.latitude ?? 41.311081;
      final lng = pos?.longitude ?? 69.240562;

      await _updateTaxiOrderStatusUseCase(
        orderId: event.orderId,
        status: event.status,
        lat: lat,
        lng: lng,
      );

      _currentActiveOrder = _currentActiveOrder!.copyWith(status: event.status);
      emit(ActiveOrderLoadedState(_currentActiveOrder!));
    } on ApiException catch (e) {
      emit(TaxiRadarErrorState(e.message));
      emit(ActiveOrderLoadedState(_currentActiveOrder!));
    }
  }

  Future<void> _onCompleteOrder(
    CompleteOrderEvent event,
    Emitter<TaxiRadarState> emit,
  ) async {
    emit(const OrderProcessingState('completing'));
    try {
      final result = await _completeTaxiOrderUseCase(
        orderId: event.orderId,
        finalPrice: event.finalPrice,
        paymentReceived: event.paymentReceived,
      );

      _webSocketService.unsubscribeFromOrder(event.orderId);
      _currentActiveOrder = null;
      emit(OrderCompletedState(result));
    } on ApiException catch (e) {
      emit(TaxiRadarErrorState(e.message));
      if (_currentActiveOrder != null) {
        emit(ActiveOrderLoadedState(_currentActiveOrder!));
      }
    }
  }

  Future<void> _onCancelOrder(
    CancelOrderEvent event,
    Emitter<TaxiRadarState> emit,
  ) async {
    emit(const OrderProcessingState('cancelling'));
    try {
      await _cancelTaxiOrderUseCase(
        orderId: event.orderId,
        reason: event.reason,
      );

      _webSocketService.unsubscribeFromOrder(event.orderId);
      _currentActiveOrder = null;
      add(const FetchRadarOrdersEvent());
    } on ApiException catch (e) {
      emit(TaxiRadarErrorState(e.message));
      if (_currentActiveOrder != null) {
        emit(ActiveOrderLoadedState(_currentActiveOrder!));
      }
    }
  }

  void _onNewOrderOffer(
    NewOrderOfferReceivedEvent event,
    Emitter<TaxiRadarState> emit,
  ) {
    try {
      final newOffer = TaxiOrderOfferModel.fromJson(event.data);
      if (!_cachedOffers.any((o) => o.orderId == newOffer.orderId)) {
        // New list, not insert(): states compare by value, so mutating the
        // list the current state holds would make the emit a no-op.
        _cachedOffers = [newOffer, ..._cachedOffers];
        AudioAlertService.instance.playNewOrderAlert();
        emit(RadarOrdersLoadedState(
          offers: _cachedOffers,
          activeOrder: _currentActiveOrder,
        ));
      }
    } catch (_) {}
  }

  void _onOrderStatusChanged(
    OrderStatusChangedEvent event,
    Emitter<TaxiRadarState> emit,
  ) {
    final status = event.data['status']?.toString();
    if (status != null && _currentActiveOrder != null) {
      if (status == 'cancelled' || status == 'cancelled_by_passenger') {
        AudioAlertService.instance.playOrderCancelledAlert();
      }
      _currentActiveOrder = _currentActiveOrder!.copyWith(status: status);
      emit(ActiveOrderLoadedState(_currentActiveOrder!));
    }
  }

  Future<void> _onPollTick(
    RadarPollTickEvent event,
    Emitter<TaxiRadarState> emit,
  ) async {
    // Never overwrite a screen that is mid-action or still loading.
    if (state is OrderProcessingState ||
        state is TaxiRadarLoading ||
        state is TaxiRadarInitial ||
        state is OrderCompletedState) {
      return;
    }
    final last = _lastServerSync;
    if (_webSocketService.isConnected &&
        last != null &&
        _clock().difference(last) < connectedPollInterval) {
      return;
    }

    try {
      if (_currentActiveOrder != null) {
        await _pollActiveOrder(emit);
      } else {
        await _pollOffers(emit);
      }
    } catch (_) {
      // Transient failure: keep what is on screen and retry on the next tick.
    }
  }

  Future<void> _pollOffers(Emitter<TaxiRadarState> emit) async {
    final pos = await _locationService.getCurrentPosition();
    final offers = await _getRadarOrdersUseCase(
      lat: pos?.latitude ?? 41.311081,
      lng: pos?.longitude ?? 69.240562,
    );
    _lastServerSync = _clock();
    if (_currentActiveOrder != null) return; // accepted meanwhile

    final known = _cachedOffers.map((o) => o.orderId).toSet();
    final fresh =
        offers.where((o) => !_declinedOfferIds.contains(o.orderId)).toList();
    if (fresh.any((o) => !known.contains(o.orderId))) {
      AudioAlertService.instance.playNewOrderAlert();
    }
    _cachedOffers = fresh;
    emit(RadarOrdersLoadedState(offers: _cachedOffers, activeOrder: null));
  }

  Future<void> _pollActiveOrder(Emitter<TaxiRadarState> emit) async {
    final current = _currentActiveOrder!;
    final latest = await _getActiveTaxiOrderUseCase();
    _lastServerSync = _clock();
    if (_currentActiveOrder?.orderId != current.orderId) return;

    if (latest == null || latest.orderId != current.orderId) {
      // The server no longer has this order active and the driver did not
      // complete it here: the passenger (or dispatch) cancelled it.
      if (current.status == 'cancelled') return;
      AudioAlertService.instance.playOrderCancelledAlert();
      _currentActiveOrder = current.copyWith(status: 'cancelled');
      emit(ActiveOrderLoadedState(_currentActiveOrder!));
    } else if (latest.status != current.status) {
      _currentActiveOrder = latest;
      emit(ActiveOrderLoadedState(latest));
    }
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    _taxiOfferSubscription?.cancel();
    _orderStatusSubscription?.cancel();
    return super.close();
  }
}
