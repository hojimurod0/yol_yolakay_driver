import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_responsive.dart';
import '../../../../core/theme/app_text_sizes.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/widgets/app_avatar_initials.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/battery_optimization_guide_dialog.dart';
import '../../../../core/widgets/logout_delete_modal.dart';
import '../../../../core/localization/app_localizations_helper.dart';
import '../../../../core/widgets/uzbek_license_plate.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/driver_profile_entity.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../../../../core/widgets/app_menu_drawer.dart';

class DriverProfilePage extends StatefulWidget {
  const DriverProfilePage({super.key});

  @override
  State<DriverProfilePage> createState() => _DriverProfilePageState();
}

class _DriverProfilePageState extends State<DriverProfilePage> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const LoadProfileEvent());
  }

  Future<void> _pickAndUploadAvatar() async {
    HapticFeedback.lightImpact();

    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
      );

      if (picked != null && mounted) {
        context.read<ProfileBloc>().add(UploadAvatarEvent(File(picked.path)));
      }
    } catch (_) {
      if (mounted) {
        AppSnackBar.showError(context, 'Rasm yuklashda xatolik yuz berdi');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    final themeMode = context.watch<ThemeCubit>().state;
    final hPad = AppResponsive.horizontalPadding(context);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : const Color(0xFFF8F9FA),
      appBar: AppBar(
        leading: ShellBackButton(onPressed: () => context.go('/driver/home')),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: hPad,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Haydovchi profili',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: AppTextSizes.lg,
                color: isDark ? Colors.white : AppColors.charcoalBlack,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              'Hisob va avtomobil sozlamalari',
              style: TextStyle(
                fontSize: AppTextSizes.xs,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              context
                  .read<ProfileBloc>()
                  .add(const LoadProfileEvent(refresh: true));
            },
            icon: const Icon(Icons.refresh_rounded, size: 22),
            tooltip: l10n.refresh,
          ),
          SizedBox(width: hPad / 2),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: isDark ? AppColors.borderDark : const Color(0xFFE5E7EB),
            height: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              AppSnackBar.showError(context, state.errorMessage!);
            }
          },
          builder: (context, state) {
            if (state.status == ProfileStatus.loading &&
                state.profile == null) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppResponsive.maxContentWidth,
                  ),
                  child: ListView(
                    padding: EdgeInsets.all(hPad),
                    children: const [
                      AppSkeletonDriverTripCard(),
                      SizedBox(height: 14),
                      AppSkeletonNotificationCard(),
                    ],
                  ),
                ),
              );
            }

            if (state.status == ProfileStatus.error && state.profile == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          size: 48, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text(
                        state.errorMessage ?? 'Xatolik yuz berdi',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: AppTextSizes.base,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 24),
                      AppButton(
                        text: l10n.retry,
                        width: 180,
                        onPressed: () => context
                            .read<ProfileBloc>()
                            .add(const LoadProfileEvent(refresh: true)),
                        variant: AppButtonVariant.taxi,
                      ),
                    ],
                  ),
                ),
              );
            }

            final profile = state.profile;
            if (profile == null) return const SizedBox.shrink();

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppResponsive.maxContentWidth,
                ),
                child: RefreshIndicator(
                  onRefresh: () async {
                    context
                        .read<ProfileBloc>()
                        .add(const LoadProfileEvent(refresh: true));
                  },
                  color: AppColors.taxiYellowDark,
                  backgroundColor:
                      isDark ? AppColors.surfaceDark : Colors.white,
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(hPad, 14, hPad, 120),
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    children: [
                      // 1. Driver ID Header Card
                      _buildAnimatedCardItem(
                        index: 0,
                        child: _buildHeroDriverIdCard(
                          context,
                          profile: profile,
                          isUploadingAvatar: state.isUploadingAvatar,
                          isDark: isDark,
                          l10n: l10n,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 2. Vehicle Passport Card or Add Vehicle Prompt
                      _buildAnimatedCardItem(
                        index: 1,
                        child: profile.vehicle != null
                            ? _buildVehiclePassportCard(
                                profile.vehicle!,
                                isDark: isDark,
                                l10n: l10n,
                              )
                            : _buildAddVehiclePrompt(
                                context,
                                isDark: isDark,
                                l10n: l10n,
                              ),
                      ),
                      const SizedBox(height: 14),

                      // 3. Section 1: Xizmatlar & Moliya
                      _buildAnimatedCardItem(
                        index: 2,
                        child: _buildSettingsGroup(
                          title: 'XIZMATLAR VA MOLIYA',
                          isDark: isDark,
                          children: [
                            _buildModernMenuItem(
                              icon: Icons.account_balance_wallet_rounded,
                              iconColor: const Color(0xFF10B981),
                              title: l10n.walletAndEarningsMenu,
                              subtitle: 'Balans, tushumlar va to‘lovlar',
                              onTap: () {
                                HapticFeedback.lightImpact();
                                context.push('/driver/wallet');
                              },
                              isDark: isDark,
                            ),
                            _buildMenuDivider(isDark),
                            _buildModernMenuItem(
                              icon: Icons.star_rounded,
                              iconColor: AppColors.starGold,
                              title: l10n.reviewsAndRatingMenu,
                              subtitle: 'Yo‘lovchilar baholari va sharhlari',
                              onTap: () {
                                HapticFeedback.lightImpact();
                                context.push('/driver/reviews');
                              },
                              isDark: isDark,
                            ),
                            _buildMenuDivider(isDark),
                            _buildModernMenuItem(
                              icon: Icons.notifications_rounded,
                              iconColor: const Color(0xFF3B82F6),
                              title: l10n.notificationsMenu,
                              subtitle: 'Tizim va qatnov xabarnomalari',
                              onTap: () {
                                HapticFeedback.lightImpact();
                                context.push('/driver/notifications');
                              },
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 4. Section 2: Qurilma & Ilova Sozlamalari
                      _buildAnimatedCardItem(
                        index: 3,
                        child: _buildSettingsGroup(
                          title: 'ILOVA VA SOZLAMALAR',
                          isDark: isDark,
                          children: [
                            _buildModernMenuItem(
                              icon: Icons.battery_charging_full_rounded,
                              iconColor: const Color(0xFF10B981),
                              title: 'Fonda ishlash sozlamasi (GPS)',
                              subtitle:
                                  'Xiaomi / Samsung batareya optimizatsiyasi',
                              trailingPill: 'Yo‘riqnoma',
                              onTap: () {
                                HapticFeedback.lightImpact();
                                BatteryOptimizationGuideDialog.show(context);
                              },
                              isDark: isDark,
                            ),
                            _buildMenuDivider(isDark),
                            _buildModernMenuItem(
                              icon: Icons.settings_rounded,
                              iconColor: AppColors.taxiYellowDark,
                              title: context.l10n.settings,
                              subtitle:
                                  '${context.l10n.language}, ${context.l10n.appearance.toLowerCase()}',
                              trailingPill: themeMode == ThemeMode.dark
                                  ? context.l10n.themeDarkShort
                                  : (themeMode == ThemeMode.light
                                      ? context.l10n.themeLightShort
                                      : context.l10n.themeAuto),
                              onTap: () {
                                HapticFeedback.lightImpact();
                                context.push('/settings');
                              },
                              isDark: isDark,
                            ),
                            _buildMenuDivider(isDark),
                            _buildModernMenuItem(
                              icon: Icons.lock_outline_rounded,
                              iconColor: const Color(0xFFF59E0B),
                              title: isRu
                                  ? 'Безопасность и пароль'
                                  : 'Xavfsizlik va parol',
                              subtitle: isRu
                                  ? 'Смена или установка пароля'
                                  : 'Parol o‘rnatish yoki o‘zgartirish',
                              onTap: () {
                                HapticFeedback.lightImpact();
                                context.push('/set-password');
                              },
                              isDark: isDark,
                            ),
                            _buildMenuDivider(isDark),
                            _buildModernMenuItem(
                              icon: Icons.support_agent_rounded,
                              iconColor: const Color(0xFF0EA5E9),
                              title: l10n.supportMenu,
                              subtitle: 'Operator va yordam markazi 24/7',
                              onTap: () {
                                HapticFeedback.lightImpact();
                                context.push('/driver/support');
                              },
                              isDark: isDark,
                            ),
                            _buildMenuDivider(isDark),
                            _buildModernMenuItem(
                              icon: Icons.info_outline_rounded,
                              iconColor: const Color(0xFF64748B),
                              title: isRu ? 'О приложении' : 'Ilova haqida',
                              subtitle: 'Versiya 1.0.0 • Yo‘l-Yo‘lakay',
                              onTap: () =>
                                  _showAboutModal(context, isDark, isRu),
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 5. Logout Action
                      _buildAnimatedCardItem(
                        index: 4,
                        child: _buildLogoutCard(context,
                            isDark: isDark, l10n: l10n),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Staggered micro-animation wrapper for profile cards
  Widget _buildAnimatedCardItem({
    required Widget child,
    required int index,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 320 + (index * 70)),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, value, _) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 16 * (1.0 - value)),
            child: child,
          ),
        );
      },
    );
  }

  /// Driver Profile Header Card (Clean, modern, matching User app aesthetics)
  Widget _buildHeroDriverIdCard(
    BuildContext context, {
    required DriverProfileEntity profile,
    required bool isUploadingAvatar,
    required bool isDark,
    required AppLocalizations l10n,
  }) {
    final cardBg = isDark ? const Color(0xFF13151D) : Colors.white;
    final borderCol =
        isDark ? const Color(0xFF232733) : const Color(0xFFE5E7EB);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderCol, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          // Avatar with Camera Tap Trigger
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(2.5),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.taxiYellow,
                ),
                child: AppAvatarInitials(
                  name: profile.fullName.isNotEmpty
                      ? profile.fullName
                      : 'Haydovchi',
                  avatarUrl: profile.avatarUrl,
                  size: 60,
                  fontSize: 22,
                ),
              ),
              if (isUploadingAvatar)
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.taxiYellow,
                      ),
                    ),
                  ),
                ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickAndUploadAvatar,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppColors.taxiYellow,
                      shape: BoxShape.circle,
                      border: Border.all(color: cardBg, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 13,
                      color: AppColors.charcoalBlack,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),

          // Name, Verified Badge, Phone Number
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        profile.fullName.isNotEmpty
                            ? profile.fullName
                            : 'Haydovchi',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppTextSizes.lg,
                          fontWeight: FontWeight.w800,
                          color:
                              isDark ? Colors.white : AppColors.charcoalBlack,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    if (profile.verificationStatus == 'approved') ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.verified_rounded,
                        color: AppColors.taxiYellowDark,
                        size: 18,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  profile.phone,
                  style: TextStyle(
                    fontSize: AppTextSizes.sm,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),

          // Quick Refresh / Sync icon
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              context
                  .read<ProfileBloc>()
                  .add(const LoadProfileEvent(refresh: true));
            },
            icon: const Icon(Icons.sync_rounded, size: 20),
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
            tooltip: 'Yangilash',
          ),
        ],
      ),
    );
  }

  /// Vehicle Passport Card with authentic Uzbek license plate & comfort badge
  Widget _buildVehiclePassportCard(
    DriverVehicleEntity vehicle, {
    required bool isDark,
    required AppLocalizations l10n,
  }) {
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final borderCol = isDark ? AppColors.borderDark : const Color(0xFFE5E7EB);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderCol, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.taxiYellow.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.directions_car_rounded,
                      color: AppColors.taxiYellowDark,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Biriktirilgan avtomobil',
                    style: TextStyle(
                      fontSize: AppTextSizes.sm,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.charcoalBlack,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.taxiYellow.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  vehicle.comfortClass.toUpperCase(),
                  style: const TextStyle(
                    fontSize: AppTextSizes.xxs,
                    fontWeight: FontWeight.w900,
                    color: AppColors.charcoalBlack,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${vehicle.make} ${vehicle.model}',
                      style: TextStyle(
                        fontSize: AppTextSizes.base,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.charcoalBlack,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Rangi: ${vehicle.color} • Yili: ${vehicle.year}',
                      style: TextStyle(
                        fontSize: AppTextSizes.xs,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              // Uzbek License Plate
              UzbekLicensePlate(
                plateNumber: vehicle.licensePlate,
                height: 28,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddVehiclePrompt(
    BuildContext context, {
    required bool isDark,
    required AppLocalizations l10n,
  }) {
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final borderCol = isDark ? AppColors.borderDark : const Color(0xFFE5E7EB);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderCol, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.taxiYellow.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.directions_car_filled_rounded,
              color: AppColors.taxiYellowDark,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Avtomobil ma’lumotlari',
                  style: TextStyle(
                    fontSize: AppTextSizes.sm,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.charcoalBlack,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Avtomobil hali biriktirilmagan',
                  style: TextStyle(
                    fontSize: AppTextSizes.xs,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              context.push('/verification');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.taxiYellow,
              foregroundColor: AppColors.charcoalBlack,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Qo‘shish',
              style: TextStyle(
                fontSize: AppTextSizes.xs,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup({
    required String title,
    required bool isDark,
    required List<Widget> children,
  }) {
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final borderCol = isDark ? AppColors.borderDark : const Color(0xFFE5E7EB);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: AppTextSizes.xs,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderCol, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildModernMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    String? trailingPill,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: iconColor.withValues(alpha: 0.14),
        highlightColor: iconColor.withValues(alpha: 0.06),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: AppTextSizes.sm,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.charcoalBlack,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: AppTextSizes.xs,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailingPill != null) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF232733)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    trailingPill,
                    style: TextStyle(
                      fontSize: AppTextSizes.xxs,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white70 : AppColors.charcoalBlack,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 58,
      color: isDark ? const Color(0xFF232733) : const Color(0xFFF3F4F6),
    );
  }

  Widget _buildLogoutCard(
    BuildContext context, {
    required bool isDark,
    required AppLocalizations l10n,
  }) {
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final borderCol = isDark ? AppColors.borderDark : const Color(0xFFE5E7EB);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderCol, width: 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            showLogoutDeleteAccountModal(context);
          },
          borderRadius: BorderRadius.circular(18),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout_rounded,
                  color: AppColors.error,
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  'Tizimdan chiqish',
                  style: TextStyle(
                    fontSize: AppTextSizes.sm,
                    fontWeight: FontWeight.w800,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAboutModal(BuildContext context, bool isDark, bool isRu) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF191B24) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.taxiYellow.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_taxi_rounded,
                  color: AppColors.taxiYellowDark,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Yo‘l-Yo‘lakay Driver',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              const Text(
                'Versiya 1.0.0 (Release 2026)',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Text(
                isRu
                    ? 'Профессиональное приложение для водителей междугороднего и городского такси Республики Узбекистан.'
                    : 'O‘zbekiston Respublikasi bo‘ylab shaharlararo va shahar ichi haydovchilari uchun maxsus professional ilova.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.4,
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.taxiYellow,
                    foregroundColor: AppColors.charcoalBlack,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Yopish',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
