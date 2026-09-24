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
  })  : _getRadarOrdersUseCase = getRadarOrdersUseCase,
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

    // Listen to WebSocket events with managed subscriptions
    _taxiOfferSubscription = _webSocketService.onTaxiOffer.listen((data) {
      add(NewOrderOfferReceivedEvent(data));
    });
    _orderStatusSubscription =
        _webSocketService.onOrderStatusChanged.listen((data) {
      add(OrderStatusChangedEvent(data));
    });
  }

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
      _cachedOffers = List.from(offers);
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
      _cachedOffers.removeWhere((o) => o.orderId == event.orderId);
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
    _cachedOffers.removeWhere((o) => o.orderId == event.orderId);
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
        _cachedOffers.insert(0, newOffer);
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

  @override
  Future<void> close() {
    _taxiOfferSubscription?.cancel();
    _orderStatusSubscription?.cancel();
    return super.close();
  }
}
