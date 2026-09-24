import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../config/app_config.dart';
import '../constants/api_endpoints.dart';
import '../network/api_client.dart';
import '../utils/app_logger.dart';

/// Production-grade Real-time WebSocket Service.
/// Supports Laravel Reverb / Pusher protocol, exponential backoff with jitter,
/// network-aware auto-reconnection, channel re-subscription, and message deduplication.
class WebSocketService {
  WebSocketService({
    required ApiClient apiClient,
    String? wsUrl,
  })  : _apiClient = apiClient,
        _wsUrl = wsUrl ?? AppConfig.activeWebSocketUrl {
    _initConnectivityListener();
  }

  final ApiClient _apiClient;
  final String _wsUrl;

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  String? _socketId;
  String? _currentDriverId;
  String? _activeTaxiOrderId;
  bool _isConnected = false;
  bool _isExplicitlyDisconnected = false;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxBackoffSeconds = 30;

  // Active channel subscription registry for seamless reconnects
  final Set<String> _activeSubscribedChannels = {};

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

  bool get isConnected => _isConnected;

  void _initConnectivityListener() {
    try {
      _connectivitySubscription =
          Connectivity().onConnectivityChanged.listen((results) {
        final hasConnection = results.any((r) => r != ConnectivityResult.none);
        if (hasConnection &&
            !_isConnected &&
            !_isExplicitlyDisconnected &&
            _currentDriverId != null) {
          AppLogger.info(
              'Internet restored. Triggering immediate WebSocket reconnect...',
              module: LogModule.system);
          _reconnectAttempts = 0;
          _reconnectTimer?.cancel();
          connect(_currentDriverId!);
        }
      });
    } catch (e) {
      AppLogger.warning(
          'Could not attach connectivity listener to WebSocket: $e',
          module: LogModule.system);
    }
  }

  Future<void> connect([String? driverId]) async {
    if (driverId != null) {
      _currentDriverId = driverId;
    }
    if (_currentDriverId == null) {
      return;
    }
    _isExplicitlyDisconnected = false;
    _disconnectInternal();

    try {
      final uri = Uri.parse(
          '$_wsUrl?appKey=yolyolakay&protocol=7&client=js&version=8.4.0-reverb');
      _channel = WebSocketChannel.connect(uri);

      _subscription = _channel!.stream.listen(
        _handleMessage,
        onError: (err) {
          AppLogger.warning('WebSocket connection error: $err',
              module: LogModule.system);
          _scheduleReconnect();
        },
        onDone: () {
          AppLogger.info('WebSocket connection closed.',
              module: LogModule.system);
          _scheduleReconnect();
        },
        cancelOnError: false,
      );
    } catch (e) {
      AppLogger.warning('Failed to connect to WebSocket: $e',
          module: LogModule.system);
      _scheduleReconnect();
    }
  }

  Future<void> subscribeToOrder(String orderId) async {
    _activeTaxiOrderId = orderId;
    final channelName = ApiEndpoints.taxiOrderChannel(orderId);
    _activeSubscribedChannels.add(channelName);
    if (_isConnected && _socketId != null) {
      await _subscribeChannel(channelName);
    }
  }

  void unsubscribeFromOrder(String orderId) {
    final channelName = ApiEndpoints.taxiOrderChannel(orderId);
    _activeSubscribedChannels.remove(channelName);
    if (_activeTaxiOrderId == orderId) {
      _activeTaxiOrderId = null;
    }
    _sendPusherEvent('pusher:unsubscribe', {'channel': channelName});
  }

  void sendLocationUpdate({
    required double lat,
    required double lng,
    double? bearing,
    double? speed,
  }) {
    if (!_isConnected || _currentDriverId == null) return;

    final channelName = ApiEndpoints.driverChannel(_currentDriverId!);
    _sendPusherEvent(
      'client-DRIVER_LOCATION_UPDATE',
      {
        'lat': lat,
        'lng': lng,
        'bearing': bearing,
        'speed_kmh': speed,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      },
      channel: channelName,
    );
  }

  Future<void> _handleMessage(dynamic rawMessage) async {
    try {
      final parsed = jsonDecode(rawMessage.toString()) as Map<String, dynamic>;
      final event = parsed['event']?.toString() ?? '';
      final dataStr = parsed['data'];
      Map<String, dynamic> data = {};
      if (dataStr is String) {
        try {
          data = jsonDecode(dataStr) as Map<String, dynamic>;
        } catch (_) {}
      } else if (dataStr is Map<String, dynamic>) {
        data = dataStr;
      }

      switch (event) {
        case 'pusher:connection_established':
          _socketId = data['socket_id']?.toString();
          _isConnected = true;
          _reconnectAttempts = 0;
          _reconnectTimer?.cancel();
          AppLogger.info('WebSocket connected. Socket ID: $_socketId',
              module: LogModule.system);

          // Always ensure driver channel is in active registry
          if (_currentDriverId != null) {
            final driverChannel = ApiEndpoints.driverChannel(_currentDriverId!);
            _activeSubscribedChannels.add(driverChannel);
          }

          // Automatically re-subscribe to all active channels
          for (final channelName in _activeSubscribedChannels) {
            await _subscribeChannel(channelName);
          }
          break;

        case 'pusher:ping':
          _sendPusherEvent('pusher:pong', {});
          break;

        case 'NEW_TAXI_ORDER_OFFER':
        case 'TaxiOfferCreated':
          if (_isDuplicateMessage(event, data)) return;
          _taxiOfferController.add(data);
          break;

        case 'BOOKING_UPDATE':
        case 'BookingCreated':
        case 'BookingCancelledByPassenger':
          if (_isDuplicateMessage(event, data)) return;
          _bookingUpdateController.add(data);
          break;

        case 'ORDER_CANCELLED_BY_PASSENGER':
        case 'OrderCancelled':
          if (_isDuplicateMessage(event, data)) return;
          _orderCancelledController.add(data);
          break;

        case 'ORDER_STATUS_CHANGED':
        case 'TaxiOrderStatusChanged':
          if (_isDuplicateMessage(event, data)) return;
          _orderStatusChangedController.add(data);
          break;

        case 'WALLET_DEPOSITED':
        case 'WalletDeposited':
          if (_isDuplicateMessage(event, data)) return;
          _walletDepositedController.add(data);
          break;

        default:
          break;
      }
    } catch (e) {
      AppLogger.warning('WebSocket message parse error: $e',
          module: LogModule.system);
    }
  }

  /// Deduplicates server pushed events within a sliding window.
  bool _isDuplicateMessage(String event, Map<String, dynamic> data) {
    final messageId = data['id']?.toString() ??
        data['order_id']?.toString() ??
        data['booking_id']?.toString() ??
        data['transaction_id']?.toString() ??
        data['created_at']?.toString() ??
        '';

    final signature = '$event:$messageId';
    if (messageId.isNotEmpty && _recentMessageSignatures.contains(signature)) {
      AppLogger.debug('Dropped duplicate WebSocket event: $signature',
          module: LogModule.system);
      return true;
    }

    if (signature.isNotEmpty) {
      _recentMessageSignatures.add(signature);
      if (_recentMessageSignatures.length > _maxRecentSignatures) {
        _recentMessageSignatures.removeAt(0);
      }
    }
    return false;
  }

  Future<void> _subscribeChannel(String channelName) async {
    if (_socketId == null) return;

    try {
      final authResponse = await _apiClient.post(
        ApiEndpoints.broadcastAuth,
        data: {
          'socket_id': _socketId,
          'channel_name': channelName,
        },
      );

      final authSig = authResponse.data?['auth']?.toString();
      if (authSig != null) {
        _sendPusherEvent('pusher:subscribe', {
          'channel': channelName,
          'auth': authSig,
        });
        AppLogger.info('Subscribed to channel: $channelName',
            module: LogModule.system);
      }
    } catch (e) {
      AppLogger.warning('Channel authorization failed for $channelName: $e',
          module: LogModule.system);
    }
  }

  void _sendPusherEvent(String event, Map<String, dynamic> data,
      {String? channel}) {
    if (_channel == null) return;
    try {
      final payload = {
        'event': event,
        'data': data,
        if (channel != null) 'channel': channel,
      };
      _channel!.sink.add(jsonEncode(payload));
    } catch (e) {
      AppLogger.warning('Failed to send WebSocket event $event: $e',
          module: LogModule.system);
    }
  }

  void _scheduleReconnect() {
    _isConnected = false;
    if (_isExplicitlyDisconnected || _currentDriverId == null) return;

    _reconnectTimer?.cancel();

    // Exponential backoff with jitter: min(1.5 * 1.8^attempts, 30s)
    final backoffSec = (1.5 * math.pow(1.8, _reconnectAttempts))
        .clamp(1.5, _maxBackoffSeconds.toDouble());
    final jitter = (math.Random().nextDouble() * 0.5) - 0.25;
    final totalDelay =
        Duration(milliseconds: ((backoffSec + jitter) * 1000).round());

    _reconnectAttempts++;
    AppLogger.info(
      'WebSocket reconnect scheduled in ${totalDelay.inSeconds}s (attempt: $_reconnectAttempts)',
      module: LogModule.system,
    );

    _reconnectTimer = Timer(totalDelay, () {
      if (_currentDriverId != null && !_isExplicitlyDisconnected) {
        connect(_currentDriverId!);
      }
    });
  }

  void _disconnectInternal() {
    _reconnectTimer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
    _isConnected = false;
  }

  void disconnect() {
    _isExplicitlyDisconnected = true;
    _currentDriverId = null;
    _activeTaxiOrderId = null;
    _activeSubscribedChannels.clear();
    _recentMessageSignatures.clear();
    _disconnectInternal();
  }

  void dispose() {
    disconnect();
    _connectivitySubscription?.cancel();
    _taxiOfferController.close();
    _bookingUpdateController.close();
    _orderCancelledController.close();
    _orderStatusChangedController.close();
    _walletDepositedController.close();
  }
}
