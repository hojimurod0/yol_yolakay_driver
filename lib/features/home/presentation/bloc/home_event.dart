import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object?> get props => [];
}

class LoadHomeDashboardEvent extends HomeEvent {
  const LoadHomeDashboardEvent();
}

class ToggleShiftEvent extends HomeEvent {
  const ToggleShiftEvent(this.isOnline);
  final bool isOnline;

  @override
  List<Object?> get props => [isOnline];
}
