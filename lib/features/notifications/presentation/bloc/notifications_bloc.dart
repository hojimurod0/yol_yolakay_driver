import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/driver_notifications_usecases.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final GetDriverNotificationsUseCase _getNotificationsUseCase;
  final MarkNotificationAsReadUseCase _markReadUseCase;
  final MarkAllNotificationsAsReadUseCase _markAllReadUseCase;

  int _currentPage = 1;

  NotificationsBloc({
    required GetDriverNotificationsUseCase getNotificationsUseCase,
    required MarkNotificationAsReadUseCase markReadUseCase,
    required MarkAllNotificationsAsReadUseCase markAllReadUseCase,
  })  : _getNotificationsUseCase = getNotificationsUseCase,
        _markReadUseCase = markReadUseCase,
        _markAllReadUseCase = markAllReadUseCase,
        super(const NotificationsState()) {
    on<LoadNotificationsEvent>(_onLoadNotifications);
    on<LoadMoreNotificationsEvent>(_onLoadMoreNotifications);
    on<MarkNotificationReadEvent>(_onMarkNotificationRead);
    on<MarkAllNotificationsReadEvent>(_onMarkAllNotificationsRead);
  }

  Future<void> _onLoadNotifications(
    LoadNotificationsEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    if (!event.refresh && state.status == NotificationsStatus.loaded) return;

    if (!event.refresh) {
      emit(state.copyWith(
          status: NotificationsStatus.loading, errorMessage: null));
    }

    try {
      _currentPage = 1;
      final result = await _getNotificationsUseCase(page: 1, limit: 20);

      emit(state.copyWith(
        status: NotificationsStatus.loaded,
        unreadCount: result.unreadCount,
        notifications: result.items,
        hasReachedMax: result.items.length < 20,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: NotificationsStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onLoadMoreNotifications(
    LoadMoreNotificationsEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state.isLoadingMore || state.hasReachedMax) return;

    emit(state.copyWith(isLoadingMore: true));

    try {
      final nextPage = _currentPage + 1;
      final result = await _getNotificationsUseCase(page: nextPage, limit: 20);

      _currentPage = nextPage;
      final updated = List.of(state.notifications)..addAll(result.items);

      emit(state.copyWith(
        isLoadingMore: false,
        unreadCount: result.unreadCount,
        notifications: updated,
        hasReachedMax: result.items.length < 20,
      ));
    } catch (_) {
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onMarkNotificationRead(
    MarkNotificationReadEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    final updatedList = state.notifications.map((n) {
      if (n.id == event.id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    final newUnread = (state.unreadCount - 1).clamp(0, 999);
    emit(state.copyWith(notifications: updatedList, unreadCount: newUnread));

    try {
      await _markReadUseCase(event.id);
    } catch (_) {
      // Background sync, keep optimistic update
    }
  }

  Future<void> _onMarkAllNotificationsRead(
    MarkAllNotificationsReadEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    final updatedList =
        state.notifications.map((n) => n.copyWith(isRead: true)).toList();
    emit(state.copyWith(notifications: updatedList, unreadCount: 0));

    try {
      await _markAllReadUseCase();
    } catch (_) {
      // Background sync
    }
  }
}
