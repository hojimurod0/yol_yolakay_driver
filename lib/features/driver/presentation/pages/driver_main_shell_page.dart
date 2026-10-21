import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

/// Floating minimalist dock bottom navigation bar for Driver App.
/// Matches Yo'l-Yo'lakay Passenger App navigation standards.
class DriverMainShellPage extends StatelessWidget {
  const DriverMainShellPage({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _onTabTapped(int index) {
    HapticFeedback.selectionClick();
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentIndex = navigationShell.currentIndex;

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Container(
            height: 68.0,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: AppRadius.borderXl,
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    context: context,
                    index: 0,
                    currentIndex: currentIndex,
                    icon: Icons.dashboard_outlined,
                    selectedIcon: Icons.dashboard_rounded,
                    label: 'Asosiy',
                    onTap: () => _onTabTapped(0),
                  ),
                  _buildNavItem(
                    context: context,
                    index: 1,
                    currentIndex: currentIndex,
                    icon: Icons.alt_route_outlined,
                    selectedIcon: Icons.alt_route_rounded,
                    label: 'Qatnovlar',
                    onTap: () => _onTabTapped(1),
                  ),
                  _buildNavItem(
                    context: context,
                    index: 2,
                    currentIndex: currentIndex,
                    icon: Icons.account_balance_wallet_outlined,
                    selectedIcon: Icons.account_balance_wallet_rounded,
                    label: 'Hamyon',
                    onTap: () => _onTabTapped(2),
                  ),
                  _buildNavItem(
                    context: context,
                    index: 3,
                    currentIndex: currentIndex,
                    icon: Icons.person_outline_rounded,
                    selectedIcon: Icons.person_rounded,
                    label: 'Profil',
                    onTap: () => _onTabTapped(3),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }


  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required int currentIndex,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isSelected = index == currentIndex;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const selectedColor = AppColors.taxiYellow;
    final unselectedColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final textColor = isSelected
        ? (isDark ? Colors.white : AppColors.textPrimaryLight)
        : unselectedColor;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderXl,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.08 : 1.0,
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeInOut,
              child: Icon(
                isSelected ? selectedIcon : icon,
                size: isSelected ? 24.0 : 22.0,
                color: isSelected ? selectedColor : unselectedColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: textColor,
                height: 1.15,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
