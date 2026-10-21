import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/services/push_notification_service.dart';
import '../../../../core/utils/bloc_transformers.dart';
import '../../domain/usecases/auth_usecases.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required SendOtpUseCase sendOtpUseCase,
    required VerifyOtpUseCase verifyOtpUseCase,
    required LogoutUseCase logoutUseCase,
    required CheckAuthStatusUseCase checkAuthStatusUseCase,
    LoginWithPasswordUseCase? loginWithPasswordUseCase,
    SetPasswordUseCase? setPasswordUseCase,
  })  : _sendOtpUseCase = sendOtpUseCase,
        _verifyOtpUseCase = verifyOtpUseCase,
        _logoutUseCase = logoutUseCase,
        _checkAuthStatusUseCase = checkAuthStatusUseCase,
        _loginWithPasswordUseCase = loginWithPasswordUseCase,
        _setPasswordUseCase = setPasswordUseCase,
        super(const AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<SendOtpEvent>(_onSendOtp, transformer: droppableTransformer());
    on<LoginWithPasswordEvent>(_onLoginWithPassword, transformer: droppableTransformer());
    on<SetPasswordEvent>(_onSetPassword, transformer: droppableTransformer());
    on<ResendOtpEvent>(_onResendOtp, transformer: droppableTransformer());
    on<VerifyOtpEvent>(_onVerifyOtp, transformer: droppableTransformer());
    on<LogoutEvent>(_onLogout, transformer: droppableTransformer());
  }

  final SendOtpUseCase _sendOtpUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final LogoutUseCase _logoutUseCase;
  final CheckAuthStatusUseCase _checkAuthStatusUseCase;
  final LoginWithPasswordUseCase? _loginWithPasswordUseCase;
  final SetPasswordUseCase? _setPasswordUseCase;

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    final isAuthenticated = await _checkAuthStatusUseCase();
    if (isAuthenticated) {
      // In authenticated state, actual profile / driver will be fetched by HomeBloc / ProfileBloc
      emit(const AuthInitial());
      _syncPushToken();
    } else {
      emit(const UnauthenticatedState());
    }
  }

  Future<void> _onSendOtp(
    SendOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final session = await _sendOtpUseCase(event.phone);
      emit(OtpSentState(phone: event.phone, session: session));
    } on ApiException catch (e) {
      emit(AuthErrorState(
        message: e.message,
        errorCode: e.errorCode,
        fieldErrors: e.fieldErrors,
      ));
    } catch (e) {
      emit(AuthErrorState(message: e.toString()));
    }
  }

  Future<void> _onLoginWithPassword(
    LoginWithPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      if (_loginWithPasswordUseCase == null) {
        throw Exception('LoginWithPasswordUseCase not provided');
      }
      final authResult = await _loginWithPasswordUseCase!(
        phone: event.phone,
        password: event.password,
      );
      emit(AuthenticatedState(authResult));
      _syncPushToken();
    } on ApiException catch (e) {
      emit(AuthErrorState(
        message: e.message,
        errorCode: e.errorCode,
        fieldErrors: e.fieldErrors,
      ));
    } catch (e) {
      emit(AuthErrorState(message: e.toString()));
    }
  }

  Future<void> _onSetPassword(
    SetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      if (_setPasswordUseCase == null) {
        throw Exception('SetPasswordUseCase not provided');
      }
      await _setPasswordUseCase!(event.newPassword);
      emit(const PasswordSetSuccessState());
    } on ApiException catch (e) {
      emit(AuthErrorState(
        message: e.message,
        errorCode: e.errorCode,
        fieldErrors: e.fieldErrors,
      ));
    } catch (e) {
      emit(AuthErrorState(message: e.toString()));
    }
  }

  Future<void> _onResendOtp(
    ResendOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final session = await _sendOtpUseCase(event.phone);
      emit(OtpSentState(phone: event.phone, session: session));
    } on ApiException catch (e) {
      emit(AuthErrorState(
        message: e.message,
        errorCode: e.errorCode,
        fieldErrors: e.fieldErrors,
      ));
    }
  }

  Future<void> _onVerifyOtp(
    VerifyOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final authResult = await _verifyOtpUseCase(
        phone: event.phone,
        sessionId: event.sessionId,
        code: event.code,
      );
      emit(AuthenticatedState(authResult));
      _syncPushToken();
    } on ApiException catch (e) {
      emit(AuthErrorState(
        message: e.message,
        errorCode: e.errorCode,
        fieldErrors: e.fieldErrors,
      ));
    } catch (e) {
      emit(AuthErrorState(message: e.toString()));
    }
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _logoutUseCase(fcmToken: event.fcmToken);
    } catch (_) {}
    emit(const UnauthenticatedState());
  }

  void _syncPushToken() {
    try {
      if (sl.isRegistered<PushNotificationService>()) {
        sl<PushNotificationService>().syncPendingTokenAfterLogin();
      }
    } catch (_) {}
  }
}
