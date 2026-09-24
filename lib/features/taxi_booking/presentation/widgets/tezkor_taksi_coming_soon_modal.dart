import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Shows the premium, animated "Tezkor Taksi — Tez kunda" bottom modal sheet.
/// Freezes the mock taxi ordering flow with a polished, fintech-grade coming soon experience.
void showTezkorTaksiModal(BuildContext context) {
  HapticFeedback.mediumImpact();
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (context) => _TezkorTaksiComingSoonSheet(isDark: isDark),
  );
}

class _TezkorTaksiComingSoonSheet extends StatefulWidget {
  final bool isDark;

  const _TezkorTaksiComingSoonSheet({required this.isDark});

  @override
  State<_TezkorTaksiComingSoonSheet> createState() =>
      _TezkorTaksiComingSoonSheetState();
}

class _TezkorTaksiComingSoonSheetState
    extends State<_TezkorTaksiComingSoonSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;
  late final Animation<double> _glowAlpha;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 0.96, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowAlpha = Tween<double>(begin: 0.25, end: 0.65).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final locale = Localizations.localeOf(context).languageCode;
    final isRu = locale == 'ru';
    final isEn = locale == 'en';

    final title = isRu
        ? 'Быстрое городское такси'
        : (isEn ? 'Fast City Taxi' : 'Tezkor Shahar Taksisi');
    final comingSoonBadge =
        isRu ? 'СКОРО' : (isEn ? 'COMING SOON' : 'TEZ KUNDA');
    final description = isRu
        ? 'Сервис междугородних поездок и посылок работает в полном объёме. Функция вызова такси по городу запускается в ближайшее время!'
        : (isEn
            ? 'Intercity ride-sharing and parcel delivery are fully operational. City taxi dispatch will launch very soon!'
            : 'Shaharlararo qatnovlar va tezkor pochta xizmati to\'liq ishlamoqda. Shahar ichida tezkor taksi chaqirish xizmati tez orada ishga tushiriladi!');

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF18181E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF282834) : const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF383842) : const Color(0xFFD4D4D8),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Animated Micro-Pulse Taxi Icon
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glowing outer aura
                    Container(
                      width: 86 * _pulseScale.value,
                      height: 86 * _pulseScale.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.taxiYellow
                            .withValues(alpha: _glowAlpha.value * 0.4),
                      ),
                    ),
                    // Inner emblem
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? const Color(0xFF242430)
                            : AppColors.primaryLight,
                        border: Border.all(
                          color: AppColors.taxiYellow,
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.taxiYellow.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.local_taxi_rounded,
                          color: AppColors.taxiYellowDark,
                          size: 34,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: AppSpacing.md),

            // "TEZ KUNDA" Pill Tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.taxiYellow
                    .withValues(alpha: isDark ? 0.18 : 0.14),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.taxiYellowDark.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.taxiYellowDark,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    comingSoonBadge,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: isDark
                          ? AppColors.taxiYellow
                          : AppColors.charcoalBlack,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // Title
            Text(
              title,
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColors.charcoalBlack,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.xs),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(
                description,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.45,
                  color: isDark
                      ? const Color(0xFFA0A0AB)
                      : AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Feature Highlights Row
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF202028) : const Color(0xFFF9FAFB),
                borderRadius: AppRadius.borderLg,
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF2E2E38)
                      : const Color(0xFFE5E7EB),
                ),
              ),
              child: Row(
                children: [
                  _buildFeatureBullet(
                    icon: Icons.bolt_rounded,
                    title: isRu ? '1-3 мин' : '1-3 daqiqa',
                    subtitle: isRu ? 'Подача авто' : 'Tezkor yetib kelish',
                    isDark: isDark,
                  ),
                  Container(
                    width: 1,
                    height: 38,
                    color: isDark
                        ? const Color(0xFF32323E)
                        : const Color(0xFFE5E7EB),
                  ),
                  _buildFeatureBullet(
                    icon: Icons.verified_outlined,
                    title: isRu ? 'Фикс. цена' : 'Shaffof narx',
                    subtitle: isRu ? 'Без сюрпризов' : 'Aniq tariflar',
                    isDark: isDark,
                  ),
                  Container(
                    width: 1,
                    height: 38,
                    color: isDark
                        ? const Color(0xFF32323E)
                        : const Color(0xFFE5E7EB),
                  ),
                  _buildFeatureBullet(
                    icon: Icons.near_me_rounded,
                    title: isRu ? 'GPS трекер' : 'Jonli xarita',
                    subtitle: isRu ? 'В реальном времени' : 'Kuzatuv',
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.taxiYellow,
                  foregroundColor: AppColors.charcoalBlack,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.borderMd),
                ),
                child: Text(
                  isRu
                      ? 'Понятно, спасибо'
                      : (isEn ? 'Got it, thanks' : 'Tushunarli, rahmat'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureBullet({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.taxiYellowDark, size: 20),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.charcoalBlack,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10.5,
              color: isDark
                  ? const Color(0xFF8E8E98)
                  : AppColors.textTertiaryLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
