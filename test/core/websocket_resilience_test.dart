import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WebSocket Resilience & Deduplication Tests', () {
    test('calculates exponential backoff capped at 30 seconds', () {
      const maxBackoffSeconds = 30;

      Duration calculateDelay(int attempt) {
        final seconds = (1.5 * math.pow(1.8, attempt))
            .clamp(1.5, maxBackoffSeconds.toDouble());
        return Duration(milliseconds: (seconds * 1000).round());
      }

      final delay0 = calculateDelay(0);
      final delay1 = calculateDelay(1);
      final delay2 = calculateDelay(2);
      final delay3 = calculateDelay(3);
      final delay10 = calculateDelay(10);

      expect(delay0.inMilliseconds, 1500); // 1.5s
      expect(delay1.inMilliseconds, greaterThan(delay0.inMilliseconds));
      expect(delay2.inMilliseconds, greaterThan(delay1.inMilliseconds));
      expect(delay3.inMilliseconds, greaterThan(delay2.inMilliseconds));
      expect(delay10.inSeconds, maxBackoffSeconds); // Capped at 30s
    });

    test('deduplicates incoming socket messages within sliding window', () {
      final List<String> recentMessageSignatures = [];
      const int maxRecentSignatures = 200;

      bool isDuplicate(String event, String messageId) {
        final signature = '$event:$messageId';
        if (recentMessageSignatures.contains(signature)) {
          return true;
        }
        recentMessageSignatures.add(signature);
        if (recentMessageSignatures.length > maxRecentSignatures) {
          recentMessageSignatures.removeAt(0);
        }
        return false;
      }

      // First time event arrives -> should be processed
      expect(isDuplicate('NEW_TAXI_ORDER_OFFER', 'order_001'), isFalse);

      // Duplicate event arrives -> should be discarded
      expect(isDuplicate('NEW_TAXI_ORDER_OFFER', 'order_001'), isTrue);

      // Different event or different ID -> should be processed
      expect(isDuplicate('NEW_TAXI_ORDER_OFFER', 'order_002'), isFalse);
      expect(isDuplicate('BOOKING_UPDATE', 'order_001'), isFalse);
    });

    test('maintains active channel registry for reconnection', () {
      final Set<String> activeChannels = {};

      void subscribe(String channel) {
        activeChannels.add(channel);
      }

      void unsubscribe(String channel) {
        activeChannels.remove(channel);
      }

      subscribe('private-driver.drv_123');
      subscribe('private-taxi-order.ord_456');

      expect(activeChannels.length, 2);
      expect(activeChannels.contains('private-driver.drv_123'), isTrue);
      expect(activeChannels.contains('private-taxi-order.ord_456'), isTrue);

      // After completing order
      unsubscribe('private-taxi-order.ord_456');
      expect(activeChannels.length, 1);
      expect(activeChannels.contains('private-driver.drv_123'), isTrue);
    });
  });
}
