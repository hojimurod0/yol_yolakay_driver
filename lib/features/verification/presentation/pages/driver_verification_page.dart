import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../bloc/verification_bloc.dart';
import '../bloc/verification_event.dart';
import '../bloc/verification_state.dart';

class DriverVerificationPage extends StatefulWidget {
  const DriverVerificationPage({super.key});

  @override
  State<DriverVerificationPage> createState() => _DriverVerificationPageState();
}

class _DriverVerificationPageState extends State<DriverVerificationPage> {
  final _formKey = GlobalKey<FormState>();

  // Personal Info Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _birthDateController = TextEditingController();
  String _gender = 'male';

  // Vehicle Info Controllers
  final _carModelController = TextEditingController();
  final _carColorController = TextEditingController();
  final _carYearController = TextEditingController();
  final _plateNumberController = TextEditingController();
  final _techPassportController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  int _carSeatsCount = 4;
  bool _hasAc = true;

  // Document & Car Photos Map (Key -> Local File Path)
  final Map<String, String> _photos = {
    'driver_license_front': '',
    'driver_license_back': '',
    'tech_passport_front': '',
    'tech_passport_back': '',
    'car_front_photo': '',
    'car_interior_photo': '',
  };

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _birthDateController.dispose();
    _carModelController.dispose();
    _carColorController.dispose();
    _carYearController.dispose();
    _plateNumberController.dispose();
    _techPassportController.dispose();
    _licenseNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String fieldKey, ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (file != null) {
        setState(() {
          _photos[fieldKey] = file.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rasm tanlashda xatolik: $e')),
        );
      }
    }
  }

  void _showImageSourceDialog(String fieldKey, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded,
                  color: AppColors.taxiYellowDark),
              title: Text(l10n.cameraOption),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(fieldKey, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded,
                  color: AppColors.taxiYellowDark),
              title: Text(l10n.galleryOption),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(fieldKey, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _submit(AppLocalizations l10n) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check all 6 photos are attached
    for (final entry in _photos.entries) {
      if (entry.value.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.uploadAllPhotosPrompt),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    final textFields = {
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'birth_date': _birthDateController.text.trim(),
      'gender': _gender,
      'car_model': _carModelController.text.trim(),
      'car_color': _carColorController.text.trim(),
      'car_year': int.tryParse(_carYearController.text.trim()) ?? 2022,
      'plate_number': _plateNumberController.text.trim().replaceAll(' ', ''),
      'tech_passport_number': _techPassportController.text.trim(),
      'driver_license_number': _licenseNumberController.text.trim(),
      'car_seats_count': _carSeatsCount,
      'has_ac': _hasAc,
    };

    context.read<VerificationBloc>().add(
          SubmitDriverApplicationEvent(
            textFields: textFields,
            photoFiles: _photos,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<VerificationBloc, VerificationState>(
      listener: (context, state) {
        if (state is ApplicationSubmittedSuccessState) {
          _showSuccessModal(context, state.response.message, l10n);
        } else if (state is VerificationErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final isSubmitting = state is SubmittingApplicationState;

        return Scaffold(
          backgroundColor:
              isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
          appBar: AppBar(
            backgroundColor:
                isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            title: Text(
              l10n.driverVerificationTitle,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: isDark ? Colors.white : AppColors.charcoalBlack,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                color:
                    isDark ? const Color(0xFF2C2C38) : const Color(0xFFE5E7EB),
                height: 1,
              ),
            ),
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 120),
              children: [
                // Info Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        AppColors.taxiYellow.withOpacity(isDark ? 0.15 : 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.taxiYellow.withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shield_outlined,
                          color: AppColors.taxiYellowDark, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.verificationBannerText,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                            color:
                                isDark ? Colors.white : AppColors.charcoalBlack,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 1. Shaxsiy ma'lumotlar
                _buildSectionHeader(l10n.personalInfoSectionTitle,
                    Icons.person_outline_rounded, isDark),
                const SizedBox(height: 12),
                _buildTextField(
                    'Ismingiz', _firstNameController, 'Alisher', isDark, l10n),
                const SizedBox(height: 10),
                _buildTextField('Familiyangiz', _lastNameController, 'Usmonov',
                    isDark, l10n),
                const SizedBox(height: 10),
                _buildTextField('Tug\'ilgan sana (YYYY-MM-DD)',
                    _birthDateController, '1992-05-15', isDark, l10n),
                const SizedBox(height: 10),
                _buildGenderSelector(isDark),

                const SizedBox(height: 28),

                // 2. Avtomobil ma'lumotlari
                _buildSectionHeader(l10n.vehicleInfoSectionTitle,
                    Icons.directions_car_outlined, isDark),
                const SizedBox(height: 12),
                _buildTextField('Avtomobil rusumi', _carModelController,
                    'Chevrolet Cobalt', isDark, l10n),
                const SizedBox(height: 10),
                _buildTextField(
                    'Rangi', _carColorController, 'Oq', isDark, l10n),
                const SizedBox(height: 10),
                _buildTextField('Ishlab chiqarilgan yili', _carYearController,
                    '2022', isDark, l10n,
                    isNumber: true),
                const SizedBox(height: 10),
                _buildTextField('Davlat raqami (masalan: 01A777AA)',
                    _plateNumberController, '01A777AA', isDark, l10n),
                const SizedBox(height: 10),
                _buildTextField('Tex passport seriya va raqami',
                    _techPassportController, 'AAF1234567', isDark, l10n),
                const SizedBox(height: 10),
                _buildTextField('Guvohnoma (Prava) raqami',
                    _licenseNumberController, 'AB1234567', isDark, l10n),
                const SizedBox(height: 12),

                // O'rindiqlar soni va AC
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color:
                              isDark ? const Color(0xFF1E1E26) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF2E2E3C)
                                : const Color(0xFFE2E4E8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('O\'rindiqlar: ',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 13)),
                            DropdownButton<int>(
                              value: _carSeatsCount,
                              underline: const SizedBox(),
                              items: [1, 2, 3, 4, 5, 6, 7, 8].map((n) {
                                return DropdownMenuItem(
                                    value: n, child: Text('$n ta'));
                              }).toList(),
                              onChanged: (val) =>
                                  setState(() => _carSeatsCount = val ?? 4),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color:
                              isDark ? const Color(0xFF1E1E26) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF2E2E3C)
                                : const Color(0xFFE2E4E8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Konditsioner',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 13)),
                            Switch.adaptive(
                              value: _hasAc,
                              activeColor: AppColors.taxiYellowDark,
                              onChanged: (val) => setState(() => _hasAc = val),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // 3. Hujjatlar va Avtomobil fotosuratlari
                _buildSectionHeader(l10n.documentsAndPhotosSectionTitle,
                    Icons.camera_alt_outlined, isDark),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildPhotoCard('Haydovchilik guvohnomasi (Oldi)',
                        'driver_license_front', isDark, l10n),
                    _buildPhotoCard('Haydovchilik guvohnomasi (Orqasi)',
                        'driver_license_back', isDark, l10n),
                    _buildPhotoCard('Tex passport (Oldi)',
                        'tech_passport_front', isDark, l10n),
                    _buildPhotoCard('Tex passport (Orqasi)',
                        'tech_passport_back', isDark, l10n),
                    _buildPhotoCard('Avtomobil old ko\'rinishi',
                        'car_front_photo', isDark, l10n),
                    _buildPhotoCard(
                        'Avtomobil saloni', 'car_interior_photo', isDark, l10n),
                  ],
                ),

                const SizedBox(height: 32),

                // Submit CTA Button
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    text: l10n.submitApplicationAction,
                    onPressed: () => _submit(l10n),
                    isLoading: isSubmitting,
                    variant: AppButtonVariant.taxi,
                    height: 52,
                    leadingIcon: const Icon(Icons.send_rounded, size: 20),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.taxiYellowDark),
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
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint,
    bool isDark,
    AppLocalizations l10n, {
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (val) {
        if (val == null || val.trim().isEmpty) {
          return l10n.fieldRequiredError(label);
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: isDark ? const Color(0xFF1E1E26) : Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF2E2E3C) : const Color(0xFFE2E4E8),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF2E2E3C) : const Color(0xFFE2E4E8),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderSelector(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: RadioListTile<String>(
            title: const Text('Erkak',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            value: 'male',
            groupValue: _gender,
            activeColor: AppColors.taxiYellowDark,
            contentPadding: EdgeInsets.zero,
            onChanged: (val) => setState(() => _gender = val ?? 'male'),
          ),
        ),
        Expanded(
          child: RadioListTile<String>(
            title: const Text('Ayol',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            value: 'female',
            groupValue: _gender,
            activeColor: AppColors.taxiYellowDark,
            contentPadding: EdgeInsets.zero,
            onChanged: (val) => setState(() => _gender = val ?? 'female'),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoCard(
      String title, String fieldKey, bool isDark, AppLocalizations l10n) {
    final hasPhoto = _photos[fieldKey]!.isNotEmpty;

    return GestureDetector(
      onTap: () => _showImageSourceDialog(fieldKey, l10n),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E26) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasPhoto
                ? AppColors.success
                : (isDark ? const Color(0xFF2E2E3C) : const Color(0xFFE2E4E8)),
            width: hasPhoto ? 1.8 : 1.0,
          ),
        ),
        child: hasPhoto
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(_photos[fieldKey]!),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check,
                          size: 14, color: Colors.white),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_a_photo_outlined,
                      size: 30, color: AppColors.taxiYellowDark),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white70 : AppColors.charcoalBlack,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
      ),
    );
  }

  void _showSuccessModal(
      BuildContext context, String message, AppLocalizations l10n) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  color: Colors.white, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.applicationSubmittedModalTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: const TextStyle(fontSize: 13, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: l10n.goToHomeAction,
                onPressed: () {
                  Navigator.pop(ctx);
                  context.go('/driver/home');
                },
                variant: AppButtonVariant.taxi,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
