import '../entities/taxi_order_entity.dart';

abstract class TaxiRadarRepository {
  Future<List<TaxiOrderOfferEntity>> getRadarOrders({
    required double lat,
    required double lng,
    double radiusKm = 5.0,
  });

  Future<ActiveTaxiOrderEntity?> getActiveOrder();

  Future<ActiveTaxiOrderEntity> acceptOrder({
    required String orderId,
    required double lat,
    required double lng,
  });

  Future<void> declineOrder(String orderId);

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
    required double lat,
    required double lng,
  });

  Future<TaxiCompletionResultEntity> completeOrder({
    required String orderId,
    required int finalPrice,
    required bool paymentReceived,
  });

  Future<void> cancelOrder({
    required String orderId,
    required String reason,
  });
}
