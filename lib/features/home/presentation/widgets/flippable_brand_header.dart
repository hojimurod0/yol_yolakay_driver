import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Clean, text-only Brand Header displaying "Yo'l-Yo'lakay TAXI".
class FlippableBrandHeader extends StatelessWidget {
  const FlippableBrandHeader({
    super.key,
    required this.isDark,
  });

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Yo\'l-Yo\'lakay',
          style: AppTypography.displayMedium.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: -0.5,
            color: isDark ? Colors.white : AppColors.charcoalBlack,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.taxiYellow,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'TAXI',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              color: AppColors.charcoalBlack,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}
