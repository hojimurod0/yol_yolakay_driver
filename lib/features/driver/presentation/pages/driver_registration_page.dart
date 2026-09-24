import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/uzbek_license_plate.dart';
import '../../../../core/widgets/uzbek_license_plate_input.dart';
import '../../../rides/domain/entities/vehicle_entity.dart';
import '../../domain/entities/driver_profile_entity.dart';
import '../providers/driver_provider.dart';

class DriverRegistrationPage extends ConsumerStatefulWidget {
  const DriverRegistrationPage({super.key});

  @override
  ConsumerState<DriverRegistrationPage> createState() =>
      _DriverRegistrationPageState();
}

class _DriverRegistrationPageState
    extends ConsumerState<DriverRegistrationPage> {
  int _currentStep = 0;
  static const int _totalSteps = 4;

  // Step 1: Personal
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();

  // Step 2: Driver Info
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _licenseExpiryController =
      TextEditingController();

  // Step 3: Vehicle Info
  String _licensePlate = '01 A 777 AA';
  String _selectedMake = 'Chevrolet';
  String _selectedModel = 'Cobalt';
  String _selectedColor = 'Oq';
  VehicleType _selectedVehicleType = VehicleType.sedan;

  // Step 4: Options & Verification
  bool _hasAc = true;
  bool _hasTrunk = true;
  bool _acceptParcels = true;
  bool _isSmokingAllowed = false;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _popularModels = [
    {'make': 'Chevrolet', 'model': 'Cobalt', 'type': VehicleType.sedan},
    {
      'make': 'Chevrolet',
      'model': 'Gentra / Lacetti',
      'type': VehicleType.sedan
    },
    {'make': 'Chevrolet', 'model': 'Nexia 3', 'type': VehicleType.sedan},
    {'make': 'Chevrolet', 'model': 'Monza', 'type': VehicleType.sedan},
    {'make': 'Chevrolet', 'model': 'Tracker', 'type': VehicleType.crossover},
    {'make': 'Chevrolet', 'model': 'Malibu 2', 'type': VehicleType.sedan},
    {'make': 'BYD', 'model': 'Song Plus', 'type': VehicleType.crossover},
    {'make': 'BYD', 'model': 'Chazor', 'type': VehicleType.sedan},
    {'make': 'Chevrolet', 'model': 'Damas', 'type': VehicleType.minivan},
    {'make': 'Kia', 'model': 'K5', 'type': VehicleType.sedan},
  ];

  final List<Map<String, dynamic>> _carColorOptions = [
    {'name': 'Oq', 'color': Colors.white, 'border': true},
    {'name': 'Qora', 'color': const Color(0xFF1E1E24), 'border': false},
    {'name': 'Mokriy', 'color': const Color(0xFF4B5563), 'border': false},
    {'name': 'Kumush', 'color': const Color(0xFF9CA3AF), 'border': false},
    {'name': 'Ko\'k', 'color': const Color(0xFF1D4ED8), 'border': false},
    {'name': 'Qizil', 'color': const Color(0xFFDC2626), 'border': false},
  ];

  @override
  void initState() {
    super.initState();
    final driverProfile = ref.read(driverNotifierProvider).profile;
    if (driverProfile != null && driverProfile.fullName.isNotEmpty) {
      _fullNameController.text = driverProfile.fullName;
      _phoneController.text = driverProfile.phoneNumber;
      _selectedModel = driverProfile.vehicle.model;
      _selectedMake = driverProfile.vehicle.make;
      _licensePlate = driverProfile.vehicle.licensePlate;
      _selectedColor = driverProfile.vehicle.color;
      _selectedVehicleType = driverProfile.vehicle.type;
      _hasAc = driverProfile.vehicle.hasAc;
      _hasTrunk = driverProfile.vehicle.hasSpaciousTrunk;
      _acceptParcels = driverProfile.isAcceptingParcels;
      _isSmokingAllowed = driverProfile.vehicle.isSmokingAllowed;
      _licenseController.text = driverProfile.licenseNumber;
      _experienceController.text = '${driverProfile.experienceYears}';
      _cityController.text = 'Toshkent';
      _birthDateController.text = '15.05.1990';
      _licenseExpiryController.text = '2030';
    } else {
      _fullNameController.text = 'Rizo Karimov';
      _phoneController.text = '+998 90 123 45 67';
      _cityController.text = 'Toshkent';
      _birthDateController.text = '15.05.1990';
      _licensePlate = '01 A 777 AA';
      _licenseController.text = 'AB 7654321';
      _experienceController.text = '5';
      _licenseExpiryController.text = '2030';
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _birthDateController.dispose();
    _licenseController.dispose();
    _experienceController.dispose();
    _licenseExpiryController.dispose();
    super.dispose();
  }

  bool _validateCurrentStep(bool isRu) {
    if (_currentStep == 0) {
      if (_fullNameController.text.trim().isEmpty) {
        _showError(
            isRu ? 'Введите имя и фамилию' : 'Ism va familiyangizni kiriting');
        return false;
      }
      if (_phoneController.text.trim().length < 9) {
        _showError(isRu
            ? 'Введите корректный номер телефона'
            : 'Telefon raqamingizni to\'liq kiriting');
        return false;
      }
    } else if (_currentStep == 1) {
      if (_licenseController.text.trim().length < 5) {
        _showError(isRu
            ? 'Введите номер водительского удостоверения'
            : 'Haydovchilik guvohnomasi seriya va raqamini kiriting');
        return false;
      }
      if (_experienceController.text.trim().isEmpty) {
        _showError(isRu
            ? 'Укажите стаж вождения'
            : 'Haydovchilik stajingizni kiriting');
        return false;
      }
    } else if (_currentStep == 2) {
      if (_licensePlate.trim().length < 4) {
        _showError(isRu
            ? 'Введите номер автомобиля'
            : 'Avtomobil davlat raqamini to\'liq kiriting');
        return false;
      }
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleNext(bool isRu) {
    HapticFeedback.selectionClick();
    if (!_validateCurrentStep(isRu)) return;

    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    } else {
      _handleSubmit();
    }
  }

  void _handleBack() {
    HapticFeedback.selectionClick();
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      if (Navigator.canPop(context)) {
        context.pop();
      } else {
        context.go('/driver/home');
      }
    }
  }

  Future<void> _handleSubmit() async {
    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      final expYears = int.tryParse(_experienceController.text.trim()) ?? 3;

      final vehicle = VehicleEntity(
        id: 'veh_${DateTime.now().millisecondsSinceEpoch}',
        make: _selectedMake,
        model: _selectedModel,
        color: _selectedColor,
        licensePlate: _licensePlate.trim().toUpperCase(),
        type: _selectedVehicleType,
        hasAc: _hasAc,
        hasSpaciousTrunk: _hasTrunk,
        isSmokingAllowed: _isSmokingAllowed,
      );

      final profile = DriverProfileEntity(
        id: 'drv_${DateTime.now().millisecondsSinceEpoch}',
        fullName: _fullNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        licenseNumber: _licenseController.text.trim().toUpperCase(),
        experienceYears: expYears,
        vehicle: vehicle,
        status: DriverOnlineStatus.offline,
        isVerified: true,
        isAcceptingParcels: _acceptParcels,
        rating: 5.0,
      );

      await ref.read(driverNotifierProvider.notifier).updateProfile(profile);
      ref.read(driverNotifierProvider.notifier).switchRole(AppUserRole.driver);

      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setString('user_role', 'driver');
      await prefs.setBool('is_role_selected', true);

      if (mounted) {
        context.go('/driver/home');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = ref.watch(localeNotifierProvider);
    final isRu = locale.languageCode == 'ru';

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: _handleBack,
        ),
        title: Text(
          isRu
              ? 'Регистрация водителя'
              : 'Haydovchi sifatida ro\'yxatdan o\'tish',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 16.5,
            color: isDark ? Colors.white : AppColors.charcoalBlack,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_currentStep + 1) / _totalSteps,
            backgroundColor:
                isDark ? AppColors.borderDark : const Color(0xFFE5E7EB),
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.taxiYellow),
            minHeight: 3.5,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Step Header Indicator
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isRu
                        ? 'Шаг ${_currentStep + 1} из $_totalSteps'
                        : '${_currentStep + 1}-bosqich / $_totalSteps',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.taxiYellowDark,
                    ),
                  ),
                  Text(
                    _getStepName(_currentStep, isRu),
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),

            // Step Content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: ListView(
                  key: ValueKey<int>(_currentStep),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildStepHeader(isDark, isRu),
                    const SizedBox(height: AppSpacing.lg),
                    if (_currentStep == 0) _buildStep1Personal(isDark, isRu),
                    if (_currentStep == 1) _buildStep2Driver(isDark, isRu),
                    if (_currentStep == 2) _buildStep3Vehicle(isDark, isRu),
                    if (_currentStep == 3) _buildStep4Options(isDark, isRu),
                  ],
                ),
              ),
            ),

            // Bottom Navigation Actions
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                border: Border(
                  top: BorderSide(
                    color:
                        isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
              ),
              child: Row(
                children: [
                  if (_currentStep > 0) ...[
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : _handleBack,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: const RoundedRectangleBorder(
                              borderRadius: AppRadius.borderMd),
                          side: BorderSide(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                          ),
                        ),
                        child: Text(
                          isRu ? 'Назад' : 'Orqaga',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      text: _currentStep == _totalSteps - 1
                          ? (isRu ? 'Завершить' : 'Ro\'yxatdan o\'tish')
                          : (isRu ? 'Далее' : 'Keyingisi'),
                      isLoading: _isLoading,
                      trailingIcon: _currentStep == _totalSteps - 1
                          ? const Icon(Icons.check_rounded,
                              color: AppColors.charcoalBlack, size: 18)
                          : const Icon(Icons.arrow_forward_rounded,
                              color: AppColors.charcoalBlack, size: 18),
                      onPressed: () => _handleNext(isRu),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStepName(int step, bool isRu) {
    switch (step) {
      case 0:
        return isRu ? 'Личные данные' : 'Shaxsiy ma\'lumotlar';
      case 1:
        return isRu ? 'Водительские права' : 'Haydovchilik guvohnomasi';
      case 2:
        return isRu ? 'Автомобиль' : 'Avtomobil';
      case 3:
        return isRu ? 'Удобства и верификация' : 'Qulayliklar va tekshirish';
      default:
        return '';
    }
  }

  Widget _buildStepHeader(bool isDark, bool isRu) {
    String title;
    String desc;

    switch (_currentStep) {
      case 0:
        title = isRu ? 'Личные данные' : 'Shaxsiy ma\'lumotlar';
        desc = isRu
            ? 'Укажите ваше ФИО и номер телефона для подтверждения профиля'
            : 'Foydalanuvchilar sizni tanishi uchun ism va telefon raqamingizni kiriting';
        break;
      case 1:
        title =
            isRu ? 'Водительское удостоверение' : 'Haydovchilik guvohnomasi';
        desc = isRu
            ? 'Введите серию и номер прав, а также ваш водительский стаж'
            : 'Haydovchilik guvohnomangiz seriya/raqami va haydash stajingizni kiriting';
        break;
      case 2:
        title = isRu ? 'Данные автомобиля' : 'Avtomobil ma\'lumotlari';
        desc = isRu
            ? 'Выберите модель, цвет и введите государственный номер'
            : 'Qatnovlarni amalga oshiradigan avtomobilingiz rusumi, rangi va davlat raqami';
        break;
      case 3:
      default:
        title = isRu ? 'Удобства поездки' : 'Qulayliklar va tasdiqlash';
        desc = isRu
            ? 'Укажите доступные удобства в салоне вашего автомобиля'
            : 'Salondagi qulayliklar (konditsioner, yukxona, pochta olish)ni belgilang';
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: isDark ? Colors.white : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          desc,
          style: AppTypography.bodySmall.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  // Step 1: Personal Info
  Widget _buildStep1Personal(bool isDark, bool isRu) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          controller: _fullNameController,
          label: isRu ? 'Имя и фамилия' : 'Ism va familiya',
          hint: isRu ? 'Например: Rizo Karimov' : 'Masalan: Rizo Karimov',
          prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _phoneController,
          label: isRu ? 'Номер телефона' : 'Telefon raqami',
          hint: '+998 90 123 45 67',
          keyboardType: TextInputType.phone,
          prefixIcon: const Icon(Icons.phone_outlined, size: 20),
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _cityController,
          label: isRu ? 'Город проживания' : 'Yashash shahri / Viloyat',
          hint: isRu ? 'Ташкент' : 'Toshkent, Andijon, Farg\'ona...',
          prefixIcon: const Icon(Icons.location_city_rounded, size: 20),
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _birthDateController,
          label: isRu ? 'Дата рождения' : 'Tug\'ilgan sana',
          hint: '15.05.1990',
          keyboardType: TextInputType.datetime,
          prefixIcon: const Icon(Icons.calendar_today_rounded, size: 20),
        ),
      ],
    );
  }

  // Step 2: Driver Info
  Widget _buildStep2Driver(bool isDark, bool isRu) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          controller: _licenseController,
          label: isRu ? 'Серия и номер прав' : 'Haydovchilik guvohnomasi',
          hint: 'AB 1234567',
          prefixIcon: const Icon(Icons.badge_outlined, size: 20),
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _experienceController,
          label: isRu ? 'Стаж вождения (в годах)' : 'Haydovchilik staji (yil)',
          hint: '5',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          prefixIcon: const Icon(Icons.timeline_rounded, size: 20),
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _licenseExpiryController,
          label:
              isRu ? 'Срок действия прав (год)' : 'Amal qilish muddati (yil)',
          hint: '2030',
          keyboardType: TextInputType.number,
          prefixIcon: const Icon(Icons.verified_user_outlined, size: 20),
        ),
      ],
    );
  }

  // Step 3: Vehicle Info
  Widget _buildStep3Vehicle(bool isDark, bool isRu) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Uzbek License Plate with Live Preview
        Text(
          isRu ? 'Государственный номер' : 'Davlat raqami',
          style: AppTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w700,
            color:
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: UzbekLicensePlate(
            plateNumber: _licensePlate.isEmpty ? '01 A 777 AA' : _licensePlate,
            height: 28,
          ),
        ),
        const SizedBox(height: 12),
        UzbekLicensePlateInput(
          initialValue: _licensePlate,
          isDark: isDark,
          isRu: isRu,
          onChanged: (newVal) => setState(() => _licensePlate = newVal),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Model Selector
        Text(
          isRu ? 'Модель автомобиля' : 'Avtomobil rusumi',
          style: AppTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w700,
            color:
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _popularModels.map((item) {
            final isSelected = _selectedModel == item['model'];
            return ChoiceChip(
              label: Text(
                '${item['make']} ${item['model']}',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? AppColors.charcoalBlack
                      : (isDark ? Colors.white : AppColors.textPrimaryLight),
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.taxiYellow,
              backgroundColor:
                  isDark ? AppColors.surfaceSubtleDark : AppColors.surfaceLight,
              onSelected: (val) {
                if (val) {
                  setState(() {
                    _selectedMake = item['make'] as String;
                    _selectedModel = item['model'] as String;
                    _selectedVehicleType = item['type'] as VehicleType;
                  });
                }
              },
            );
          }).toList(),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Color Options
        Text(
          isRu ? 'Цвет кузова' : 'Avtomobil rangi',
          style: AppTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w700,
            color:
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          children: _carColorOptions.map((opt) {
            final isSelected = _selectedColor == opt['name'];
            final Color color = opt['color'] as Color;
            return InkWell(
              onTap: () =>
                  setState(() => _selectedColor = opt['name'] as String),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceSubtleDark
                      : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.taxiYellow
                        : (isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFD1D5DB)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      opt['name'] as String,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w600,
                        color:
                            isDark ? Colors.white : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Step 4: Options & Verification Preview
  Widget _buildStep4Options(bool isDark, bool isRu) {
    return Column(
      children: [
        _buildSwitchTile(
          isDark: isDark,
          icon: Icons.ac_unit_rounded,
          iconColor: const Color(0xFF3B82F6),
          title: isRu ? 'Кондиционер (AC)' : 'Konditsioner mavjud',
          subtitle: isRu
              ? 'В салоне работает климат-контроль'
              : 'Salonda doimiy salqinlik va qulaylik',
          value: _hasAc,
          onChanged: (val) => setState(() => _hasAc = val),
        ),
        const SizedBox(height: 10),
        _buildSwitchTile(
          isDark: isDark,
          icon: Icons.luggage_rounded,
          iconColor: AppColors.taxiYellowDark,
          title: isRu ? 'Вместительный багажник' : 'Katta hajmli yukxona',
          subtitle: isRu
              ? 'Место для сумок и багажа'
              : 'Yo\'lovchilarning sumkalari va yuklari uchun',
          value: _hasTrunk,
          onChanged: (val) => setState(() => _hasTrunk = val),
        ),
        const SizedBox(height: 10),
        _buildSwitchTile(
          isDark: isDark,
          icon: Icons.markunread_mailbox_rounded,
          iconColor: const Color(0xFF10B981),
          title: isRu
              ? 'Доставка посылок / почта'
              : 'Pochta va posilkalar qabul qilish',
          subtitle: isRu
              ? 'Дополнительный заработок в пути'
              : 'Yo\'l-yo\'lakay pochta yetkazish orqali qo\'shimcha daromad',
          value: _acceptParcels,
          onChanged: (val) => setState(() => _acceptParcels = val),
        ),
        const SizedBox(height: 10),
        _buildSwitchTile(
          isDark: isDark,
          icon: Icons.smoke_free_rounded,
          iconColor: const Color(0xFFEF4444),
          title: isRu ? 'Курение запрещено' : 'Salonda chekish taqiqlangan',
          subtitle: isRu
              ? 'Чистый салон без дыма'
              : 'Toza va hidsiz avtomobil saloni',
          value: !_isSmokingAllowed,
          onChanged: (val) => setState(() => _isSmokingAllowed = !val),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: isDark ? 0.2 : 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: AppColors.taxiYellow,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
