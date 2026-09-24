import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
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
  })  : _sendOtpUseCase = sendOtpUseCase,
        _verifyOtpUseCase = verifyOtpUseCase,
        _logoutUseCase = logoutUseCase,
        _checkAuthStatusUseCase = checkAuthStatusUseCase,
        super(const AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<SendOtpEvent>(_onSendOtp, transformer: droppableTransformer());
    on<ResendOtpEvent>(_onResendOtp, transformer: droppableTransformer());
    on<VerifyOtpEvent>(_onVerifyOtp, transformer: droppableTransformer());
    on<LogoutEvent>(_onLogout, transformer: droppableTransformer());
  }

  final SendOtpUseCase _sendOtpUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final LogoutUseCase _logoutUseCase;
  final CheckAuthStatusUseCase _checkAuthStatusUseCase;

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    final isAuthenticated = await _checkAuthStatusUseCase();
    if (isAuthenticated) {
      // In authenticated state, actual profile / driver will be fetched by HomeBloc / ProfileBloc
      emit(const AuthInitial());
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
}
