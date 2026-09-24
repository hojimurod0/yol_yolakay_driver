import 'package:flutter_test/flutter_test.dart';
import 'package:yol_yolakay_driver/features/auth/domain/entities/driver_user_entity.dart';
import 'package:yol_yolakay_driver/features/auth/domain/repositories/auth_repository.dart';
import 'package:yol_yolakay_driver/features/auth/domain/usecases/auth_usecases.dart';
import 'package:yol_yolakay_driver/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:yol_yolakay_driver/features/auth/presentation/bloc/auth_event.dart';
import 'package:yol_yolakay_driver/features/auth/presentation/bloc/auth_state.dart';

class FakeAuthRepository implements AuthRepository {
  bool loggedIn = false;

  @override
  Future<OtpSessionEntity> sendOtp(String phone) async {
    return const OtpSessionEntity(
      sessionId: 'sess-123',
      expiresIn: 120,
      resendInterval: 60,
    );
  }

  @override
  Future<DriverAuthEntity> verifyOtp({
    required String phone,
    required String sessionId,
    required String code,
  }) async {
    loggedIn = true;
    return const DriverAuthEntity(
      isRegistered: true,
      verificationStatus: 'approved',
      tokens: DriverTokensEntity(
        accessToken: 'access-token-123',
        refreshToken: 'refresh-token-123',
        expiresIn: 3600,
      ),
      driver: DriverUserEntity(
        id: 'driver-1',
        phone: '+998901234567',
        firstName: 'Rustam',
        lastName: 'Karimov',
        rating: 4.9,
        totalTrips: 150,
        balance: 100000,
        isOnline: false,
      ),
    );
  }

  @override
  Future<DriverTokensEntity> refreshToken(String refreshToken) async {
    return const DriverTokensEntity(
      accessToken: 'new-access-token',
      refreshToken: 'new-refresh-token',
      expiresIn: 3600,
    );
  }

  @override
  Future<void> logout({String? fcmToken}) async {
    loggedIn = false;
  }

  @override
  Future<bool> isAuthenticated() async => loggedIn;

  @override
  Future<String?> getSavedAccessToken() async =>
      loggedIn ? 'access-token-123' : null;

  @override
  Future<String?> getSavedDriverId() async => loggedIn ? 'driver-1' : null;
}

void main() {
  late FakeAuthRepository fakeRepo;
  late AuthBloc authBloc;

  setUp(() {
    fakeRepo = FakeAuthRepository();
    authBloc = AuthBloc(
      sendOtpUseCase: SendOtpUseCase(fakeRepo),
      verifyOtpUseCase: VerifyOtpUseCase(fakeRepo),
      logoutUseCase: LogoutUseCase(fakeRepo),
      checkAuthStatusUseCase: CheckAuthStatusUseCase(fakeRepo),
    );
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc Tests', () {
    test('initial state is AuthInitial', () {
      expect(authBloc.state, const AuthInitial());
    });

    test('CheckAuthStatusEvent emits UnauthenticatedState when not logged in',
        () async {
      authBloc.add(const CheckAuthStatusEvent());

      await expectLater(
        authBloc.stream,
        emits(const UnauthenticatedState()),
      );
    });

    test('SendOtpEvent emits [AuthLoading, OtpSentState]', () async {
      authBloc.add(const SendOtpEvent('+998901234567'));

      await expectLater(
        authBloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          predicate<OtpSentState>((s) =>
              s.phone == '+998901234567' && s.session.sessionId == 'sess-123'),
        ]),
      );
    });

    test('VerifyOtpEvent emits [AuthLoading, AuthenticatedState]', () async {
      authBloc.add(const VerifyOtpEvent(
        phone: '+998901234567',
        sessionId: 'sess-123',
        code: '123456',
      ));

      await expectLater(
        authBloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          predicate<AuthenticatedState>(
              (s) => s.auth.driver.fullName == 'Rustam Karimov'),
        ]),
      );
    });

    test('LogoutEvent emits [AuthLoading, UnauthenticatedState]', () async {
      fakeRepo.loggedIn = true;
      authBloc.add(const LogoutEvent());

      await expectLater(
        authBloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          const UnauthenticatedState(),
        ]),
      );
    });
  });
}
