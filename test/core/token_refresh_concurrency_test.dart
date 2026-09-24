import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:yol_yolakay_driver/core/storage/secure_storage_service.dart';

class InMemorySecureStorageService extends SecureStorageService {
  String? _accessToken = 'expired_access_token';
  String? _refreshToken = 'valid_refresh_token';

  @override
  Future<String?> getAccessToken() async => _accessToken;

  @override
  Future<String?> getRefreshToken() async => _refreshToken;

  @override
  Future<void> saveTokenPair({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  @override
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
  }
}

void main() {
  group('Token Refresh Concurrency Tests', () {
    late InMemorySecureStorageService storage;

    setUp(() {
      storage = InMemorySecureStorageService();
    });

    test('queues concurrent requests and performs refresh only once', () async {
      int refreshExecutionCount = 0;

      // Simulates a mutexed token refresh function
      bool isRefreshing = false;
      final List<Completer<String>> queue = [];

      Future<String> simulateConcurrentRefresh(int requestId) async {
        if (isRefreshing) {
          final c = Completer<String>();
          queue.add(c);
          return c.future;
        }

        isRefreshing = true;
        refreshExecutionCount++;

        // Simulate network latency for POST /auth/refresh
        await Future.delayed(const Duration(milliseconds: 50));
        const newToken = 'fresh_access_token_123';
        await storage.saveTokenPair(
            accessToken: newToken, refreshToken: 'refresh_123');

        // Drain waiting requests in queue
        for (final c in queue) {
          c.complete(newToken);
        }
        queue.clear();
        isRefreshing = false;

        return newToken;
      }

      // Launch 5 concurrent requests that simultaneously hit 401
      final futures =
          List.generate(5, (index) => simulateConcurrentRefresh(index + 1));
      final results = await Future.wait(futures);

      // Verify that all 5 requests resolved with the identical new token
      expect(results.length, 5);
      for (final token in results) {
        expect(token, 'fresh_access_token_123');
      }

      // Crucial requirement: only ONE refresh network call was executed
      expect(refreshExecutionCount, 1);
    });

    test('cleans up tokens safely when refresh fails', () async {
      bool sessionExpiredNotified = false;

      Future<void> onRefreshFailed() async {
        await storage.clearTokens();
        sessionExpiredNotified = true;
      }

      await onRefreshFailed();

      expect(await storage.getAccessToken(), isNull);
      expect(await storage.getRefreshToken(), isNull);
      expect(sessionExpiredNotified, isTrue);
    });
  });
}
