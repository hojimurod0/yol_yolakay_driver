import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_loading.dart';

enum AppButtonVariant { primary, secondary, outline, text, danger, taxi }

/// Modern, minimal Taxi CTA button with high-contrast Taxi Yellow (#FFC107) and Charcoal Black (#111111).
/// Features 100ms tactile press micro-animations (AnimatedScale + AnimatedOpacity) and haptic feedback.
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isEnabled = true,
    this.usePulsingDots = true,
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
  final bool usePulsingDots;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final double height;
  final double? width;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed =
        (widget.isEnabled && !widget.isLoading) ? widget.onPressed : null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color backgroundColor;
    Color foregroundColor;
    BorderSide? borderSide;

    switch (widget.variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.taxi:
        backgroundColor = widget.isEnabled
            ? AppColors.taxiYellow
            : (isDark ? const Color(0xFF2C2C30) : const Color(0xFFE5E7EB));
        foregroundColor =
            widget.isEnabled ? AppColors.charcoalBlack : const Color(0xFF9CA3AF);
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
          width: 1.2,
        );
        break;
      case AppButtonVariant.text:
        backgroundColor = Colors.transparent;
        foregroundColor =
            isDark ? AppColors.taxiYellow : AppColors.charcoalBlack;
        borderSide = null;
        break;
      case AppButtonVariant.danger:
        backgroundColor =
            isDark ? AppColors.errorDarkBg : AppColors.errorLight;
        foregroundColor =
            isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626);
        borderSide = null;
        break;
    }

    Widget innerContent = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.isLoading) ...[
            if (widget.usePulsingDots)
              AppPulsingDots(
                size: 6,
                color: foregroundColor,
                spacing: 4,
              )
            else
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                ),
              ),
            const SizedBox(width: AppSpacing.sm),
          ] else if (widget.leadingIcon != null) ...[
            IconTheme(
              data: IconThemeData(color: foregroundColor, size: 19),
              child: widget.leadingIcon!,
            ),
            const SizedBox(width: AppSpacing.xs + 2),
          ],
          Flexible(
            child: Text(
              widget.text,
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
          if (!widget.isLoading && widget.trailingIcon != null) ...[
            const SizedBox(width: AppSpacing.xs + 2),
            IconTheme(
              data: IconThemeData(color: foregroundColor, size: 19),
              child: widget.trailingIcon!,
            ),
          ],
        ],
      ),
    );

    return AnimatedScale(
      scale: _isPressed && widget.isEnabled ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: _isPressed && widget.isEnabled ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: SizedBox(
          width: widget.width ?? double.infinity,
          height: widget.height.clamp(48.0, 56.0),
          child: Material(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(14),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: effectiveOnPressed != null
                  ? () {
                      HapticFeedback.lightImpact();
                      effectiveOnPressed();
                    }
                  : null,
              onHighlightChanged: (highlighted) {
                if (mounted && widget.isEnabled) {
                  setState(() => _isPressed = highlighted);
                }
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: borderSide != null
                      ? Border.fromBorderSide(borderSide)
                      : null,
                ),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                alignment: Alignment.center,
                child: innerContent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
