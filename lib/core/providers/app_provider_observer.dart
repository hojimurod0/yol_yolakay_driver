import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/app_logger.dart';

/// Riverpod [ProviderObserver] that logs provider state changes and errors in debug mode.
class AppProviderObserver extends ProviderObserver {
  const AppProviderObserver();

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    // Disabled verbose state logging to eliminate GC frame drops and logcat saturation
  }

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    final name = provider.name ?? provider.runtimeType.toString();
    AppLogger.error(
      'Provider Failure in $name',
      module: LogModule.state,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
