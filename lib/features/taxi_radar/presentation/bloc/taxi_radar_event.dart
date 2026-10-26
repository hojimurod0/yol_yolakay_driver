import 'package:equatable/equatable.dart';

abstract class TaxiRadarEvent extends Equatable {
  const TaxiRadarEvent();
  @override
  List<Object?> get props => [];
}

class FetchRadarOrdersEvent extends TaxiRadarEvent {
  const FetchRadarOrdersEvent();
}

class CheckActiveTaxiOrderEvent extends TaxiRadarEvent {
  const CheckActiveTaxiOrderEvent();
}

class AcceptOrderEvent extends TaxiRadarEvent {
  const AcceptOrderEvent(this.orderId);
  final String orderId;

  @override
  List<Object?> get props => [orderId];
}

class DeclineOrderEvent extends TaxiRadarEvent {
  const DeclineOrderEvent(this.orderId);
  final String orderId;

  @override
  List<Object?> get props => [orderId];
}

class UpdateOrderStatusEvent extends TaxiRadarEvent {
  const UpdateOrderStatusEvent({
    required this.orderId,
    required this.status,
  });

  final String orderId;
  final String status;

  @override
  List<Object?> get props => [orderId, status];
}

class CompleteOrderEvent extends TaxiRadarEvent {
  const CompleteOrderEvent({
    required this.orderId,
    required this.finalPrice,
    required this.paymentReceived,
  });

  final String orderId;
  final int finalPrice;
  final bool paymentReceived;

  @override
  List<Object?> get props => [orderId, finalPrice, paymentReceived];
}

class CancelOrderEvent extends TaxiRadarEvent {
  const CancelOrderEvent({
    required this.orderId,
    required this.reason,
  });

  final String orderId;
  final String reason;

  @override
  List<Object?> get props => [orderId, reason];
}

class NewOrderOfferReceivedEvent extends TaxiRadarEvent {
  const NewOrderOfferReceivedEvent(this.data);
  final Map<String, dynamic> data;

  @override
  List<Object?> get props => [data];
}

class OrderStatusChangedEvent extends TaxiRadarEvent {
  const OrderStatusChangedEvent(this.data);
  final Map<String, dynamic> data;

  @override
  List<Object?> get props => [data];
}

/// Periodic HTTP refresh so offers and passenger cancellations still arrive
/// when the WebSocket is down.
class RadarPollTickEvent extends TaxiRadarEvent {
  const RadarPollTickEvent();
}
