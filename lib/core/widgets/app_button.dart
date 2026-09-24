import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_loading.dart';

enum AppButtonVariant { primary, secondary, outline, text, danger, taxi }

/// Modern, minimal Taxi CTA button with high-contrast Taxi Yellow (#FFC107) and Charcoal Black (#111111).
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isEnabled = true,
    this.leadingIcon,
    this.trailingIcon,
    this.height = AppDimensions.buttonHeightLg,
    this.width,
  });

  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isEnabled;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = (isEnabled && !isLoading) ? onPressed : null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color backgroundColor;
    Color foregroundColor;
    BorderSide? borderSide;

    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.taxi:
        backgroundColor = isEnabled
            ? AppColors.taxiYellow
            : (isDark ? const Color(0xFF2C2C30) : const Color(0xFFE5E7EB));
        foregroundColor =
            isEnabled ? AppColors.charcoalBlack : const Color(0xFF9CA3AF);
        borderSide = null;
        break;
      case AppButtonVariant.secondary:
        backgroundColor = isDark ? AppColors.surfaceSubtleDark : Colors.white;
        foregroundColor = isDark ? Colors.white : AppColors.charcoalBlack;
        borderSide = BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1.2,
        );
        break;
      case AppButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = isDark ? Colors.white : AppColors.charcoalBlack;
        borderSide = BorderSide(
          color: isDark ? Colors.white24 : AppColors.borderLight,
          width: 1.5,
        );
        break;
      case AppButtonVariant.text:
        backgroundColor = Colors.transparent;
        foregroundColor =
            isDark ? AppColors.taxiYellow : AppColors.charcoalBlack;
        borderSide = null;
        break;
      case AppButtonVariant.danger:
        backgroundColor = AppColors.error;
        foregroundColor = Colors.white;
        borderSide = null;
        break;
    }

    Widget innerContent = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading) ...[
            AppPulsingDots(
              size: 6,
              color: foregroundColor,
              spacing: 4,
            ),
            const SizedBox(width: AppSpacing.sm),
          ] else if (leadingIcon != null) ...[
            IconTheme(
              data: IconThemeData(color: foregroundColor, size: 20),
              child: leadingIcon!,
            ),
            const SizedBox(width: AppSpacing.xs + 2),
          ],
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTypography.titleMedium.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w800,
                fontSize: 15,
                letterSpacing: -0.1,
              ),
            ),
          ),
          if (!isLoading && trailingIcon != null) ...[
            const SizedBox(width: AppSpacing.xs + 2),
            IconTheme(
              data: IconThemeData(color: foregroundColor, size: 20),
              child: trailingIcon!,
            ),
          ],
        ],
      ),
    );

    return SizedBox(
      width: width ?? double.infinity,
      height: height.clamp(48.0, 56.0),
      child: ElevatedButton(
        onPressed: effectiveOnPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor:
              isDark ? const Color(0xFF2C2C30) : const Color(0xFFE5E7EB),
          elevation: (variant == AppButtonVariant.primary ||
                      variant == AppButtonVariant.taxi) &&
                  isEnabled
              ? 1
              : 0,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderMd,
            side: borderSide ?? BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        ),
        child: innerContent,
      ),
    );
  }
}
