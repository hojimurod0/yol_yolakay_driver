import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Professional RegisterPage matching the sleek dark mockup design
/// with Terms of Service, Privacy Policy & Safety permissions.
/// - Native OutlineInputBorder with notch floating label
/// - Phone formatting up to 9 digits (XX XXX XX XX)
/// - SMS kodni olish CTA button directly below checkbox (no Spacer)
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _agreeToTerms = false;
  String? _phoneError;
  String? _termsError;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(() {
      if (_phoneError != null) {
        setState(() => _phoneError = null);
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

    bool isValid = true;
    setState(() {
      if (rawPhone.length != 9) {
        _phoneError = 'Telefon raqamini to\'liq kiriting (9 ta raqam)';
        isValid = false;
      } else {
        _phoneError = null;
      }

      if (!_agreeToTerms) {
        _termsError =
            'Xizmat ko\'rsatish shartlari va maxfiylik siyosatiga rozilik bering';
        isValid = false;
      } else {
        _termsError = null;
      }
    });

    if (!_agreeToTerms) {
      _showLegalBottomSheet(context);
    }

    if (!isValid) return;

    final fullPhone = '+998$rawPhone';
    context.read<AuthBloc>().add(SendOtpEvent(fullPhone));
  }

  void _showLegalBottomSheet(BuildContext context) {
    HapticFeedback.selectionClick();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryYellow = Color(0xFFFFA000);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF161922) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.45,
          maxChildSize: 0.92,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ListView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: primaryYellow.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.verified_user_rounded,
                          color: primaryYellow,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Maxfiylik va Xavfsizlik shartlari',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: isDark
                                ? Colors.white
                                : AppColors.charcoalBlack,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _buildLegalItem(
                    icon: Icons.lock_outline_rounded,
                    title: '1. Maxfiylik va ma\'lumotlar xavfsizligi',
                    description:
                        'Sizning telefon raqamingiz, shaxsiy ma\'lumotlaringiz va ilovadagi amaliyotlaringiz xavfsiz shifrlangan holda saqlanadi hamda uchinchi tomonlarga berilmaydi.',
                    isDark: isDark,
                  ),
                  _buildLegalItem(
                    icon: Icons.my_location_rounded,
                    title: '2. Geolokatsiya va xavfsiz harakatlanish',
                    description:
                        'Haydovchi sifatida buyurtmalarni qabul qilish va yo\'lovchilar xavfsizligini ta\'minlash uchun aniq joylashuv ma\'lumotlaridan foydalanishga rozilik bildirasiz.',
                    isDark: isDark,
                  ),
                  _buildLegalItem(
                    icon: Icons.security_rounded,
                    title: '3. Qoidalar va javobgarlik',
                    description:
                        'Yo\'l harakati xavfsizligi qoidalariga rioya qilish, yo\'lovchilarga xushmuomalada bo\'lish va xizmat sifatini yuqori darajada saqlash talab etiladi.',
                    isDark: isDark,
                  ),
                  _buildLegalItem(
                    icon: Icons.account_balance_wallet_outlined,
                    title: '4. To\'lovlar va hisob-kitob shaffofligi',
                    description:
                        'Barcha qatnovlar va to\'lovlar shaffof hisoblanadi. Tizim qoidalariga zid harakatlar profil cheklanishiga olib kelishi mumkin.',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: primaryYellow.withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _agreeToTerms = true;
                          _termsError = null;
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryYellow,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Tushundim va Roziman',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLegalItem({
    required IconData icon,
    required String title,
    required String description,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 20,
              color: const Color(0xFFFFA000),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      color: isDark ? Colors.white : AppColors.charcoalBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.45,
                      color: isDark
                          ? const Color(0xFF9EA3B2)
                          : AppColors.textSecondary,
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg =
        isDark ? const Color(0xFF111319) : AppColors.backgroundLight;
    final cardBg = isDark ? const Color(0xFF161922) : Colors.white;
    const primaryYellow = Color(0xFFFFA000);

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is OtpSentState) {
          HapticFeedback.mediumImpact();
          context.push('/otp', extra: {
            'phone': state.phone,
            'session': state.session,
          });
        } else if (state is AuthErrorState) {
          HapticFeedback.vibrate();
          AppSnackBar.showError(context, state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: scaffoldBg,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            systemOverlayStyle:
                isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
            leading: context.canPop()
                ? IconButton(
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
                    onPressed: () => context.pop(),
                  )
                : null,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),

                    // Brand Yellow Circle Logo with ambient glow
                    Center(
                      child: Container(
                        width: 82,
                        height: 82,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDBE11),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primaryYellow.withValues(alpha: 0.38),
                              blurRadius: 36,
                              spreadRadius: 6,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Image.asset(
                          'assets/icon/app_icon.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                            child: Text(
                              'y',
                              style: TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                                fontStyle: FontStyle.italic,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Title: Ro'yxatdan o'tish
                    Text(
                      'Ro\'yxatdan o\'tish',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 26,
                        letterSpacing: -0.4,
                        color: isDark ? Colors.white : AppColors.charcoalBlack,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    // Subtitle: Telefon raqamga SMS kod yuboriladi
                    Text(
                      'Telefon raqamga SMS kod yuboriladi',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: isDark
                            ? const Color(0xFF8E93A2)
                            : AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    // Phone Input Field (Native Notch OutlineInputBorder)
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.charcoalBlack,
                        letterSpacing: 0.8,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
                        _PhoneNumberFormatter(),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Telefon raqami',
                        labelStyle: const TextStyle(
                          color: Color(0xFF8E93A2),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        floatingLabelStyle: TextStyle(
                          color: _phoneError != null
                              ? AppColors.error
                              : primaryYellow,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        filled: true,
                        fillColor: cardBg,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 16, right: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '+998',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.charcoalBlack,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                width: 1,
                                height: 22,
                                color: isDark
                                    ? const Color(0xFF2B3242)
                                    : Colors.black12,
                              ),
                            ],
                          ),
                        ),
                        prefixIconConstraints:
                            const BoxConstraints(minWidth: 0, minHeight: 0),
                        hintText: '90 123 45 67',
                        hintStyle: TextStyle(
                          color: isDark
                              ? const Color(0xFF4B5162)
                              : Colors.black26,
                          fontWeight: FontWeight.w500,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: isDark
                                ? const Color(0xFF262C3A)
                                : AppColors.borderLight,
                            width: 1.2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: primaryYellow,
                            width: 1.5,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppColors.error,
                            width: 1.5,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppColors.error,
                            width: 1.5,
                          ),
                        ),
                        errorText: _phoneError,
                        errorStyle: const TextStyle(
                          color: AppColors.error,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onSubmitted: (_) => _handleSendOtp(),
                    ),

                    const SizedBox(height: 20),

                    // Terms and Privacy Policy Checkbox
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Checkbox(
                            value: _agreeToTerms,
                            activeColor: primaryYellow,
                            checkColor: Colors.black,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            side: BorderSide(
                              color: _termsError != null
                                  ? AppColors.error
                                  : (isDark
                                      ? const Color(0xFF3C4354)
                                      : AppColors.borderLight),
                              width: 1.5,
                            ),
                            onChanged: (val) {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _agreeToTerms = val ?? false;
                                if (_agreeToTerms) {
                                  _termsError = null;
                                }
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: 'Men ',
                              style: TextStyle(
                                fontSize: 12.5,
                                height: 1.35,
                                color: isDark
                                    ? const Color(0xFFC7CBD6)
                                    : AppColors.textSecondary,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Xizmat ko\'rsatish shartlari',
                                  style: const TextStyle(
                                    color: primaryYellow,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () =>
                                        _showLegalBottomSheet(context),
                                ),
                                const TextSpan(text: ' hamda '),
                                TextSpan(
                                  text: 'Maxfiylik siyosati',
                                  style: const TextStyle(
                                    color: primaryYellow,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () =>
                                        _showLegalBottomSheet(context),
                                ),
                                const TextSpan(text: 'ga roziman'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (_termsError != null) ...[
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _termsError!,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 28),

                    // Glowing CTA Button: SMS kodni olish (Placed directly below checkbox)
                    Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: primaryYellow.withValues(alpha: 0.38),
                            blurRadius: 24,
                            spreadRadius: 1,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: isLoading ? () {} : _handleSendOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryYellow,
                          foregroundColor: Colors.black,
                          disabledBackgroundColor: primaryYellow,
                          disabledForegroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.black,
                                  ),
                                ),
                              )
                            : const Text(
                                'SMS kodni olish',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                  letterSpacing: 0.3,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Footer: Akkauntingiz bormi? Kirish
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Akkauntingiz bormi? ',
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFF8E93A2)
                                : AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.push('/login');
                            }
                          },
                          child: const Text(
                            'Kirish',
                            style: TextStyle(
                              color: primaryYellow,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Phone Formatter for Uzbekistan numbers (XX XXX XX XX)
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Handle backspace when the previous character was a space
    if (oldValue.text.endsWith(' ') &&
        newValue.text.length == oldValue.text.length - 1 &&
        digits.isNotEmpty) {
      digits = digits.substring(0, digits.length - 1);
    }

    if (digits.length > 9) {
      return oldValue;
    }
    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 2 || i == 5 || i == 7) buffer.write(' ');
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
