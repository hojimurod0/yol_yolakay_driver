import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Modal guide for drivers to disable aggressive Android OEM battery savers
/// (Xiaomi MIUI/HyperOS, Samsung OneUI, Huawei) to prevent the background GPS/WebSocket from getting killed.
class BatteryOptimizationGuideDialog extends StatelessWidget {
  const BatteryOptimizationGuideDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const BatteryOptimizationGuideDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF191B24) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.taxiYellow.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.battery_charging_full_rounded,
                  color: AppColors.taxiYellowDark,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Fonda uzluksiz ishlash sozlamasi',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Xiaomi (Redmi) va Samsung telefonlari batareyani tejash uchun fondagi ilovalarni to\'xtatib qo\'yishi mumkin. Yangi buyurtmalarni o\'tkazib yubormaslik uchun quyidagi 2 ta sozlamani yoqing:',
            style: TextStyle(
              fontSize: 13.5,
              height: 1.45,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          _buildStepItem(
            stepNumber: '1',
            title: 'Batareya tejash: Cheklovlarsiz',
            subtitle:
                'Sozlamalar ➔ Ilovalar ➔ Yo\'l-Yo\'lakay ➔ Batareya tejash ➔ "Cheklovlarsiz" (Без ограничений / No restrictions) qilib belgilang.',
            icon: Icons.flash_on_rounded,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildStepItem(
            stepNumber: '2',
            title: 'Avto-ishga tushirish (Autostart)',
            subtitle:
                'Ilova sozlamalarida "Avto-ishga tushirish" (Автозапуск) ruxsatini yoqib qo\'ying.',
            icon: Icons.autorenew_rounded,
            isDark: isDark,
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.taxiYellow,
                foregroundColor: AppColors.charcoalBlack,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Tushundim, rahmat!',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required String stepNumber,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF222634) : const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.taxiYellowDark.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.taxiYellowDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
