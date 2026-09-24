import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_avatar_initials.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/uzbek_license_plate.dart';
import '../../domain/entities/nearby_driver.dart';

/// Authentic Yandex Go style modal sheet for animated driver search and assigned driver details.
class DriverSearchingDialog extends StatefulWidget {
  const DriverSearchingDialog({
    super.key,
    required this.isAssigned,
    this.driver,
    required this.onCancel,
  });

  final bool isAssigned;
  final NearbyDriver? driver;
  final VoidCallback onCancel;

  @override
  State<DriverSearchingDialog> createState() => _DriverSearchingDialogState();
}

class _DriverSearchingDialogState extends State<DriverSearchingDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localeCode = Localizations.localeOf(context).languageCode;
    final isRu = localeCode == 'ru';

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.yandexDarkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: isDark ? AppShadows.darkLg : AppShadows.lg,
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A30) : const Color(0xFFE8E8ED),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF3E3E48) : const Color(0xFFD0D0D8),
              borderRadius: AppRadius.borderPill,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          if (!widget.isAssigned) ...[
            // Animated Radar Pulse
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = 1.0 + (_pulseController.value * 0.25);
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 80 * scale,
                      height: 80 * scale,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.yandexYellow.withValues(
                            alpha: 0.2 * (1 - _pulseController.value)),
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.yandexYellow,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.local_taxi_rounded,
                          color: AppColors.yandexBlack,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: AppSpacing.md + 4),

            Text(
              isRu ? 'Поиск водителя...' : 'Haydovchi qidirilmoqda...',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isRu
                  ? 'Подбираем ближайшую машину'
                  : 'Yaqin atrofdagi eng qulay taksi sizga biriktirilmoqda',
              style: AppTypography.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.lg),

            AppButton(
              text: isRu ? 'Отменить заказ' : 'Buyurtmani bekor qilish',
              variant: AppButtonVariant.outline,
              height: 48,
              onPressed: widget.onCancel,
            ),
          ] else if (widget.driver != null) ...[
            // Assigned Driver Details Card
            Row(
              children: [
                AppAvatarInitials(
                  name: widget.driver!.name,
                  size: 52,
                  fontSize: 18,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.driver!.name,
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.15),
                              borderRadius: AppRadius.borderPill,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded,
                                    size: 14, color: Colors.amber),
                                const SizedBox(width: 2),
                                Text(
                                  widget.driver!.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.amber,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.driver!.carModel,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      UzbekLicensePlate(
                        plateNumber: widget.driver!.licensePlate,
                        height: 22,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: isRu ? 'Позвонить' : 'Qo\'ng\'iroq',
                    variant: AppButtonVariant.taxi,
                    height: 48,
                    leadingIcon: const Icon(Icons.phone_rounded, size: 18),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '${widget.driver!.name} ga qo\'ng\'iroq qilinmoqda...'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppButton(
                    text: isRu ? 'Отмена' : 'Bekor qilish',
                    variant: AppButtonVariant.outline,
                    height: 48,
                    onPressed: widget.onCancel,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
