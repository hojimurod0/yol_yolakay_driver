import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations_helper.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_avatar_initials.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/profile_provider.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  String? _phone;

  @override
  void initState() {
    super.initState();
    final user = ref.read(profileNotifierProvider).user;
    final locale = ref.read(localeNotifierProvider).languageCode;
    _firstNameController = TextEditingController(
      text: user?.firstName ?? (locale == 'ru' ? 'Ризо' : 'Rizo'),
    );
    _lastNameController = TextEditingController(
      text: user?.lastName ?? (locale == 'ru' ? 'Каримов' : 'Karimov'),
    );
    _phone = user?.phoneNumber ?? '+998 90 123 45 67';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty) {
      final localeCode = ref.read(localeNotifierProvider).languageCode;
      final errorMsg = localeCode == 'ru'
          ? 'Пожалуйста, заполните имя и фамилию'
          : (localeCode == 'en'
              ? 'Please fill in first and last name'
              : 'Iltimos, ism va familiyangizni kiriting');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final success =
        await ref.read(profileNotifierProvider.notifier).updateProfile(
              firstName: firstName,
              lastName: lastName,
            );

    if (success && mounted) {
      final localeCode = ref.read(localeNotifierProvider).languageCode;
      final msg = localeCode == 'ru'
          ? 'Профиль успешно обновлен'
          : (localeCode == 'en'
              ? 'Profile updated successfully'
              : 'Profil muvaffaqiyatli yangilandi');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(profileNotifierProvider);
    final localeCode = ref.watch(localeNotifierProvider).languageCode;
    final isRu = localeCode == 'ru';

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          l10n.editProfile,
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),

              // Initials Avatar Display with Taxi Yellow Ring
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _firstNameController,
                builder: (context, val1, _) {
                  return ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _lastNameController,
                    builder: (context, val2, _) {
                      final fullName = '${val1.text} ${val2.text}'.trim();
                      return Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.taxiYellow,
                            width: 3.0,
                          ),
                        ),
                        child: AppAvatarInitials(
                          name: fullName.isNotEmpty ? fullName : null,
                          size: AppDimensions.avatarXl,
                          fontSize: 32,
                        ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Form fields card
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color:
                      isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: AppRadius.borderXl,
                  border: Border.all(
                    color:
                        isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      controller: _firstNameController,
                      label: l10n.firstName,
                      prefixIcon: const Icon(Icons.person_outline_rounded,
                          color: AppColors.taxiYellowDark),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    AppTextField(
                      controller: _lastNameController,
                      label: l10n.lastName,
                      prefixIcon: const Icon(Icons.badge_outlined,
                          color: AppColors.taxiYellowDark),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Phone Number (Read-only / Verified)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 6),
                          child: Row(
                            children: [
                              Text(
                                isRu ? 'Номер телефона' : 'Telefon raqami',
                                style: AppTypography.labelMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.lock_outline_rounded,
                                  size: 14, color: AppColors.taxiYellowDark),
                            ],
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E1E26)
                                : const Color(0xFFF3F4F6),
                            borderRadius: AppRadius.borderMd,
                            border: Border.all(
                              color: isDark
                                  ? AppColors.borderDark
                                  : const Color(0xFFE5E7EB),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.phone_iphone_rounded,
                                  size: 20, color: AppColors.taxiYellowDark),
                              const SizedBox(width: 10),
                              Text(
                                _phone ?? '+998 90 123 45 67',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white70
                                      : AppColors.charcoalBlack,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.success.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isRu ? 'Подтвержден' : 'Tasdiqlangan',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.success,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxl * 1.2),

              AppButton(
                text: l10n.save,
                isLoading: state.isSaving,
                onPressed: _handleSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
