import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/uzbek_license_plate_input.dart';
import 'verification_formatters.dart';
import 'verification_photo_card.dart';

/// Step 3: Vehicle Information, License Plate, Tech Passport & Vehicle Photos.
class Step3VehicleView extends StatelessWidget {
  const Step3VehicleView({
    super.key,
    required this.isDark,
    required this.carModelController,
    required this.carColorController,
    required this.carYearController,
    required this.plateNumberController,
    required this.plateNumberError,
    required this.onPlateNumberChanged,
    required this.carSeatsCount,
    required this.onCarSeatsChanged,
    required this.hasAc,
    required this.onHasAcChanged,
    required this.ownershipType,
    required this.onOwnershipTypeChanged,
    required this.techPassportSeriesController,
    required this.techPassportNumberController,
    required this.photos,
    required this.onPickPhoto,
    required this.onRemovePhoto,
  });

  final bool isDark;
  final TextEditingController carModelController;
  final TextEditingController carColorController;
  final TextEditingController carYearController;
  final TextEditingController plateNumberController;
  final String? plateNumberError;
  final ValueChanged<String> onPlateNumberChanged;

  final int carSeatsCount;
  final ValueChanged<int> onCarSeatsChanged;
  final bool hasAc;
  final ValueChanged<bool> onHasAcChanged;
  final String ownershipType; // 'own' | 'power_of_attorney' | 'rent'
  final ValueChanged<String> onOwnershipTypeChanged;

  final TextEditingController techPassportSeriesController;
  final TextEditingController techPassportNumberController;

  final Map<String, String> photos;
  final void Function(String key) onPickPhoto;
  final void Function(String key) onRemovePhoto;

  static const List<String> _popularModels = [
    'Chevrolet Cobalt',
    'Chevrolet Lacetti',
    'Chevrolet Gentra',
    'Chevrolet Nexia 3',
    'Chevrolet Tracker',
    'Chevrolet Onix',
    'BYD Song Plus',
    'Kia K5',
  ];

  static const List<String> _popularColors = [
    'Oq',
    'Qora',
    'Mokriy asfalt',
    'Kumushrang',
    'Kulrang',
    'Ko\'k',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Avtomobil parametrlari Card
        _buildSectionCard(
          title: 'Avtomobil parametrlari',
          subtitle: 'Buyurtmachilar ko\'radigan avtomobilingiz ma\'lumotlari',
          icon: Icons.directions_car_rounded,
          isDark: isDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Model / Rusum
              _buildTextField(
                label: 'Avtomobil rusumi va modeli',
                controller: carModelController,
                hint: 'Masalan: Chevrolet Cobalt',
                isDark: isDark,
                prefixIcon: Icons.directions_car_outlined,
                textCapitalization: TextCapitalization.words,
                validator: VerificationValidators.validateCarModel,
              ),
              const SizedBox(height: 8),

              // Tezkor model takliflari
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _popularModels.map((model) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ActionChip(
                        label: Text(model, style: const TextStyle(fontSize: 11.5)),
                        onPressed: () => carModelController.text = model,
                        backgroundColor: isDark ? AppColors.surfaceSubtleDark : AppColors.surfaceSubtleLight,
                        side: BorderSide(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),

              // Rangi va Yili (Row)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildTextField(
                      label: 'Rangi',
                      controller: carColorController,
                      hint: 'Oq',
                      isDark: isDark,
                      prefixIcon: Icons.palette_outlined,
                      textCapitalization: TextCapitalization.words,
                      validator: VerificationValidators.validateCarColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      label: 'Yili',
                      controller: carYearController,
                      hint: '2022',
                      isDark: isDark,
                      isNumber: true,
                      prefixIcon: Icons.event_outlined,
                      inputFormatters: [DigitsOnlyFormatter(maxLength: 4)],
                      validator: VerificationValidators.validateCarYear,
                      helperText: '1990-${DateTime.now().year + 1}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Tezkor rang takliflari
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _popularColors.map((color) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ActionChip(
                        label: Text(color, style: const TextStyle(fontSize: 11.5)),
                        onPressed: () => carColorController.text = color,
                        backgroundColor: isDark ? AppColors.surfaceSubtleDark : AppColors.surfaceSubtleLight,
                        side: BorderSide(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // O'rindiqlar soni va Konditsioner (Responsive LayoutBuilder for narrow screen support)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 320;

                  final seatsWidget = Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceSubtleDark : AppColors.surfaceSubtleLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'O\'rindiqlar:',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: carSeatsCount,
                            isDense: true,
                            dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
                            items: [1, 2, 3, 4, 5, 6, 7, 8].map((n) {
                              return DropdownMenuItem(
                                value: n,
                                child: Text(
                                  '$n ta',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: isDark ? Colors.white : AppColors.charcoalBlack,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) onCarSeatsChanged(val);
                            },
                          ),
                        ),
                      ],
                    ),
                  );

                  final acWidget = Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceSubtleDark : AppColors.surfaceSubtleLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Konditsioner',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                        ),
                        Transform.scale(
                          scale: 0.8,
                          child: Switch.adaptive(
                            value: hasAc,
                            activeTrackColor: AppColors.taxiYellowDark,
                            onChanged: onHasAcChanged,
                          ),
                        ),
                      ],
                    ),
                  );

                  if (isCompact) {
                    return Column(
                      children: [
                        seatsWidget,
                        const SizedBox(height: 10),
                        acWidget,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: seatsWidget),
                      const SizedBox(width: 10),
                      Expanded(child: acWidget),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              // Egalik holati (Ownership type)
              Text(
                'Avtomobilga egalik holati',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white70 : AppColors.charcoalBlack,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildOwnershipOption(
                      label: 'O\'zimniki',
                      type: 'own',
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildOwnershipOption(
                      label: 'Ishonchnoma',
                      type: 'power_of_attorney',
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildOwnershipOption(
                      label: 'Ijara / Boshqa',
                      type: 'rent',
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 2. Davlat raqami Card (Authentic Uzbekistan License Plate Input)
        _buildSectionCard(
          title: 'Davlat raqam belgisi',
          subtitle: 'Hudud kodi va raqamni aniq kiriting (masalan: 01 A 777 AA)',
          icon: Icons.featured_play_list_rounded,
          isDark: isDark,
          child: UzbekLicensePlateInput(
            initialValue: plateNumberController.text,
            label: 'Avtomobil davlat raqami',
            isDark: isDark,
            errorText: plateNumberError,
            onChanged: (val) {
              plateNumberController.text = val;
              onPlateNumberChanged(val);
            },
          ),
        ),
        const SizedBox(height: 20),

        // 3. Texnik passport ma'lumotlari Card (Seriya va Raqam alohida)
        _buildSectionCard(
          title: 'Texnik pasport (Texpasport)',
          subtitle: 'Transport vositasi qayd etish guvohnomasi seriyasi va raqami',
          icon: Icons.description_rounded,
          isDark: isDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      label: 'Seriya',
                      controller: techPassportSeriesController,
                      hint: 'AAF',
                      isDark: isDark,
                      prefixIcon: Icons.font_download_outlined,
                      inputFormatters: [SeriesInputFormatter(maxLength: 3)],
                      textCapitalization: TextCapitalization.characters,
                      validator: (val) => VerificationValidators.validateTechPassportSeries(val),
                      helperText: '2-3 ta harf',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 4,
                    child: _buildTextField(
                      label: 'Texpasport raqami',
                      controller: techPassportNumberController,
                      hint: '1234567',
                      isDark: isDark,
                      isNumber: true,
                      prefixIcon: Icons.pin_rounded,
                      inputFormatters: [DigitsOnlyFormatter(maxLength: 7)],
                      validator: (val) => VerificationValidators.validateTechPassportNumber(val),
                      helperText: '6 yoki 7 ta raqam',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Tex pasport fotosuratlari (Oldi va orqasi)
              Text(
                'Texnik pasport fotosuratlari',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white70 : AppColors.charcoalBlack,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: VerificationPhotoCard(
                      title: 'Texpasport (Oldi)',
                      fieldKey: 'tech_passport_front',
                      imagePath: photos['tech_passport_front'] ?? '',
                      onPick: () => onPickPhoto('tech_passport_front'),
                      onRemove: () => onRemovePhoto('tech_passport_front'),
                      icon: Icons.assignment_outlined,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: VerificationPhotoCard(
                      title: 'Texpasport (Orqasi)',
                      fieldKey: 'tech_passport_back',
                      imagePath: photos['tech_passport_back'] ?? '',
                      onPick: () => onPickPhoto('tech_passport_back'),
                      onRemove: () => onRemovePhoto('tech_passport_back'),
                      icon: Icons.flip_rounded,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 4. Avtomobil fotosuratlari Card (Old ko'rinish va Salon)
        _buildSectionCard(
          title: 'Avtomobil fotosuratlari',
          subtitle: 'Avtomobilingizning oldi (davlat raqami aniq ko\'ringan) va ichki salon suratlari',
          icon: Icons.camera_alt_rounded,
          isDark: isDark,
          child: Row(
            children: [
              Expanded(
                child: VerificationPhotoCard(
                  title: 'Avtomobil (Old ko\'rinish)',
                  fieldKey: 'car_front_photo',
                  imagePath: photos['car_front_photo'] ?? '',
                  onPick: () => onPickPhoto('car_front_photo'),
                  onRemove: () => onRemovePhoto('car_front_photo'),
                  icon: Icons.directions_car_outlined,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: VerificationPhotoCard(
                  title: 'Avtomobil (Saloni)',
                  fieldKey: 'car_interior_photo',
                  imagePath: photos['car_interior_photo'] ?? '',
                  onPick: () => onPickPhoto('car_interior_photo'),
                  onRemove: () => onRemovePhoto('car_interior_photo'),
                  icon: Icons.airline_seat_recline_normal_rounded,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOwnershipOption({
    required String label,
    required String type,
    required bool isDark,
  }) {
    final isSelected = ownershipType == type;

    return InkWell(
      onTap: () => onOwnershipTypeChanged(type),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.taxiYellow.withValues(alpha: isDark ? 0.22 : 0.15)
              : (isDark ? const Color(0xFF16161D) : const Color(0xFFF9FAFB)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.taxiYellowDark
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected
                ? (isDark ? Colors.white : AppColors.charcoalBlack)
                : (isDark ? Colors.white60 : const Color(0xFF4B5563)),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
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
        fillColor: isDark ? AppColors.surfaceSubtleDark : AppColors.surfaceSubtleLight,
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
}
