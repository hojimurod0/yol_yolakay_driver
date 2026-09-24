import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yol_yolakay_driver/core/localization/app_localizations_helper.dart';
import 'package:yol_yolakay_driver/core/theme/app_colors.dart';
import 'package:yol_yolakay_driver/core/theme/app_radius.dart';
import 'package:yol_yolakay_driver/core/theme/app_shadows.dart';
import 'package:yol_yolakay_driver/core/theme/app_spacing.dart';
import '../../../taxi_booking/presentation/widgets/tezkor_taksi_coming_soon_modal.dart';

/// Main Shell container with stateful bottom navigation bar,
/// 60 FPS sliding active indicator, spring transitions, and "Tezkor Taksi" freeze trigger.
class MainShellPage extends ConsumerWidget {
  const MainShellPage({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _onTabTapped(BuildContext context, int index) {
    HapticFeedback.selectionClick();

    // Tab 1 is "Tezkor Taksi": Freeze real ordering flow and show "Tez kunda" micro-animation
    if (index == 1) {
      showTezkorTaksiModal(context);
      return;
    }

    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;
    final currentIndex = navigationShell.currentIndex;
    final locale = Localizations.localeOf(context).languageCode;
    final isRu = locale == 'ru';

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: RepaintBoundary(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
            child: Container(
              height: 66,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF191A20) : Colors.white,
                borderRadius: AppRadius.borderXl,
                border: Border.all(
                  color:
                      isDark ? const Color(0xFF282932) : AppColors.borderLight,
                  width: 1.2,
                ),
                boxShadow: isDark ? AppShadows.darkMd : AppShadows.bottomNav,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = constraints.maxWidth / 4;
                  // If Tab 1 is clicked it doesn't move shell branch, but if shell branch happens to be 1, indicator displays cleanly
                  final activeLeft = currentIndex * itemWidth;

                  return Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      // 1. Sliding Active Capsule Indicator (Spring easeOutCubic)
                      AnimatedPositioned(
                        left: activeLeft,
                        top: 0,
                        bottom: 0,
                        width: itemWidth,
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutCubic,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.taxiYellow.withValues(alpha: 0.12)
                                : AppColors.primaryLight,
                            borderRadius: AppRadius.borderMd,
                            border: Border.all(
                              color: AppColors.taxiYellow
                                  .withValues(alpha: isDark ? 0.35 : 0.5),
                              width: 1,
                            ),
                          ),
                        ),
                      ),

                      // 2. Tab Items Row
                      Row(
                        children: [
                          _buildNavItem(
                            context: context,
                            index: 0,
                            icon: Icons.home_outlined,
                            activeIcon: Icons.home_rounded,
                            label: l10n.navHome,
                            isSelected: currentIndex == 0,
                            isDark: isDark,
                          ),
                          _buildNavItem(
                            context: context,
                            index: 1,
                            icon: Icons.local_taxi_outlined,
                            activeIcon: Icons.local_taxi_rounded,
                            label: isRu ? 'Такси' : 'Tezkor Taksi',
                            isSelected: currentIndex == 1,
                            isDark: isDark,
                            badge: 'SOON',
                          ),
                          _buildNavItem(
                            context: context,
                            index: 2,
                            icon: Icons.directions_car_outlined,
                            activeIcon: Icons.directions_car_rounded,
                            label: l10n.navTrips,
                            isSelected: currentIndex == 2,
                            isDark: isDark,
                          ),
                          _buildNavItem(
                            context: context,
                            index: 3,
                            icon: Icons.person_outline_rounded,
                            activeIcon: Icons.person_rounded,
                            label: l10n.navProfile,
                            isSelected: currentIndex == 3,
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isSelected,
    required bool isDark,
    String? badge,
  }) {
    final activeColor = isDark ? AppColors.taxiYellow : AppColors.charcoalBlack;
    final inactiveColor =
        isDark ? const Color(0xFF888894) : const Color(0xFF6B7280);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onTabTapped(context, index),
        child: AnimatedScale(
          scale: isSelected ? 1.04 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: Icon(
                      isSelected ? activeIcon : icon,
                      key: ValueKey<bool>(isSelected),
                      color: isSelected
                          ? (isDark
                              ? AppColors.taxiYellow
                              : AppColors.taxiYellowDark)
                          : inactiveColor,
                      size: 23,
                    ),
                  ),
                  if (badge != null)
                    Positioned(
                      top: -4,
                      right: -14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.taxiYellow,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: AppColors.charcoalBlack,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  color: isSelected ? activeColor : inactiveColor,
                  letterSpacing: -0.1,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
