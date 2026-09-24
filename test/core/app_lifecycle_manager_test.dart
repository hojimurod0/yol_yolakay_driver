import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yol_yolakay_driver/core/services/app_lifecycle_manager.dart';
import 'package:yol_yolakay_driver/core/services/websocket_service.dart';

class MockWebSocketService extends Fake implements WebSocketService {
  int connectCalls = 0;

  @override
  Future<void> connect([String? driverId]) async {
    connectCalls++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppLifecycleManager Tests', () {
    late MockWebSocketService mockSocket;
    late AppLifecycleManager manager;
    int resumeCallbacks = 0;

    setUp(() {
      mockSocket = MockWebSocketService();
      resumeCallbacks = 0;
      manager = AppLifecycleManager(
        webSocketService: mockSocket,
        onAppResumed: () async {
          resumeCallbacks++;
        },
      );
    });

    test(
        'reconnects socket and triggers resume callback on AppLifecycleState.resumed',
        () {
      manager.initialize();
      manager.didChangeAppLifecycleState(AppLifecycleState.resumed);

      expect(mockSocket.connectCalls, equals(1));
      expect(resumeCallbacks, equals(1));

      manager.dispose();
    });

    test('ignores non-resumed lifecycle states', () {
      manager.initialize();
      manager.didChangeAppLifecycleState(AppLifecycleState.paused);
      manager.didChangeAppLifecycleState(AppLifecycleState.inactive);

      expect(mockSocket.connectCalls, equals(0));
      expect(resumeCallbacks, equals(0));

      manager.dispose();
    });
  });
}
