import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

class LoginWithPasswordEvent extends AuthEvent {
  const LoginWithPasswordEvent({
    required this.phone,
    required this.password,
  });
  final String phone;
  final String password;

  @override
  List<Object?> get props => [phone, password];
}

class SetPasswordEvent extends AuthEvent {
  const SetPasswordEvent(this.newPassword);
  final String newPassword;

  @override
  List<Object?> get props => [newPassword];
}

class SendOtpEvent extends AuthEvent {
  const SendOtpEvent(this.phone);
  final String phone;

  @override
  List<Object?> get props => [phone];
}

class ResendOtpEvent extends AuthEvent {
  const ResendOtpEvent(this.phone);
  final String phone;

  @override
  List<Object?> get props => [phone];
}

class VerifyOtpEvent extends AuthEvent {
  const VerifyOtpEvent({
    required this.phone,
    required this.sessionId,
    required this.code,
  });

  final String phone;
  final String sessionId;
  final String code;

  @override
  List<Object?> get props => [phone, sessionId, code];
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent({this.fcmToken});
  final String? fcmToken;

  @override
  List<Object?> get props => [fcmToken];
}
