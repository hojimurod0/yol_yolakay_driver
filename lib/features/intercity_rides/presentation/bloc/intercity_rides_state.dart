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
    this.isOfflineCached = false,
  });

  final List<IntercityRideEntity> rides;
  final String status;
  final PaginationModel pagination;
  final bool isOfflineCached;

  @override
  List<Object?> get props => [rides, status, pagination, isOfflineCached];
}

class IntercityRideDetailsLoaded extends IntercityRidesState {
  const IntercityRideDetailsLoaded(this.ride, {this.isOfflineCached = false});
  final IntercityRideEntity ride;
  final bool isOfflineCached;

  @override
  List<Object?> get props => [ride, isOfflineCached];
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

class UpdatingRideState extends IntercityRidesState {
  const UpdatingRideState();
}

class RideUpdatedSuccessState extends IntercityRidesState {
  const RideUpdatedSuccessState(this.rideId);
  final String rideId;

  @override
  List<Object?> get props => [rideId];
}

class RideDeletedSuccessState extends IntercityRidesState {
  const RideDeletedSuccessState(this.rideId);
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
