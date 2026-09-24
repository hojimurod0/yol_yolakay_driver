import 'package:equatable/equatable.dart';
import '../../domain/entities/taxi_order_entity.dart';

abstract class TaxiRadarState extends Equatable {
  const TaxiRadarState();
  @override
  List<Object?> get props => [];
}

class TaxiRadarInitial extends TaxiRadarState {
  const TaxiRadarInitial();
}

class TaxiRadarLoading extends TaxiRadarState {
  const TaxiRadarLoading();
}

class RadarOrdersLoadedState extends TaxiRadarState {
  const RadarOrdersLoadedState({
    required this.offers,
    this.activeOrder,
  });

  final List<TaxiOrderOfferEntity> offers;
  final ActiveTaxiOrderEntity? activeOrder;

  @override
  List<Object?> get props => [offers, activeOrder];
}

class ActiveOrderLoadedState extends TaxiRadarState {
  const ActiveOrderLoadedState(this.activeOrder);
  final ActiveTaxiOrderEntity activeOrder;

  @override
  List<Object?> get props => [activeOrder];
}

class OrderProcessingState extends TaxiRadarState {
  const OrderProcessingState(this.action);
  final String action;

  @override
  List<Object?> get props => [action];
}

class OrderCompletedState extends TaxiRadarState {
  const OrderCompletedState(this.result);
  final TaxiCompletionResultEntity result;

  @override
  List<Object?> get props => [result];
}

class TaxiRadarErrorState extends TaxiRadarState {
  const TaxiRadarErrorState(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
