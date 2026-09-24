import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NetworkStatus { online, offline, restored }

class NetworkConnectivityNotifier extends StateNotifier<NetworkStatus> {
  NetworkConnectivityNotifier({bool autoInit = true})
      : super(NetworkStatus.online) {
    if (autoInit) {
      _init();
    }
  }

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _wasOffline = false;
  bool _isChecking = false;

  Timer? _initialCheckTimer;

  void _init() {
    // Defer initial connectivity check to allow the UI and first frame to render smoothly
    _initialCheckTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) _checkStatus();
    });

    // Listen to network changes safely
    try {
      _subscription = _connectivity.onConnectivityChanged.listen(
        (results) {
          _evaluateResults(results);
        },
        onError: (error) {
          if (mounted) state = NetworkStatus.online;
        },
      );
    } catch (_) {
      if (mounted) state = NetworkStatus.online;
    }
  }

  Future<void> _checkStatus() async {
    if (_isChecking || !mounted) return;
    _isChecking = true;
    try {
      final results = await _connectivity.checkConnectivity().timeout(
            const Duration(seconds: 2),
            onTimeout: () => [ConnectivityResult.other],
          );
      await _evaluateResults(results);
    } catch (_) {
      if (mounted) state = NetworkStatus.online;
    } finally {
      _isChecking = false;
    }
  }

  Future<void> _evaluateResults(List<ConnectivityResult> results) async {
    final hasPhysicalConnection = results.any(
      (r) => r != ConnectivityResult.none,
    );

    if (!hasPhysicalConnection) {
      _wasOffline = true;
      if (mounted) state = NetworkStatus.offline;
      return;
    }

    // Active internet check with short timeout
    final hasInternet = await _hasActiveInternet();
    if (!mounted) return;

    if (!hasInternet) {
      _wasOffline = true;
      state = NetworkStatus.offline;
    } else {
      if (_wasOffline) {
        _wasOffline = false;
        state = NetworkStatus.restored;
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && state == NetworkStatus.restored) {
            state = NetworkStatus.online;
          }
        });
      } else {
        state = NetworkStatus.online;
      }
    }
  }

  Future<bool> _hasActiveInternet() async {
    try {
      final lookup = await InternetAddress.lookup('google.com').timeout(
        const Duration(milliseconds: 1200),
      );
      return lookup.isNotEmpty && lookup[0].rawAddress.isNotEmpty;
    } catch (_) {
      // If DNS lookup fails or times out, assume physical status to avoid false offline banners
      return true;
    }
  }

  Future<void> retryConnection() async {
    await _checkStatus();
  }

  void forceDismiss() {
    state = NetworkStatus.online;
  }

  @override
  void dispose() {
    _initialCheckTimer?.cancel();
    _subscription?.cancel();
    super.dispose();
  }
}

final networkStatusProvider =
    StateNotifierProvider<NetworkConnectivityNotifier, NetworkStatus>((ref) {
  return NetworkConnectivityNotifier();
});
