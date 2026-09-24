import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';
import 'vehicle_seat_models.dart';

/// Interactive hardware-accelerated 3D Vehicle & Cabin Inspection Viewer.
/// Provides smooth 360° touch rotation, perspective depth, real-time lighting,
/// and interactive seat selection without requiring heavy native 3D assets.
class Vehicle3DViewer extends StatefulWidget {
  const Vehicle3DViewer({
    super.key,
    required this.seats,
    required this.onSeatTapped,
    required this.vehicleModel,
    this.vehicleColorName = "Oq",
    this.isRu = false,
  });

  final List<VehicleSeatItem> seats;
  final ValueChanged<VehicleSeatItem> onSeatTapped;
  final String vehicleModel;
  final String vehicleColorName;
  final bool isRu;

  @override
  State<Vehicle3DViewer> createState() => _Vehicle3DViewerState();
}

class _Vehicle3DViewerState extends State<Vehicle3DViewer>
    with SingleTickerProviderStateMixin {
  // Default camera angles for the best perspective look
  static const double _initialYaw = 0.55;
  static const double _initialPitch = 0.42;

  double _yaw = _initialYaw;
  double _pitch = _initialPitch;
  final double _scale = 1.0;

  late AnimationController _resetController;
  late Animation<double> _yawAnimation;
  late Animation<double> _pitchAnimation;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  void _resetView() {
    HapticFeedback.lightImpact();
    _yawAnimation = Tween<double>(begin: _yaw, end: _initialYaw).animate(
      CurvedAnimation(parent: _resetController, curve: Curves.easeOutCubic),
    );
    _pitchAnimation = Tween<double>(begin: _pitch, end: _initialPitch).animate(
      CurvedAnimation(parent: _resetController, curve: Curves.easeOutCubic),
    );

    _resetController.reset();
    _resetController.addListener(() {
      setState(() {
        _yaw = _yawAnimation.value;
        _pitch = _pitchAnimation.value;
      });
    });
    _resetController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top Toolbar: Model Badge, 360 Rotation Hint & Reset View
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Vehicle Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF222228)
                      : const Color(0xFFF3F4F6),
                  borderRadius: AppRadius.borderPill,
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF33333C)
                        : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.directions_car_filled_rounded,
                      size: 14,
                      color: AppColors.taxiYellow,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "${widget.vehicleModel} (${widget.vehicleColorName})",
                      style: AppTypography.labelSmall.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        color: isDark ? Colors.white : AppColors.charcoalBlack,
                      ),
                    ),
                  ],
                ),
              ),

              // Reset Camera View Button
              InkWell(
                onTap: _resetView,
                borderRadius: AppRadius.borderPill,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF25252D)
                        : const Color(0xFFF4F5F8),
                    borderRadius: AppRadius.borderPill,
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF33333E)
                          : const Color(0xFFE2E4E9),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.refresh_rounded,
                          size: 13, color: AppColors.taxiYellow),
                      const SizedBox(width: 4),
                      Text(
                        widget.isRu ? "Сброс" : "Qayta tiklash",
                        style: AppTypography.labelSmall.copyWith(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Interactive 3D Canvas
        GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              _yaw += details.delta.dx * 0.012;
              _pitch = (_pitch - details.delta.dy * 0.008).clamp(0.18, 0.78);
            });
          },
          child: Container(
            width: double.infinity,
            height: 230,
            margin: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.9,
                colors: isDark
                    ? [const Color(0xFF1E1E24), const Color(0xFF131316)]
                    : [const Color(0xFFFFFFFF), const Color(0xFFF2F4F7)],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color:
                    isDark ? const Color(0xFF282832) : const Color(0xFFE5E7EB),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                // 3D Chassis & Cabin CustomPainter
                Positioned.fill(
                  child: CustomPaint(
                    painter: _Vehicle3DCustomPainter(
                      yaw: _yaw,
                      pitch: _pitch,
                      scale: _scale,
                      seats: widget.seats,
                      isDark: isDark,
                    ),
                  ),
                ),

                // Touch & Rotate overlay hint
                Positioned(
                  bottom: 10,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.black : Colors.white)
                          .withValues(alpha: 0.7),
                      borderRadius: AppRadius.borderPill,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.sync_rounded,
                            size: 12, color: AppColors.taxiYellow),
                        const SizedBox(width: 4),
                        Text(
                          widget.isRu
                              ? "Вращайте для осмотра 360°"
                              : "360° aylantirib ko'ring",
                          style: AppTypography.labelSmall.copyWith(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Bottom Fast Seat Selection Pills for 3D View
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: widget.seats.map((seat) {
              final isSelected = seat.status == VehicleSeatStatus.selected;
              final isOccupied = seat.status == VehicleSeatStatus.occupied;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: InkWell(
                    onTap: seat.isSelectable
                        ? () {
                            HapticFeedback.selectionClick();
                            widget.onSeatTapped(seat);
                          }
                        : () {
                            HapticFeedback.heavyImpact();
                          },
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: seat.status.getBackgroundColor(isDark),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: seat.status.getBorderColor(isDark),
                          width: isSelected ? 2.0 : 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.taxiYellow
                                      .withValues(alpha: 0.35),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected
                                ? Icons.check_circle_rounded
                                : (isOccupied
                                    ? Icons.lock_outline_rounded
                                    : Icons
                                        .airline_seat_recline_normal_rounded),
                            size: 16,
                            color: seat.status.getForegroundColor(isDark),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "№ ${seat.seatNumber}",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: seat.status.getForegroundColor(isDark),
                            ),
                          ),
                          Text(
                            seat.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w600,
                              color: seat.status
                                  .getForegroundColor(isDark)
                                  .withValues(alpha: 0.75),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// 3D Geometry Painter for vehicle cabin, chassis, wheels, and seating
class _Vehicle3DCustomPainter extends CustomPainter {
  _Vehicle3DCustomPainter({
    required this.yaw,
    required this.pitch,
    required this.scale,
    required this.seats,
    required this.isDark,
  });

  final double yaw;
  final double pitch;
  final double scale;
  final List<VehicleSeatItem> seats;
  final bool isDark;

  // 3D Point projection math
  Offset _project(double x, double y, double z, Size size) {
    // 1. Yaw rotation (around Z/Vertical axis)
    final double cosY = math.cos(yaw);
    final double sinY = math.sin(yaw);
    final double x1 = x * cosY - y * sinY;
    final double y1 = x * sinY + y * cosY;

    // 2. Pitch rotation (around X/Horizontal axis)
    final double cosP = math.cos(pitch);
    final double sinP = math.sin(pitch);
    final double y2 = y1 * cosP - z * sinP;
    final double z2 = y1 * sinP + z * cosP;

    // 3. Perspective Projection
    const double cameraDistance = 350.0;
    final double factor = cameraDistance / (cameraDistance + y2 * 0.85);

    final double screenX = size.width / 2 + (x1 * 85.0 * scale) * factor;
    final double screenY = size.height / 2 + 15 - (z2 * 75.0 * scale) * factor;

    return Offset(screenX, screenY);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Paint bodyPaint = Paint()
      ..color = isDark ? const Color(0xFF222228) : const Color(0xFFE5E7EB)
      ..style = PaintingStyle.fill;

    final Paint outlinePaint = Paint()
      ..color = isDark ? const Color(0xFF383844) : const Color(0xFFB0B4BF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    final Paint accentPaint = Paint()
      ..color = AppColors.taxiYellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    final Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: isDark ? 0.45 : 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);

    // 1. Ground Ambient Shadow
    final Path groundShadow = Path()
      ..addOval(Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2 + 48),
        width: 170 * scale,
        height: 80 * scale,
      ));
    canvas.drawPath(groundShadow, shadowPaint);

    // 2. Vehicle Floor Chassis (Base polygon)
    final pFL = _project(-0.85, -1.2, -0.4, size); // Front Left
    final pFR = _project(0.85, -1.2, -0.4, size); // Front Right
    final pRR = _project(0.85, 1.2, -0.4, size); // Rear Right
    final pRL = _project(-0.85, 1.2, -0.4, size); // Rear Left

    final Path chassisPath = Path()
      ..moveTo(pFL.dx, pFL.dy)
      ..lineTo(pFR.dx, pFR.dy)
      ..lineTo(pRR.dx, pRR.dy)
      ..lineTo(pRL.dx, pRL.dy)
      ..close();
    canvas.drawPath(chassisPath, bodyPaint);
    canvas.drawPath(chassisPath, outlinePaint);

    // 3. Cabin Outline Pillars (Windshield & Roof)
    final pRoofFL = _project(-0.7, -0.4, 0.45, size);
    final pRoofFR = _project(0.7, -0.4, 0.45, size);
    final pRoofRR = _project(0.7, 0.9, 0.45, size);
    final pRoofRL = _project(-0.7, 0.9, 0.45, size);

    // Glass Windshield
    final Paint glassPaint = Paint()
      ..color = (isDark ? const Color(0xFF4C5D73) : const Color(0xFFBFD3EC))
          .withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    final Path windshield = Path()
      ..moveTo(pRoofFL.dx, pRoofFL.dy)
      ..lineTo(pRoofFR.dx, pRoofFR.dy)
      ..lineTo(pFR.dx, pFR.dy)
      ..lineTo(pFL.dx, pFL.dy)
      ..close();
    canvas.drawPath(windshield, glassPaint);
    canvas.drawPath(windshield, outlinePaint);

    // Roof Structure Rails
    final Path roofPath = Path()
      ..moveTo(pRoofFL.dx, pRoofFL.dy)
      ..lineTo(pRoofRL.dx, pRoofRL.dy)
      ..lineTo(pRoofRR.dx, pRoofRR.dy)
      ..lineTo(pRoofFR.dx, pRoofFR.dy);
    canvas.drawPath(roofPath, outlinePaint);

    // Subtle Brand Taxi Roof Strip
    final Path roofStrip = Path()
      ..moveTo(pRoofFL.dx, pRoofFL.dy)
      ..lineTo(pRoofFR.dx, pRoofFR.dy);
    canvas.drawPath(roofStrip, accentPaint);

    // 4. Driver Seat (Always Front-Left: -0.45, -0.32)
    _drawSeat3D(
      canvas: canvas,
      size: size,
      x: -0.45,
      y: -0.32,
      isDriver: true,
      status: VehicleSeatStatus.occupied,
      seatNumber: 0,
    );

    // 5. Passenger Seats in Cabin Space
    for (final seat in seats) {
      _drawSeat3D(
        canvas: canvas,
        size: size,
        x: seat.cabinX,
        y: seat.cabinY,
        isDriver: false,
        status: seat.status,
        seatNumber: seat.seatNumber,
      );
    }
  }

  void _drawSeat3D({
    required Canvas canvas,
    required Size size,
    required double x,
    required double y,
    required bool isDriver,
    required VehicleSeatStatus status,
    required int seatNumber,
  }) {
    // 3D coordinates for seat base & backrest
    const double seatW = 0.22;
    const double seatL = 0.24;

    final p1 = _project(x - seatW, y - seatL, -0.35, size);
    final p2 = _project(x + seatW, y - seatL, -0.35, size);
    final p3 = _project(x + seatW, y + seatL, -0.35, size);
    final p4 = _project(x - seatW, y + seatL, -0.35, size);

    // Backrest Top
    final bTop1 = _project(x - seatW, y + seatL, 0.25, size);
    final bTop2 = _project(x + seatW, y + seatL, 0.25, size);

    Color seatColor;
    if (isDriver) {
      seatColor = isDark ? const Color(0xFF282830) : const Color(0xFF4B5563);
    } else {
      switch (status) {
        case VehicleSeatStatus.selected:
          seatColor = AppColors.taxiYellow;
          break;
        case VehicleSeatStatus.occupied:
          seatColor =
              isDark ? const Color(0xFF141418) : const Color(0xFF1F242F);
          break;
        case VehicleSeatStatus.available:
          seatColor =
              isDark ? const Color(0xFF32323D) : const Color(0xFFFFFFFF);
          break;
        case VehicleSeatStatus.unavailable:
          seatColor =
              isDark ? const Color(0xFF1E1E22) : const Color(0xFFE5E7EB);
          break;
      }
    }

    final Paint seatBasePaint = Paint()
      ..color = seatColor
      ..style = PaintingStyle.fill;

    final Paint seatOutline = Paint()
      ..color = status == VehicleSeatStatus.selected
          ? AppColors.taxiYellowDark
          : (isDark ? const Color(0xFF4C4C58) : const Color(0xFF9CA3AF))
      ..style = PaintingStyle.stroke
      ..strokeWidth = status == VehicleSeatStatus.selected ? 2.2 : 1.2;

    // Draw Seat Cushion
    final Path cushionPath = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..lineTo(p4.dx, p4.dy)
      ..close();
    canvas.drawPath(cushionPath, seatBasePaint);
    canvas.drawPath(cushionPath, seatOutline);

    // Draw Seat Backrest
    final Path backrestPath = Path()
      ..moveTo(p4.dx, p4.dy)
      ..lineTo(p3.dx, p3.dy)
      ..lineTo(bTop2.dx, bTop2.dy)
      ..lineTo(bTop1.dx, bTop1.dy)
      ..close();
    canvas.drawPath(
      backrestPath,
      Paint()
        ..color = seatColor.withValues(alpha: 0.9)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(backrestPath, seatOutline);

    // Driver Steering Wheel Icon or Seat Number Text
    final centerOffset = Offset(
      (p1.dx + p2.dx + p3.dx + p4.dx) / 4,
      (p1.dy + p2.dy + p3.dy + p4.dy) / 4 - 3,
    );

    if (isDriver) {
      final Paint iconPaint = Paint()
        ..color = isDark ? Colors.white54 : Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8;
      canvas.drawCircle(centerOffset, 5.5, iconPaint);
    } else {
      final textSpan = TextSpan(
        text: "$seatNumber",
        style: TextStyle(
          color: status == VehicleSeatStatus.selected
              ? AppColors.charcoalBlack
              : (status == VehicleSeatStatus.occupied
                  ? Colors.white54
                  : (isDark ? Colors.white : AppColors.charcoalBlack)),
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(centerOffset.dx - textPainter.width / 2,
            centerOffset.dy - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _Vehicle3DCustomPainter oldDelegate) {
    return oldDelegate.yaw != yaw ||
        oldDelegate.pitch != pitch ||
        oldDelegate.scale != scale ||
        oldDelegate.seats != seats ||
        oldDelegate.isDark != isDark;
  }
}
