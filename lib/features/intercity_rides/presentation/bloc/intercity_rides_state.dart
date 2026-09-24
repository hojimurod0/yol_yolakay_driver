import 'package:equatable/equatable.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/intercity_ride_entity.dart';

abstract class IntercityRidesState extends Equatable {
  const IntercityRidesState();
  @override
  List<Object?> get props => [];
}

class IntercityRidesInitial extends IntercityRidesState {
  const IntercityRidesInitial();
}

class IntercityRidesLoading extends IntercityRidesState {
  const IntercityRidesLoading();
}

class IntercityRidesLoaded extends IntercityRidesState {
  const IntercityRidesLoaded({
    required this.rides,
    required this.status,
    required this.pagination,
  });

  final List<IntercityRideEntity> rides;
  final String status;
  final PaginationModel pagination;

  @override
  List<Object?> get props => [rides, status, pagination];
}

class IntercityRideDetailsLoaded extends IntercityRidesState {
  const IntercityRideDetailsLoaded(this.ride);
  final IntercityRideEntity ride;

  @override
  List<Object?> get props => [ride];
}

class CreatingRideState extends IntercityRidesState {
  const CreatingRideState();
}

class RideCreatedSuccessState extends IntercityRidesState {
  const RideCreatedSuccessState(this.rideId);
  final String rideId;

  @override
  List<Object?> get props => [rideId];
}

class IntercityRidesError extends IntercityRidesState {
  const IntercityRidesError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
