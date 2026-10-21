import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';

/// Shows status screens for driver verification:
/// - 'under_review' (Tekshirilmoqda)
/// - 'approved' (Tasdiqlandi)
/// - 'action_required' (Tuzatish kerak)
/// - 'rejected' (Rad etildi)
class VerificationStatusView extends StatelessWidget {
  const VerificationStatusView({
    super.key,
    required this.status,
    required this.isDark,
    this.rejectionReason,
    this.driverName,
    required this.onEditApplication,
    required this.onRefreshStatus,
    required this.onGoHome,
  });

  final String status;
  final bool isDark;
  final String? rejectionReason;
  final String? driverName;
  final VoidCallback onEditApplication;
  final VoidCallback onRefreshStatus;
  final VoidCallback onGoHome;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case 'approved':
        return _buildApprovedState(context);
      case 'under_review':
        return _buildUnderReviewState(context);
      case 'action_required':
      case 'rejected':
      default:
        return _buildActionRequiredState(context);
    }
  }

  Widget _buildUnderReviewState(BuildContext context) {
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Icon badge
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.taxiYellow.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.taxiYellow.withValues(alpha: 0.35),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.hourglass_top_rounded,
              color: AppColors.taxiYellowDark,
              size: 44,
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Arizangiz ko\'rib chiqilmoqda',
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 22,
              color: isDark ? Colors.white : AppColors.charcoalBlack,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (driverName != null && driverName!.isNotEmpty) ...[
            Text(
              'Haydovchi: $driverName',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.taxiYellow : AppColors.taxiYellowDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
          ],
          Text(
            'Hujjatlaringiz adminga yuborildi va 12 soat ichida tekshirilib tasdiqlanadi. Hozircha sinov rejimida ilovadan to\'liq foydalanishingiz mumkin.',
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),

          // Stepper Timeline Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tekshiruv bosqichlari',
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.charcoalBlack,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTimelineItem(
                  icon: Icons.check_circle_rounded,
                  iconColor: AppColors.success,
                  title: '1. Ariza muvaffaqiyatli topshirildi',
                  subtitle: 'Barcha ma\'lumotlar va suratlar yuborildi',
                  isCompleted: true,
                  isLast: false,
                ),
                _buildTimelineItem(
                  icon: Icons.sync_rounded,
                  iconColor: AppColors.taxiYellowDark,
                  title: '2. Admin tekshiruvi (12 soat ichida)',
                  subtitle: 'Hujjatlar admin tomonidan ko\'rib chiqilmoqda (12 soat ichida tasdiqlanadi)',
                  isCompleted: false,
                  isActive: true,
                  isLast: false,
                ),
                _buildTimelineItem(
                  icon: Icons.verified_user_rounded,
                  iconColor: const Color(0xFF9CA3AF),
                  title: '3. Profilni faollashtirish',
                  subtitle: 'Admin tekshirib tasdiqlagach hisob to\'liq aktiv holatga o\'tadi',
                  isCompleted: false,
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Support Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF16161E) : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.support_agent_rounded,
                  color: AppColors.taxiYellowDark,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Savollaringiz bormi?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.charcoalBlack,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Qo\'llab-quvvatlash xizmati: @yol_yolakay_support',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Primary CTA: Direct entry to app
          AppButton(
            text: 'Ilovaga kirish',
            onPressed: onGoHome,
            variant: AppButtonVariant.taxi,
            height: 52,
            leadingIcon: const Icon(Icons.arrow_forward_rounded, size: 20),
          ),
          const SizedBox(height: 12),
          AppButton(
            text: 'Holatni tekshirish',
            onPressed: onRefreshStatus,
            variant: AppButtonVariant.outline,
            height: 50,
            leadingIcon: const Icon(Icons.refresh_rounded, size: 20),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onEditApplication,
            icon: const Icon(Icons.edit_note_rounded, size: 20),
            label: const Text(
              'Arizani tahrirlash',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovedState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.35),
                  width: 2.5,
                ),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 52,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Arizangiz tasdiqlandi!',
              style: AppTypography.headlineLarge.copyWith(
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppColors.charcoalBlack,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Tabriklaymiz! Sizning haydovchilik profilingiz to\'liq tekshiruvdan o\'tdi. Endi navbatga chiqib, yo\'lovchilar buyurtmalarini qabul qilishingiz mumkin.',
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),
            AppButton(
              text: 'Buyurtmalarni qabul qilish',
              onPressed: onGoHome,
              variant: AppButtonVariant.taxi,
              height: 54,
              trailingIcon: const Icon(Icons.arrow_forward_rounded, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionRequiredState(BuildContext context) {
    final isActionRequired = status == 'action_required';
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Icon(
              isActionRequired
                  ? Icons.drive_file_rename_outline_rounded
                  : Icons.cancel_outlined,
              color: AppColors.error,
              size: 44,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isActionRequired
                ? 'Arizada tuzatish talab qilinadi'
                : 'Arizangiz rad etildi',
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 22,
              color: isDark ? Colors.white : AppColors.charcoalBlack,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            isActionRequired
                ? 'Hujjatlaringizda quyidagi noaniqlik aniqlandi. Iltimos, xatolikni tuzatib qayta yuboring:'
                : 'Afsuski, arizangiz quyidagi sababga ko\'ra qabul qilinmadi:',
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Rejection Reason Highlight Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tuzatish sababi:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.red.shade300 : AppColors.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  rejectionReason?.isNotEmpty == true
                      ? rejectionReason!
                      : 'Sabab ko\'rsatilmadi. Iltimos, ma\'lumotlar va hujjatlarni qayta tekshirib yuboring.',
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.45,
                    color: isDark ? Colors.white : AppColors.charcoalBlack,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Instruction Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.taxiYellowDark,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Siz avval kiritgan barcha ma\'lumotlar saqlab qolingan. Faqat xato ko\'rsatilgan qismni yangilab qayta topshiring.',
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.4,
                      color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          AppButton(
            text: 'Arizani tahrirlash va qayta topshirish',
            onPressed: onEditApplication,
            variant: AppButtonVariant.taxi,
            height: 52,
            leadingIcon: const Icon(Icons.edit_rounded, size: 20),
          ),
          const SizedBox(height: 12),
          AppButton(
            text: 'Asosiy ekranga qaytish',
            onPressed: onGoHome,
            variant: AppButtonVariant.outline,
            height: 50,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isCompleted,
    bool isActive = false,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: iconColor, width: 1.5),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: isCompleted
                        ? AppColors.success
                        : (isDark ? AppColors.borderDark : AppColors.borderLight),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isActive || isCompleted
                          ? FontWeight.w800
                          : FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.charcoalBlack,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
