import 'package:equatable/equatable.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotificationsEvent extends NotificationsEvent {
  final bool refresh;
  const LoadNotificationsEvent({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}

class LoadMoreNotificationsEvent extends NotificationsEvent {
  const LoadMoreNotificationsEvent();
}

class MarkNotificationReadEvent extends NotificationsEvent {
  final String id;
  const MarkNotificationReadEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class MarkAllNotificationsReadEvent extends NotificationsEvent {
  const MarkAllNotificationsReadEvent();
}
