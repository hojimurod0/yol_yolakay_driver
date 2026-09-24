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

class UpdateDriverLocationEvent extends HomeEvent {
  const UpdateDriverLocationEvent({
    required this.lat,
    required this.lng,
    this.bearing,
    this.speed,
  });

  final double lat;
  final double lng;
  final double? bearing;
  final double? speed;

  @override
  List<Object?> get props => [lat, lng, bearing, speed];
}
