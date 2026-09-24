import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'location_service.dart';

enum AppPermissionType {
  foregroundLocation,
  backgroundLocation,
  notifications,
  camera,
  gallery,
}

enum AppPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  restricted,
  limited,
  serviceDisabled,
}

enum CannotGoOnlineReason {
  unauthenticated,
  accountBlocked,
  verificationRequired,
  locationPermissionMissing,
  locationPermissionPermanentlyDenied,
  locationServiceDisabled,
  backgroundLocationMissing,
}

/// Centralized permission service managing runtime permission requests,
/// pre-request rationale dialogs, driver online gate, and navigation to device system settings.
class PermissionService {
  PermissionService({
    required LocationService locationService,
  }) : _locationService = locationService;

  final LocationService _locationService;

  /// Checks status for a specific permission type
  Future<AppPermissionStatus> checkStatus(AppPermissionType type) async {
    switch (type) {
      case AppPermissionType.foregroundLocation:
      case AppPermissionType.backgroundLocation:
        final status = await _locationService.checkAndRequestPermission();
        return switch (status) {
          LocationPermissionStatus.granted => AppPermissionStatus.granted,
          LocationPermissionStatus.denied => AppPermissionStatus.denied,
          LocationPermissionStatus.permanentlyDenied =>
            AppPermissionStatus.permanentlyDenied,
          LocationPermissionStatus.serviceDisabled =>
            AppPermissionStatus.serviceDisabled,
        };
      default:
        // Default to granted for platforms/permissions managed by native plugins
        return AppPermissionStatus.granted;
    }
  }

  /// Driver Online Gate: strictly verifies all operational prerequisites
  /// before allowing the driver state to switch to Online.
  Future<CannotGoOnlineReason?> validateCanGoOnline({
    required bool isAuthenticated,
    required String verificationStatus,
  }) async {
    if (!isAuthenticated) {
      return CannotGoOnlineReason.unauthenticated;
    }

    final normalizedStatus = verificationStatus.toLowerCase().trim();
    if (normalizedStatus == 'rejected' ||
        normalizedStatus == 'blocked' ||
        normalizedStatus == 'suspended') {
      return CannotGoOnlineReason.accountBlocked;
    }
    if (normalizedStatus != 'approved') {
      return CannotGoOnlineReason.verificationRequired;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return CannotGoOnlineReason.locationServiceDisabled;
    }

    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return CannotGoOnlineReason.locationPermissionPermanentlyDenied;
    }
    if (permission == LocationPermission.denied) {
      final requested = await Geolocator.requestPermission();
      if (requested == LocationPermission.deniedForever) {
        return CannotGoOnlineReason.locationPermissionPermanentlyDenied;
      }
      if (requested == LocationPermission.denied) {
        return CannotGoOnlineReason.locationPermissionMissing;
      }
    }

    return null; // All prerequisites met
  }

  /// Displays an explanatory modal before invoking the OS permission prompt.
  Future<bool> showPermissionRationaleDialog({
    required BuildContext context,
    required String title,
    required String explanation,
    String confirmLabel = 'Ruxsat berish',
    String cancelLabel = 'Keyinroq',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.security, color: Color(0xFF10B981)),
            const SizedBox(width: 8),
            Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold))),
          ],
        ),
        content: Text(
          explanation,
          style: const TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child:
                Text(cancelLabel, style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child:
                Text(confirmLabel, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Opens the device settings page for this app when permission is permanently denied.
  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  /// Opens device GPS location settings.
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();
}
