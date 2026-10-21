import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Clean, informative top step indicator for the 4-step driver verification process.
class VerificationStepProgress extends StatelessWidget {
  const VerificationStepProgress({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.isDark,
    this.onStepTapped,
  });

  final int currentStep; // 0-indexed: 0, 1, 2, 3
  final int totalSteps; // 4
  final bool isDark;
  final ValueChanged<int>? onStepTapped;

  static const List<({String title, IconData icon})> _steps = [
    (title: 'Shaxsiy', icon: Icons.person_rounded),
    (title: 'Guvohnoma', icon: Icons.badge_rounded),
    (title: 'Avtomobil', icon: Icons.directions_car_rounded),
    (title: 'Tekshirish', icon: Icons.fact_check_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final activeInfo = _steps[currentStep.clamp(0, _steps.length - 1)];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Header: Name and Stage fraction
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.taxiYellow
                            .withValues(alpha: isDark ? 0.25 : 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        activeInfo.icon,
                        size: 16,
                        color: AppColors.taxiYellowDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${currentStep + 1}-bosqich: ${activeInfo.title}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppColors.charcoalBlack,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2C2C38)
                      : const Color(0xFFF1F3F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${currentStep + 1} / $totalSteps',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white70 : AppColors.charcoalBlack,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Horizontal Progress Circles & Connector Lines
          Row(
            children: List.generate(totalSteps * 2 - 1, (index) {
              if (index.isOdd) {
                // Divider line between steps
                final stepBefore = index ~/ 2;
                final isDone = stepBefore < currentStep;

                return Expanded(
                  child: Container(
                    height: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isDone
                          ? AppColors.taxiYellowDark
                          : (isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }

              // Circle Indicator for Step
              final stepIndex = index ~/ 2;
              final isCompleted = stepIndex < currentStep;
              final isCurrent = stepIndex == currentStep;

              Color circleBg;
              Color circleBorder;
              Widget circleChild;

              if (isCompleted) {
                circleBg = AppColors.success;
                circleBorder = AppColors.success;
                circleChild = const Icon(
                  Icons.check_rounded,
                  size: 14,
                  color: Colors.white,
                );
              } else if (isCurrent) {
                circleBg = AppColors.taxiYellowDark;
                circleBorder = AppColors.taxiYellowDark;
                circleChild = Text(
                  '${stepIndex + 1}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                );
              } else {
                circleBg =
                    isDark ? AppColors.surfaceSubtleDark : AppColors.surfaceSubtleLight;
                circleBorder =
                    isDark ? AppColors.borderDark : AppColors.borderLight;
                circleChild = Text(
                  '${stepIndex + 1}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
                  ),
                );
              }

              return InkWell(
                onTap: stepIndex < currentStep
                    ? () => onStepTapped?.call(stepIndex)
                    : null,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: circleBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: circleBorder, width: 1.5),
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: AppColors.taxiYellowDark
                                  .withValues(alpha: 0.35),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(child: circleChild),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
