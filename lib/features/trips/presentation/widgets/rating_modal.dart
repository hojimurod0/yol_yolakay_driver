import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

/// Post-trip 5-star rating, review feedback tags, and written comment modal.
class RatingModal extends StatefulWidget {
  const RatingModal({
    super.key,
    required this.tripId,
    required this.driverName,
    required this.onSubmit,
  });

  final String tripId;
  final String driverName;
  final Function(int rating, String feedback, List<String> tags) onSubmit;

  @override
  State<RatingModal> createState() => _RatingModalState();
}

class _RatingModalState extends State<RatingModal> {
  int _selectedRating = 5;
  final TextEditingController _feedbackController = TextEditingController();
  final Set<String> _selectedTags = {};

  final List<String> _availableTags = [
    'Toza avtomobil',
    'Xushmuomala haydovchi',
    'O\'z vaqtida',
    'Qulay',
    'Xavfsiz haydash',
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          top: AppSpacing.xl,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.ratingTitle,
                style: AppTypography.headlineMedium.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${widget.driverName} bilan safaringizni baholang',
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 5-Star Interactive Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starIndex = index + 1;
                  final isFilled = starIndex <= _selectedRating;
                  return IconButton(
                    iconSize: 36,
                    icon: Icon(
                      isFilled ? Icons.star_rounded : Icons.star_border_rounded,
                      color: AppColors.starGold,
                    ),
                    onPressed: () =>
                        setState(() => _selectedRating = starIndex),
                  );
                }),
              ),

              const SizedBox(height: AppSpacing.md),

              // Predefined Feedback Tags
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                alignment: WrapAlignment.center,
                children: _availableTags.map((tag) {
                  final isSelected = _selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags.remove(tag);
                        }
                      });
                    },
                    selectedColor:
                        isDark ? AppColors.primary : AppColors.primaryLight,
                    backgroundColor: isDark
                        ? AppColors.surfaceSubtleDark
                        : AppColors.surfaceLight,
                  );
                }).toList(),
              ),

              const SizedBox(height: AppSpacing.lg),

              AppTextField(
                controller: _feedbackController,
                hint: l10n.ratingFeedbackHint,
                maxLines: 3,
              ),

              const SizedBox(height: AppSpacing.xl),

              AppButton(
                text: l10n.submitRating,
                onPressed: () {
                  widget.onSubmit(
                    _selectedRating,
                    _feedbackController.text.trim(),
                    _selectedTags.toList(),
                  );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
