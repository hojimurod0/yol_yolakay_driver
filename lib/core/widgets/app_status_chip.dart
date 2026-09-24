import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Semantic status variant for [AppStatusChip].
enum StatusVariant {
  pending,
  approved,
  rejected,
  completed,
  cancelled,
  active,
  inProgress,
  arrived,
  online,
  offline,
}

/// Accessible, standardized status badge that combines icon + text + semantic colors.
/// Adheres strictly to WCAG accessibility guidelines by never communicating state via color alone.
class AppStatusChip extends StatelessWidget {
  const AppStatusChip({
    super.key,
    required this.label,
    required this.variant,
    this.customIcon,
    this.compact = false,
  });

  final String label;
  final StatusVariant variant;
  final IconData? customIcon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final (Color primaryColor, Color bgColor, IconData defaultIcon) =
        switch (variant) {
      StatusVariant.online => (
          AppColors.statusOnline,
          AppColors.statusOnline.withValues(alpha: 0.15),
          Icons.sensors_rounded,
        ),
      StatusVariant.offline => (
          AppColors.statusOffline,
          AppColors.statusOffline.withValues(alpha: 0.15),
          Icons.sensors_off_rounded,
        ),
      StatusVariant.pending => (
          AppColors.statusPending,
          AppColors.statusPending.withValues(alpha: 0.15),
          Icons.schedule_rounded,
        ),
      StatusVariant.approved => (
          AppColors.statusApproved,
          AppColors.statusApproved.withValues(alpha: 0.15),
          Icons.check_circle_rounded,
        ),
      StatusVariant.rejected => (
          AppColors.statusRejected,
          AppColors.statusRejected.withValues(alpha: 0.15),
          Icons.cancel_rounded,
        ),
      StatusVariant.completed => (
          AppColors.statusApproved,
          AppColors.statusApproved.withValues(alpha: 0.15),
          Icons.task_alt_rounded,
        ),
      StatusVariant.cancelled => (
          AppColors.statusRejected,
          AppColors.statusRejected.withValues(alpha: 0.15),
          Icons.do_not_disturb_on_rounded,
        ),
      StatusVariant.active || StatusVariant.inProgress => (
          AppColors.statusActive,
          AppColors.statusActive.withValues(alpha: 0.15),
          Icons.directions_car_rounded,
        ),
      StatusVariant.arrived => (
          AppColors.statusActive,
          AppColors.statusActive.withValues(alpha: 0.15),
          Icons.pin_drop_rounded,
        ),
    };

    final iconData = customIcon ?? defaultIcon;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            size: compact ? 12 : 14,
            color: primaryColor,
          ),
          SizedBox(width: compact ? 4 : 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: compact ? 11 : 12,
                fontWeight: FontWeight.w700,
                color: primaryColor,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
