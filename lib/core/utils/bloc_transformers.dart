import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Production-ready BLoC Event Transformers for idempotency and concurrency protection.

/// Discards any incoming events while the previous event is still executing.
/// Ideal for financial operations, OTP submission, shift toggles, and trip status updates.
EventTransformer<E> droppableTransformer<E>() {
  return (events, mapper) {
    return Stream<E>.multi((controller) {
      bool isProcessing = false;
      StreamSubscription<E>? subscription;

      subscription = events.listen(
        (event) {
          if (!isProcessing) {
            isProcessing = true;
            mapper(event).listen(
              controller.add,
              onError: controller.addError,
              onDone: () {
                isProcessing = false;
              },
            );
          }
        },
        onError: controller.addError,
        onDone: controller.close,
      );

      controller.onCancel = () {
        subscription?.cancel();
      };
    });
  };
}

/// Debounces incoming events with a given duration.
/// Ideal for search query inputs, map pan updates, and high-frequency slider changes.
EventTransformer<E> debounceTransformer<E>(Duration duration) {
  return (events, mapper) {
    Timer? timer;
    return Stream<E>.multi((controller) {
      StreamSubscription<E>? subscription;

      subscription = events.listen(
        (event) {
          timer?.cancel();
          timer = Timer(duration, () {
            mapper(event).listen(
              controller.add,
              onError: controller.addError,
            );
          });
        },
        onError: controller.addError,
        onDone: () {
          timer?.cancel();
          controller.close();
        },
      );

      controller.onCancel = () {
        timer?.cancel();
        subscription?.cancel();
      };
    });
  };
}
