import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// One row of the side menu: icon, title, optional hint and a chevron.
class AppMenuItem {
  const AppMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
}

/// Side menu opened from the ☰ button on the map home screen.
///
/// Layout: [header] (who is signed in) → optional [highlight] card →
/// uniform [items] → log out pinned to the bottom.
class AppMenuDrawer extends StatelessWidget {
  const AppMenuDrawer({
    super.key,
    required this.header,
    required this.items,
    required this.logoutLabel,
    required this.onLogout,
    this.highlight,
  });

  final Widget header;
  final Widget? highlight;
  final List<AppMenuItem> items;
  final String logoutLabel;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Drawer(
      width: 300,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(26)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              if (highlight != null) ...[
                const SizedBox(height: 12),
                highlight!,
              ],
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    for (final item in items) AppMenuRow(item: item),
                  ],
                ),
              ),
              AppMenuRow(
                item: AppMenuItem(
                  icon: Icons.logout_rounded,
                  title: logoutLabel,
                  onTap: onLogout,
                ),
                destructive: true,
                showChevron: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppMenuRow extends StatelessWidget {
  const AppMenuRow({
    super.key,
    required this.item,
    this.destructive = false,
    this.showChevron = true,
  });

  final AppMenuItem item;
  final bool destructive;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = destructive
        ? AppColors.error
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);
    final muted =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: destructive
                    ? AppColors.error.withValues(alpha: isDark ? 0.18 : 0.08)
                    : (isDark
                        ? AppColors.surfaceSubtleDark
                        : AppColors.surfaceSubtleLight),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, size: 20, color: ink),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: ink,
                    ),
                  ),
                  if (item.subtitle != null)
                    Text(
                      item.subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.5, color: muted),
                    ),
                ],
              ),
            ),
            if (showChevron)
              Icon(Icons.chevron_right_rounded,
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiaryLight),
          ],
        ),
      ),
    );
  }
}

/// Back arrow for pages that are roots of a shell branch (no bottom bar):
/// returns to the map home screen instead of leaving the app.
class ShellBackButton extends StatelessWidget {
  const ShellBackButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      icon: const Icon(Icons.arrow_back_rounded),
      onPressed: onPressed,
    );
  }
}

/// Round floating button used over the map (☰, notifications, recenter).
class MapRoundButton extends StatelessWidget {
  const MapRoundButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.badge,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final button = Material(
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: const CircleBorder(),
      elevation: 3,
      shadowColor: Colors.black38,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(
          icon,
          color:
              isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
    );
    if (badge == null || badge == 0) return button;
    return Badge(
      label: Text('$badge'),
      backgroundColor: AppColors.taxiYellow,
      textColor: AppColors.textPrimaryLight,
      child: button,
    );
  }
}
