import '../entities/taxi_order_entity.dart';
import '../repositories/taxi_radar_repository.dart';

class GetRadarOrdersUseCase {
  const GetRadarOrdersUseCase(this._repository);
  final TaxiRadarRepository _repository;

  Future<List<TaxiOrderOfferEntity>> call({
    required double lat,
    required double lng,
    double radiusKm = 5.0,
  }) =>
      _repository.getRadarOrders(lat: lat, lng: lng, radiusKm: radiusKm);
}

class GetActiveTaxiOrderUseCase {
  const GetActiveTaxiOrderUseCase(this._repository);
  final TaxiRadarRepository _repository;

  Future<ActiveTaxiOrderEntity?> call() => _repository.getActiveOrder();
}

class AcceptTaxiOrderUseCase {
  const AcceptTaxiOrderUseCase(this._repository);
  final TaxiRadarRepository _repository;

  Future<ActiveTaxiOrderEntity> call({
    required String orderId,
    required double lat,
    required double lng,
  }) =>
      _repository.acceptOrder(orderId: orderId, lat: lat, lng: lng);
}

class DeclineTaxiOrderUseCase {
  const DeclineTaxiOrderUseCase(this._repository);
  final TaxiRadarRepository _repository;

  Future<void> call(String orderId) => _repository.declineOrder(orderId);
}

class UpdateTaxiOrderStatusUseCase {
  const UpdateTaxiOrderStatusUseCase(this._repository);
  final TaxiRadarRepository _repository;

  Future<void> call({
    required String orderId,
    required String status,
    required double lat,
    required double lng,
  }) =>
      _repository.updateOrderStatus(
        orderId: orderId,
        status: status,
        lat: lat,
        lng: lng,
      );
}

class CompleteTaxiOrderUseCase {
  const CompleteTaxiOrderUseCase(this._repository);
  final TaxiRadarRepository _repository;

  Future<TaxiCompletionResultEntity> call({
    required String orderId,
    required int finalPrice,
    required bool paymentReceived,
  }) =>
      _repository.completeOrder(
        orderId: orderId,
        finalPrice: finalPrice,
        paymentReceived: paymentReceived,
      );
}

class CancelTaxiOrderUseCase {
  const CancelTaxiOrderUseCase(this._repository);
  final TaxiRadarRepository _repository;

  Future<void> call({required String orderId, required String reason}) =>
      _repository.cancelOrder(orderId: orderId, reason: reason);
}
