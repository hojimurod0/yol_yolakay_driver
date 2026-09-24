import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_spacing.dart';

/// Base Shimmer wrapper that automatically selects comfortable colors for Light and Dark themes.
class AppShimmerEffect extends StatelessWidget {
  const AppShimmerEffect({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseColor =
        isDark ? const Color(0xFF242430) : const Color(0xFFE5E7EB);
    final highlightColor =
        isDark ? const Color(0xFF353545) : const Color(0xFFF3F4F6);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: child,
    );
  }
}

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
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
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
    return AppShimmerEffect(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shift status banner skeleton
          Container(
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // 2x2 Stats Grid
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Wallet Card skeleton
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
    return AppShimmerEffect(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Tier badge, timer, price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                ShimmerBox(width: 80, height: 22, borderRadius: 6),
                ShimmerBox(width: 100, height: 24, borderRadius: 6),
              ],
            ),
            const SizedBox(height: 14),

            // Pickup address line
            Row(
              children: const [
                ShimmerBox(width: 10, height: 10, shape: BoxShape.circle),
                SizedBox(width: 8),
                Expanded(child: ShimmerBox(width: null, height: 14)),
              ],
            ),
            const SizedBox(height: 10),

            // Destination address line
            Row(
              children: const [
                ShimmerBox(width: 10, height: 10, shape: BoxShape.circle),
                SizedBox(width: 8),
                Expanded(child: ShimmerBox(width: null, height: 14)),
              ],
            ),
            const SizedBox(height: 16),

            // Action Buttons Row (Accept / Decline)
            Row(
              children: const [
                Expanded(
                    child:
                        ShimmerBox(width: null, height: 44, borderRadius: 10)),
                SizedBox(width: 10),
                Expanded(
                    flex: 2,
                    child:
                        ShimmerBox(width: null, height: 44, borderRadius: 10)),
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
    return AppShimmerEffect(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status and departure time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                ShimmerBox(width: 70, height: 20, borderRadius: 6),
                ShimmerBox(width: 110, height: 18),
              ],
            ),
            const SizedBox(height: 12),

            // Route Cities: Tashkent -> Samarkand
            Row(
              children: const [
                ShimmerBox(width: 90, height: 18),
                SizedBox(width: 8),
                ShimmerBox(width: 16, height: 16, shape: BoxShape.circle),
                SizedBox(width: 8),
                ShimmerBox(width: 100, height: 18),
              ],
            ),
            const SizedBox(height: 12),

            // Details chips
            Row(
              children: const [
                ShimmerBox(width: 90, height: 24, borderRadius: 6),
                SizedBox(width: 8),
                ShimmerBox(width: 110, height: 24, borderRadius: 6),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer skeleton for Wallet Transactions list.
class TransactionShimmer extends StatelessWidget {
  const TransactionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmerEffect(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const ShimmerBox(width: 44, height: 44, shape: BoxShape.circle),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ShimmerBox(width: 140, height: 16),
                    SizedBox(height: 6),
                    ShimmerBox(width: 90, height: 12),
                  ],
                ),
              ),
              const ShimmerBox(width: 80, height: 18),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shimmer skeleton for Driver Profile and Vehicle.
class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmerEffect(
      child: Column(
        children: [
          // Avatar + Name
          Row(
            children: [
              const ShimmerBox(width: 64, height: 64, shape: BoxShape.circle),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ShimmerBox(width: 160, height: 20),
                    SizedBox(height: 8),
                    ShimmerBox(width: 120, height: 14),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Vehicle Card
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          const SizedBox(height: 16),

          // Menu Items
          ...List.generate(
            4,
            (_) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer skeleton for Notifications list.
class NotificationShimmer extends StatelessWidget {
  const NotificationShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmerEffect(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ShimmerBox(width: 40, height: 40, shape: BoxShape.circle),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ShimmerBox(width: 180, height: 16),
                    SizedBox(height: 6),
                    ShimmerBox(width: double.infinity, height: 12),
                    SizedBox(height: 4),
                    ShimmerBox(width: 120, height: 12),
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
