import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';
import 'vehicle_seat_models.dart';

/// Crisp 2D Top-Down vehicle cabin seat selector fallback.
/// Renders driver seat, passenger seats, steering wheel, and clear state indicators.
class Vehicle2DSeatFallback extends StatelessWidget {
  const Vehicle2DSeatFallback({
    super.key,
    required this.seats,
    required this.onSeatTapped,
    required this.vehicleModel,
    this.isRu = false,
  });

  final List<VehicleSeatItem> seats;
  final ValueChanged<VehicleSeatItem> onSeatTapped;
  final String vehicleModel;
  final bool isRu;

  VehicleSeatItem? _getSeat(int number) {
    try {
      return seats.firstWhere((s) => s.seatNumber == number);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final seat1 = _getSeat(1); // Front passenger
    final seat2 = _getSeat(2); // Rear left
    final seat3 = _getSeat(3); // Rear middle
    final seat4 = _getSeat(4); // Rear right

    return Center(
      child: Container(
        width: 280,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF18181D) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark ? const Color(0xFF2E2E38) : const Color(0xFFE5E7EB),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Vehicle Hood & Windshield Representation
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 110,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF282832)
                        : const Color(0xFFD1D5DB),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(10)),
                  ),
                ),
              ],
            ),
            Container(
              width: 190,
              height: 14,
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF22222A) : const Color(0xFFE5E7EB),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: Center(
                child: Text(
                  vehicleModel.toUpperCase(),
                  style: AppTypography.labelSmall.copyWith(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // FRONT ROW: Driver (Left) + Passenger Seat 1 (Right)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Driver Seat (Non-selectable)
                _buildDriverSeat(isDark),

                // Front Passenger Seat (Seat 1)
                if (seat1 != null)
                  _buildSeatButton(seat1, isDark)
                else
                  const SizedBox(width: 76, height: 76),
              ],
            ),

            const SizedBox(height: 16),

            // Divider / Center Console
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 3,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF2E2E38)
                        : const Color(0xFFE2E4E9),
                    borderRadius: AppRadius.borderPill,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // REAR ROW: Seat 2 (Left), Seat 3 (Middle), Seat 4 (Right)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (seat2 != null) _buildSeatButton(seat2, isDark),
                if (seat3 != null) _buildSeatButton(seat3, isDark),
                if (seat4 != null) _buildSeatButton(seat4, isDark),
              ],
            ),

            const SizedBox(height: 12),

            // Trunk Bar
            Container(
              width: 160,
              height: 6,
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF24242C) : const Color(0xFFE5E7EB),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(6)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverSeat(bool isDark) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F1F26) : const Color(0xFFEEF0F4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF33333E) : const Color(0xFFD6DAE2),
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_motorsports_rounded,
            size: 22,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
          const SizedBox(height: 4),
          Text(
            isRu ? "Водитель" : "Haydovchi",
            style: AppTypography.labelSmall.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white38 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatButton(VehicleSeatItem seat, bool isDark) {
    final bg = seat.status.getBackgroundColor(isDark);
    final fg = seat.status.getForegroundColor(isDark);
    final border = seat.status.getBorderColor(isDark);
    final isSelected = seat.status == VehicleSeatStatus.selected;

    return InkWell(
      onTap: seat.isSelectable
          ? () {
              HapticFeedback.selectionClick();
              onSeatTapped(seat);
            }
          : () {
              HapticFeedback.heavyImpact();
            },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        width: 74,
        height: 76,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: border,
            width: isSelected ? 2.2 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.taxiYellow.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : (seat.status == VehicleSeatStatus.occupied
                      ? Icons.lock_outline_rounded
                      : Icons.airline_seat_recline_normal_rounded),
              size: 22,
              color: fg,
            ),
            const SizedBox(height: 4),
            Text(
              "№ ${seat.seatNumber}",
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: fg,
              ),
            ),
            Text(
              seat.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: fg.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
