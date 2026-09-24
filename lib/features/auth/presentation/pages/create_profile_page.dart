import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations_helper.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/validator.dart';
import '../../../../core/widgets/app_avatar_initials.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class CreateProfilePage extends ConsumerStatefulWidget {
  const CreateProfilePage({super.key});

  @override
  ConsumerState<CreateProfilePage> createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends ConsumerState<CreateProfilePage> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  final TextEditingController _emailController = TextEditingController();

  String? _firstNameError;
  String? _lastNameError;

  @override
  void initState() {
    super.initState();
    final locale = ref.read(localeNotifierProvider).languageCode;
    _firstNameController =
        TextEditingController(text: locale == 'ru' ? 'Ризо' : 'Rizo');
    _lastNameController =
        TextEditingController(text: locale == 'ru' ? 'Каримов' : 'Karimov');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleComplete() async {
    final first = _firstNameController.text.trim();
    final last = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final localeCode = ref.read(localeNotifierProvider).languageCode;

    final firstErrorMsg = localeCode == 'ru'
        ? 'Имя должно содержать не менее 2 букв'
        : (localeCode == 'en'
            ? 'First name must be at least 2 characters'
            : 'Ism kamida 2 ta harf bo\'lishi kerak');

    final lastErrorMsg = localeCode == 'ru'
        ? 'Фамилия должна содержать не менее 2 букв'
        : (localeCode == 'en'
            ? 'Last name must be at least 2 characters'
            : 'Familiya kamida 2 ta harf bo\'lishi kerak');

    bool hasError = false;
    if (!AppValidator.isValidName(first)) {
      setState(() => _firstNameError = firstErrorMsg);
      hasError = true;
    } else {
      setState(() => _firstNameError = null);
    }

    if (!AppValidator.isValidName(last)) {
      setState(() => _lastNameError = lastErrorMsg);
      hasError = true;
    } else {
      setState(() => _lastNameError = null);
    }

    if (hasError) return;

    final success = await ref.read(authNotifierProvider.notifier).createProfile(
          firstName: first,
          lastName: last,
          email: email.isNotEmpty ? email : null,
        );

    if (mounted) {
      if (success) {
        context.go('/home');
      } else {
        final authError = ref.read(authNotifierProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authError ??
                (localeCode == 'ru'
                    ? 'Ошибка создания профиля'
                    : 'Profil yaratishda xatolik yuz berdi')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;
    final locale = ref.watch(localeNotifierProvider);
    final localeCode = locale.languageCode;
    final authState = ref.watch(authNotifierProvider);

    final avatarCaption = localeCode == 'ru'
        ? 'Аватар профиля (автоматически)'
        : (localeCode == 'en'
            ? 'Profile avatar (auto)'
            : 'Profil avatari (avtomatik)');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.createProfileTitle,
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.createProfileSubtitle,
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Passenger Initials Avatar Display (No profile photo required)
              Center(
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _firstNameController,
                  builder: (context, val1, _) {
                    return ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _lastNameController,
                      builder: (context, val2, _) {
                        final fullName = '${val1.text} ${val2.text}'.trim();
                        return Column(
                          children: [
                            AppAvatarInitials(
                              name: fullName.isNotEmpty ? fullName : null,
                              size: 80,
                              fontSize: 28,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              avatarCaption,
                              style: AppTypography.labelSmall.copyWith(
                                color: isDark
                                    ? AppColors.textTertiaryDark
                                    : AppColors.textTertiaryLight,
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              AppTextField(
                controller: _firstNameController,
                label: l10n.firstName,
                hint: l10n.firstNameHint,
                errorText: _firstNameError,
                textInputAction: TextInputAction.next,
                prefixIcon: const Icon(Icons.person_outline_rounded),
              ),
              const SizedBox(height: AppSpacing.lg),

              AppTextField(
                controller: _lastNameController,
                label: l10n.lastName,
                hint: l10n.lastNameHint,
                errorText: _lastNameError,
                textInputAction: TextInputAction.next,
                prefixIcon: const Icon(Icons.badge_outlined),
              ),
              const SizedBox(height: AppSpacing.lg),

              AppTextField(
                controller: _emailController,
                label: l10n.email,
                hint: l10n.emailHint,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                prefixIcon: const Icon(Icons.mail_outline_rounded),
              ),

              const SizedBox(height: AppSpacing.xxl * 1.5),

              AppButton(
                text: l10n.completeRegistration,
                isLoading: authState.status == AuthStatus.loading,
                onPressed: _handleComplete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
