import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

enum StatusBadgeType {
  confirmed,
  inProgress,
  completed,
  cancelled,
  pending,
  neutral,
}

/// Reusable status badge with contextual icon and color styling.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.type,
    this.icon,
  });

  final String label;
  final StatusBadgeType type;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData defaultIcon;

    switch (type) {
      case StatusBadgeType.confirmed:
        bg = AppColors.successLight;
        fg = AppColors.success;
        defaultIcon = Icons.check_circle_rounded;
        break;
      case StatusBadgeType.inProgress:
        bg = AppColors.primaryLight;
        fg = AppColors.primary;
        defaultIcon = Icons.directions_car_rounded;
        break;
      case StatusBadgeType.completed:
        bg = AppColors.successLight;
        fg = AppColors.success;
        defaultIcon = Icons.task_alt_rounded;
        break;
      case StatusBadgeType.cancelled:
        bg = AppColors.errorLight;
        fg = AppColors.error;
        defaultIcon = Icons.cancel_rounded;
        break;
      case StatusBadgeType.pending:
        bg = AppColors.warningLight;
        fg = AppColors.warning;
        defaultIcon = Icons.hourglass_top_rounded;
        break;
      case StatusBadgeType.neutral:
        bg = AppColors.surfaceSubtleLight;
        fg = AppColors.textSecondaryLight;
        defaultIcon = Icons.info_outline_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs + 2,
        vertical: AppSpacing.xxs + 1,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.borderPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon ?? defaultIcon,
            size: 14,
            color: fg,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
