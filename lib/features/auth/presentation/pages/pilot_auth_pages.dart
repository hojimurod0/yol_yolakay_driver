import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localizations_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validator.dart';
import '../../../home/presentation/pages/pilot_open_route_page.dart'
    show PilotPrimaryButton;
import '../../domain/entities/driver_user_entity.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Formats Uzbek local digits as `93 456 78 90`.
class UzPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('998') && digits.length > 9) {
      digits = digits.substring(3);
    }
    if (digits.length > 9) digits = digits.substring(0, 9);
    final b = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 2 || i == 5 || i == 7) b.write(' ');
      b.write(digits[i]);
    }
    final text = b.toString();
    return TextEditingValue(
        text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}

class _AuthScaffold extends StatelessWidget {
  const _AuthScaffold({required this.children, this.bottom});

  final List<Widget> children;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 48,
                child: Row(
                  children: [
                    if (context.canPop())
                      IconButton.filledTonal(
                        onPressed: () => context.pop(),
                        tooltip: MaterialLocalizations.of(context)
                            .backButtonTooltip,
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: children,
                  ),
                ),
              ),
              if (bottom != null) bottom!,
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- A1

/// Driver sign-in: phone number only, the code comes by SMS.
class PilotDriverPhonePage extends StatefulWidget {
  const PilotDriverPhonePage({super.key});

  @override
  State<PilotDriverPhonePage> createState() => _PilotDriverPhonePageState();
}

class _PilotDriverPhonePageState extends State<PilotDriverPhonePage> {
  final _phone = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  void _submit() {
    final digits = _phone.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 9 || !AppValidator.isValidUzPhone(digits)) {
      setState(() => _error = context.l10n.daPhoneInvalid);
      return;
    }
    HapticFeedback.lightImpact();
    setState(() => _error = null);
    context.read<AuthBloc>().add(SendOtpEvent('+998$digits'));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is OtpSentState) {
          context.push('/otp',
              extra: {'phone': state.phone, 'session': state.session});
        } else if (state is AuthErrorState) {
          setState(() => _error = state.message);
        }
      },
      builder: (context, state) {
        final loading = state is AuthLoading;
        return _AuthScaffold(
          bottom: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PilotPrimaryButton(
                label: l10n.daGetCode,
                loading: loading,
                onPressed: loading ? null : _submit,
              ),
              const SizedBox(height: 10),
              Text(l10n.daTermsNote,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondaryLight)),
              TextButton(
                onPressed: () => context.push('/login-password'),
                child: Text(l10n.daWithPassword),
              ),
            ],
          ),
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text('YY',
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimaryLight)),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(l10n.daBadge,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF92400E))),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(l10n.daPhoneTitle,
                style: const TextStyle(
                    fontSize: 26, fontWeight: FontWeight.w900, height: 1.15)),
            const SizedBox(height: 6),
            Text(l10n.daPhoneBody,
                style: const TextStyle(
                    fontSize: 14.5, color: AppColors.textSecondaryLight)),
            const SizedBox(height: 22),
            TextField(
              controller: _phone,
              autofocus: true,
              keyboardType: TextInputType.phone,
              autofillHints: const [AutofillHints.telephoneNumberNational],
              inputFormatters: [UzPhoneFormatter()],
              onSubmitted: (_) => _submit(),
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: 0.5),
              decoration: InputDecoration(
                hintText: '93 456 78 90',
                errorText: _error,
                errorMaxLines: 3,
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 16, right: 10),
                  child: Text('+998',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 0),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------- A2

class PilotDriverOtpPage extends StatefulWidget {
  const PilotDriverOtpPage({
    super.key,
    required this.phone,
    required this.session,
  });

  final String phone;
  final OtpSessionEntity session;

  /// New drivers still have to submit documents; everyone else goes home.
  static String nextRouteFor(DriverAuthEntity auth) =>
      auth.isPendingOrRejected ? '/verification' : '/driver/home';

  @override
  State<PilotDriverOtpPage> createState() => _PilotDriverOtpPageState();
}

class _PilotDriverOtpPageState extends State<PilotDriverOtpPage> {
  final _code = TextEditingController();
  final _focus = FocusNode();
  late String _sessionId = widget.session.sessionId;
  Timer? _timer;
  int _seconds = 60;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startTimer(
        widget.session.resendInterval > 0 ? widget.session.resendInterval : 60);
    _code.addListener(_onChanged);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _startTimer(int seconds) {
    _timer?.cancel();
    setState(() => _seconds = seconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_seconds <= 1) t.cancel();
      setState(() => _seconds = (_seconds - 1).clamp(0, 999));
    });
  }

  void _onChanged() {
    setState(() => _error = null);
    if (_code.text.length == 6) {
      context.read<AuthBloc>().add(VerifyOtpEvent(
          phone: widget.phone, sessionId: _sessionId, code: _code.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final time =
        '${_seconds ~/ 60}:${(_seconds % 60).toString().padLeft(2, '0')}';

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is OtpSentState) {
          _sessionId = state.session.sessionId;
          _startTimer(
              state.session.resendInterval > 0 ? state.session.resendInterval : 60);
        } else if (state is AuthenticatedState) {
          HapticFeedback.mediumImpact();
          context.go(PilotDriverOtpPage.nextRouteFor(state.auth));
        } else if (state is AuthErrorState) {
          HapticFeedback.heavyImpact();
          setState(() => _error = state.message);
          _code.clear();
        }
      },
      builder: (context, state) {
        final code = _code.text;
        final loading = state is AuthLoading;
        return _AuthScaffold(
          children: [
            Text(l10n.daOtpTitle,
                style: const TextStyle(
                    fontSize: 26, fontWeight: FontWeight.w900, height: 1.15)),
            const SizedBox(height: 6),
            Row(
              children: [
                Flexible(
                  child: Text(l10n.daOtpSentTo(widget.phone),
                      style: const TextStyle(
                          fontSize: 14.5, color: AppColors.textSecondaryLight)),
                ),
                TextButton(
                    onPressed: () => context.pop(), child: Text(l10n.daChange)),
              ],
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () => _focus.requestFocus(),
              child: Stack(
                children: [
                  Opacity(
                    opacity: 0,
                    child: TextField(
                      controller: _code,
                      focusNode: _focus,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      autofillHints: const [AutofillHints.oneTimeCode],
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      for (var i = 0; i < 6; i++) ...[
                        Expanded(
                          child: Container(
                            height: 58,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: i == code.length
                                  ? Theme.of(context).colorScheme.surface
                                  : (isDark
                                      ? AppColors.surfaceSubtleDark
                                      : AppColors.surfaceSubtleLight),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _error != null
                                    ? AppColors.error
                                    : i == code.length
                                        ? AppColors.primary
                                        : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Text(i < code.length ? code[i] : '',
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.w900)),
                          ),
                        ),
                        if (i < 5) const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!,
                  style: const TextStyle(color: AppColors.error, fontSize: 13)),
            ],
            const SizedBox(height: 18),
            Center(
              child: loading
                  ? const CircularProgressIndicator()
                  : _seconds > 0
                      ? Text(l10n.daResendIn(time),
                          style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondaryLight))
                      : TextButton(
                          onPressed: () {
                            context
                                .read<AuthBloc>()
                                .add(ResendOtpEvent(widget.phone));
                          },
                          child: Text(l10n.daResend)),
            ),
            const SizedBox(height: 8),
            Text(l10n.daOtpAuto,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textTertiaryLight)),
          ],
        );
      },
    );
  }
}
