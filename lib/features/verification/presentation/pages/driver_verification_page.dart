import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../profile/domain/entities/driver_profile_entity.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../bloc/verification_bloc.dart';
import '../bloc/verification_event.dart';
import '../bloc/verification_state.dart';
import '../../data/models/driver_verification_request_dto.dart';
import '../widgets/step1_personal_info_view.dart';
import '../widgets/step2_license_view.dart';
import '../widgets/step3_vehicle_view.dart';
import '../widgets/step4_review_submit_view.dart';
import '../widgets/verification_formatters.dart';
import '../widgets/verification_status_view.dart';
import '../widgets/verification_step_progress.dart';

class DriverVerificationPage extends StatefulWidget {
  const DriverVerificationPage({super.key});

  @override
  State<DriverVerificationPage> createState() => _DriverVerificationPageState();
}

class _DriverVerificationPageState extends State<DriverVerificationPage> {
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();
  final PageController _pageController = PageController();

  int _currentStep = 0; // 0: Shaxsiy, 1: Guvohnoma, 2: Avtomobil, 3: Tekshirish

  // 1. Shaxsiy ma'lumotlar
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _birthDateController = TextEditingController();

  // 2. Haydovchilik guvohnomasi
  final _licenseSeriesController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _licenseIssueDateController = TextEditingController();
  final _licenseExpiryDateController = TextEditingController();
  final List<String> _selectedCategories = ['B'];

  // 3. Avtomobil ma'lumotlari
  final _carModelController = TextEditingController();
  final _carColorController = TextEditingController();
  final _carYearController = TextEditingController(text: '2022');
  final _plateNumberController = TextEditingController(text: '01 A 777 AA');
  String? _plateNumberError;
  final int _carSeatsCount = 4;
  bool _hasAc = true;
  String _ownershipType = 'own';
  final _techPassportSeriesController = TextEditingController(text: 'AAF');
  final _techPassportNumberController = TextEditingController();

  // 4. Consent
  bool _hasConsent = false;

  // Document & Car Photos Map (Key -> Local File Path)
  final Map<String, String> _photos = {
    'avatar': '',
    'driver_license_front': '',
    'driver_license_back': '',
    'tech_passport_front': '',
    'tech_passport_back': '',
    'car_front_photo': '',
    'car_interior_photo': '',
  };

  final ImagePicker _picker = ImagePicker();

  bool _isSubmitting = false;
  bool _forceShowForm = false;
  bool _profileInitialized = false;

  @override
  void initState() {
    super.initState();
    final profileBloc = context.read<ProfileBloc>();
    profileBloc.add(const LoadProfileEvent());
    final currentProfile = profileBloc.state.profile;
    if (currentProfile != null) {
      _profileInitialized = true;
      _prefillFromProfile(currentProfile);
    }
  }

  void _prefillFromProfile(DriverProfileEntity? profile) {
    if (profile == null) return;
    if (_firstNameController.text.isEmpty && profile.firstName.isNotEmpty) {
      _firstNameController.text = profile.firstName;
    }
    if (_lastNameController.text.isEmpty && profile.lastName.isNotEmpty) {
      _lastNameController.text = profile.lastName;
    }
    if (profile.vehicle != null) {
      final v = profile.vehicle!;
      if (_carModelController.text.isEmpty &&
          (v.make.isNotEmpty || v.model.isNotEmpty)) {
        _carModelController.text = '${v.make} ${v.model}'.trim();
      }
      if (_carColorController.text.isEmpty && v.color.isNotEmpty) {
        _carColorController.text = v.color;
      }
      if (v.year > 1990) {
        _carYearController.text = v.year.toString();
      }
      if (v.licensePlate.isNotEmpty) {
        _plateNumberController.text = v.licensePlate;
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _middleNameController.dispose();
    _birthDateController.dispose();

    _licenseSeriesController.dispose();
    _licenseNumberController.dispose();
    _licenseIssueDateController.dispose();
    _licenseExpiryDateController.dispose();

    _carModelController.dispose();
    _carColorController.dispose();
    _carYearController.dispose();
    _plateNumberController.dispose();
    _techPassportSeriesController.dispose();
    _techPassportNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickDateForController(
    TextEditingController controller,
    String label, {
    DateTime? minDate,
    DateTime? maxDate,
  }) async {
    final now = DateTime.now();
    DateTime initial = maxDate ?? now;
    if (controller.text.isNotEmpty) {
      final parsed = DateTime.tryParse(controller.text);
      if (parsed != null) initial = parsed;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: minDate ?? DateTime(1945),
      lastDate: maxDate ?? DateTime(2050),
      helpText: label,
      cancelText: 'Bekor qilish',
      confirmText: 'Tanlash',
      builder: (ctx, child) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: AppColors.taxiYellowDark,
                    onPrimary: Colors.black,
                    surface: AppColors.surfaceDark,
                    onSurface: Colors.white,
                  )
                : const ColorScheme.light(
                    primary: AppColors.taxiYellowDark,
                    onPrimary: Colors.black,
                    surface: Colors.white,
                    onSurface: AppColors.charcoalBlack,
                  ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final y = picked.year.toString().padLeft(4, '0');
      final m = picked.month.toString().padLeft(2, '0');
      final d = picked.day.toString().padLeft(2, '0');
      setState(() {
        controller.text = '$y-$m-$d';
      });
    }
  }

  Future<void> _pickImage(String fieldKey, ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 75,
      );
      if (file != null) {
        final path = file.path;
        final ext = path.split('.').last.toLowerCase();
        if (!['jpg', 'jpeg', 'png'].contains(ext)) {
          if (mounted) {
            AppSnackBar.showError(
              context,
              'Faqat JPG, JPEG yoki PNG formatidagi rasmlar qabul qilinadi',
            );
          }
          return;
        }

        final fileBytes = await file.length();
        if (fileBytes > 8 * 1024 * 1024) {
          if (mounted) {
            AppSnackBar.showError(
              context,
              'Rasm hajmi 8 MB dan oshmasligi kerak',
            );
          }
          return;
        }

        setState(() {
          _photos[fieldKey] = path;
        });
      }
    } catch (_) {
      if (mounted) {
        AppSnackBar.showError(context, 'Suratni tanlashda xatolik yuz berdi');
      }
    }
  }

  void _showPhotoSourceSheet(BuildContext context, String fieldKey) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : AppColors.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded,
                    color: AppColors.taxiYellowDark),
                title: const Text('Kameradan suratga olish',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(fieldKey, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded,
                    color: AppColors.taxiYellowDark),
                title: const Text('Galereyadan tanlash',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(fieldKey, ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onCategoryToggled(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        if (_selectedCategories.length > 1) {
          _selectedCategories.remove(category);
        }
      } else {
        _selectedCategories.add(category);
      }
    });
  }

  void _nextStep() {
    FocusScope.of(context).unfocus();

    if (_currentStep == 0) {
      if (!_step1Key.currentState!.validate()) {
        AppSnackBar.showError(
            context, 'Iltimos, ism va familiyangizni to\'liq kiriting');
        return;
      }

      setState(() => _currentStep = 1);
      _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOutCubic,
      );
    } else if (_currentStep == 1) {
      if (!_step2Key.currentState!.validate()) {
        AppSnackBar.showError(context,
            'Iltimos, haydovchilik guvohnomasi ma\'lumotlarini to\'ldiring');
        return;
      }

      if ((_photos['driver_license_front'] ?? '').isEmpty ||
          (_photos['driver_license_back'] ?? '').isEmpty) {
        AppSnackBar.showError(context,
            'Iltimos, guvohnomaning old va orqa suratlarini yuklang');
        return;
      }

      setState(() => _currentStep = 2);
      _pageController.animateToPage(
        2,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOutCubic,
      );
    } else if (_currentStep == 2) {
      setState(() {
        _plateNumberError = VerificationValidators.validatePlateNumber(
            _plateNumberController.text);
      });

      if (!_step3Key.currentState!.validate() || _plateNumberError != null) {
        AppSnackBar.showError(
            context, 'Iltimos, avtomobil ma\'lumotlarini to\'g\'ri to\'ldiring');
        return;
      }

      if ((_photos['tech_passport_front'] ?? '').isEmpty ||
          (_photos['tech_passport_back'] ?? '').isEmpty) {
        AppSnackBar.showError(context,
            'Iltimos, texnik pasportning old va orqa suratlarini yuklang');
        return;
      }

      if ((_photos['car_front_photo'] ?? '').isEmpty ||
          (_photos['car_interior_photo'] ?? '').isEmpty) {
        AppSnackBar.showError(context,
            'Iltimos, avtomobilning old va salon suratlarini yuklang');
        return;
      }

      setState(() => _currentStep = 3);
      _pageController.animateToPage(
        3,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _previousStep() {
    FocusScope.of(context).unfocus();
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOutCubic,
      );
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _onStepTapped(int stepIndex) {
    if (stepIndex < _currentStep) {
      FocusScope.of(context).unfocus();
      setState(() => _currentStep = stepIndex);
      _pageController.animateToPage(
        stepIndex,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Tizimdan chiqish',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Haqiqatan ham profilingizdan chiqmoqchimisiz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const LogoutEvent());
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Chiqish'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    if (!_hasConsent) {
      AppSnackBar.showError(
        context,
        'Iltimos, qoidalar va shartlarga rozilik bildiring',
      );
      return;
    }

    final plateClean =
        VerificationNormalizers.normalizePlateNumber(_plateNumberController.text);
    final plateError = VerificationValidators.validatePlateNumber(plateClean);
    if (plateError != null) {
      AppSnackBar.showError(context, plateError);
      return;
    }

    final requiredPhotos = [
      ('driver_license_front', 'Guvohnoma (Oldi)'),
      ('driver_license_back', 'Guvohnoma (Orqasi)'),
      ('tech_passport_front', 'Tex passport (Oldi)'),
      ('tech_passport_back', 'Tex passport (Orqasi)'),
      ('car_front_photo', 'Avtomobil (Oldi)'),
      ('car_interior_photo', 'Avtomobil (Saloni)'),
    ];

    for (final item in requiredPhotos) {
      final path = _photos[item.$1] ?? '';
      if (path.isEmpty) {
        AppSnackBar.showError(
            context, 'Iltimos, ${item.$2} fotosuratini yuklang');
        return;
      }
      final file = File(path);
      if (!file.existsSync()) {
        AppSnackBar.showError(
          context,
          '${item.$2} fotosurati fayli topilmadi. Qaytadan tanlang.',
        );
        return;
      }
    }

    final formData = DriverVerificationFormData(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      birthDate: _birthDateController.text.trim(),
      gender: 'male',
      carModel: _carModelController.text.trim(),
      carColor: _carColorController.text.trim(),
      carYear: int.tryParse(_carYearController.text.trim()) ?? 2022,
      plateNumber: plateClean,
      carSeatsCount: _carSeatsCount,
      hasAc: _hasAc,
      techPassportSeries: _techPassportSeriesController.text.trim(),
      techPassportNumber: _techPassportNumberController.text.trim(),
      licenseSeries: _licenseSeriesController.text.trim(),
      licenseNumber: _licenseNumberController.text.trim(),
      photos: _photos,
    );

    final requestDto = DriverVerificationRequestDto.fromFormData(formData);

    final avatarPath = _photos['avatar'] ?? '';
    if (avatarPath.isNotEmpty) {
      final avatarFile = File(avatarPath);
      if (avatarFile.existsSync()) {
        context.read<ProfileBloc>().add(UploadAvatarEvent(avatarFile));
      }
    }

    setState(() => _isSubmitting = true);

    // 1. Admin tekshiruvini kutmasdan, hozircha darhol 'approved' deb saqlash
    if (sl.isRegistered<SecureStorageService>()) {
      await sl<SecureStorageService>().saveVerificationStatus('approved');
    }

    if (!mounted) return;

    // 2. Serverga ham ilova foni orqali arizani yuborish
    try {
      context.read<VerificationBloc>().add(
            SubmitDriverApplicationEvent(
              textFields: requestDto.toTextFieldsMap(),
              photoFiles: requestDto.photoFiles,
            ),
          );
    } catch (_) {}

    // 3. Foydalanuvchini to'g'ridan-to'g'ri ilovaga kiritish
    if (mounted) {
      setState(() => _isSubmitting = false);
      context.read<ProfileBloc>().add(const LoadProfileEvent(refresh: true));
      HapticFeedback.heavyImpact();
      AppSnackBar.showSuccess(
        context,
        'Muvaffaqiyatli kirdingiz!',
      );
      context.go('/driver/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = context.watch<ProfileBloc>().state.profile;
    final userPhone = profile?.phone ?? '';

    if (!_profileInitialized && profile != null) {
      _profileInitialized = true;
      _prefillFromProfile(profile);
    }

    final verificationStatus =
        profile?.verificationStatus ?? 'pending_submission';
    // Admin tekshiruvi (under_review) va tasdiqlangan (approved) holatda to'xtatib qo'ymaslik
    final bool showStatusScreen = !_forceShowForm &&
        (verificationStatus == 'rejected' ||
            verificationStatus == 'action_required');

    if (showStatusScreen) {
      return Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor:
              isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => context.go('/driver/home'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: AppColors.error),
              tooltip: 'Tizimdan chiqish',
              onPressed: () => _confirmLogout(context),
            ),
          ],
          title: Text(
            'Verifikatsiya holati',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: isDark ? Colors.white : AppColors.charcoalBlack,
            ),
          ),
        ),
        body: VerificationStatusView(
          status: verificationStatus,
          isDark: isDark,
          rejectionReason: profile?.rejectionReason,
          driverName: profile?.fullName,
          onEditApplication: () {
            _prefillFromProfile(profile);
            setState(() {
              _forceShowForm = true;
              _currentStep = 0;
            });
          },
          onRefreshStatus: () {
            context.read<ProfileBloc>().add(const LoadProfileEvent());
          },
          onGoHome: () {
            context.go('/driver/home');
          },
        ),
      );
    }

    return PopScope(
      canPop: _currentStep == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _currentStep > 0) {
          _previousStep();
        }
      },
      child: BlocConsumer<VerificationBloc, VerificationState>(
        listener: (context, state) {
          if (state is ApplicationSubmittedSuccessState) {
            setState(() => _isSubmitting = false);
            context.read<ProfileBloc>().add(const LoadProfileEvent(refresh: true));
            AppSnackBar.showSuccess(
              context,
              'Ma\'lumotlaringiz adminga yuborildi! 12 soat ichida tekshiriladi. Hozircha ilovadan to\'liq foydalanishingiz mumkin.',
            );
            // Hozircha ma'lumotlarni to'ldirib bo'lgach to'g'ridan-to'g'ri ilovaga kiritib yuborish
            context.go('/driver/home');
          } else if (state is VerificationErrorState) {
            setState(() => _isSubmitting = false);
            AppSnackBar.showError(context, state.message);
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
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: _previousStep,
              ),
              title: Text(
                'Haydovchi verifikatsiyasi',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: isDark ? Colors.white : AppColors.charcoalBlack,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(
                  color: isDark
                      ? AppColors.borderDark
                      : AppColors.borderLight,
                  height: 1,
                ),
              ),
            ),
            body: Column(
              children: [
                // Step Progress Indicator
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.xs,
                  ),
                  child: VerificationStepProgress(
                    currentStep: _currentStep,
                    totalSteps: 4,
                    isDark: isDark,
                    onStepTapped: _onStepTapped,
                  ),
                ),

                // Smooth Sliding PageView (No flickering/rebuilding)
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      // Step 0: Shaxsiy ma'lumotlar
                      SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.sm,
                          AppSpacing.lg,
                          20,
                        ),
                        child: Form(
                          key: _step1Key,
                          child: Step1PersonalInfoView(
                            isDark: isDark,
                            firstNameController: _firstNameController,
                            lastNameController: _lastNameController,
                            middleNameController: _middleNameController,
                            birthDateController: _birthDateController,
                            userPhone: userPhone,
                            photos: _photos,
                            onPickPhoto: (key) =>
                                _showPhotoSourceSheet(context, key),
                            onRemovePhoto: (key) =>
                                setState(() => _photos[key] = ''),
                            onPickDate: _pickDateForController,
                          ),
                        ),
                      ),

                      // Step 1: Haydovchilik guvohnomasi
                      SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.sm,
                          AppSpacing.lg,
                          20,
                        ),
                        child: Form(
                          key: _step2Key,
                          child: Step2LicenseView(
                            isDark: isDark,
                            licenseSeriesController: _licenseSeriesController,
                            licenseNumberController: _licenseNumberController,
                            licenseIssueDateController:
                                _licenseIssueDateController,
                            licenseExpiryDateController:
                                _licenseExpiryDateController,
                            selectedCategories: _selectedCategories,
                            onCategoryToggled: _onCategoryToggled,
                            photos: _photos,
                            onPickPhoto: (key) =>
                                _showPhotoSourceSheet(context, key),
                            onRemovePhoto: (key) =>
                                setState(() => _photos[key] = ''),
                            onPickDate: _pickDateForController,
                          ),
                        ),
                      ),

                      // Step 2: Avtomobil ma'lumotlari
                      SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.sm,
                          AppSpacing.lg,
                          20,
                        ),
                        child: Form(
                          key: _step3Key,
                          child: Step3VehicleView(
                            isDark: isDark,
                            carModelController: _carModelController,
                            carColorController: _carColorController,
                            carYearController: _carYearController,
                            plateNumberController: _plateNumberController,
                            plateNumberError: _plateNumberError,
                            carSeatsCount: _carSeatsCount,
                            hasAc: _hasAc,
                            ownershipType: _ownershipType,
                            techPassportSeriesController:
                                _techPassportSeriesController,
                            techPassportNumberController:
                                _techPassportNumberController,
                            photos: _photos,
                            onCarSeatsChanged: (_) {},
                            onHasAcChanged: (v) => setState(() => _hasAc = v),
                            onOwnershipTypeChanged: (v) =>
                                setState(() => _ownershipType = v),
                            onPlateNumberChanged: (v) => setState(() {
                              _plateNumberError =
                                  VerificationValidators.validatePlateNumber(v);
                            }),
                            onPickPhoto: (key) =>
                                _showPhotoSourceSheet(context, key),
                            onRemovePhoto: (key) =>
                                setState(() => _photos[key] = ''),
                          ),
                        ),
                      ),

                      // Step 3: Tekshirish va Yuborish
                      SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.sm,
                          AppSpacing.lg,
                          30,
                        ),
                        child: Step4ReviewSubmitView(
                          isDark: isDark,
                          fullName:
                              '${_lastNameController.text} ${_firstNameController.text} ${_middleNameController.text}'
                                  .trim(),
                          birthDate: _birthDateController.text.trim(),
                          userPhone: userPhone,
                          licenseSeriesNumber:
                              '${_licenseSeriesController.text.trim()} ${_licenseNumberController.text.trim()}'
                                  .trim(),
                          licenseExpiryDate:
                              _licenseExpiryDateController.text.trim(),
                          licenseCategories: _selectedCategories,
                          carModel: _carModelController.text.trim(),
                          carColor: _carColorController.text.trim(),
                          carYear: _carYearController.text.trim(),
                          plateNumber: _plateNumberController.text.trim(),
                          carSeatsCount: _carSeatsCount,
                          hasAc: _hasAc,
                          techPassportSeriesNumber:
                              '${_techPassportSeriesController.text.trim().toUpperCase()} ${_techPassportNumberController.text.trim()}'
                                  .trim(),
                          photos: _photos,
                          hasConsent: _hasConsent,
                          onConsentChanged: (val) =>
                              setState(() => _hasConsent = val ?? false),
                          onEditStep: (stepIndex) {
                            setState(() => _currentStep = stepIndex);
                            _pageController.animateToPage(
                              stepIndex,
                              duration: const Duration(milliseconds: 280),
                              curve: Curves.easeInOutCubic,
                            );
                          },
                          onSubmit: _submit,
                          isSubmitting: isSubmitting,
                        ),
                      ),
                    ],
                  ),
                ),

                // Responsive Bottom Navigation Bar for Steps 0, 1, 2
                if (_currentStep < 3)
                  Container(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      12,
                      AppSpacing.lg,
                      16,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceDark
                          : Colors.white,
                      border: Border(
                        top: BorderSide(
                          color: isDark
                              ? const Color(0xFF262C3A)
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Row(
                        children: [
                          if (_currentStep > 0) ...[
                            // Square back button without text (Cannot overflow!)
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E212B)
                                    : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF2C3242)
                                      : const Color(0xFFE5E7EB),
                                  width: 1.2,
                                ),
                              ),
                              child: IconButton(
                                tooltip: 'Orqaga',
                                icon: Icon(
                                  Icons.arrow_back_rounded,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.charcoalBlack,
                                  size: 22,
                                ),
                                onPressed: _previousStep,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: AppButton(
                              text: 'Keyingi bosqich',
                              onPressed: _nextStep,
                              variant: AppButtonVariant.taxi,
                              height: 52,
                              trailingIcon: const Icon(
                                Icons.arrow_forward_rounded,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
