import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/uzbek_license_plate.dart';

/// Step 4: Complete Review, Consent and Final Submission.
class Step4ReviewSubmitView extends StatelessWidget {
  const Step4ReviewSubmitView({
    super.key,
    required this.isDark,
    required this.fullName,
    required this.birthDate,
    required this.userPhone,
    required this.licenseSeriesNumber,
    required this.licenseExpiryDate,
    required this.licenseCategories,
    required this.carModel,
    required this.carColor,
    required this.carYear,
    required this.plateNumber,
    required this.carSeatsCount,
    required this.hasAc,
    required this.techPassportSeriesNumber,
    required this.photos,
    required this.hasConsent,
    required this.onConsentChanged,
    required this.onEditStep,
    required this.onSubmit,
    required this.isSubmitting,
  });

  final bool isDark;

  // Personal Info
  final String fullName;
  final String birthDate;
  final String userPhone;

  // License Info
  final String licenseSeriesNumber;
  final String licenseExpiryDate;
  final List<String> licenseCategories;

  // Vehicle Info
  final String carModel;
  final String carColor;
  final String carYear;
  final String plateNumber;
  final int carSeatsCount;
  final bool hasAc;
  final String techPassportSeriesNumber;

  // Photos
  final Map<String, String> photos;

  // Consent & Actions
  final bool hasConsent;
  final ValueChanged<bool?> onConsentChanged;
  final ValueChanged<int> onEditStep;
  final VoidCallback onSubmit;
  final bool isSubmitting;

  int get _uploadedPhotosCount => [
        'driver_license_front',
        'driver_license_back',
        'tech_passport_front',
        'tech_passport_back',
        'car_front_photo',
        'car_interior_photo',
      ].where((k) => (photos[k] ?? '').isNotEmpty).length;

  bool get _hasRequiredLicensePhotos =>
      (photos['driver_license_front']?.isNotEmpty ?? false) &&
      (photos['driver_license_back']?.isNotEmpty ?? false);

  bool get _hasRequiredTechPassportPhotos =>
      (photos['tech_passport_front']?.isNotEmpty ?? false) &&
      (photos['tech_passport_back']?.isNotEmpty ?? false);

  bool get _hasRequiredCarPhotos =>
      (photos['car_front_photo']?.isNotEmpty ?? false) &&
      (photos['car_interior_photo']?.isNotEmpty ?? false);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Notice Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.taxiYellow.withValues(alpha: isDark ? 0.15 : 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.taxiYellowDark.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: AppColors.taxiYellowDark,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Ma\'lumotlarni diqqat bilan tekshiring. Yuborilgandan so\'ng moderatorlar tomonidan tasdiqlanadi.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.charcoalBlack,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 2. Summary Card 1: Shaxsiy ma'lumotlar
        _buildSummaryCard(
          title: 'Shaxsiy ma\'lumotlar',
          icon: Icons.person_rounded,
          stepIndex: 0,
          isDark: isDark,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDataRow('F.I.SH:', fullName, isDark),
              _buildDataRow('Tug\'ilgan sana:', birthDate, isDark),
              _buildDataRow('Telefon:', userPhone, isDark),
              _buildPhotoStatusRow(
                'Profil fotosurati:',
                (photos['avatar'] ?? '').isNotEmpty,
                isDark,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 3. Summary Card 2: Guvohnoma (Prava)
        _buildSummaryCard(
          title: 'Haydovchilik guvohnomasi',
          icon: Icons.badge_rounded,
          stepIndex: 1,
          isDark: isDark,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDataRow('Guvohnoma raqami:', licenseSeriesNumber, isDark),
              if (licenseExpiryDate.isNotEmpty)
                _buildDataRow('Amal muddati:', licenseExpiryDate, isDark),
              _buildDataRow(
                'Toifalar:',
                licenseCategories.join(', '),
                isDark,
              ),
              _buildPhotoStatusRow(
                'Old va orqa fotosurati:',
                _hasRequiredLicensePhotos,
                isDark,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 4. Summary Card 3: Avtomobil ma'lumotlari
        _buildSummaryCard(
          title: 'Avtomobil ma\'lumotlari',
          icon: Icons.directions_car_rounded,
          stepIndex: 2,
          isDark: isDark,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDataRow('Rusum va model:', carModel, isDark),
              _buildDataRow('Rangi va yili:', '$carColor, $carYear-yil', isDark),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Davlat raqami:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white60 : const Color(0xFF6B7280),
                    ),
                  ),
                  UzbekLicensePlate(plateNumber: plateNumber, height: 26),
                ],
              ),
              const SizedBox(height: 6),
              _buildDataRow('O\'rindiqlar soni:', '$carSeatsCount ta', isDark),
              _buildDataRow('Konditsioner:', hasAc ? 'Mavjud' : 'Yo\'q', isDark),
              _buildDataRow(
                  'Texpasport raqami:', techPassportSeriesNumber, isDark),
              _buildPhotoStatusRow(
                'Texpasport fotosuratlari:',
                _hasRequiredTechPassportPhotos,
                isDark,
              ),
              _buildPhotoStatusRow(
                'Avtomobil fotosuratlari:',
                _hasRequiredCarPhotos,
                isDark,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 5. Photos count badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161922) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? const Color(0xFF262C3A) : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Yuklangan majburiy fotosuratlar:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : AppColors.charcoalBlack,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _uploadedPhotosCount == 6
                      ? AppColors.success.withValues(alpha: 0.18)
                      : AppColors.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_uploadedPhotosCount / 6',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: _uploadedPhotosCount == 6
                        ? AppColors.success
                        : AppColors.error,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 6. Consent Checkbox
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161922) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasConsent
                  ? AppColors.taxiYellowDark
                  : (isDark ? const Color(0xFF262C3A) : const Color(0xFFE5E7EB)),
              width: hasConsent ? 1.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: hasConsent,
                activeColor: AppColors.taxiYellowDark,
                checkColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                onChanged: onConsentChanged,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => onConsentChanged(!hasConsent),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      'Men taqdim etilgan barcha ma\'lumotlar haqiqiyligini va Yo\'l-Yo\'lakay xizmati qoidalariga roziligimni tasdiqlayman.',
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.4,
                        color:
                            isDark ? Colors.white70 : AppColors.charcoalBlack,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 7. Submit Button
        AppButton(
          text: 'Arizani yuborish',
          onPressed: isSubmitting ? null : onSubmit,
          isLoading: isSubmitting,
          variant: AppButtonVariant.taxi,
          height: 52,
          trailingIcon: const Icon(Icons.send_rounded, size: 18),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required IconData icon,
    required int stepIndex,
    required bool isDark,
    required Widget content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161922) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF262C3A) : const Color(0xFFE5E7EB),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: AppColors.taxiYellowDark, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.charcoalBlack,
                    ),
                  ),
                ],
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: AppColors.taxiYellowDark,
                ),
                tooltip: 'O\'zgartirish',
                onPressed: () => onEditStep(stepIndex),
              ),
            ],
          ),
          Divider(
            height: 20,
            color: isDark ? const Color(0xFF262C3A) : const Color(0xFFF1F3F5),
          ),
          content,
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFF8E93A2) : AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '-',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.charcoalBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoStatusRow(String label, bool isUploaded, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFF8E93A2) : AppColors.textSecondary,
              ),
            ),
          ),
          Icon(
            isUploaded ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 15,
            color: isUploaded ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: 4),
          Text(
            isUploaded ? 'Yuklangan' : 'Yuklanmagan',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isUploaded ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}
