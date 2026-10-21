import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../di/injection.dart';
import '../localization/locale_cubit.dart';
import '../storage/secure_storage_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';

/// Displays the modern Account Management modal with distinct "Log Out" and "Delete Account" actions.
Future<void> showLogoutDeleteAccountModal(
  BuildContext context, [
  dynamic unusedRef,
]) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final locale = context.read<LocaleCubit>().state.languageCode;
  final isRu = locale == 'ru';

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (modalContext) {
      return _LogoutDeleteBottomSheet(
        isDark: isDark,
        isRu: isRu,
      );
    },
  );
}

class _LogoutDeleteBottomSheet extends StatefulWidget {
  const _LogoutDeleteBottomSheet({
    required this.isDark,
    required this.isRu,
  });

  final bool isDark;
  final bool isRu;

  @override
  State<_LogoutDeleteBottomSheet> createState() =>
      _LogoutDeleteBottomSheetState();
}

class _LogoutDeleteBottomSheetState extends State<_LogoutDeleteBottomSheet> {
  bool _isLoading = false;

  Future<void> _handleLogout() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final prefs = sl<SharedPreferences>();
      await prefs.remove('user_role');
      await prefs.remove('auth_token');
      await sl<SecureStorageService>().clearTokens();

      if (mounted) {
        context.read<AuthBloc>().add(const LogoutEvent());
      }

      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (mounted) {
        context.go('/splash');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showDeleteConfirmationStep() {
    showDialog<void>(
      context: context,
      barrierDismissible: !_isLoading,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor:
              widget.isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
          icon: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.error,
              size: 28,
            ),
          ),
          title: Text(
            widget.isRu ? 'Удалить аккаунт?' : 'Hisobni o\'chirish?',
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: widget.isDark ? Colors.white : AppColors.textPrimaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            widget.isRu
                ? 'Вы уверены, что хотите удалить аккаунт? Все ваши данные и история поездок будут стёрты без возможности восстановления.'
                : 'Haqiqatan ham hisobingizni butunlay o\'chirmoqchimisiz? Barcha ma\'lumotlaringiz va safarlar tarixi tiklab bo\'lmaydigan qilib o\'chiriladi.',
            style: AppTypography.bodyMedium.copyWith(
              color: widget.isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              fontSize: 13.5,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogCtx),
                    style: OutlinedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.borderMd),
                      side: BorderSide(
                        color: widget.isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      widget.isRu ? 'Отмена' : 'Bekor qilish',
                      style: TextStyle(
                        color: widget.isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(dialogCtx);
                      await _handleDeleteAccount();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.borderMd),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: Text(
                      widget.isRu ? 'Удалить' : 'O\'chirish',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleDeleteAccount() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final prefs = sl<SharedPreferences>();
      await prefs.clear();
      await sl<SecureStorageService>().clearTokens();

      if (mounted) {
        context.read<AuthBloc>().add(const LogoutEvent());
      }

      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (mounted) {
        context.go('/splash');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppRadius.topXl,
        border: Border.all(
          color: widget.isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        MediaQuery.of(context).padding.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: widget.isDark
                    ? AppColors.borderDarkHover
                    : const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title & Description
          Text(
            widget.isRu ? 'Управление аккаунтом' : 'Hisob boshqaruvi',
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: widget.isDark ? Colors.white : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.isRu
                ? 'Выберите необходимое действие для вашего аккаунта'
                : 'Profilingiz uchun kerakli amalni tanlang',
            style: AppTypography.bodySmall.copyWith(
              color: widget.isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.lg),

          // 1. Log Out Button Card
          _ActionCard(
            isDark: widget.isDark,
            icon: Icons.logout_rounded,
            iconColor: AppColors.taxiYellowDark,
            title: widget.isRu ? 'Выйти из аккаунта' : 'Chiqish',
            subtitle: widget.isRu
                ? 'Вы сможете войти снова в любое время'
                : 'Istalgan vaqtda qayta kirishingiz mumkin',
            isLoading: _isLoading,
            onTap: _handleLogout,
            isDestructive: false,
          ),

          const SizedBox(height: AppSpacing.sm + 4),

          // 2. Delete Account Button Card (Destructive)
          _ActionCard(
            isDark: widget.isDark,
            icon: Icons.delete_forever_rounded,
            iconColor: AppColors.error,
            title:
                widget.isRu ? 'Удалить аккаунт' : 'Hisobni butunlay o\'chirish',
            subtitle: widget.isRu
                ? 'Все данные и история будут безвозвратно удалены'
                : 'Barcha ma\'lumotlar va tarix to\'liq o\'chiriladi',
            isLoading: _isLoading,
            onTap: _showDeleteConfirmationStep,
            isDestructive: true,
          ),

          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.isDark,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.isLoading,
    required this.onTap,
    required this.isDestructive,
  });

  final bool isDark;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isLoading;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: AppRadius.borderLg,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDark
                ? (isDestructive
                    ? AppColors.error.withValues(alpha: 0.08)
                    : AppColors.surfaceSubtleDark)
                : (isDestructive
                    ? const Color(0xFFFEF2F2)
                    : const Color(0xFFF9FAFB)),
            borderRadius: AppRadius.borderLg,
            border: Border.all(
              color: isDestructive
                  ? AppColors.error.withValues(alpha: isDark ? 0.25 : 0.2)
                  : (isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: isDark ? 0.2 : 0.12),
                  shape: BoxShape.circle,
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
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                        color: isDestructive
                            ? AppColors.error
                            : (isDark ? Colors.white : AppColors.textPrimaryLight),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
