import 'dart:async';
import 'package:flutter/services.dart';
import '../utils/app_logger.dart';

/// Audio and Haptic feedback alert service for Yo'l-Yo'lakay Driver.
/// Provides immediate auditory and tactile stimulation when urgent real-time events occur
/// (e.g. new taxi orders, passenger bookings, order cancellations).
class AudioAlertService {
  AudioAlertService._();

  static final AudioAlertService instance = AudioAlertService._();

  /// Urgent alerting pattern for new incoming taxi order offers or bookings.
  /// Combines repeated heavy haptic pulses with high-priority system sound.
  Future<void> playNewOrderAlert() async {
    try {
      // 1. Play audible system alert sound
      await SystemSound.play(SystemSoundType.alert);

      // 2. High-intensity tactile pulse sequence
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 180));
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 180));
      await HapticFeedback.heavyImpact();

      AppLogger.debug('Played urgent new order audio/haptic alert',
          module: LogModule.system);
    } catch (e) {
      AppLogger.warning('Failed to play new order alert: $e',
          module: LogModule.system);
    }
  }

  /// Warning alert when a passenger cancels an active order or booking.
  Future<void> playOrderCancelledAlert() async {
    try {
      await SystemSound.play(SystemSoundType.alert);
      await HapticFeedback.vibrate();
      AppLogger.debug('Played order cancellation alert',
          module: LogModule.system);
    } catch (e) {
      AppLogger.warning('Failed to play cancellation alert: $e',
          module: LogModule.system);
    }
  }

  /// Positive feedback when an action successfully executes (e.g. order accepted, completed).
  Future<void> playSuccessAlert() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }
}
