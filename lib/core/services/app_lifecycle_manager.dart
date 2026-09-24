import 'package:flutter/widgets.dart';
import '../utils/app_logger.dart';
import 'websocket_service.dart';

class AppLifecycleManager with WidgetsBindingObserver {
  AppLifecycleManager({
    required WebSocketService webSocketService,
    Future<void> Function()? onAppResumed,
  })  : _webSocketService = webSocketService,
        _onAppResumed = onAppResumed;

  final WebSocketService _webSocketService;
  final Future<void> Function()? _onAppResumed;
  bool _isInitialized = false;

  void initialize() {
    if (_isInitialized) return;
    _isInitialized = true;
    WidgetsBinding.instance.addObserver(this);
    AppLogger.info('AppLifecycleManager initialized', module: LogModule.system);
  }

  void dispose() {
    if (!_isInitialized) return;
    WidgetsBinding.instance.removeObserver(this);
    _isInitialized = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    AppLogger.debug('AppLifecycleState changed: $state',
        module: LogModule.system);
    switch (state) {
      case AppLifecycleState.resumed:
        _webSocketService.connect();
        _onAppResumed?.call();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }
}
