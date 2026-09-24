import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations_helper.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_avatar_initials.dart';
import '../../../../core/widgets/logout_delete_modal.dart';
import '../../../../core/widgets/settings_modal.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

/// Professional, minimal, fintech-grade Profile Screen.
/// Clean visual hierarchy: Avatar & User Identity -> Quick Stats -> Grouped Account Cards -> Logout.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;
    final locale = ref.watch(localeNotifierProvider);
    final localeCode = locale.languageCode;
    final isRu = localeCode == 'ru';
    final isEn = localeCode == 'en';

    final profileState = ref.watch(profileNotifierProvider);
    final authUser = ref.watch(authNotifierProvider).user;
    final user = profileState.user ?? authUser;

    final currentTheme = ref.watch(themeNotifierProvider);

    final langName = switch (localeCode) {
      'uz' => '🇺🇿 O\'zbekcha',
      'ru' => '🇷🇺 Русский',
      'en' => '🇬🇧 English',
      _ => '🇺🇿 O\'zbekcha',
    };

    final themeName = switch (currentTheme) {
      ThemeMode.system => (isRu ? '🌓 Авто' : '🌓 Tizim'),
      ThemeMode.light => (isRu ? '☀️ Светлая' : '☀️ Yorug\''),
      ThemeMode.dark => (isRu ? '🌙 Тёмная' : '🌙 Qorong\'i'),
    };

    final fullName =
        user?.fullName.isNotEmpty == true ? user!.fullName : 'Rizo Karimov';
    final phone = user?.phoneNumber.isNotEmpty == true
        ? user!.phoneNumber
        : '+998 90 123 45 67';
    final email = user?.email ?? 'rizo.karimov@mail.uz';

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF131418) : const Color(0xFFF8F9FA),
      body: SafeArea(
        top: true,
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            110, // Generous clearance for animated bottom navigation bar
          ),
          children: [
            // 1. User Identity Header (Clean, minimal, high-contrast)
            _buildUserHeader(
              context: context,
              fullName: fullName,
              phone: phone,
              email: email,
              isDark: isDark,
              isRu: isRu,
              isEn: isEn,
            ),

            const SizedBox(height: AppSpacing.md),

            // 2. Account Summary & Quick Stats Card
            _buildStatsCard(
              isDark: isDark,
              isRu: isRu,
              isEn: isEn,
            ),

            const SizedBox(height: AppSpacing.lg),

            // 3. Group: Hisob ma'lumotlari (Account & Edit Profile)
            _buildSectionHeader(
              title: isRu
                  ? 'УЧЁТНАЯ ЗАПИСЬ'
                  : (isEn ? 'ACCOUNT' : 'HISOB MA\'LUMOTLARI'),
              isDark: isDark,
            ),
            const SizedBox(height: 6),
            _buildCardContainer(
              isDark: isDark,
              children: [
                _buildMenuTile(
                  isDark: isDark,
                  icon: Icons.person_outline_rounded,
                  iconColor: const Color(0xFF3B82F6),
                  title: isRu
                      ? 'Редактировать профиль'
                      : (isEn ? 'Edit Profile' : 'Profilni tahrirlash'),
                  subtitle: isRu
                      ? 'Имя, фамилия и контакты'
                      : (isEn
                          ? 'Name and contact info'
                          : 'Ism, familiya va kontaktlar'),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.push('/profile/edit');
                  },
                  isTop: true,
                ),
                _buildDivider(isDark),
                _buildMenuTile(
                  isDark: isDark,
                  icon: Icons.bookmark_border_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  title: isRu
                      ? 'Мои адреса'
                      : (isEn ? 'Saved Places' : 'Saqlangan manzillar'),
                  subtitle: isRu
                      ? 'Дом, работа и избранные'
                      : 'Uy, ish va sevimli joylar',
                  onTap: () => _showSavedPlacesModal(context, isDark, isRu),
                  isBottom: true,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // 4. Group: Ilova sozlamalari (Preferences)
            _buildSectionHeader(
              title: isRu
                  ? 'НАСТРОЙКИ ПРИЛОЖЕНИЯ'
                  : (isEn ? 'PREFERENCES' : 'ILOVA SOZLAMALARI'),
              isDark: isDark,
            ),
            const SizedBox(height: 6),
            _buildCardContainer(
              isDark: isDark,
              children: [
                _buildMenuTile(
                  isDark: isDark,
                  icon: Icons.language_rounded,
                  iconColor: const Color(0xFF6366F1),
                  title: l10n.language,
                  trailingText: langName,
                  onTap: () => showLanguageModal(context),
                  isTop: true,
                ),
                _buildDivider(isDark),
                _buildMenuTile(
                  isDark: isDark,
                  icon: Icons.palette_outlined,
                  iconColor: const Color(0xFFEAB308),
                  title: l10n.theme,
                  trailingText: themeName,
                  onTap: () => showThemeModal(context),
                ),
                _buildDivider(isDark),
                _buildMenuTile(
                  isDark: isDark,
                  icon: Icons.notifications_none_rounded,
                  iconColor: const Color(0xFF10B981),
                  title: isRu
                      ? 'Уведомления'
                      : (isEn ? 'Notifications' : 'Bildirishnomalar'),
                  subtitle:
                      isRu ? 'Push va SMS xabarlar' : 'Push va SMS xabarlar',
                  onTap: () => context.push('/notifications'),
                  isBottom: true,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // 5. Group: Xavfsizlik va Maxfiylik (Security & Privacy)
            _buildSectionHeader(
              title: isRu
                  ? 'БЕЗОПАСНОСТЬ'
                  : (isEn ? 'SECURITY' : 'XAVFSIZLIK VA MAXFIYLIK'),
              isDark: isDark,
            ),
            const SizedBox(height: 6),
            _buildCardContainer(
              isDark: isDark,
              children: [
                _buildMenuTile(
                  isDark: isDark,
                  icon: Icons.security_rounded,
                  iconColor: const Color(0xFF14B8A6),
                  title: isRu
                      ? 'Безопасность аккаунта'
                      : (isEn ? 'Account Security' : 'Hisob xavfsizligi'),
                  subtitle: isRu
                      ? 'Сессии и аутентификация'
                      : 'Sessiyalar va autentifikatsiya',
                  onTap: () => _showSecurityDialog(context, isDark, isRu),
                  isTop: true,
                ),
                _buildDivider(isDark),
                _buildMenuTile(
                  isDark: isDark,
                  icon: Icons.privacy_tip_outlined,
                  iconColor: const Color(0xFF8B5CF6),
                  title: isRu
                      ? 'Политика конфиденциальности'
                      : 'Maxfiylik siyosati',
                  onTap: () => _showPrivacyPolicyDialog(context, isDark, isRu),
                  isBottom: true,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // 6. Group: Yordam va Ma'lumot (Support & Info)
            _buildSectionHeader(
              title:
                  isRu ? 'ПОДДЕРЖКА' : (isEn ? 'SUPPORT' : 'YORDAM VA ALOQA'),
              isDark: isDark,
            ),
            const SizedBox(height: 6),
            _buildCardContainer(
              isDark: isDark,
              children: [
                _buildMenuTile(
                  isDark: isDark,
                  icon: Icons.headset_mic_outlined,
                  iconColor: const Color(0xFF06B6D4),
                  title: isRu
                      ? 'Служба заботы 24/7'
                      : (isEn
                          ? 'Support 24/7'
                          : 'Qo\'llab-quvvatlash xizmati 24/7'),
                  subtitle: isRu
                      ? 'Оператор билан алоқа'
                      : 'Tezkor yordam va murojaatlar',
                  onTap: () => context.push('/support'),
                  isTop: true,
                ),
                _buildDivider(isDark),
                _buildMenuTile(
                  isDark: isDark,
                  icon: Icons.info_outline_rounded,
                  iconColor: const Color(0xFF64748B),
                  title: isRu
                      ? 'О сервисе'
                      : (isEn ? 'About App' : 'Ilova haqida'),
                  trailingText: 'v1.0.0',
                  onTap: () => _showAboutDialog(context, isDark, isRu),
                  isBottom: true,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // 7. Group: Logout Button
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1F26) : Colors.white,
                borderRadius: AppRadius.borderXl,
                border: Border.all(
                  color: AppColors.error.withValues(alpha: isDark ? 0.35 : 0.2),
                ),
                boxShadow: isDark ? AppShadows.darkSm : AppShadows.sm,
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.borderXl),
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color:
                        AppColors.error.withValues(alpha: isDark ? 0.16 : 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.error,
                    size: 20,
                  ),
                ),
                title: Text(
                  l10n.logout,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.error,
                  size: 22,
                ),
                onTap: () {
                  HapticFeedback.lightImpact();
                  showLogoutDeleteAccountModal(context, ref);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader({
    required BuildContext context,
    required String fullName,
    required String phone,
    required String email,
    required bool isDark,
    required bool isRu,
    required bool isEn,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1D24) : Colors.white,
        borderRadius: AppRadius.borderXl,
        border: Border.all(
          color: isDark ? const Color(0xFF282932) : AppColors.borderLight,
        ),
        boxShadow: isDark ? AppShadows.darkSm : AppShadows.sm,
      ),
      child: Row(
        children: [
          // Avatar with subtle yellow ring & edit badge
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.taxiYellow,
                    width: 2.2,
                  ),
                ),
                child: AppAvatarInitials(
                  name: fullName,
                  size: 58,
                  fontSize: 22,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => context.push('/profile/edit'),
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.taxiYellow,
                      border: Border.all(
                        color: isDark ? const Color(0xFF1C1D24) : Colors.white,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      size: 11,
                      color: AppColors.charcoalBlack,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: AppSpacing.md),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        fullName,
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                          color:
                              isDark ? Colors.white : AppColors.charcoalBlack,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.verified_rounded,
                      color: Color(0xFF22C55E),
                      size: 17,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  phone,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFFA0A0AB)
                        : AppColors.textSecondaryLight,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark
                        ? const Color(0xFF70707C)
                        : AppColors.textTertiaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard({
    required bool isDark,
    required bool isRu,
    required bool isEn,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1D24) : Colors.white,
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: isDark ? const Color(0xFF282932) : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          _buildStatItem(
            title: '14 ta',
            label: isRu ? 'Поездок' : (isEn ? 'Rides' : 'Safarlar'),
            icon: Icons.directions_car_rounded,
            iconColor: AppColors.taxiYellowDark,
            isDark: isDark,
          ),
          Container(
            width: 1,
            height: 32,
            color: isDark ? const Color(0xFF2E2E38) : AppColors.borderLight,
          ),
          _buildStatItem(
            title: '5.0 ★',
            label: isRu ? 'Рейтинг' : (isEn ? 'Rating' : 'Reyting'),
            icon: Icons.star_rounded,
            iconColor: const Color(0xFFF59E0B),
            isDark: isDark,
          ),
          Container(
            width: 1,
            height: 32,
            color: isDark ? const Color(0xFF2E2E38) : AppColors.borderLight,
          ),
          _buildStatItem(
            title: isRu ? 'Активен' : 'Faol',
            label: isRu ? 'Статус' : (isEn ? 'Status' : 'Holat'),
            icon: Icons.verified_user_outlined,
            iconColor: const Color(0xFF22C55E),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String title,
    required String label,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
  }) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.charcoalBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? const Color(0xFF8E8E98)
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required bool isDark}) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: isDark ? const Color(0xFF70707C) : const Color(0xFF9CA3AF),
        ),
      ),
    );
  }

  Widget _buildCardContainer(
      {required bool isDark, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1D24) : Colors.white,
        borderRadius: AppRadius.borderXl,
        border: Border.all(
          color: isDark ? const Color(0xFF282932) : AppColors.borderLight,
        ),
        boxShadow: isDark ? AppShadows.darkSm : AppShadows.sm,
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 52,
      color: isDark ? const Color(0xFF24252E) : const Color(0xFFF1F3F5),
    );
  }

  Widget _buildMenuTile({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
    String? subtitle,
    String? trailingText,
    bool isTop = false,
    bool isBottom = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: isTop ? const Radius.circular(20) : Radius.zero,
          bottom: isBottom ? const Radius.circular(20) : Radius.zero,
        ),
      ),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: isDark ? 0.16 : 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 19),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: isDark ? Colors.white : AppColors.charcoalBlack,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 11.5,
                color: isDark
                    ? const Color(0xFF8E8E98)
                    : AppColors.textSecondaryLight,
              ),
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null) ...[
            Text(
              trailingText,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? const Color(0xFFA0A0AB)
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Icon(
            Icons.chevron_right_rounded,
            color: isDark ? const Color(0xFF62626E) : const Color(0xFF9CA3AF),
            size: 20,
          ),
        ],
      ),
      onTap: onTap,
    );
  }

  void _showSavedPlacesModal(BuildContext context, bool isDark, bool isRu) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF18181E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF383842)
                          : const Color(0xFFD4D4D8),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  isRu ? 'Сохраненные адреса' : 'Saqlangan manzillar',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: AppSpacing.md),
                ListTile(
                  leading: const Icon(Icons.home_rounded,
                      color: AppColors.taxiYellowDark),
                  title: Text(isRu ? 'Дом' : 'Uy'),
                  subtitle: const Text('Toshkent, Chilonzor 9-mavze'),
                  trailing: const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF22C55E), size: 18),
                ),
                ListTile(
                  leading:
                      const Icon(Icons.work_rounded, color: Color(0xFF3B82F6)),
                  title: Text(isRu ? 'Работа' : 'Ishxona'),
                  subtitle: const Text('Toshkent, Amir Temur shoh ko\'chasi'),
                  trailing: const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF22C55E), size: 18),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.add_location_alt_outlined, size: 18),
                    label: Text(isRu
                        ? 'Добавить новый адрес'
                        : 'Yangi manzil qo\'shish'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.borderMd),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSecurityDialog(BuildContext context, bool isDark, bool isRu) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1F26) : Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
        title: Row(
          children: [
            const Icon(Icons.security_rounded, color: Color(0xFF14B8A6)),
            const SizedBox(width: 8),
            Text(
              isRu ? 'Безопасность' : 'Hisob xavfsizligi',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isRu
                  ? 'Все сессии защищены сквозным шифрованием (JWT). Аутентификация осуществляется по одноразовому SMS-коду.'
                  : 'Barcha sessiyalar xavfsiz tokenlar (JWT) bilan shifrlangan. Kirish har doim bir martalik SMS-kod orqali himoyalangan.',
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? const Color(0xFFA0A0AB)
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF22C55E), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isRu
                          ? 'Текущая сессия активна и защищена'
                          : 'Joriy sessiya faol va himoyalangan',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF22C55E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('OK', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context, bool isDark, bool isRu) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1F26) : Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
        title: Text(
          isRu ? 'Конфиденциальность' : 'Maxfiylik siyosati',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Text(
          isRu
              ? 'Yo\'l-Yo\'lakay уважает конфиденциальность пользователей. Ваши персональные данные, геолокация и история поездок хранятся исключительно для выполнения заказов.'
              : 'Yo\'l-Yo\'lakay foydalanuvchilar maxfiyligini qadrlaydi. Shaxsiy ma\'lumotlar, joylashuv va qatnovlar tarixi faqat buyurtmalarni bajarish maqsadida qo\'llaniladi.',
          style: TextStyle(
            fontSize: 13,
            color:
                isDark ? const Color(0xFFA0A0AB) : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('OK', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context, bool isDark, bool isRu) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1F26) : Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
        title: const Text(
          'Yo\'l-Yo\'lakay',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Text(
          isRu
              ? 'YolYolakay — сервис междугородних поездок и такси по городам и районам Ферганской долины (Андижан, Фергана, Наманган) и Ташкента.\n\nВерсия: 1.0.0 (Production Ready)'
              : 'YolYolakay — Farg\'ona vodiysi (Andijon, Farg\'ona, Namangan) va Toshkent bo\'ylab shahar va tumanlararo qulay qatnovlar hamda taksi platformasi.\n\nVersiya: 1.0.0 (Production Ready)',
          style: TextStyle(
            fontSize: 13,
            color:
                isDark ? const Color(0xFFA0A0AB) : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(
                  color: AppColors.taxiYellowDark, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
