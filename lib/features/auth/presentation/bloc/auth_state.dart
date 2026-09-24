import 'package:equatable/equatable.dart';
import '../../domain/entities/driver_user_entity.dart';
import '../../../../core/network/api_response.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class OtpSentState extends AuthState {
  const OtpSentState({
    required this.phone,
    required this.session,
  });

  final String phone;
  final OtpSessionEntity session;

  @override
  List<Object?> get props => [phone, session];
}

class AuthenticatedState extends AuthState {
  const AuthenticatedState(this.auth);
  final DriverAuthEntity auth;

  @override
  List<Object?> get props => [auth];
}

class UnauthenticatedState extends AuthState {
  const UnauthenticatedState();
}

class AuthErrorState extends AuthState {
  const AuthErrorState({
    required this.message,
    this.errorCode,
    this.fieldErrors = const [],
  });

  final String message;
  final String? errorCode;
  final List<FieldError> fieldErrors;

  @override
  List<Object?> get props => [message, errorCode, fieldErrors];
}
