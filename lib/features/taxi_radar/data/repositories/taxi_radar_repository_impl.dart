import '../../domain/entities/taxi_order_entity.dart';
import '../../domain/repositories/taxi_radar_repository.dart';
import '../datasources/taxi_radar_remote_data_source.dart';

class TaxiRadarRepositoryImpl implements TaxiRadarRepository {
  TaxiRadarRepositoryImpl(this._remoteDataSource);

  final TaxiRadarRemoteDataSource _remoteDataSource;

  @override
  Future<List<TaxiOrderOfferEntity>> getRadarOrders({
    required double lat,
    required double lng,
    double radiusKm = 5.0,
  }) {
    return _remoteDataSource.getRadarOrders(
        lat: lat, lng: lng, radiusKm: radiusKm);
  }

  @override
  Future<ActiveTaxiOrderEntity?> getActiveOrder() {
    return _remoteDataSource.getActiveOrder();
  }

  @override
  Future<ActiveTaxiOrderEntity> acceptOrder({
    required String orderId,
    required double lat,
    required double lng,
  }) {
    return _remoteDataSource.acceptOrder(orderId: orderId, lat: lat, lng: lng);
  }

  @override
  Future<void> declineOrder(String orderId) {
    return _remoteDataSource.declineOrder(orderId);
  }

  @override
  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
    required double lat,
    required double lng,
  }) {
    return _remoteDataSource.updateOrderStatus(
      orderId: orderId,
      status: status,
      lat: lat,
      lng: lng,
    );
  }

  @override
  Future<TaxiCompletionResultEntity> completeOrder({
    required String orderId,
    required int finalPrice,
    required bool paymentReceived,
  }) {
    return _remoteDataSource.completeOrder(
      orderId: orderId,
      finalPrice: finalPrice,
      paymentReceived: paymentReceived,
    );
  }

  @override
  Future<void> cancelOrder({
    required String orderId,
    required String reason,
  }) {
    return _remoteDataSource.cancelOrder(orderId: orderId, reason: reason);
  }
}
