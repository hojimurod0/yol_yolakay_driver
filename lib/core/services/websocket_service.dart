import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../config/app_config.dart';
import '../storage/secure_storage_service.dart';
import '../utils/app_logger.dart';

/// Socket.IO event names exchanged with the NestJS driver gateway.
/// Each incoming event is registered under both naming styles
/// (`UPPER_SNAKE` from BACKEND_TZ_DRIVER.md and `colon:case`) until the
/// backend contract is frozen.
abstract class DriverSocketEvents {
  // Driver ➔ Server
  static const String driverLocationUpdate = 'DRIVER_LOCATION_UPDATE';
  static const String joinTaxiOrder = 'join_taxi_order';
  static const String leaveTaxiOrder = 'leave_taxi_order';

  // Server ➔ Driver
  static const List<String> taxiOffer = [
    'NEW_TAXI_ORDER_OFFER',
    'taxi:order:offer',
  ];
  static const List<String> bookingUpdate = [
    'BOOKING_UPDATE',
    'booking:update',
  ];
  static const List<String> orderCancelled = [
    'ORDER_CANCELLED_BY_PASSENGER',
    'taxi:order:cancelled',
  ];
  static const List<String> orderStatusChanged = [
    'ORDER_STATUS_CHANGED',
    'taxi:status:changed',
  ];
  static const List<String> walletDeposited = [
    'WALLET_DEPOSITED',
    'wallet:deposited',
  ];
}

/// Real-time Socket.IO client for the driver gateway (`wss://<host>/ws`, namespace `/`).
/// Authenticates with the current access token on every (re)connect, re-joins
/// the active taxi order room after reconnects, and deduplicates server events.
class WebSocketService {
  WebSocketService({
    required SecureStorageService secureStorage,
    String? wsUrl,
  })  : _secureStorage = secureStorage,
        _wsUrl = wsUrl ?? AppConfig.activeWebSocketUrl;

  final SecureStorageService _secureStorage;
  final String _wsUrl;

  io.Socket? _socket;
  String? _activeTaxiOrderId;
  bool _isExplicitlyDisconnected = true;
  Timer? _serverDisconnectRetryTimer;
  int _serverDisconnectRetries = 0;
  static const int _maxServerDisconnectRetries = 5;

  // Deduplication ring buffer for incoming real-time messages
  final List<String> _recentMessageSignatures = [];
  static const int _maxRecentSignatures = 200;

  // Real-time Event Streams
  final _taxiOfferController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _bookingUpdateController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _orderCancelledController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _orderStatusChangedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _walletDepositedController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get onTaxiOffer => _taxiOfferController.stream;
  Stream<Map<String, dynamic>> get onBookingUpdate =>
      _bookingUpdateController.stream;
  Stream<Map<String, dynamic>> get onOrderCancelled =>
      _orderCancelledController.stream;
  Stream<Map<String, dynamic>> get onOrderStatusChanged =>
      _orderStatusChangedController.stream;
  Stream<Map<String, dynamic>> get onWalletDeposited =>
      _walletDepositedController.stream;

  bool get isConnected => _socket?.connected ?? false;

  /// Opens the Socket.IO connection if an access token is stored.
  /// [driverId] is kept for call-site compatibility; the server identifies
  /// the driver from the JWT.
  Future<void> connect([String? driverId]) async {
    final token = await _secureStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      AppLogger.debug('WebSocket connect skipped: no access token',
          module: LogModule.system);
      return;
    }

    _isExplicitlyDisconnected = false;

    final socket = _socket;
    if (socket != null) {
      if (!socket.connected && !socket.active) {
        socket.connect();
      }
      return;
    }

    // The URL path is the Socket.IO engine path, not the namespace:
    // `wss://host/ws` ➔ origin `wss://host`, path `/ws`, namespace `/`.
    final uri = Uri.parse(_wsUrl);
    final enginePath = uri.path.isEmpty || uri.path == '/' ? '/ws' : uri.path;
    final origin = '${uri.scheme}://${uri.authority}';

    _socket = io.io(
      origin,
      io.OptionBuilder()
          .setPath(enginePath)
          .setTransports(['websocket'])
          .setAuthFn((callback) {
            // Read the token on every handshake so reconnects use the refreshed one.
            _secureStorage
                .getAccessToken()
                .then((t) => callback({'token': t ?? ''}))
                .catchError((_) => callback({'token': ''}));
          })
          .enableForceNew()
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(1500)
          .setReconnectionDelayMax(30000)
          .setRandomizationFactor(0.5)
          .build(),
    );

    _registerHandlers(_socket!);
    _socket!.connect();
  }

  void _registerHandlers(io.Socket socket) {
    socket.onConnect((_) {
      _serverDisconnectRetries = 0;
      AppLogger.info('WebSocket connected. Socket ID: ${socket.id}',
          module: LogModule.system);
      final orderId = _activeTaxiOrderId;
      if (orderId != null) {
        socket.emit(DriverSocketEvents.joinTaxiOrder, {'order_id': orderId});
      }
    });

    socket.onConnectError((err) {
      AppLogger.warning('WebSocket connection error: $err',
          module: LogModule.system);
    });

    socket.onDisconnect((reason) {
      AppLogger.info('WebSocket disconnected: $reason',
          module: LogModule.system);
      // Socket.IO does not auto-reconnect after a server-side disconnect
      // (e.g. rejected/expired token), so retry with backoff while the
      // HTTP layer refreshes the token.
      if (reason == 'io server disconnect' && !_isExplicitlyDisconnected) {
        _scheduleServerDisconnectRetry();
      }
    });

    void register(
      List<String> eventNames,
      StreamController<Map<String, dynamic>> controller,
    ) {
      for (final name in eventNames) {
        socket.on(name, (raw) {
          final data = _extractPayload(raw);
          if (data == null || _isDuplicateMessage(name, data)) return;
          if (!controller.isClosed) controller.add(data);
        });
      }
    }

    register(DriverSocketEvents.taxiOffer, _taxiOfferController);
    register(DriverSocketEvents.bookingUpdate, _bookingUpdateController);
    register(DriverSocketEvents.orderCancelled, _orderCancelledController);
    register(
        DriverSocketEvents.orderStatusChanged, _orderStatusChangedController);
    register(DriverSocketEvents.walletDeposited, _walletDepositedController);

    if (kDebugMode) {
      // Surfaces event names the backend actually emits while the contract is unconfirmed.
      socket.onAny((event, data) {
        AppLogger.debug('WebSocket event: $event', module: LogModule.system);
      });
    }
  }

  void _scheduleServerDisconnectRetry() {
    if (_serverDisconnectRetries >= _maxServerDisconnectRetries) {
      AppLogger.warning(
          'WebSocket rejected by server $_serverDisconnectRetries times; waiting for next connect()',
          module: LogModule.system);
      return;
    }
    final delay = Duration(seconds: 2 << _serverDisconnectRetries);
    _serverDisconnectRetries++;
    _serverDisconnectRetryTimer?.cancel();
    _serverDisconnectRetryTimer = Timer(delay, () {
      if (!_isExplicitlyDisconnected) connect();
    });
  }

  /// Socket.IO payloads arrive either bare or wrapped as `{event, data}`.
  Map<String, dynamic>? _extractPayload(dynamic raw) {
    if (raw is List && raw.isNotEmpty) raw = raw.first;
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final inner = map['data'];
    if (inner is Map) return Map<String, dynamic>.from(inner);
    return map;
  }

  Future<void> subscribeToOrder(String orderId) async {
    _activeTaxiOrderId = orderId;
    if (isConnected) {
      _socket!.emit(DriverSocketEvents.joinTaxiOrder, {'order_id': orderId});
    }
  }

  Future<void> unsubscribeFromOrder(String orderId) async {
    if (_activeTaxiOrderId == orderId) {
      _activeTaxiOrderId = null;
    }
    if (isConnected) {
      _socket!.emit(DriverSocketEvents.leaveTaxiOrder, {'order_id': orderId});
    }
  }

  /// Sends GPS telemetry. [speedKmh] must already be converted from m/s.
  void sendLocationUpdate({
    required double lat,
    required double lng,
    double? bearing,
    double? speedKmh,
    double? accuracy,
  }) {
    if (!isConnected) return;
    _socket!.emit(DriverSocketEvents.driverLocationUpdate, {
      'lat': lat,
      'lng': lng,
      'bearing': bearing,
      'speed_kmh': speedKmh,
      'accuracy': accuracy,
      'is_online': true,
      'active_trip_id': _activeTaxiOrderId,
    });
  }

  /// Deduplicates server pushed events within a sliding window.
  bool _isDuplicateMessage(String event, Map<String, dynamic> data) {
    final messageId = data['id']?.toString() ??
        data['order_id']?.toString() ??
        data['booking_id']?.toString() ??
        data['transaction_id']?.toString() ??
        data['created_at']?.toString() ??
        '';

    final status = data['status']?.toString() ?? '';
    final signature = '$event:$messageId:$status';
    if (messageId.isNotEmpty && _recentMessageSignatures.contains(signature)) {
      AppLogger.debug('Dropped duplicate WebSocket event: $signature',
          module: LogModule.system);
      return true;
    }

    _recentMessageSignatures.add(signature);
    if (_recentMessageSignatures.length > _maxRecentSignatures) {
      _recentMessageSignatures.removeAt(0);
    }
    return false;
  }

  void disconnect() {
    _isExplicitlyDisconnected = true;
    _serverDisconnectRetryTimer?.cancel();
    _serverDisconnectRetries = 0;
    _activeTaxiOrderId = null;
    _recentMessageSignatures.clear();
    _socket?.dispose();
    _socket = null;
  }

  void dispose() {
    disconnect();
    _taxiOfferController.close();
    _bookingUpdateController.close();
    _orderCancelledController.close();
    _orderStatusChangedController.close();
    _walletDepositedController.close();
  }
}
