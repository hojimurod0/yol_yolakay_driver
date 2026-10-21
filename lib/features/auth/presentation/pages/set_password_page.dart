import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// State-of-the-art Driver SetPasswordPage matching Yo'l-Yo'lakay passenger architecture
/// with smooth micro-animations, real-time strength meter, and interactive checklist.
class SetPasswordPage extends StatefulWidget {
  const SetPasswordPage({
    super.key,
    this.nextRoute,
  });

  final String? nextRoute;

  @override
  State<SetPasswordPage> createState() => _SetPasswordPageState();
}

class _SetPasswordPageState extends State<SetPasswordPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FocusNode _newPasswordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  String? _newPasswordError;
  String? _confirmPasswordError;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _heroSlideAnimation;
  late final Animation<Offset> _headerSlideAnimation;
  late final Animation<Offset> _inputsSlideAnimation;
  late final Animation<Offset> _checklistSlideAnimation;
  late final Animation<Offset> _buttonSlideAnimation;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );

    _heroSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
    ));

    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.15, 0.55, curve: Curves.easeOutCubic),
    ));

    _inputsSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic),
    ));

    _checklistSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.45, 0.85, curve: Curves.easeOutCubic),
    ));

    _buttonSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
    ));

    _newPasswordController.addListener(() {
      setState(() {
        if (_newPasswordError != null &&
            _newPasswordController.text.isNotEmpty) {
          _newPasswordError = null;
        }
      });
    });

    _confirmPasswordController.addListener(() {
      setState(() {
        if (_confirmPasswordError != null &&
            _confirmPasswordController.text.isNotEmpty) {
          _confirmPasswordError = null;
        }
      });
    });

    _newPasswordFocusNode.addListener(() => setState(() {}));
    _confirmPasswordFocusNode.addListener(() => setState(() {}));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _newPasswordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  // Password strength: 0 = empty, 1 = weak (<6), 2 = medium (>=6 letters+digits), 3 = strong (>=8 mix)
  int _calculateStrength(String text) {
    if (text.isEmpty) return 0;
    if (text.length < 6) return 1;
    final bool hasLetters = text.contains(RegExp(r'[A-Za-z]'));
    final bool hasDigits = text.contains(RegExp(r'[0-9]'));
    final bool hasSpecial = text.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));

    if (text.length >= 8 && hasLetters && hasDigits && hasSpecial) return 3;
    if (text.length >= 6 && (hasLetters && hasDigits)) return 2;
    return 1;
  }

  void _handleSavePassword(bool isRu) {
    HapticFeedback.mediumImpact();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    bool isValid = true;
    setState(() {
      if (newPassword.isEmpty) {
        _newPasswordError = isRu ? 'Введите новый пароль' : 'Yangi parolni kiriting';
        isValid = false;
      } else if (newPassword.length < 6) {
        _newPasswordError = isRu
            ? 'Пароль должен содержать минимум 6 символов'
            : 'Parol kamida 6 ta belgidan iborat bo\'lishi kerak';
        isValid = false;
      } else {
        _newPasswordError = null;
      }

      if (confirmPassword.isEmpty) {
        _confirmPasswordError =
            isRu ? 'Подтвердите пароль' : 'Parolni tasdiqlang';
        isValid = false;
      } else if (confirmPassword != newPassword) {
        _confirmPasswordError =
            isRu ? 'Пароли не совпадают' : 'Parollar bir-biriga mos kelmadi';
        isValid = false;
      } else {
        _confirmPasswordError = null;
      }
    });

    if (!isValid) return;

    context.read<AuthBloc>().add(SetPasswordEvent(newPassword));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localeCode = Localizations.localeOf(context).languageCode;
    final isRu = localeCode == 'ru';

    final scaffoldBg =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final borderCol = isDark ? AppColors.borderDark : AppColors.borderLight;

    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;
    final strength = _calculateStrength(newPass);

    final hasMinLength = newPass.length >= 6;
    final hasNumber = newPass.contains(RegExp(r'[0-9]'));
    final isMatching = confirmPass.isNotEmpty && confirmPass == newPass;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is PasswordSetSuccessState || state is AuthenticatedState) {
          HapticFeedback.heavyImpact();
          AppSnackBar.showSuccess(
            context,
            isRu
                ? 'Пароль успешно сохранён!'
                : 'Parol muvaffaqiyatli saqlandi!',
          );
          final destination = widget.nextRoute ?? '/driver/home';
          if (context.canPop() && widget.nextRoute == null) {
            context.pop();
          } else {
            context.go(destination);
          }
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
            actions: [
              if (widget.nextRoute != null)
                TextButton(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    context.go(widget.nextRoute!);
                  },
                  child: Text(
                    isRu ? 'Пропустить' : 'O‘tkazish',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),

                    // 1. Hero Badge with animated slide & ambient pulse
                    SlideTransition(
                      position: _heroSlideAnimation,
                      child: Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.taxiYellow
                                .withValues(alpha: isDark ? 0.16 : 0.12),
                            border: Border.all(
                              color: AppColors.taxiYellow
                                  .withValues(alpha: 0.5),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.taxiYellow
                                    .withValues(alpha: isDark ? 0.3 : 0.18),
                                blurRadius: 28,
                                spreadRadius: 2,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.lock_reset_rounded,
                              color: AppColors.taxiYellow,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 2. Title & Subtitle with smooth slide
                    SlideTransition(
                      position: _headerSlideAnimation,
                      child: Column(
                        children: [
                          Text(
                            isRu ? 'Создание пароля' : 'Parol yaratish',
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
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              isRu
                                  ? 'Установите надёжный пароль для безопасного входа в аккаунт водителя'
                                  : 'Haydovchi profilingiz xavfsizligi va keyingi tezkor kirishlar uchun yangi parol o‘rnating',
                              style: AppTypography.bodyMedium.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                                fontSize: 13.5,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // 3. Inputs Section with Staggered Slide
                    SlideTransition(
                      position: _inputsSlideAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // New Password Input
                          _buildPasswordField(
                            controller: _newPasswordController,
                            focusNode: _newPasswordFocusNode,
                            isDark: isDark,
                            cardBg: cardBg,
                            borderCol: borderCol,
                            label: isRu ? 'Новый пароль' : 'Yangi parol',
                            hintText: isRu
                                ? 'Минимум 6 символов'
                                : 'Kamida 6 ta belgi kiriting',
                            icon: Icons.lock_outline_rounded,
                            obscureText: _obscureNewPassword,
                            onToggleVisibility: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _obscureNewPassword = !_obscureNewPassword;
                              });
                            },
                            errorText: _newPasswordError,
                            onSubmitted: (_) =>
                                _confirmPasswordFocusNode.requestFocus(),
                          ),

                          // Live Password Strength Bar
                          if (newPass.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _buildStrengthBar(
                              strength: strength,
                              isDark: isDark,
                              isRu: isRu,
                            ),
                          ],

                          const SizedBox(height: 18),

                          // Confirm Password Input
                          _buildPasswordField(
                            controller: _confirmPasswordController,
                            focusNode: _confirmPasswordFocusNode,
                            isDark: isDark,
                            cardBg: cardBg,
                            borderCol: borderCol,
                            label: isRu
                                ? 'Подтвердите пароль'
                                : 'Parolni tasdiqlang',
                            hintText: isRu
                                ? 'Повторите новый пароль'
                                : 'Parolni qaytadan kiriting',
                            icon: Icons.verified_user_outlined,
                            obscureText: _obscureConfirmPassword,
                            onToggleVisibility: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                            errorText: _confirmPasswordError,
                            onSubmitted: (_) => _handleSavePassword(isRu),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // 4. Interactive Animated Checklist Card
                    SlideTransition(
                      position: _checklistSlideAnimation,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF161922)
                              : const Color(0xFFF8FAFC),
                          borderRadius: AppRadius.borderLg,
                          border: Border.all(color: borderCol, width: 1.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCheckRuleItem(
                              isValid: hasMinLength,
                              label: isRu
                                  ? 'Минимум 6 символов'
                                  : 'Kamida 6 ta belgi',
                              isDark: isDark,
                            ),
                            const SizedBox(height: 8),
                            _buildCheckRuleItem(
                              isValid: hasNumber,
                              label: isRu
                                  ? 'Минимум одна цифра (0-9)'
                                  : 'Kamida bitta raqam (0-9)',
                              isDark: isDark,
                            ),
                            const SizedBox(height: 8),
                            _buildCheckRuleItem(
                              isValid: isMatching,
                              label: isRu
                                  ? 'Пароли совпадают'
                                  : 'Parollar bir-biriga mos keladi',
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 5. Glowing CTA Button with slide & micro-bounce
                    SlideTransition(
                      position: _buttonSlideAnimation,
                      child: Container(
                        width: double.infinity,
                        height: AppDimensions.buttonHeightLg,
                        decoration: BoxDecoration(
                          borderRadius: AppRadius.borderLg,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.taxiYellow
                                  .withValues(alpha: isDark ? 0.35 : 0.25),
                              blurRadius: 22,
                              spreadRadius: 1,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () => _handleSavePassword(isRu),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.taxiYellow,
                            foregroundColor: AppColors.charcoalBlack,
                            disabledBackgroundColor: AppColors.taxiYellow
                                .withValues(alpha: 0.6),
                            elevation: 0,
                            shape: const RoundedRectangleBorder(
                              borderRadius: AppRadius.borderLg,
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.charcoalBlack,
                                    ),
                                  ),
                                )
                              : Text(
                                  isRu
                                      ? 'Сохранить и продолжить'
                                      : 'Parolni saqlash va davom etish',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.charcoalBlack,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    // Skip action if inside registration pipeline
                    if (widget.nextRoute != null) ...[
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          context.go(widget.nextRoute!);
                        },
                        child: Text(
                          isRu ? 'Настроить позже' : 'Keyinroq o‘rnatish',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],

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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isDark,
    required Color cardBg,
    required Color borderCol,
    required String label,
    required String hintText,
    required IconData icon,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required String? errorText,
    required ValueChanged<String> onSubmitted,
  }) {
    final isFocused = focusNode.hasFocus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: errorText != null
                  ? AppColors.error
                  : (isFocused
                      ? AppColors.taxiYellow
                      : (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight)),
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: AppRadius.borderLg,
            border: Border.all(
              color: errorText != null
                  ? AppColors.error
                  : (isFocused ? AppColors.taxiYellow : borderCol),
              width: isFocused ? 1.6 : 1.0,
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: AppColors.taxiYellow.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscureText,
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.charcoalBlack,
              letterSpacing: obscureText ? 2.0 : 0.4,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                letterSpacing: 0,
              ),
              prefixIcon: Icon(
                icon,
                color: isFocused
                    ? AppColors.taxiYellow
                    : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
                size: 20,
              ),
              suffixIcon: IconButton(
                splashRadius: 20,
                icon: Icon(
                  obscureText
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  size: 20,
                ),
                onPressed: onToggleVisibility,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            onSubmitted: onSubmitted,
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 13,
                  color: AppColors.error,
                ),
                const SizedBox(width: 4),
                Text(
                  errorText,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStrengthBar({
    required int strength,
    required bool isDark,
    required bool isRu,
  }) {
    Color getStrengthColor(int level) {
      if (level <= 1) return AppColors.error;
      if (level == 2) return AppColors.warning;
      return AppColors.success;
    }

    String getStrengthText(int level) {
      if (level <= 1) {
        return isRu ? 'Слишком простой пароль' : 'Zaif parol';
      }
      if (level == 2) {
        return isRu ? 'Средняя надёжность' : 'O‘rtacha ishonchli parol';
      }
      return isRu ? 'Надёжный и безопасный пароль' : 'Kuchli va xavfsiz parol';
    }

    final activeColor = getStrengthColor(strength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (int i = 1; i <= 3; i++) ...[
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: strength >= i
                        ? activeColor
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.08)),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              if (i < 3) const SizedBox(width: 6),
            ],
          ],
        ),
        const SizedBox(height: 6),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Text(
            getStrengthText(strength),
            key: ValueKey<int>(strength),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: activeColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckRuleItem({
    required bool isValid,
    required String label,
    required bool isDark,
  }) {
    return Row(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, anim) => ScaleTransition(
            scale: anim,
            child: child,
          ),
          child: Icon(
            isValid
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            key: ValueKey<bool>(isValid),
            size: 16,
            color: isValid
                ? AppColors.success
                : (isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isValid ? FontWeight.w600 : FontWeight.w400,
              color: isValid
                  ? (isDark ? Colors.white : AppColors.charcoalBlack)
                  : (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight),
            ),
          ),
        ),
      ],
    );
  }
}
