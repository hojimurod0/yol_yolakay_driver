import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Explicit status of each individual vehicle seat.
enum VehicleSeatStatus {
  available,
  selected,
  occupied,
  unavailable;

  String get uzbekDescription {
    switch (this) {
      case VehicleSeatStatus.available:
        return "Bu joy bo‘sh";
      case VehicleSeatStatus.selected:
        return "Bu joy tanlandi";
      case VehicleSeatStatus.occupied:
        return "Bu joy band";
      case VehicleSeatStatus.unavailable:
        return "Mavjud emas";
    }
  }

  String get russianDescription {
    switch (this) {
      case VehicleSeatStatus.available:
        return "Место свободно";
      case VehicleSeatStatus.selected:
        return "Место выбрано";
      case VehicleSeatStatus.occupied:
        return "Место занято";
      case VehicleSeatStatus.unavailable:
        return "Недоступно";
    }
  }

  Color getBackgroundColor(bool isDark) {
    switch (this) {
      case VehicleSeatStatus.available:
        return isDark ? const Color(0xFF282830) : const Color(0xFFFFFFFF);
      case VehicleSeatStatus.selected:
        return AppColors.taxiYellow;
      case VehicleSeatStatus.occupied:
        return isDark ? const Color(0xFF141416) : const Color(0xFF1F1F24);
      case VehicleSeatStatus.unavailable:
        return isDark ? const Color(0xFF1E1E22) : const Color(0xFFE5E7EB);
    }
  }

  Color getForegroundColor(bool isDark) {
    switch (this) {
      case VehicleSeatStatus.available:
        return isDark ? Colors.white : AppColors.charcoalBlack;
      case VehicleSeatStatus.selected:
        return AppColors.charcoalBlack;
      case VehicleSeatStatus.occupied:
        return Colors.white54;
      case VehicleSeatStatus.unavailable:
        return isDark ? Colors.white24 : Colors.black26;
    }
  }

  Color getBorderColor(bool isDark) {
    switch (this) {
      case VehicleSeatStatus.available:
        return isDark ? const Color(0xFF3F3F48) : const Color(0xFFD1D5DB);
      case VehicleSeatStatus.selected:
        return AppColors.taxiYellowDark;
      case VehicleSeatStatus.occupied:
        return isDark ? const Color(0xFF2A2A30) : const Color(0xFF374151);
      case VehicleSeatStatus.unavailable:
        return Colors.transparent;
    }
  }
}

/// Representation of a single interactive seat in 3D/2D space.
class VehicleSeatItem {
  const VehicleSeatItem({
    required this.seatNumber,
    required this.label,
    required this.status,
    required this.cabinX,
    required this.cabinY,
    this.priceModifier = 0,
  });

  final int seatNumber;
  final String label;
  final VehicleSeatStatus status;

  /// Normalized horizontal coordinate (-1.0 to 1.0 from cabin center).
  final double cabinX;

  /// Normalized longitudinal coordinate (-1.0 front to 1.0 back).
  final double cabinY;
  final int priceModifier;

  bool get isSelectable =>
      status == VehicleSeatStatus.available ||
      status == VehicleSeatStatus.selected;

  VehicleSeatItem copyWith({
    int? seatNumber,
    String? label,
    VehicleSeatStatus? status,
    double? cabinX,
    double? cabinY,
    int? priceModifier,
  }) {
    return VehicleSeatItem(
      seatNumber: seatNumber ?? this.seatNumber,
      label: label ?? this.label,
      status: status ?? this.status,
      cabinX: cabinX ?? this.cabinX,
      cabinY: cabinY ?? this.cabinY,
      priceModifier: priceModifier ?? this.priceModifier,
    );
  }

  static List<VehicleSeatItem> defaultSedanSeats({
    Set<int> occupiedNumbers = const {},
    Set<int> selectedNumbers = const {},
  }) {
    return [
      VehicleSeatItem(
        seatNumber: 1,
        label: "Oldi o'ng",
        status: occupiedNumbers.contains(1)
            ? VehicleSeatStatus.occupied
            : (selectedNumbers.contains(1)
                ? VehicleSeatStatus.selected
                : VehicleSeatStatus.available),
        cabinX: 0.45,
        cabinY: -0.32,
      ),
      VehicleSeatItem(
        seatNumber: 2,
        label: "Orqa chap",
        status: occupiedNumbers.contains(2)
            ? VehicleSeatStatus.occupied
            : (selectedNumbers.contains(2)
                ? VehicleSeatStatus.selected
                : VehicleSeatStatus.available),
        cabinX: -0.55,
        cabinY: 0.45,
      ),
      VehicleSeatItem(
        seatNumber: 3,
        label: "Orqa o'rta",
        status: occupiedNumbers.contains(3)
            ? VehicleSeatStatus.occupied
            : (selectedNumbers.contains(3)
                ? VehicleSeatStatus.selected
                : VehicleSeatStatus.available),
        cabinX: 0.0,
        cabinY: 0.45,
      ),
      VehicleSeatItem(
        seatNumber: 4,
        label: "Orqa o'ng",
        status: occupiedNumbers.contains(4)
            ? VehicleSeatStatus.occupied
            : (selectedNumbers.contains(4)
                ? VehicleSeatStatus.selected
                : VehicleSeatStatus.available),
        cabinX: 0.55,
        cabinY: 0.45,
      ),
    ];
  }
}
