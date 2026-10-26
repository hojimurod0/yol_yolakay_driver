import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/services/driver_tracking_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/utils/bloc_transformers.dart';
import '../../domain/usecases/home_usecases.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    required GetHomeDashboardUseCase getHomeDashboardUseCase,
    required ToggleShiftUseCase toggleShiftUseCase,
    required LocationService locationService,
    required DriverTrackingService trackingService,
    PermissionService? permissionService,
  })  : _getHomeDashboardUseCase = getHomeDashboardUseCase,
        _toggleShiftUseCase = toggleShiftUseCase,
        _locationService = locationService,
        _trackingService = trackingService,
        _permissionService = permissionService,
        super(const HomeInitial()) {
    on<LoadHomeDashboardEvent>(_onLoadHomeDashboard);
    on<ToggleShiftEvent>(_onToggleShift, transformer: droppableTransformer());
  }

  final GetHomeDashboardUseCase _getHomeDashboardUseCase;
  final ToggleShiftUseCase _toggleShiftUseCase;
  final LocationService _locationService;
  final DriverTrackingService _trackingService;
  final PermissionService? _permissionService;

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
        await _trackingService.start();
      } else {
        _trackingService.stop();
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
        await _trackingService.start();
      } else {
        _trackingService.stop();
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
}
