import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/services/audio_alert_service.dart';
import '../../../../core/services/websocket_service.dart';
import '../../../../core/utils/bloc_transformers.dart';
import '../../domain/entities/intercity_ride_entity.dart';
import '../../domain/usecases/intercity_rides_usecases.dart';
import 'intercity_rides_event.dart';
import 'intercity_rides_state.dart';

class IntercityRidesBloc
    extends Bloc<IntercityRidesEvent, IntercityRidesState> {
  IntercityRidesBloc({
    required GetRidesUseCase getRidesUseCase,
    required CreateRideUseCase createRideUseCase,
    required GetRideDetailsUseCase getRideDetailsUseCase,
    required UpdateRideStatusUseCase updateRideStatusUseCase,
    required HandleBookingActionUseCase handleBookingActionUseCase,
    required CancelBookingUseCase cancelBookingUseCase,
    UpdateRideUseCase? updateRideUseCase,
    DeleteRideUseCase? deleteRideUseCase,
    WebSocketService? webSocketService,
  })  : _getRidesUseCase = getRidesUseCase,
        _createRideUseCase = createRideUseCase,
        _getRideDetailsUseCase = getRideDetailsUseCase,
        _updateRideStatusUseCase = updateRideStatusUseCase,
        _handleBookingActionUseCase = handleBookingActionUseCase,
        _cancelBookingUseCase = cancelBookingUseCase,
        _updateRideUseCase = updateRideUseCase,
        _deleteRideUseCase = deleteRideUseCase,
        _webSocketService = webSocketService,
        super(const IntercityRidesInitial()) {
    on<LoadRidesEvent>(_onLoadRides);
    on<CreateRideEvent>(_onCreateRide, transformer: droppableTransformer());
    on<UpdateRideEvent>(_onUpdateRide, transformer: droppableTransformer());
    on<DeleteRideEvent>(_onDeleteRide, transformer: droppableTransformer());
    on<LoadRideDetailsEvent>(_onLoadRideDetails);
    on<UpdateRideStatusEvent>(_onUpdateRideStatus,
        transformer: droppableTransformer());
    on<BookingActionEvent>(_onBookingAction,
        transformer: droppableTransformer());
    on<CancelBookingEvent>(_onCancelBooking,
        transformer: droppableTransformer());
    on<BookingUpdateReceivedEvent>(_onBookingUpdateReceived);

    // Listen to real-time passenger booking updates over WebSocket
    _bookingSubscription = _webSocketService?.onBookingUpdate.listen((data) {
      add(BookingUpdateReceivedEvent(data));
    });
  }

  final GetRidesUseCase _getRidesUseCase;
  final CreateRideUseCase _createRideUseCase;
  final GetRideDetailsUseCase _getRideDetailsUseCase;
  final UpdateRideStatusUseCase _updateRideStatusUseCase;
  final HandleBookingActionUseCase _handleBookingActionUseCase;
  final CancelBookingUseCase _cancelBookingUseCase;
  final UpdateRideUseCase? _updateRideUseCase;
  final DeleteRideUseCase? _deleteRideUseCase;
  final WebSocketService? _webSocketService;

  StreamSubscription? _bookingSubscription;
  String? _currentlyViewedRideId;
  final Map<String, IntercityRideEntity> _cachedRideDetails = {};
  List<IntercityRideEntity> _cachedActiveRides = [];

  Future<void> _onLoadRides(
    LoadRidesEvent event,
    Emitter<IntercityRidesState> emit,
  ) async {
    emit(const IntercityRidesLoading());
    try {
      final response = await _getRidesUseCase(
        status: event.status,
        page: event.page,
      );
      if (event.status == 'active') {
        _cachedActiveRides = response.items;
      }
      emit(IntercityRidesLoaded(
        rides: response.items,
        status: event.status,
        pagination: response.pagination,
      ));
    } on ApiException catch (e) {
      if (event.status == 'active' && _cachedActiveRides.isNotEmpty) {
        emit(IntercityRidesLoaded(
          rides: _cachedActiveRides,
          status: event.status,
          pagination: PaginationModel(
            page: 1,
            limit: _cachedActiveRides.length,
            totalItems: _cachedActiveRides.length,
            totalPages: 1,
          ),
          isOfflineCached: true,
        ));
      } else {
        emit(IntercityRidesError(e.message));
      }
    } catch (e) {
      if (event.status == 'active' && _cachedActiveRides.isNotEmpty) {
        emit(IntercityRidesLoaded(
          rides: _cachedActiveRides,
          status: event.status,
          pagination: PaginationModel(
            page: 1,
            limit: _cachedActiveRides.length,
            totalItems: _cachedActiveRides.length,
            totalPages: 1,
          ),
          isOfflineCached: true,
        ));
      } else {
        emit(IntercityRidesError(e.toString()));
      }
    }
  }

  Future<void> _onCreateRide(
    CreateRideEvent event,
    Emitter<IntercityRidesState> emit,
  ) async {
    emit(const CreatingRideState());
    try {
      final rideId = await _createRideUseCase(event.rideData);
      _cachedActiveRides.clear();
      _webSocketService?.broadcastRideCreated({
        'ride_id': rideId,
        ...event.rideData,
      });
      emit(RideCreatedSuccessState(rideId));
    } on ApiException catch (e) {
      emit(IntercityRidesError(e.message));
    } catch (e) {
      emit(IntercityRidesError(e.toString()));
    }
  }

  Future<void> _onUpdateRide(
    UpdateRideEvent event,
    Emitter<IntercityRidesState> emit,
  ) async {
    emit(const UpdatingRideState());
    try {
      final updateUseCase = _updateRideUseCase;
      if (updateUseCase != null) {
        await updateUseCase(
          rideId: event.rideId,
          rideData: event.rideData,
        );
      }
      _cachedActiveRides.clear();
      emit(RideUpdatedSuccessState(event.rideId));
      add(LoadRideDetailsEvent(event.rideId));
    } on ApiException catch (e) {
      emit(IntercityRidesError(e.message));
    } catch (e) {
      emit(IntercityRidesError(e.toString()));
    }
  }

  Future<void> _onDeleteRide(
    DeleteRideEvent event,
    Emitter<IntercityRidesState> emit,
  ) async {
    try {
      final deleteUseCase = _deleteRideUseCase;
      if (deleteUseCase != null) {
        await deleteUseCase(
          rideId: event.rideId,
          reason: event.reason,
        );
      } else {
        await _updateRideStatusUseCase(
          rideId: event.rideId,
          status: 'cancelled',
          cancelReason: event.reason,
        );
      }
      emit(RideDeletedSuccessState(event.rideId));
      add(const LoadRidesEvent(status: 'active'));
    } on ApiException catch (e) {
      emit(IntercityRidesError(e.message));
    } catch (e) {
      emit(IntercityRidesError(e.toString()));
    }
  }

  Future<void> _onLoadRideDetails(
    LoadRideDetailsEvent event,
    Emitter<IntercityRidesState> emit,
  ) async {
    _currentlyViewedRideId = event.rideId;
    emit(const IntercityRidesLoading());
    try {
      final ride = await _getRideDetailsUseCase(event.rideId);
      _cachedRideDetails[event.rideId] = ride;
      emit(IntercityRideDetailsLoaded(ride));
    } on ApiException catch (e) {
      if (_cachedRideDetails.containsKey(event.rideId)) {
        emit(IntercityRideDetailsLoaded(
          _cachedRideDetails[event.rideId]!,
          isOfflineCached: true,
        ));
      } else {
        emit(IntercityRidesError(e.message));
      }
    } catch (e) {
      if (_cachedRideDetails.containsKey(event.rideId)) {
        emit(IntercityRideDetailsLoaded(
          _cachedRideDetails[event.rideId]!,
          isOfflineCached: true,
        ));
      } else {
        emit(IntercityRidesError(e.toString()));
      }
    }
  }

  Future<void> _onUpdateRideStatus(
    UpdateRideStatusEvent event,
    Emitter<IntercityRidesState> emit,
  ) async {
    try {
      await _updateRideStatusUseCase(
        rideId: event.rideId,
        status: event.status,
        cancelReason: event.cancelReason,
      );
      add(LoadRideDetailsEvent(event.rideId));
    } on ApiException catch (e) {
      emit(IntercityRidesError(e.message));
    }
  }

  Future<void> _onBookingAction(
    BookingActionEvent event,
    Emitter<IntercityRidesState> emit,
  ) async {
    try {
      await _handleBookingActionUseCase(
        bookingId: event.bookingId,
        action: event.action,
        rejectReason: event.rejectReason,
      );
      AudioAlertService.instance.playSuccessAlert();
      // Reload details if available to update seat counts and booking statuses
      if (event.rideId != null) {
        add(LoadRideDetailsEvent(event.rideId!));
      } else if (_currentlyViewedRideId != null) {
        add(LoadRideDetailsEvent(_currentlyViewedRideId!));
      }
    } on ApiException catch (e) {
      emit(IntercityRidesError(e.message));
    }
  }

  Future<void> _onCancelBooking(
    CancelBookingEvent event,
    Emitter<IntercityRidesState> emit,
  ) async {
    try {
      await _cancelBookingUseCase(
        bookingId: event.bookingId,
        reason: event.reason,
      );
      AudioAlertService.instance.playOrderCancelledAlert();
      if (event.rideId != null) {
        add(LoadRideDetailsEvent(event.rideId!));
      } else if (_currentlyViewedRideId != null) {
        add(LoadRideDetailsEvent(_currentlyViewedRideId!));
      }
    } on ApiException catch (e) {
      emit(IntercityRidesError(e.message));
    }
  }

  Future<void> _onBookingUpdateReceived(
    BookingUpdateReceivedEvent event,
    Emitter<IntercityRidesState> emit,
  ) async {
    // Notify driver with urgent alert
    AudioAlertService.instance.playNewOrderAlert();

    // If currently viewing this ride, automatically reload details to show new passenger
    final updatedRideId = event.data['ride_id']?.toString() ??
        event.data['trip_id']?.toString();
    if (_currentlyViewedRideId != null &&
        (updatedRideId == null || updatedRideId == _currentlyViewedRideId)) {
      add(LoadRideDetailsEvent(_currentlyViewedRideId!));
    } else {
      // Reload current active rides list
      add(const LoadRidesEvent(status: 'active'));
    }
  }

  @override
  Future<void> close() {
    _bookingSubscription?.cancel();
    return super.close();
  }
}
