import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Clean Driver Phone Login Screen conforming to Passenger App standards.
class PhonePage extends StatefulWidget {
  const PhonePage({super.key});

  @override
  State<PhonePage> createState() => _PhonePageState();
}

class _PhonePageState extends State<PhonePage> {
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _errorText;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(() {
      final hasNow = _phoneController.text.isNotEmpty;
      if (hasNow != _hasText) {
        setState(() => _hasText = hasNow);
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSendOtp() {
    HapticFeedback.mediumImpact();
    final rawPhone = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (rawPhone.length != 9) {
      setState(() {
        _errorText = 'Telefon raqamini to\'liq kiriting (9 ta raqam)';
      });
      return;
    }

    setState(() => _errorText = null);
    final fullPhone = '+998$rawPhone';
    context.read<AuthBloc>().add(SendOtpEvent(fullPhone));
  }

  void _showTermsModal(BuildContext context, bool isRu) {
    HapticFeedback.selectionClick();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: ListView(
                controller: scrollController,
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
                  const SizedBox(height: 16),
                  Text(
                    isRu
                        ? 'Условия сервиса и Политика конфиденциальности'
                        : 'Xizmat ko‘rsatish shartlari va Maxfiylik siyosati',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.charcoalBlack,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isRu
                        ? '1. Сервис Yo‘l-Yo‘lakay предоставляет платформу для пассажиров и профессиональных водителей.\n\n'
                            '2. Ваши персональные данные (номер телефона, локация, данные автомобиля) защищены и используются исключительно для обеспечения поездок и безопасности.\n\n'
                            '3. Продолжая использование, вы подтверждаете достоверность предоставляемых сведений и соглашаетесь с правилами сервиса.'
                        : '1. Yo‘l-Yo‘lakay xizmati haydovchilar va yo‘lovchilar uchun yagona ishonchli platformani taqdim etadi.\n\n'
                            '2. Shaxsiy ma’lumotlaringiz (telefon raqami, GPS joylashuvi, avtomobil ma’lumotlari) xavfsiz himoyalangan bo‘lib, faqat buyurtmalarni bajarish va xavfsizlik maqsadida foydalaniladi.\n\n'
                            '3. Tizimdan foydalanish orqali barcha qoidalarga va xavfsizlik talablariga rozilik bildirasiz.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    text: isRu ? 'Понятно' : 'Tushundim',
                    onPressed: () => Navigator.pop(context),
                    variant: AppButtonVariant.taxi,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localeCode = Localizations.localeOf(context).languageCode;
    final isRu = localeCode == 'ru';

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is OtpSentState) {
          context.push('/otp', extra: {
            'phone': state.phone,
            'session': state.session,
          });
        } else if (state is AuthErrorState) {
          AppSnackBar.showError(context, state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor:
              isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: isDark ? Colors.white : Colors.black87,
                  size: 20,
                ),
              ),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                }
              },
            ),
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight - 20),
                    child: IntrinsicHeight(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),

                            // App Logo
                            const AppLogo(size: 84, showGlow: true),

                            const SizedBox(height: 24),

                            // Header Titles
                            Text(
                              isRu
                                  ? 'Вход для водителей'
                                  : 'Haydovchi sifatida kirish',
                              style: AppTypography.displayMedium.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 24,
                                letterSpacing: -0.4,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.charcoalBlack,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 8),

                            Text(
                              isRu
                                  ? 'Введите номер телефона для получения SMS-кода'
                                  : 'SMS orqali tasdiqlash kodini olish uchun raqamingizni kiriting',
                              style: AppTypography.bodyMedium.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                                fontSize: 13.5,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 36),

                            // Phone Input with Floating Label and Clear Button
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 4, bottom: 6),
                                  child: Text(
                                    isRu ? 'Номер телефона' : 'Telefon raqam',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppColors.taxiYellow : AppColors.primaryDark,
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.surfaceDark
                                        : AppColors.surfaceLight,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: _errorText != null
                                          ? AppColors.error
                                          : (isDark
                                              ? AppColors.borderDark
                                              : AppColors.borderLight),
                                      width: 1.0,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                            alpha: isDark ? 0.2 : 0.04),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  child: Row(
                                    children: [
                                      // Prefix Code +998
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? const Color(0xFF282834)
                                              : const Color(0xFFF3F4F6),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            const Text('🇺🇿',
                                                style: TextStyle(fontSize: 18)),
                                            const SizedBox(width: 6),
                                            Text(
                                              '+998',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 15,
                                                color: isDark
                                                    ? Colors.white
                                                    : AppColors.charcoalBlack,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      // Digits Field
                                      Expanded(
                                        child: TextField(
                                          controller: _phoneController,
                                          keyboardType: TextInputType.phone,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.digitsOnly,
                                            LengthLimitingTextInputFormatter(9),
                                            _UzbekPhoneFormatter(),
                                          ],
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 1.2,
                                            color: isDark
                                                ? Colors.white
                                                : AppColors.charcoalBlack,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: '90 123 45 67',
                                            hintStyle: TextStyle(
                                              color: isDark
                                                  ? Colors.white24
                                                  : Colors.black26,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 1.2,
                                            ),
                                            border: InputBorder.none,
                                          ),
                                          onSubmitted: (_) => _handleSendOtp(),
                                        ),
                                      ),

                                      // Clear button when entered
                                      if (_hasText)
                                        IconButton(
                                          icon: Icon(
                                            Icons.cancel_rounded,
                                            size: 18,
                                            color: isDark
                                                ? Colors.white38
                                                : Colors.black26,
                                          ),
                                          onPressed: () {
                                            _phoneController.clear();
                                            setState(() => _errorText = null);
                                          },
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            if (_errorText != null) ...[
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  _errorText!,
                                  style: const TextStyle(
                                    color: AppColors.error,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],

                            const Spacer(),

                            // Continue CTA Button
                            SizedBox(
                              width: double.infinity,
                              child: AppButton(
                                text: isRu ? 'Продолжить' : 'Davom etish',
                                onPressed: _handleSendOtp,
                                isLoading: isLoading,
                                variant: AppButtonVariant.taxi,
                                height: 52,
                                trailingIcon: const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 20),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Terms disclaimer with clickable BottomSheet
                            GestureDetector(
                              onTap: () => _showTermsModal(context, isRu),
                              child: Text(
                                isRu
                                    ? 'Продолжая, вы соглашаетесь с условиями сервиса'
                                    : 'Davom etish orqali foydalanish shartlariga rozilik bildirasiz',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  decoration: TextDecoration.underline,
                                  color: isDark
                                      ? Colors.white54
                                      : AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

/// Custom formatter for "90 123 45 67" format.
class _UzbekPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      if (i == 2 || i == 5 || i == 7) {
        buffer.write(' ');
      }
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
