import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/services/websocket_service.dart';
import '../../../../core/utils/bloc_transformers.dart';
import '../../domain/usecases/home_usecases.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    required GetHomeDashboardUseCase getHomeDashboardUseCase,
    required ToggleShiftUseCase toggleShiftUseCase,
    required UpdateLocationUseCase updateLocationUseCase,
    required LocationService locationService,
    WebSocketService? webSocketService,
    PermissionService? permissionService,
  })  : _getHomeDashboardUseCase = getHomeDashboardUseCase,
        _toggleShiftUseCase = toggleShiftUseCase,
        _updateLocationUseCase = updateLocationUseCase,
        _locationService = locationService,
        _webSocketService = webSocketService,
        _permissionService = permissionService,
        super(const HomeInitial()) {
    on<LoadHomeDashboardEvent>(_onLoadHomeDashboard);
    on<ToggleShiftEvent>(_onToggleShift, transformer: droppableTransformer());
    on<UpdateDriverLocationEvent>(_onUpdateDriverLocation);
  }

  final GetHomeDashboardUseCase _getHomeDashboardUseCase;
  final ToggleShiftUseCase _toggleShiftUseCase;
  final UpdateLocationUseCase _updateLocationUseCase;
  final LocationService _locationService;
  final WebSocketService? _webSocketService;
  final PermissionService? _permissionService;

  DateTime? _lastHttpLocationSyncTime;

  Future<void> _onLoadHomeDashboard(
    LoadHomeDashboardEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    try {
      final dashboard = await _getHomeDashboardUseCase();
      emit(HomeLoaded(dashboard));

      // Synchronize tracking with initial online status
      if (dashboard.isOnline) {
        _locationService.startLocationTracking(
          onPositionChanged: (pos) {
            add(UpdateDriverLocationEvent(
              lat: pos.latitude,
              lng: pos.longitude,
              bearing: pos.heading,
              speed: pos.speed,
            ));
          },
        );
      } else {
        _locationService.stopLocationTracking();
      }
    } on NetworkException catch (e) {
      emit(HomeError(message: e.message, isNoInternet: true));
    } on ApiException catch (e) {
      emit(HomeError(message: e.message));
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  Future<void> _onToggleShift(
    ToggleShiftEvent event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;

    // Driver Online Gate: validate prerequisites when attempting to go online
    if (event.isOnline && _permissionService != null) {
      final verificationStatus = currentState is HomeLoaded
          ? currentState.dashboard.verificationStatus
          : 'approved';
      final reason = await _permissionService!.validateCanGoOnline(
        isAuthenticated: true,
        verificationStatus: verificationStatus,
      );

      if (reason != null) {
        final message = switch (reason) {
          CannotGoOnlineReason.locationServiceDisabled =>
            'GPS xizmati yoqilmagan. Iltimos, joylashuv xizmatini yoqing.',
          CannotGoOnlineReason.locationPermissionMissing =>
            'Joylashuv ruxsati berilmagan. Davom etish uchun ruxsat bering.',
          CannotGoOnlineReason.locationPermissionPermanentlyDenied =>
            'Joylashuv ruxsati rad etilgan. Iltimos, ilova sozlamalaridan ruxsat bering.',
          CannotGoOnlineReason.verificationRequired =>
            'Arizangiz hali tasdiqlanmagan. Faqat tasdiqlangan haydovchilar liniyaga chiqa oladi.',
          CannotGoOnlineReason.accountBlocked =>
            "Hisobingiz to'xtatilgan yoki bloklangan. Qo'llab-quvvatlash xizmati bilan bog'laning.",
          _ => "Liniyaga chiqish uchun barcha talablar bajarilishi shart.",
        };
        emit(HomeError(message: message));
        if (currentState is HomeLoaded) {
          emit(currentState);
        }
        return;
      }
    }

    emit(ShiftTogglingState(event.isOnline));

    try {
      final pos = await _locationService.getCurrentPosition();
      final isOnline = await _toggleShiftUseCase(
        isOnline: event.isOnline,
        lat: pos?.latitude,
        lng: pos?.longitude,
      );

      if (isOnline) {
        _locationService.startLocationTracking(
          onPositionChanged: (p) {
            add(UpdateDriverLocationEvent(
              lat: p.latitude,
              lng: p.longitude,
              bearing: p.heading,
              speed: p.speed,
            ));
          },
        );
      } else {
        _locationService.stopLocationTracking();
      }

      if (currentState is HomeLoaded) {
        emit(HomeLoaded(currentState.dashboard.copyWith(isOnline: isOnline)));
      } else {
        add(const LoadHomeDashboardEvent());
      }
    } on ApiException catch (e) {
      emit(HomeError(message: e.message));
      if (currentState is HomeLoaded) {
        emit(currentState);
      }
    } catch (e) {
      emit(HomeError(message: e.toString()));
      if (currentState is HomeLoaded) {
        emit(currentState);
      }
    }
  }

  Future<void> _onUpdateDriverLocation(
    UpdateDriverLocationEvent event,
    Emitter<HomeState> emit,
  ) async {
    // 1. Primary real-time location stream over WebSocket (zero HTTP overhead)
    if (_webSocketService != null && _webSocketService!.isConnected) {
      _webSocketService!.sendLocationUpdate(
        lat: event.lat,
        lng: event.lng,
        bearing: event.bearing,
        speed: event.speed,
      );
    }

    // 2. HTTP Fallback / Periodic Persistence
    // Only send HTTP POST if WebSocket is disconnected OR if 45+ seconds have elapsed since last HTTP sync
    final now = DateTime.now();
    final shouldSendHttp = _webSocketService == null ||
        !_webSocketService!.isConnected ||
        _lastHttpLocationSyncTime == null ||
        now.difference(_lastHttpLocationSyncTime!).inSeconds >= 45;

    if (shouldSendHttp) {
      _lastHttpLocationSyncTime = now;
      try {
        await _updateLocationUseCase(
          lat: event.lat,
          lng: event.lng,
          bearing: event.bearing,
          speed: event.speed,
        );
      } catch (_) {}
    }
  }
}
