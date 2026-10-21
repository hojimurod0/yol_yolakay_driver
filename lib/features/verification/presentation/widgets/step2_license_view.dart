import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import 'verification_formatters.dart';
import 'verification_photo_card.dart';

/// Step 2: Driver's License Information, Categories, and Photos.
class Step2LicenseView extends StatelessWidget {
  const Step2LicenseView({
    super.key,
    required this.isDark,
    required this.licenseSeriesController,
    required this.licenseNumberController,
    required this.licenseIssueDateController,
    required this.licenseExpiryDateController,
    required this.selectedCategories,
    required this.onCategoryToggled,
    required this.photos,
    required this.onPickPhoto,
    required this.onRemovePhoto,
    required this.onPickDate,
    this.birthDate,
  });

  final bool isDark;
  final TextEditingController licenseSeriesController;
  final TextEditingController licenseNumberController;
  final TextEditingController licenseIssueDateController;
  final TextEditingController licenseExpiryDateController;
  final List<String> selectedCategories;
  final ValueChanged<String> onCategoryToggled;

  final Map<String, String> photos;
  final void Function(String key) onPickPhoto;
  final void Function(String key) onRemovePhoto;
  final Future<void> Function(TextEditingController controller, String label, {DateTime? minDate, DateTime? maxDate}) onPickDate;
  final String? birthDate;

  static const List<String> _availableCategories = ['A', 'B', 'C', 'D', 'E'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Info Note Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.taxiYellow.withValues(alpha: isDark ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.taxiYellow.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.taxiYellow.withValues(alpha: isDark ? 0.25 : 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.card_membership_rounded,
                  color: AppColors.taxiYellowDark,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Taksi xizmatida faoliyat yuritish uchun kamida "B" toifali haydovchilik guvohnomasi talab etiladi.',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    color: isDark ? Colors.white : AppColors.charcoalBlack,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 2. Guvohnoma ma'lumotlari Card
        _buildSectionCard(
          title: 'Guvohnoma (Prava) ma\'lumotlari',
          subtitle: 'Guvohnomadagi seriya, raqam va muddatlarni to\'liq kiriting',
          icon: Icons.badge_rounded,
          isDark: isDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seriya va Raqam - ALOHIDA MAYDONLARDA!
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      label: 'Seriya',
                      controller: licenseSeriesController,
                      hint: 'AA',
                      isDark: isDark,
                      prefixIcon: Icons.font_download_outlined,
                      inputFormatters: [SeriesInputFormatter(maxLength: 2)],
                      textCapitalization: TextCapitalization.characters,
                      validator: (val) => VerificationValidators.validateLicenseSeries(val),
                      helperText: '2 ta harf',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 4,
                    child: _buildTextField(
                      label: 'Guvohnoma raqami',
                      controller: licenseNumberController,
                      hint: '9876543',
                      isDark: isDark,
                      isNumber: true,
                      prefixIcon: Icons.pin_rounded,
                      inputFormatters: [DigitsOnlyFormatter(maxLength: 7)],
                      validator: (val) => VerificationValidators.validateLicenseNumber(val),
                      helperText: '7 ta raqam',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Sanalar (Berilgan sana va Amal qilish muddati)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildDateField(
                      label: 'Berilgan sana',
                      controller: licenseIssueDateController,
                      isDark: isDark,
                      validator: (val) => VerificationValidators.validateDocIssueDate(
                        val,
                        birthDateStr: birthDate,
                      ),
                      onTap: () => onPickDate(
                        licenseIssueDateController,
                        'Guvohnoma berilgan sana',
                        minDate: DateTime(1980),
                        maxDate: DateTime.now(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDateField(
                      label: 'Amal qilish muddati',
                      controller: licenseExpiryDateController,
                      isDark: isDark,
                      validator: (val) => VerificationValidators.validateDocExpiryDate(
                        val,
                        issueDateStr: licenseIssueDateController.text,
                      ),
                      onTap: () => onPickDate(
                        licenseExpiryDateController,
                        'Guvohnoma amal qilish muddati',
                        minDate: DateTime.now(),
                        maxDate: DateTime(2050),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Haydovchilik toifalari (Categories)
              Text(
                'Haydovchilik toifalari',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white70 : AppColors.charcoalBlack,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: _availableCategories.map((category) {
                  final isSelected = selectedCategories.contains(category);
                  final isB = category == 'B'; // B is standard

                  return FilterChip(
                    label: Text(
                      'Toifa $category',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected
                            ? Colors.black
                            : (isDark ? Colors.white70 : AppColors.charcoalBlack),
                      ),
                    ),
                    selected: isSelected,
                    onSelected: isB
                        ? null // B cannot be deselected (mandatory for taxi)
                        : (_) => onCategoryToggled(category),
                    selectedColor: AppColors.taxiYellow,
                    backgroundColor: isDark ? const Color(0xFF16161D) : const Color(0xFFF9FAFB),
                    checkmarkColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.taxiYellowDark
                            : (isDark ? AppColors.borderDark : AppColors.borderLight),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 3. Guvohnomaning old va orqa tomon rasmlari Card
        _buildSectionCard(
          title: 'Guvohnoma fotosuratlari',
          subtitle: 'Guvohnomaning old va orqa tomoni burchaklari to\'liq tushgan yorug\' suratini yuklang',
          icon: Icons.camera_alt_rounded,
          isDark: isDark,
          child: Row(
            children: [
              Expanded(
                child: VerificationPhotoCard(
                  title: 'Guvohnoma (Oldi)',
                  fieldKey: 'driver_license_front',
                  imagePath: photos['driver_license_front'] ?? '',
                  onPick: () => onPickPhoto('driver_license_front'),
                  onRemove: () => onRemovePhoto('driver_license_front'),
                  icon: Icons.badge_outlined,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: VerificationPhotoCard(
                  title: 'Guvohnoma (Orqasi)',
                  fieldKey: 'driver_license_back',
                  imagePath: photos['driver_license_back'] ?? '',
                  onPick: () => onPickPhoto('driver_license_back'),
                  onRemove: () => onRemovePhoto('driver_license_back'),
                  icon: Icons.flip_rounded,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.taxiYellow
                      .withValues(alpha: isDark ? 0.2 : 0.15),
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
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.charcoalBlack,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white54 : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            height: 1,
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required bool isDark,
    IconData? prefixIcon,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
    bool isNumber = false,
    String? helperText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      validator: validator,
      style: TextStyle(
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : AppColors.charcoalBlack,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white60 : const Color(0xFF6B7280),
        ),
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 13.5,
          color: isDark ? Colors.white24 : const Color(0xFF9CA3AF),
        ),
        helperText: helperText,
        helperStyle: TextStyle(
          fontSize: 11,
          color: isDark ? Colors.white54 : const Color(0xFF6B7280),
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF16161D) : const Color(0xFFF9FAFB),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon,
                size: 20,
                color: isDark ? Colors.white60 : const Color(0xFF6B7280))
            : null,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.taxiYellowDark,
            width: 1.8,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    required bool isDark,
    required VoidCallback onTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      validator: validator,
      style: TextStyle(
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : AppColors.charcoalBlack,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white60 : const Color(0xFF6B7280),
        ),
        hintText: 'YYYY-MM-DD',
        hintStyle: TextStyle(
          fontSize: 13.5,
          color: isDark ? Colors.white24 : const Color(0xFF9CA3AF),
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF16161D) : const Color(0xFFF9FAFB),
        prefixIcon: Icon(
          Icons.calendar_today_rounded,
          size: 19,
          color: isDark ? Colors.white60 : const Color(0xFF6B7280),
        ),
        suffixIcon: IconButton(
          icon: const Icon(
            Icons.calendar_month_rounded,
            color: AppColors.taxiYellowDark,
          ),
          onPressed: onTap,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.taxiYellowDark,
            width: 1.8,
          ),
        ),
      ),
    );
  }
}
