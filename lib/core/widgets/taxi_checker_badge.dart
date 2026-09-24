import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Authentic Taxi Checkerboard "TAXI" Badge.
/// Renders standard taxi checker squares in Taxi Yellow (#FFC107) and Charcoal Black (#111111).
class TaxiCheckerBadge extends StatelessWidget {
  const TaxiCheckerBadge({
    super.key,
    this.height = 26,
    this.fontSize = 12.5,
  });

  final double height;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.charcoalBlack,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.taxiYellow.withValues(alpha: 0.8),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.taxiYellow.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left Checker Pattern Strip
            _buildCheckerStrip(4),

            // TAXI Bold Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: Text(
                'TAXI',
                style: TextStyle(
                  color: AppColors.taxiYellow,
                  fontWeight: FontWeight.w900,
                  fontSize: fontSize,
                  letterSpacing: 1.2,
                  height: 1.1,
                ),
              ),
            ),

            // Right Checker Pattern Strip
            _buildCheckerStrip(4),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckerStrip(int columns) {
    return SizedBox(
      height: height,
      width: columns * 4.5,
      child: CustomPaint(
        painter: _TaxiCheckerPainter(columns: columns),
      ),
    );
  }
}

class _TaxiCheckerPainter extends CustomPainter {
  const _TaxiCheckerPainter({required this.columns});
  final int columns;

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / columns;
    final cellHeight = size.height / 2;

    final yellowPaint = Paint()..color = AppColors.taxiYellow;
    final charcoalPaint = Paint()..color = AppColors.charcoalBlack;

    for (int col = 0; col < columns; col++) {
      for (int row = 0; row < 2; row++) {
        final isEven = (col + row) % 2 == 0;
        final paint = isEven ? yellowPaint : charcoalPaint;
        final rect = Rect.fromLTWH(
          col * cellWidth,
          row * cellHeight,
          cellWidth,
          cellHeight,
        );
        canvas.drawRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TaxiCheckerPainter oldDelegate) => false;
}
