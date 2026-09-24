import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_button.dart';

/// Professional offline screen widget with retry callback.
class NoInternetWidget extends StatelessWidget {
  const NoInternetWidget({
    super.key,
    required this.onRetry,
    this.title,
    this.message,
    this.isRetrying = false,
  });

  final VoidCallback onRetry;
  final String? title;
  final String? message;
  final bool isRetrying;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl, vertical: AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Elegant Network Disruption Illustration Badge
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isDark ? const Color(0xFF252530) : const Color(0xFFF3F4F6),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF383848)
                      : const Color(0xFFE5E7EB),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.wifi_off_rounded,
                  size: 46,
                  color: AppColors.error,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Title
            Text(
              title ?? "Internet aloqasi yo'q",
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                letterSpacing: -0.3,
                color: isDark ? Colors.white : AppColors.charcoalBlack,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),

            // Description
            Text(
              message ??
                  "Iltimos, internetingiz ulanganligini tekshiring va qayta urinib ko'ring",
              style: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                fontSize: 14,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Retry Button
            SizedBox(
              width: 220,
              child: AppButton(
                text: "Qayta urinish",
                onPressed: onRetry,
                isLoading: isRetrying,
                variant: AppButtonVariant.taxi,
                leadingIcon: const Icon(Icons.refresh_rounded, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
