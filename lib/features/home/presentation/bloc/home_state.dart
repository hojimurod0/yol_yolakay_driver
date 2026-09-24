import 'package:equatable/equatable.dart';
import '../../domain/entities/home_dashboard_entity.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  const HomeLoaded(this.dashboard);
  final HomeDashboardEntity dashboard;

  @override
  List<Object?> get props => [dashboard];
}

class HomeError extends HomeState {
  const HomeError({
    required this.message,
    this.isNoInternet = false,
  });

  final String message;
  final bool isNoInternet;

  @override
  List<Object?> get props => [message, isNoInternet];
}

class ShiftTogglingState extends HomeState {
  const ShiftTogglingState(this.targetOnline);
  final bool targetOnline;

  @override
  List<Object?> get props => [targetOnline];
}
