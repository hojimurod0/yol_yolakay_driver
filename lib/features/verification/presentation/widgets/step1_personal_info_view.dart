import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import 'verification_formatters.dart';

/// Step 1: Personal Information (Clean, streamlined, without redundant ID/Passport fields).
class Step1PersonalInfoView extends StatelessWidget {
  const Step1PersonalInfoView({
    super.key,
    required this.isDark,
    required this.firstNameController,
    required this.lastNameController,
    required this.middleNameController,
    required this.birthDateController,
    required this.userPhone,
    required this.photos,
    required this.onPickPhoto,
    required this.onRemovePhoto,
    required this.onPickDate,
  });

  final bool isDark;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController middleNameController;
  final TextEditingController birthDateController;
  final String userPhone;
  final Map<String, String> photos;
  final void Function(String key) onPickPhoto;
  final void Function(String key) onRemovePhoto;
  final Future<void> Function(
    TextEditingController controller,
    String label, {
    DateTime? minDate,
    DateTime? maxDate,
  }) onPickDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Phone & Account Notice
        _buildPhoneBadge(isDark),
        const SizedBox(height: 16),

        // 2. Profile Photo (Avatar)
        _buildAvatarSection(isDark),
        const SizedBox(height: 18),

        // 3. Shaxsiy ma'lumotlar Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161922) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? const Color(0xFF262C3A) : const Color(0xFFE5E7EB),
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.taxiYellowDark.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppColors.taxiYellowDark,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Shaxsiy ma\'lumotlar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color:
                                isDark ? Colors.white : AppColors.charcoalBlack,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Ism va familiyangizni kiriting',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? const Color(0xFF8E93A2)
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Familiya
              _buildTextField(
                label: 'Familiyangiz',
                controller: lastNameController,
                hint: 'Masalan: Usmonov',
                isDark: isDark,
                prefixIcon: Icons.badge_outlined,
                inputFormatters: [NameInputFormatter()],
                textCapitalization: TextCapitalization.words,
                validator: VerificationValidators.validateLastName,
              ),
              const SizedBox(height: 16),

              // Ism
              _buildTextField(
                label: 'Ismingiz',
                controller: firstNameController,
                hint: 'Masalan: Alisher',
                isDark: isDark,
                prefixIcon: Icons.person_outline_rounded,
                inputFormatters: [NameInputFormatter()],
                textCapitalization: TextCapitalization.words,
                validator: VerificationValidators.validateFirstName,
              ),
              const SizedBox(height: 16),

              // Otasining ismi (ixtiyoriy)
              _buildTextField(
                label: 'Otasining ismi (ixtiyoriy)',
                controller: middleNameController,
                hint: 'Masalan: Anvar o\'g\'li',
                isDark: isDark,
                prefixIcon: Icons.account_circle_outlined,
                inputFormatters: [NameInputFormatter()],
                textCapitalization: TextCapitalization.words,
                validator: VerificationValidators.validateMiddleName,
              ),
              const SizedBox(height: 16),

              // Tug'ilgan sana
              _buildDateField(
                label: 'Tug\'ilgan sana',
                controller: birthDateController,
                isDark: isDark,
                validator: VerificationValidators.validateBirthDate,
                onTap: () => onPickDate(
                  birthDateController,
                  'Tug\'ilgan sana',
                  minDate: DateTime(1945),
                  maxDate: DateTime(
                    DateTime.now().year - 18,
                    DateTime.now().month,
                    DateTime.now().day,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneBadge(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161922) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF262C3A) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 14, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bog\'langan telefon raqami',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF8E93A2),
                  ),
                ),
                Text(
                  userPhone.isNotEmpty ? userPhone : '+998 (--) --- -- --',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.charcoalBlack,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Tasdiqlangan',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(bool isDark) {
    final avatarPath = photos['avatar'] ?? '';
    final hasAvatar = avatarPath.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161922) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF262C3A) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => onPickPhoto('avatar'),
            borderRadius: BorderRadius.circular(36),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color:
                    AppColors.taxiYellow.withValues(alpha: isDark ? 0.2 : 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      hasAvatar ? AppColors.success : AppColors.taxiYellowDark,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: hasAvatar
                    ? Image.file(
                        File(avatarPath),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.person_rounded,
                          size: 32,
                        ),
                      )
                    : Icon(
                        Icons.camera_alt_rounded,
                        size: 26,
                        color: isDark
                            ? Colors.white70
                            : AppColors.charcoalBlack,
                      ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profil fotosurati',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.charcoalBlack,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  hasAvatar
                      ? 'Surat muvaffaqiyatli tanlandi'
                      : 'Yuzingiz aniq ko\'ringan suratni yuklang',
                  style: TextStyle(
                    fontSize: 12,
                    color: hasAvatar
                        ? AppColors.success
                        : (isDark
                            ? const Color(0xFF8E93A2)
                            : AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => onPickPhoto('avatar'),
            child: Text(
              hasAvatar ? 'O\'zgartirish' : 'Yuklash',
              style: const TextStyle(
                color: AppColors.taxiYellowDark,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required bool isDark,
    required IconData prefixIcon,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      validator: validator,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : AppColors.charcoalBlack,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? const Color(0xFF8E93A2) : AppColors.textSecondary,
          fontSize: 13.5,
        ),
        hintText: hint,
        hintStyle: TextStyle(
          color: isDark ? const Color(0xFF4B5162) : Colors.black26,
          fontSize: 14,
        ),
        prefixIcon: Icon(
          prefixIcon,
          size: 20,
          color: isDark ? const Color(0xFF8E93A2) : AppColors.textSecondary,
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF1A1D26) : const Color(0xFFF9FAFB),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF262C3A) : AppColors.borderLight,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF262C3A) : AppColors.borderLight,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.taxiYellowDark,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
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
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : AppColors.charcoalBlack,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? const Color(0xFF8E93A2) : AppColors.textSecondary,
          fontSize: 13.5,
        ),
        hintText: 'YYYY-MM-DD',
        hintStyle: TextStyle(
          color: isDark ? const Color(0xFF4B5162) : Colors.black26,
          fontSize: 14,
        ),
        prefixIcon: Icon(
          Icons.calendar_today_rounded,
          size: 20,
          color: isDark ? const Color(0xFF8E93A2) : AppColors.textSecondary,
        ),
        suffixIcon: const Icon(
          Icons.arrow_drop_down_rounded,
          size: 24,
          color: Color(0xFF8E93A2),
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF1A1D26) : const Color(0xFFF9FAFB),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF262C3A) : AppColors.borderLight,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF262C3A) : AppColors.borderLight,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.taxiYellowDark,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }
}
