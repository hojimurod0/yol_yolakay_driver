import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/taxi_order_models.dart';

abstract class TaxiRadarRemoteDataSource {
  Future<List<TaxiOrderOfferModel>> getRadarOrders({
    required double lat,
    required double lng,
    double radiusKm = 5.0,
  });

  Future<ActiveTaxiOrderModel?> getActiveOrder();

  Future<ActiveTaxiOrderModel> acceptOrder({
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

  Future<TaxiCompletionResultModel> completeOrder({
    required String orderId,
    required int finalPrice,
    required bool paymentReceived,
  });

  Future<void> cancelOrder({
    required String orderId,
    required String reason,
  });
}

class TaxiRadarRemoteDataSourceImpl implements TaxiRadarRemoteDataSource {
  TaxiRadarRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<TaxiOrderOfferModel>> getRadarOrders({
    required double lat,
    required double lng,
    double radiusKm = 5.0,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.taxiRadar,
      queryParameters: {
        'lat': lat,
        'lng': lng,
        'radius_km': radiusKm,
      },
      fromData: (data) {
        final List<TaxiOrderOfferModel> list = [];
        final orders = (data as Map<String, dynamic>)['active_orders'];
        if (orders is List) {
          for (final o in orders) {
            if (o is Map<String, dynamic>) {
              list.add(TaxiOrderOfferModel.fromJson(o));
            }
          }
        }
        return list;
      },
    );
    return response.data ?? [];
  }

  @override
  Future<ActiveTaxiOrderModel?> getActiveOrder() async {
    final response = await _apiClient.get(
      ApiEndpoints.taxiActiveOrder,
      fromData: (data) {
        if (data == null) return null;
        if (data is Map<String, dynamic>) {
          return ActiveTaxiOrderModel.fromJson(data);
        }
        return null;
      },
    );
    return response.data;
  }

  @override
  Future<ActiveTaxiOrderModel> acceptOrder({
    required String orderId,
    required double lat,
    required double lng,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.taxiAcceptOrder(orderId),
      idempotencyKey:
          'accept-$orderId-${DateTime.now().millisecondsSinceEpoch}',
      data: {
        'driver_lat': lat,
        'driver_lng': lng,
      },
      fromData: (data) {
        if (data is Map<String, dynamic>) {
          return ActiveTaxiOrderModel.fromJson(data);
        }
        return null;
      },
    );
    return response.data!;
  }

  @override
  Future<void> declineOrder(String orderId) async {
    await _apiClient.post(
      ApiEndpoints.taxiDeclineOrder(orderId),
      idempotencyKey:
          'decline-$orderId-${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
    required double lat,
    required double lng,
  }) async {
    await _apiClient.patch(
      ApiEndpoints.taxiOrderStatus(orderId),
      idempotencyKey:
          'status-$orderId-$status-${DateTime.now().millisecondsSinceEpoch}',
      data: {
        'status': status,
        'current_lat': lat,
        'current_lng': lng,
      },
    );
  }

  @override
  Future<TaxiCompletionResultModel> completeOrder({
    required String orderId,
    required int finalPrice,
    required bool paymentReceived,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.taxiCompleteOrder(orderId),
      idempotencyKey:
          'complete-$orderId-${DateTime.now().millisecondsSinceEpoch}',
      data: {
        'final_price': finalPrice,
        'payment_received': paymentReceived,
      },
      fromData: (data) =>
          TaxiCompletionResultModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  @override
  Future<void> cancelOrder({
    required String orderId,
    required String reason,
  }) async {
    await _apiClient.post(
      ApiEndpoints.taxiCancelOrder(orderId),
      idempotencyKey:
          'cancel-$orderId-${DateTime.now().millisecondsSinceEpoch}',
      data: {'reason': reason},
    );
  }
}
