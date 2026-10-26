import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/localization/app_localizations_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_menu_drawer.dart';
import '../../../../core/widgets/logout_delete_modal.dart';
import '../../../home/presentation/bloc/home_bloc.dart';
import '../../../home/presentation/bloc/home_state.dart';
import '../../../profile/domain/entities/driver_profile_entity.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';

/// Opens the side menu from pages inside the shell (the map home's ☰ button).
final driverShellScaffoldKey = GlobalKey<ScaffoldState>();

/// Shell without a bottom bar: the map home is the hub, every other section
/// opens from the ☰ side menu and its back arrow returns to the map.
class DriverMainShellPage extends StatelessWidget {
  const DriverMainShellPage({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  static const homeBranch = 0;
  static const tripsBranch = 1;
  static const walletBranch = 2;
  static const profileBranch = 3;

  @override
  Widget build(BuildContext context) {
    final onHome = navigationShell.currentIndex == homeBranch;
    return PopScope(
      canPop: onHome,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) navigationShell.goBranch(homeBranch);
      },
      child: Scaffold(
        key: driverShellScaffoldKey,
        drawer: _DriverMenuDrawer(navigationShell: navigationShell),
        drawerEnableOpenDragGesture: onHome,
        onDrawerChanged: (open) {
          if (open) context.read<ProfileBloc>().add(const LoadProfileEvent());
        },
        body: navigationShell,
      ),
    );
  }
}

class _DriverMenuDrawer extends StatelessWidget {
  const _DriverMenuDrawer({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = context
        .select<ProfileBloc, DriverProfileEntity?>((b) => b.state.profile);
    final stats = context.select<HomeBloc, (int, int)?>((b) {
      final s = b.state;
      return s is HomeLoaded
          ? (
              s.dashboard.dailyStats.todayEarnings,
              s.dashboard.dailyStats.todayTripsCount
            )
          : null;
    });

    void close() => Navigator.of(context).pop();
    void branch(int index) {
      close();
      HapticFeedback.lightImpact();
      navigationShell.goBranch(index);
    }

    void push(String location) {
      close();
      HapticFeedback.lightImpact();
      context.push(location);
    }

    final name = profile == null
        ? l10n.menuProfileCar
        : [profile.firstName, profile.lastName]
            .where((s) => s.isNotEmpty)
            .join(' ');
    final car = profile?.vehicle;
    final ink = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final muted =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return AppMenuDrawer(
      header: InkWell(
        onTap: () => branch(DriverMainShellPage.profileBranch),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.primary,
                backgroundImage: profile?.avatarUrl != null
                    ? NetworkImage(profile!.avatarUrl!)
                    : null,
                child: profile?.avatarUrl == null
                    ? Text(
                        name.isNotEmpty
                            ? name.characters.first.toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimaryLight,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: ink,
                      ),
                    ),
                    if (profile != null)
                      Text(
                        [
                          '★ ${profile.rating.toStringAsFixed(1)}',
                          if (car != null) '${car.color} ${car.model}',
                        ].join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: muted),
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiaryLight),
            ],
          ),
        ),
      ),
      highlight: stats == null
          ? null
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => branch(DriverMainShellPage.walletBranch),
                borderRadius: BorderRadius.circular(18),
                child: Ink(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.driverTodayEarnings,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimaryLight,
                              ),
                            ),
                            Text(
                              AppCurrencyFormatter.format(stats.$1),
                              style: const TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimaryLight,
                              ),
                            ),
                            Text(
                              l10n.tripsCountPlural(stats.$2),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textPrimaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: AppColors.textPrimaryLight),
                    ],
                  ),
                ),
              ),
            ),
      items: [
        AppMenuItem(
          icon: AppConfig.commissionEnabled
              ? Icons.account_balance_wallet_outlined
              : Icons.payments_outlined,
          title: AppConfig.commissionEnabled ? 'Hamyon' : l10n.menuEarnings,
          subtitle: l10n.menuEarningsHint,
          onTap: () => branch(DriverMainShellPage.walletBranch),
        ),
        AppMenuItem(
          icon: Icons.schedule_rounded,
          title: l10n.menuTripHistory,
          onTap: () => branch(DriverMainShellPage.tripsBranch),
        ),
        AppMenuItem(
          icon: Icons.directions_car_outlined,
          title: l10n.menuProfileCar,
          subtitle: l10n.menuProfileCarHint,
          onTap: () => branch(DriverMainShellPage.profileBranch),
        ),
        AppMenuItem(
          icon: Icons.settings_outlined,
          title: l10n.settings,
          subtitle: l10n.menuSettingsHint,
          onTap: () => push('/settings'),
        ),
        AppMenuItem(
          icon: Icons.support_agent_rounded,
          title: l10n.menuHelp,
          subtitle: l10n.menuHelpHint,
          onTap: () => push('/driver/support'),
        ),
      ],
      logoutLabel: l10n.menuLogout,
      onLogout: () {
        close();
        showLogoutDeleteAccountModal(context);
      },
    );
  }
}
