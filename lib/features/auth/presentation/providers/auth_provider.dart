import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

enum AuthStatus { initial, unauthenticated, authenticated, loading, error }

class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.phoneNumber,
    this.errorMessage,
  });

  final AuthStatus status;
  final UserEntity? user;
  final String? phoneNumber;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? phoneNumber,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  static final UserEntity defaultUser = UserEntity(
    id: 'usr_uz_default_01',
    phoneNumber: '+998 90 123 45 67',
    firstName: 'Rizo',
    lastName: 'Karimov',
    email: 'rizo.karimov@mail.uz',
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    isProfileComplete: true,
  );

  AuthNotifier(this._authRepository)
      : super(AuthState(
          status: AuthStatus.authenticated,
          user: defaultUser,
          phoneNumber: defaultUser.phoneNumber,
        )) {
    checkAuthStatus();
  }

  final AuthRepository _authRepository;

  Future<void> checkAuthStatus() async {
    try {
      final isAuth = await _authRepository.isAuthenticated();
      state = state.copyWith(
        status: isAuth ? AuthStatus.authenticated : AuthStatus.unauthenticated,
      );
    } catch (_) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> sendOtp(String phoneNumber) async {
    state =
        state.copyWith(status: AuthStatus.loading, phoneNumber: phoneNumber);
    try {
      await _authRepository.sendOtp(phoneNumber);
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> verifyOtp(String otpCode) async {
    if (state.phoneNumber == null) return false;
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _authRepository.verifyOtp(
        phone: state.phoneNumber!,
        sessionId: '',
        code: otpCode,
      );
      state = state.copyWith(status: AuthStatus.authenticated);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> createProfile({
    required String firstName,
    required String lastName,
    String? email,
  }) async {
    return true;
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _authRepository.logout();
    } catch (_) {}
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> deleteAccount() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _authRepository.logout();
    } catch (_) {}
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});
