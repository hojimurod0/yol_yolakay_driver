import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// Ultra-modern pulsing / jumping 3-dot loading indicator (Telegram & Apple style).
class AppPulsingDots extends StatefulWidget {
  const AppPulsingDots({
    super.key,
    this.size = 8.0,
    this.color,
    this.spacing = 6.0,
  });

  final double size;
  final Color? color;
  final double spacing;

  @override
  State<AppPulsingDots> createState() => _AppPulsingDotsState();
}

class _AppPulsingDotsState extends State<AppPulsingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.color ?? AppColors.taxiYellowDark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final phase = (index * 0.22);
            final progress = (_controller.value - phase) % 1.0;
            final sine = math.sin(progress * math.pi);
            final scale = 0.6 + (0.55 * (sine > 0 ? sine : 0));
            final opacity = 0.35 + (0.65 * (sine > 0 ? sine : 0));

            return Container(
              margin: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
              width: widget.size * scale,
              height: widget.size * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: effectiveColor.withValues(alpha: opacity),
              ),
            );
          },
        );
      }),
    );
  }
}

/// Centralized modern loading indicator with option for Pulsing Dots or Circular Indicator.
class AppLoading extends StatelessWidget {
  const AppLoading({
    super.key,
    this.size = 28.0,
    this.color,
    this.useDots = true,
  });

  final double size;
  final Color? color;
  final bool useDots;

  @override
  Widget build(BuildContext context) {
    if (useDots) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: AppPulsingDots(
            size: size > 16 ? 10 : size * 0.4,
            color: color ?? AppColors.taxiYellowDark,
          ),
        ),
      );
    }

    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          strokeCap: StrokeCap.round,
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? AppColors.taxiYellowDark,
          ),
        ),
      ),
    );
  }
}

/// Core sweeping gradient Shimmer effect provider.
class AppShimmer extends StatefulWidget {
  const AppShimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBase =
        isDark ? const Color(0xFF1E212A) : const Color(0xFFE5E7EB);
    final defaultHighlight =
        isDark ? const Color(0xFF2E3444) : const Color(0xFFF3F4F6);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.baseColor ?? defaultBase,
                widget.highlightColor ?? defaultHighlight,
                widget.baseColor ?? defaultBase,
              ],
              stops: [
                (_controller.value - 0.3).clamp(0.0, 1.0),
                _controller.value.clamp(0.0, 1.0),
                (_controller.value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Modern Shimmer/Skeleton box placeholder.
class AppSkeletonBox extends StatelessWidget {
  const AppSkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  final double width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF222634) : const Color(0xFFE2E4E8),
        borderRadius: borderRadius ?? AppRadius.borderSm,
      ),
    );
  }
}

/// Modern Shimmer Skeleton Card matching `RideCard` (Passenger Intercity Trips).
class AppSkeletonRideCard extends StatelessWidget {
  const AppSkeletonRideCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppShimmer(
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm + 4),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: AppRadius.borderLg,
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppSkeletonBox(width: 150, height: 16),
                AppSkeletonBox(width: 80, height: 18),
              ],
            ),
            SizedBox(height: 10),
            AppSkeletonBox(width: 120, height: 14),
            SizedBox(height: 12),
            Divider(height: 1),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    AppSkeletonBox(
                        width: 32,
                        height: 32,
                        borderRadius: BorderRadius.all(Radius.circular(16))),
                    SizedBox(width: 8),
                    AppSkeletonBox(width: 95, height: 14),
                  ],
                ),
                AppSkeletonBox(
                    width: 70,
                    height: 26,
                    borderRadius: BorderRadius.all(Radius.circular(13))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Modern Shimmer Skeleton Card for Driver Radar / Trips.
class AppSkeletonDriverTripCard extends StatelessWidget {
  const AppSkeletonDriverTripCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppShimmer(
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm + 4),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: AppRadius.borderLg,
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    AppSkeletonBox(
                        width: 36,
                        height: 36,
                        borderRadius: BorderRadius.all(Radius.circular(18))),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppSkeletonBox(width: 110, height: 14),
                        SizedBox(height: 4),
                        AppSkeletonBox(width: 70, height: 11),
                      ],
                    ),
                  ],
                ),
                AppSkeletonBox(width: 75, height: 20),
              ],
            ),
            SizedBox(height: 12),
            AppSkeletonBox(width: double.infinity, height: 14),
            SizedBox(height: 6),
            AppSkeletonBox(width: 180, height: 14),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppSkeletonBox(
                    width: 90,
                    height: 24,
                    borderRadius: BorderRadius.all(Radius.circular(8))),
                AppSkeletonBox(
                    width: 110,
                    height: 32,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer skeleton for Notifications.
class AppSkeletonNotificationCard extends StatelessWidget {
  const AppSkeletonNotificationCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppShimmer(
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: AppRadius.borderMd,
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSkeletonBox(
                width: 38,
                height: 38,
                borderRadius: BorderRadius.all(Radius.circular(19))),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSkeletonBox(width: 140, height: 14),
                  SizedBox(height: 6),
                  AppSkeletonBox(width: double.infinity, height: 12),
                  SizedBox(height: 4),
                  AppSkeletonBox(width: 180, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
