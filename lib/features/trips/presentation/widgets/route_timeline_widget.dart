import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/cyrillic_converter.dart';
import '../../domain/entities/trip_entity.dart';

class RouteTimelineWidget extends StatelessWidget {
  const RouteTimelineWidget({
    super.key,
    required this.currentStatus,
  });

  final TripProgressStatus currentStatus;

  static const List<TripProgressStatus> _stages = [
    TripProgressStatus.bookingConfirmed,
    TripProgressStatus.driverPreparing,
    TripProgressStatus.driverArrived,
    TripProgressStatus.passengerPickedUp,
    TripProgressStatus.tripStarted,
    TripProgressStatus.nearDestination,
    TripProgressStatus.tripCompleted,
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localeCode = Localizations.localeOf(context).languageCode;
    final currentIndex = _stages.indexOf(currentStatus);

    return Column(
      children: List.generate(_stages.length, (index) {
        final status = _stages[index];
        final stageInfo =
            CyrillicConverter.localizedTripStage(status, localeCode);
        final title = stageInfo['title'] ?? '';
        final desc = stageInfo['desc'] ?? '';

        final isPassed = index <= (currentIndex == -1 ? 0 : currentIndex);
        final isCurrent = index == currentIndex;
        final isLast = index == _stages.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Indicator Line & Circle
              Column(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? AppColors.primary
                          : (isPassed
                              ? AppColors.success
                              : (isDark
                                  ? AppColors.surfaceSubtleDark
                                  : AppColors.borderLight)),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCurrent
                            ? AppColors.primaryLight
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: isPassed && !isCurrent
                        ? const Icon(Icons.check, size: 12, color: Colors.white)
                        : null,
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: isPassed && index < currentIndex
                            ? AppColors.success
                            : (isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: AppSpacing.md),
              // Text Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight:
                              isCurrent ? FontWeight.w800 : FontWeight.w600,
                          color: isCurrent
                              ? AppColors.primary
                              : (isPassed
                                  ? (isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight)
                                  : (isDark
                                      ? AppColors.textTertiaryDark
                                      : AppColors.textTertiaryLight)),
                        ),
                      ),
                      Text(
                        desc,
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
