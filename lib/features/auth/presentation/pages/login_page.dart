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

/// Professional LoginPage matching the sleek dark mockup design.
/// - Native OutlineInputBorder with notch floating label
/// - Phone formatting up to 9 digits (XX XXX XX XX)
/// - Kirish CTA button directly below input fields (no Spacer)
/// - "SMS kod orqali kirish" removed
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  String? _phoneError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(() {
      if (_phoneError != null) {
        setState(() => _phoneError = null);
      }
    });
    _passwordController.addListener(() {
      if (_passwordError != null) {
        setState(() => _passwordError = null);
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    HapticFeedback.mediumImpact();
    final rawPhone = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    final password = _passwordController.text.trim();

    bool isValid = true;
    setState(() {
      if (rawPhone.length != 9) {
        _phoneError = 'Telefon raqamini to\'liq kiriting (9 ta raqam)';
        isValid = false;
      } else {
        _phoneError = null;
      }

      if (password.isEmpty) {
        _passwordError = 'Parolni kiriting';
        isValid = false;
      } else if (password.length < 6) {
        _passwordError = 'Parol kamida 6 ta belgidan iborat bo\'lishi kerak';
        isValid = false;
      } else {
        _passwordError = null;
      }
    });

    if (!isValid) return;

    final fullPhone = '+998$rawPhone';
    context.read<AuthBloc>().add(
          LoginWithPasswordEvent(phone: fullPhone, password: password),
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
        if (state is AuthenticatedState) {
          HapticFeedback.heavyImpact();
          AppSnackBar.showSuccess(context, 'Tizimga muvaffaqiyatli kirdingiz!');
          context.go('/driver/home');
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

                    // Title: Tizimga kirish
                    Text(
                      'Tizimga kirish',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 26,
                        letterSpacing: -0.4,
                        color: isDark ? Colors.white : AppColors.charcoalBlack,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    // Subtitle: Telefon raqam va parolingiz orqali kiring
                    Text(
                      'Telefon raqam va parolingiz orqali kiring',
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
                      onSubmitted: (_) => _handleLogin(),
                    ),

                    const SizedBox(height: 20),

                    // Password Input Field (Native Notch OutlineInputBorder)
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.charcoalBlack,
                        letterSpacing: _obscurePassword ? 2.0 : 0.5,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Parol',
                        labelStyle: const TextStyle(
                          color: Color(0xFF8E93A2),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        floatingLabelStyle: TextStyle(
                          color: _passwordError != null
                              ? AppColors.error
                              : primaryYellow,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        filled: true,
                        fillColor: cardBg,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Icon(
                            Icons.lock_outline_rounded,
                            color: isDark
                                ? const Color(0xFF8E93A2)
                                : AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                        prefixIconConstraints:
                            const BoxConstraints(minWidth: 44, minHeight: 0),
                        suffixIcon: IconButton(
                          splashRadius: 20,
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: isDark
                                ? const Color(0xFF8E93A2)
                                : AppColors.textSecondary,
                            size: 20,
                          ),
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        hintText: '••••••••',
                        hintStyle: TextStyle(
                          color: isDark
                              ? const Color(0xFF4B5162)
                              : Colors.black26,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.0,
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
                        errorText: _passwordError,
                        errorStyle: const TextStyle(
                          color: AppColors.error,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onSubmitted: (_) => _handleLogin(),
                    ),

                    const SizedBox(height: 28),

                    // Glowing CTA Button: Kirish (Placed directly below input fields)
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
                        onPressed: isLoading ? () {} : _handleLogin,
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
                                'Kirish',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                  letterSpacing: 0.3,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // SMS kod orqali tezkor kirish (Alternative quick login)
                    TextButton.icon(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        context.push('/phone');
                      },
                      icon: const Icon(
                        Icons.sms_outlined,
                        size: 18,
                        color: primaryYellow,
                      ),
                      label: const Text(
                        'SMS kod orqali tezkor kirish',
                        style: TextStyle(
                          color: primaryYellow,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Footer: Akkauntingiz yo'qmi? Ro'yxatdan o'tish
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Akkauntingiz yo\'qmi? ',
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
                            context.push('/register');
                          },
                          child: const Text(
                            'Ro\'yxatdan o\'tish',
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
