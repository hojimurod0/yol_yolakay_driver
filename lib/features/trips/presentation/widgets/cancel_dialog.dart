import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';

/// Cancellation confirmation dialog with reasons and policy details.
class CancelTripDialog extends StatefulWidget {
  const CancelTripDialog({
    super.key,
    required this.onConfirmCancel,
  });

  final ValueChanged<String> onConfirmCancel;

  @override
  State<CancelTripDialog> createState() => _CancelTripDialogState();
}

class _CancelTripDialogState extends State<CancelTripDialog> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;

    final reasons = [
      l10n.reasonChangePlans,
      l10n.reasonFoundAnother,
      l10n.reasonDriverAsked,
      l10n.reasonOther,
    ];

    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.cancelTripTitle,
              style: AppTypography.headlineMedium.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.cancelTripDesc,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ...List.generate(reasons.length, (index) {
              final reason = reasons[index];
              final isSelected = _selectedIndex == index;

              return InkWell(
                onTap: () => setState(() => _selectedIndex = index),
                borderRadius: AppRadius.borderMd,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              isSelected ? AppColors.error : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.error
                                : (isDark
                                    ? AppColors.borderDark
                                    : AppColors.borderLight),
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Center(
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          reason,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: l10n.close,
                    variant: AppButtonVariant.outline,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppButton(
                    text: l10n.confirm,
                    variant: AppButtonVariant.danger,
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onConfirmCancel(reasons[_selectedIndex]);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
