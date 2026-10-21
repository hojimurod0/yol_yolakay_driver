import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import 'app_loading.dart';

export 'app_loading.dart';

/// Backward-compatible AppShimmerEffect alias pointing to lightweight custom ShaderMask AppShimmer.
typedef AppShimmerEffect = AppShimmer;

/// Generic rounded placeholder block for shimmer skeletons.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.shape = BoxShape.rectangle,
  });

  final double? width;
  final double height;
  final double borderRadius;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF222634) : const Color(0xFFE2E4E8),
        shape: shape,
        borderRadius: shape == BoxShape.circle
            ? null
            : BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Shimmer for Home Screen daily stats grid.
class HomeStatsShimmer extends StatelessWidget {
  const HomeStatsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surfaceDark : Colors.white;

    return AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 72,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: AppRadius.borderLg,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(
              4,
              (index) => Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: AppRadius.borderMd,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: AppRadius.borderLg,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer skeleton matching Taxi Radar Order Cards.
class RadarOrderCardShimmer extends StatelessWidget {
  const RadarOrderCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surfaceDark : Colors.white;

    return AppShimmer(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerBox(width: 80, height: 22, borderRadius: 6),
                ShimmerBox(width: 100, height: 24, borderRadius: 6),
              ],
            ),
            SizedBox(height: 14),
            Row(
              children: [
                ShimmerBox(width: 10, height: 10, shape: BoxShape.circle),
                SizedBox(width: 8),
                Expanded(child: ShimmerBox(width: null, height: 14)),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                ShimmerBox(width: 10, height: 10, shape: BoxShape.circle),
                SizedBox(width: 8),
                Expanded(child: ShimmerBox(width: null, height: 14)),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ShimmerBox(width: null, height: 44, borderRadius: 10),
                ),
                SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ShimmerBox(width: null, height: 44, borderRadius: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer skeleton for Intercity Rides list.
class RideCardShimmer extends StatelessWidget {
  const RideCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surfaceDark : Colors.white;

    return AppShimmer(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: AppRadius.borderLg,
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerBox(width: 120, height: 18),
                ShimmerBox(width: 70, height: 20),
              ],
            ),
            SizedBox(height: 12),
            ShimmerBox(width: 200, height: 14),
            SizedBox(height: 8),
            ShimmerBox(width: 160, height: 14),
            SizedBox(height: 12),
            Divider(height: 1),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerBox(width: 90, height: 14),
                ShimmerBox(width: 110, height: 28, borderRadius: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer for Wallet transaction history list.
class WalletHistoryShimmer extends StatelessWidget {
  const WalletHistoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surfaceDark : Colors.white;

    return AppShimmer(
      child: Column(
        children: List.generate(
          5,
          (index) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: AppRadius.borderMd,
            ),
            child: const Row(
              children: [
                ShimmerBox(width: 40, height: 40, shape: BoxShape.circle),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(width: 130, height: 14),
                      SizedBox(height: 6),
                      ShimmerBox(width: 90, height: 11),
                    ],
                  ),
                ),
                ShimmerBox(width: 80, height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shimmer for Driver Profile information card.
class DriverProfileShimmer extends StatelessWidget {
  const DriverProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surfaceDark : Colors.white;

    return AppShimmer(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: AppRadius.borderLg,
            ),
            child: const Row(
              children: [
                ShimmerBox(width: 64, height: 64, shape: BoxShape.circle),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(width: 140, height: 18),
                      SizedBox(height: 8),
                      ShimmerBox(width: 100, height: 13),
                      SizedBox(height: 8),
                      ShimmerBox(width: 70, height: 20, borderRadius: 6),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: AppRadius.borderLg,
            ),
          ),
        ],
      ),
    );
  }
}

/// Backwards compatibility aliases for driver profile and wallet shimmers
typedef ProfileShimmer = DriverProfileShimmer;
typedef TransactionShimmer = WalletHistoryShimmer;

/// Shimmer for Notifications list skeleton.
class NotificationShimmer extends StatelessWidget {
  const NotificationShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surfaceDark : Colors.white;

    return AppShimmer(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: AppRadius.borderLg,
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(width: 44, height: 44, shape: BoxShape.circle),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 160, height: 16),
                    SizedBox(height: 8),
                    ShimmerBox(width: double.infinity, height: 12),
                    SizedBox(height: 6),
                    ShimmerBox(width: 80, height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shimmer skeleton for Driver Reviews page with rating summary and reviews list.
class DriverReviewsShimmer extends StatelessWidget {
  const DriverReviewsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surfaceDark : Colors.white;

    return AppShimmer(
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // 1. Rating Summary Card Shimmer
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    ShimmerBox(width: 70, height: 42, borderRadius: 8),
                    SizedBox(height: 8),
                    ShimmerBox(width: 90, height: 14, borderRadius: 4),
                    SizedBox(height: 6),
                    ShimmerBox(width: 60, height: 12, borderRadius: 4),
                  ],
                ),
                SizedBox(width: 24),
                Expanded(
                  child: Column(
                    children: [
                      ShimmerBox(width: null, height: 10, borderRadius: 4),
                      SizedBox(height: 6),
                      ShimmerBox(width: null, height: 10, borderRadius: 4),
                      SizedBox(height: 6),
                      ShimmerBox(width: null, height: 10, borderRadius: 4),
                      SizedBox(height: 6),
                      ShimmerBox(width: null, height: 10, borderRadius: 4),
                      SizedBox(height: 6),
                      ShimmerBox(width: null, height: 10, borderRadius: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          // 2. Reviews List Items Shimmer
          ...List.generate(
            4,
            (index) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShimmerBox(width: 120, height: 15, borderRadius: 4),
                      ShimmerBox(width: 70, height: 12, borderRadius: 4),
                    ],
                  ),
                  SizedBox(height: 8),
                  ShimmerBox(width: 85, height: 14, borderRadius: 4),
                  SizedBox(height: 10),
                  ShimmerBox(width: double.infinity, height: 12, borderRadius: 4),
                  SizedBox(height: 6),
                  ShimmerBox(width: 180, height: 12, borderRadius: 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer skeleton for Support FAQ & Help tickets screen.
class SupportFaqShimmer extends StatelessWidget {
  const SupportFaqShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surfaceDark : Colors.white;

    return AppShimmer(
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Contact buttons row
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const ShimmerBox(width: 180, height: 20, borderRadius: 6),
          const SizedBox(height: 14),
          // FAQ Tiles
          ...List.generate(
            5,
            (index) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ShimmerBox(width: null, height: 14, borderRadius: 4),
                  ),
                  SizedBox(width: 16),
                  ShimmerBox(width: 16, height: 16, shape: BoxShape.circle),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer skeleton matching Intercity Driver Trip Details page.
class DriverTripDetailsShimmer extends StatelessWidget {
  const DriverTripDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return AppShimmer(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Route Header Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerBox(width: 160, height: 20, borderRadius: 6),
                    ShimmerBox(width: 80, height: 24, borderRadius: 12),
                  ],
                ),
                SizedBox(height: 14),
                ShimmerBox(width: 130, height: 14, borderRadius: 4),
                SizedBox(height: 10),
                ShimmerBox(width: 100, height: 14, borderRadius: 4),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Passengers Slot Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 140, height: 16, borderRadius: 4),
                SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ShimmerBox(width: 60, height: 60, borderRadius: 12),
                    ShimmerBox(width: 60, height: 60, borderRadius: 12),
                    ShimmerBox(width: 60, height: 60, borderRadius: 12),
                    ShimmerBox(width: 60, height: 60, borderRadius: 12),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Price and Vehicle Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerBox(width: 90, height: 14, borderRadius: 4),
                    ShimmerBox(width: 110, height: 18, borderRadius: 4),
                  ],
                ),
                SizedBox(height: 12),
                Divider(height: 1),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerBox(width: 80, height: 14, borderRadius: 4),
                    ShimmerBox(width: 130, height: 16, borderRadius: 4),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

