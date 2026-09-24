import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/entities/driver_user_entity.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({
    super.key,
    required this.phone,
    required this.session,
  });

  final String phone;
  final OtpSessionEntity session;

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final TextEditingController _otpController = TextEditingController();
  late int _secondsRemaining;
  Timer? _countdownTimer;
  late String _currentSessionId;

  @override
  void initState() {
    super.initState();
    _currentSessionId = widget.session.sessionId;
    _secondsRemaining =
        widget.session.resendInterval > 0 ? widget.session.resendInterval : 60;
    _startTimer();
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _handleVerify() {
    final code = _otpController.text.trim();
    if (code.length < 4) return;

    HapticFeedback.mediumImpact();
    context.read<AuthBloc>().add(
          VerifyOtpEvent(
            phone: widget.phone,
            sessionId: _currentSessionId,
            code: code,
          ),
        );
  }

  void _handleResend() {
    if (_secondsRemaining > 0) return;
    HapticFeedback.selectionClick();
    setState(() => _secondsRemaining = 60);
    _startTimer();
    context.read<AuthBloc>().add(ResendOtpEvent(widget.phone));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localeCode = Localizations.localeOf(context).languageCode;
    final isRu = localeCode == 'ru';

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is OtpSentState) {
          setState(() {
            _currentSessionId = state.session.sessionId;
            _secondsRemaining = state.session.resendInterval;
          });
          _startTimer();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  isRu ? 'Код отправлен повторно' : 'SMS kod qayta yuborildi'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is AuthenticatedState) {
          final auth = state.auth;
          if (auth.isPendingOrRejected || auth.isUnderReview) {
            context.go('/verification');
          } else {
            context.go('/driver/home');
          }
        } else if (state is AuthErrorState) {
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
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: isDark ? Colors.white : Colors.black87,
                  size: 20,
                ),
              ),
              onPressed: () => context.pop(),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // Header title
                  Text(
                    isRu ? 'Подтверждение кода' : 'Tasdiqlash kodi',
                    style: AppTypography.displayMedium.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                      letterSpacing: -0.4,
                      color: isDark ? Colors.white : AppColors.charcoalBlack,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),

                  Text(
                    isRu
                        ? 'Мы отправили SMS-код на номер\n${widget.phone}'
                        : '${widget.phone} raqamiga yuborilgan\nSMS-kodni kiriting',
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      fontSize: 14,
                      height: 1.45,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  // OTP Input Field
                  Container(
                    width: 260,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E26) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF323242)
                            : const Color(0xFFE2E4E8),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      autofocus: true,
                      maxLength: 5,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 14,
                        color: isDark
                            ? AppColors.taxiYellow
                            : AppColors.charcoalBlack,
                      ),
                      decoration: const InputDecoration(
                        counterText: '',
                        hintText: '•••••',
                        hintStyle: TextStyle(
                          color: Colors.black26,
                          letterSpacing: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      onChanged: (val) {
                        if (val.length == 5) {
                          _handleVerify();
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Resend countdown or button
                  if (_secondsRemaining > 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 16,
                          color:
                              isDark ? Colors.white54 : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isRu
                              ? 'Повторить через: $_secondsRemaining сек'
                              : 'Qayta yuborish: $_secondsRemaining soniya',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white54
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    )
                  else
                    TextButton.icon(
                      onPressed: _handleResend,
                      icon: const Icon(Icons.refresh_rounded,
                          size: 18, color: AppColors.taxiYellowDark),
                      label: Text(
                        isRu ? 'Отправить код еще раз' : 'Kodni qayta yuborish',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.taxiYellowDark,
                        ),
                      ),
                    ),

                  const Spacer(),

                  // Verify CTA Button
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      text: isRu ? 'Подтвердить' : 'Tasdiqlash',
                      onPressed: _handleVerify,
                      isLoading: isLoading,
                      variant: AppButtonVariant.taxi,
                      height: 52,
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
