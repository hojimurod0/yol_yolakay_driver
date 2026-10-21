import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../localization/locale_cubit.dart';
import '../network/api_client.dart';
import '../network/network_cubit.dart';
import '../network/network_info.dart';
import '../services/analytics_service.dart';
import '../services/app_lifecycle_manager.dart';
import '../services/feature_flag_service.dart';
import '../services/force_update_service.dart';
import '../services/local_notification_service.dart';
import '../services/location_service.dart';
import '../services/permission_service.dart';
import '../services/push_notification_service.dart';
import '../services/session_manager.dart';
import '../services/websocket_service.dart';
import '../storage/local_storage_service.dart';
import '../storage/secure_storage_service.dart';
import '../theme/theme_cubit.dart';

// Feature: Auth
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// Feature: Verification
import '../../features/verification/data/datasources/verification_remote_data_source.dart';
import '../../features/verification/data/repositories/verification_repository_impl.dart';
import '../../features/verification/domain/repositories/verification_repository.dart';
import '../../features/verification/domain/usecases/verification_usecases.dart';
import '../../features/verification/presentation/bloc/verification_bloc.dart';

// Feature: Home
import '../../features/home/data/datasources/home_remote_data_source.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/repositories/city_repository.dart';
import '../../features/home/data/repositories/city_repository_impl.dart';
import '../../features/home/presentation/providers/city_picker_provider.dart';
import '../../features/home/domain/usecases/home_usecases.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';

// Feature: Taxi Radar
import '../../features/taxi_radar/data/datasources/taxi_radar_remote_data_source.dart';
import '../../features/taxi_radar/data/repositories/taxi_radar_repository_impl.dart';
import '../../features/taxi_radar/domain/repositories/taxi_radar_repository.dart';
import '../../features/taxi_radar/domain/usecases/taxi_radar_usecases.dart';
import '../../features/taxi_radar/presentation/bloc/taxi_radar_bloc.dart';

// Feature: Intercity Rides
import '../../features/intercity_rides/data/datasources/intercity_rides_remote_data_source.dart';
import '../../features/intercity_rides/data/repositories/intercity_rides_repository_impl.dart';
import '../../features/intercity_rides/domain/repositories/intercity_rides_repository.dart';
import '../../features/intercity_rides/domain/usecases/intercity_rides_usecases.dart';
import '../../features/intercity_rides/presentation/bloc/intercity_rides_bloc.dart';

// Feature: Wallet
import '../../features/wallet/data/datasources/wallet_remote_data_source.dart';
import '../../features/wallet/data/repositories/wallet_repository_impl.dart';
import '../../features/wallet/domain/repositories/wallet_repository.dart';
import '../../features/wallet/domain/usecases/wallet_usecases.dart';
import '../../features/wallet/presentation/bloc/wallet_bloc.dart';

// Feature: Reviews
import '../../features/reviews/data/datasources/reviews_remote_data_source.dart';
import '../../features/reviews/data/repositories/reviews_repository_impl.dart';
import '../../features/reviews/domain/repositories/reviews_repository.dart';
import '../../features/reviews/domain/usecases/reviews_usecases.dart';
import '../../features/reviews/presentation/bloc/reviews_bloc.dart';

// Feature: Notifications
import '../../features/notifications/data/datasources/driver_notifications_remote_data_source.dart';
import '../../features/notifications/data/repositories/driver_notifications_repository_impl.dart';
import '../../features/notifications/domain/repositories/driver_notifications_repository.dart';
import '../../features/notifications/domain/usecases/driver_notifications_usecases.dart';
import '../../features/notifications/presentation/bloc/notifications_bloc.dart';

// Feature: Support
import '../../features/support/data/datasources/support_remote_data_source.dart';
import '../../features/support/data/repositories/support_repository_impl.dart';
import '../../features/support/domain/repositories/support_repository.dart';
import '../../features/support/domain/usecases/support_usecases.dart';
import '../../features/support/presentation/bloc/support_bloc.dart';

// Feature: Profile
import '../../features/profile/data/datasources/driver_profile_remote_data_source.dart';
import '../../features/profile/data/repositories/driver_profile_repository_impl.dart';
import '../../features/profile/domain/repositories/driver_profile_repository.dart';
import '../../features/profile/domain/usecases/driver_profile_usecases.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';

/// Centralized GetIt service locator instance.
final sl = GetIt.instance;

/// Configures all Clean Architecture dependencies in dependency order.
Future<void> configureDependencies() async {
  // 1. External & Storage (Singletons)
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  final localStorageService = LocalStorageService(sharedPreferences);
  sl.registerSingleton<LocalStorageService>(localStorageService);

  final secureStorageService = SecureStorageService();
  sl.registerSingleton<SecureStorageService>(secureStorageService);

  final networkInfo = NetworkInfoImpl();
  sl.registerSingleton<NetworkInfo>(networkInfo);

  // 2. Core UI Cubits (LazySingletons)
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit(sl<LocalStorageService>()));
  sl.registerLazySingleton<LocaleCubit>(() => LocaleCubit(sl<LocalStorageService>()));
  sl.registerLazySingleton<NetworkCubit>(() => NetworkCubit(sl<NetworkInfo>()));

  // 3. Core Services & ApiClient
  sl.registerLazySingleton<LocationService>(() => LocationService());
  sl.registerLazySingleton<PermissionService>(
    () => PermissionService(locationService: sl<LocationService>()),
  );

  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      secureStorage: sl<SecureStorageService>(),
      networkInfo: sl<NetworkInfo>(),
      onSessionExpired: () => sl<SessionManager>().handleSessionExpired(),
    ),
  );

  sl.registerLazySingleton<WebSocketService>(
    () => WebSocketService(secureStorage: sl<SecureStorageService>()),
  );

  sl.registerLazySingleton<LocalNotificationService>(
    () => LocalNotificationService(),
  );

  sl.registerLazySingleton<PushNotificationService>(
    () => PushNotificationService(
      apiClient: sl<ApiClient>(),
      localNotificationService: sl<LocalNotificationService>(),
      secureStorage: sl<SecureStorageService>(),
    ),
  );

  sl.registerLazySingleton<SessionManager>(
    () => SessionManager(
      secureStorage: sl<SecureStorageService>(),
      webSocketService: sl<WebSocketService>(),
      locationService: sl<LocationService>(),
      pushNotificationService: sl<PushNotificationService>(),
    ),
  );

  sl.registerLazySingleton<FeatureFlagService>(
    () => FeatureFlagServiceImpl(apiClient: sl<ApiClient>()),
  );
  sl.registerLazySingleton<ForceUpdateService>(() => ForceUpdateService());
  sl.registerLazySingleton<AnalyticsService>(() => AnalyticsServiceImpl());
  sl.registerLazySingleton<AppLifecycleManager>(
    () => AppLifecycleManager(
      webSocketService: sl<WebSocketService>(),
      onAppResumed: () async {},
    ),
  );

  // 4. Feature: Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      secureStorage: sl<SecureStorageService>(),
    ),
  );
  sl.registerLazySingleton<SendOtpUseCase>(() => SendOtpUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton<VerifyOtpUseCase>(() => VerifyOtpUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton<LoginWithPasswordUseCase>(() => LoginWithPasswordUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton<SetPasswordUseCase>(() => SetPasswordUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton<LogoutUseCase>(() => LogoutUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton<CheckAuthStatusUseCase>(() => CheckAuthStatusUseCase(sl<AuthRepository>()));
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      sendOtpUseCase: sl<SendOtpUseCase>(),
      verifyOtpUseCase: sl<VerifyOtpUseCase>(),
      logoutUseCase: sl<LogoutUseCase>(),
      checkAuthStatusUseCase: sl<CheckAuthStatusUseCase>(),
      loginWithPasswordUseCase: sl<LoginWithPasswordUseCase>(),
      setPasswordUseCase: sl<SetPasswordUseCase>(),
    ),
  );

  // 5. Feature: Verification
  sl.registerLazySingleton<VerificationRemoteDataSource>(
    () => VerificationRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<VerificationRepository>(
    () => VerificationRepositoryImpl(sl<VerificationRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetCitiesUseCase>(() => GetCitiesUseCase(sl<VerificationRepository>()));
  sl.registerLazySingleton<SubmitApplicationUseCase>(() => SubmitApplicationUseCase(sl<VerificationRepository>()));
  sl.registerFactory<VerificationBloc>(
    () => VerificationBloc(
      getCitiesUseCase: sl<GetCitiesUseCase>(),
      submitApplicationUseCase: sl<SubmitApplicationUseCase>(),
    ),
  );

  // 6. Feature: Home & Shift
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(sl<HomeRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetHomeDashboardUseCase>(() => GetHomeDashboardUseCase(sl<HomeRepository>()));
  sl.registerLazySingleton<ToggleShiftUseCase>(() => ToggleShiftUseCase(sl<HomeRepository>()));
  sl.registerLazySingleton<UpdateLocationUseCase>(() => UpdateLocationUseCase(sl<HomeRepository>()));
  sl.registerFactory<HomeBloc>(
    () => HomeBloc(
      getHomeDashboardUseCase: sl<GetHomeDashboardUseCase>(),
      toggleShiftUseCase: sl<ToggleShiftUseCase>(),
      updateLocationUseCase: sl<UpdateLocationUseCase>(),
      locationService: sl<LocationService>(),
    ),
  );
  sl.registerLazySingleton<CityRepository>(
    () => CityRepositoryImpl(sl<ApiClient>()),
  );
  sl.registerFactory<CityPickerCubit>(() => CityPickerCubit(sl<CityRepository>()));

  // 7. Feature: Taxi Radar
  sl.registerLazySingleton<TaxiRadarRemoteDataSource>(
    () => TaxiRadarRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<TaxiRadarRepository>(
    () => TaxiRadarRepositoryImpl(sl<TaxiRadarRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetRadarOrdersUseCase>(() => GetRadarOrdersUseCase(sl<TaxiRadarRepository>()));
  sl.registerLazySingleton<GetActiveTaxiOrderUseCase>(() => GetActiveTaxiOrderUseCase(sl<TaxiRadarRepository>()));
  sl.registerLazySingleton<AcceptTaxiOrderUseCase>(() => AcceptTaxiOrderUseCase(sl<TaxiRadarRepository>()));
  sl.registerLazySingleton<DeclineTaxiOrderUseCase>(() => DeclineTaxiOrderUseCase(sl<TaxiRadarRepository>()));
  sl.registerLazySingleton<UpdateTaxiOrderStatusUseCase>(() => UpdateTaxiOrderStatusUseCase(sl<TaxiRadarRepository>()));
  sl.registerLazySingleton<CompleteTaxiOrderUseCase>(() => CompleteTaxiOrderUseCase(sl<TaxiRadarRepository>()));
  sl.registerLazySingleton<CancelTaxiOrderUseCase>(() => CancelTaxiOrderUseCase(sl<TaxiRadarRepository>()));
  sl.registerFactory<TaxiRadarBloc>(
    () => TaxiRadarBloc(
      getRadarOrdersUseCase: sl<GetRadarOrdersUseCase>(),
      getActiveTaxiOrderUseCase: sl<GetActiveTaxiOrderUseCase>(),
      acceptTaxiOrderUseCase: sl<AcceptTaxiOrderUseCase>(),
      declineTaxiOrderUseCase: sl<DeclineTaxiOrderUseCase>(),
      updateTaxiOrderStatusUseCase: sl<UpdateTaxiOrderStatusUseCase>(),
      completeTaxiOrderUseCase: sl<CompleteTaxiOrderUseCase>(),
      cancelTaxiOrderUseCase: sl<CancelTaxiOrderUseCase>(),
      locationService: sl<LocationService>(),
      webSocketService: sl<WebSocketService>(),
    ),
  );

  // 8. Feature: Intercity Rides
  sl.registerLazySingleton<IntercityRidesRemoteDataSource>(
    () => IntercityRidesRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<IntercityRidesRepository>(
    () => IntercityRidesRepositoryImpl(sl<IntercityRidesRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetRidesUseCase>(() => GetRidesUseCase(sl<IntercityRidesRepository>()));
  sl.registerLazySingleton<CreateRideUseCase>(() => CreateRideUseCase(sl<IntercityRidesRepository>()));
  sl.registerLazySingleton<GetRideDetailsUseCase>(() => GetRideDetailsUseCase(sl<IntercityRidesRepository>()));
  sl.registerLazySingleton<UpdateRideStatusUseCase>(() => UpdateRideStatusUseCase(sl<IntercityRidesRepository>()));
  sl.registerLazySingleton<HandleBookingActionUseCase>(() => HandleBookingActionUseCase(sl<IntercityRidesRepository>()));
  sl.registerLazySingleton<CancelBookingUseCase>(() => CancelBookingUseCase(sl<IntercityRidesRepository>()));
  sl.registerLazySingleton<UpdateRideUseCase>(() => UpdateRideUseCase(sl<IntercityRidesRepository>()));
  sl.registerLazySingleton<DeleteRideUseCase>(() => DeleteRideUseCase(sl<IntercityRidesRepository>()));
  sl.registerFactory<IntercityRidesBloc>(
    () => IntercityRidesBloc(
      getRidesUseCase: sl<GetRidesUseCase>(),
      createRideUseCase: sl<CreateRideUseCase>(),
      getRideDetailsUseCase: sl<GetRideDetailsUseCase>(),
      updateRideStatusUseCase: sl<UpdateRideStatusUseCase>(),
      handleBookingActionUseCase: sl<HandleBookingActionUseCase>(),
      cancelBookingUseCase: sl<CancelBookingUseCase>(),
      updateRideUseCase: sl<UpdateRideUseCase>(),
      deleteRideUseCase: sl<DeleteRideUseCase>(),
      webSocketService: sl<WebSocketService>(),
    ),
  );

  // 9. Feature: Wallet
  sl.registerLazySingleton<WalletRemoteDataSource>(
    () => WalletRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(sl<WalletRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetWalletHistoryUseCase>(() => GetWalletHistoryUseCase(sl<WalletRepository>()));
  sl.registerLazySingleton<DepositWalletUseCase>(() => DepositWalletUseCase(sl<WalletRepository>()));
  sl.registerLazySingleton<GetEarningsStatsUseCase>(() => GetEarningsStatsUseCase(sl<WalletRepository>()));
  sl.registerFactory<WalletBloc>(
    () => WalletBloc(
      getWalletHistoryUseCase: sl<GetWalletHistoryUseCase>(),
      depositWalletUseCase: sl<DepositWalletUseCase>(),
      getEarningsStatsUseCase: sl<GetEarningsStatsUseCase>(),
    ),
  );

  // 10. Feature: Reviews
  sl.registerLazySingleton<ReviewsRemoteDataSource>(
    () => ReviewsRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<ReviewsRepository>(
    () => ReviewsRepositoryImpl(sl<ReviewsRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetDriverReviewsUseCase>(() => GetDriverReviewsUseCase(sl<ReviewsRepository>()));
  sl.registerLazySingleton<RatePassengerUseCase>(() => RatePassengerUseCase(sl<ReviewsRepository>()));
  sl.registerFactory<ReviewsBloc>(
    () => ReviewsBloc(
      getDriverReviewsUseCase: sl<GetDriverReviewsUseCase>(),
      ratePassengerUseCase: sl<RatePassengerUseCase>(),
    ),
  );

  // 11. Feature: Notifications & Support
  sl.registerLazySingleton<DriverNotificationsRemoteDataSource>(
    () => DriverNotificationsRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<DriverNotificationsRepository>(
    () => DriverNotificationsRepositoryImpl(sl<DriverNotificationsRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetDriverNotificationsUseCase>(() => GetDriverNotificationsUseCase(sl<DriverNotificationsRepository>()));
  sl.registerLazySingleton<MarkNotificationAsReadUseCase>(() => MarkNotificationAsReadUseCase(sl<DriverNotificationsRepository>()));
  sl.registerLazySingleton<MarkAllNotificationsAsReadUseCase>(() => MarkAllNotificationsAsReadUseCase(sl<DriverNotificationsRepository>()));
  sl.registerFactory<NotificationsBloc>(
    () => NotificationsBloc(
      getNotificationsUseCase: sl<GetDriverNotificationsUseCase>(),
      markReadUseCase: sl<MarkNotificationAsReadUseCase>(),
      markAllReadUseCase: sl<MarkAllNotificationsAsReadUseCase>(),
    ),
  );

  sl.registerLazySingleton<SupportRemoteDataSource>(
    () => SupportRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<SupportRepository>(
    () => SupportRepositoryImpl(sl<SupportRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetFaqsUseCase>(() => GetFaqsUseCase(sl<SupportRepository>()));
  sl.registerLazySingleton<SubmitSupportTicketUseCase>(() => SubmitSupportTicketUseCase(sl<SupportRepository>()));
  sl.registerFactory<SupportBloc>(
    () => SupportBloc(
      getFaqsUseCase: sl<GetFaqsUseCase>(),
      submitTicketUseCase: sl<SubmitSupportTicketUseCase>(),
    ),
  );

  // 12. Feature: Profile
  sl.registerLazySingleton<DriverProfileRemoteDataSource>(
    () => DriverProfileRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<DriverProfileRepository>(
    () => DriverProfileRepositoryImpl(sl<DriverProfileRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetDriverProfileUseCase>(() => GetDriverProfileUseCase(sl<DriverProfileRepository>()));
  sl.registerLazySingleton<UploadDriverAvatarUseCase>(() => UploadDriverAvatarUseCase(sl<DriverProfileRepository>()));
  sl.registerLazySingleton<UpdateFcmTokenUseCase>(() => UpdateFcmTokenUseCase(sl<DriverProfileRepository>()));
  sl.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      getProfileUseCase: sl<GetDriverProfileUseCase>(),
      uploadAvatarUseCase: sl<UploadDriverAvatarUseCase>(),
      updateFcmTokenUseCase: sl<UpdateFcmTokenUseCase>(),
    ),
  );
}

/// Backward compatibility extension on GetIt instance to smoothly support existing calls.
extension GetItCompatibilityX on GetIt {
  void init() {
    // Synchronous placeholder if called before async configureDependencies
  }

  ApiClient get apiClient => this<ApiClient>();
  SecureStorageService get secureStorageService => this<SecureStorageService>();
  LocationService get locationService => this<LocationService>();
  WebSocketService get webSocketService => this<WebSocketService>();
  SessionManager get sessionManager => this<SessionManager>();
  PermissionService get permissionService => this<PermissionService>();
  LocalNotificationService get localNotificationService => this<LocalNotificationService>();
  PushNotificationService get pushNotificationService => this<PushNotificationService>();
  FeatureFlagService get featureFlagService => this<FeatureFlagService>();
  ForceUpdateService get forceUpdateService => this<ForceUpdateService>();
  AnalyticsService get analyticsService => this<AnalyticsService>();
  AppLifecycleManager get appLifecycleManager => this<AppLifecycleManager>();

  AuthRepository get authRepository => this<AuthRepository>();
  VerificationRepository get verificationRepository => this<VerificationRepository>();
  HomeRepository get homeRepository => this<HomeRepository>();
  TaxiRadarRepository get taxiRadarRepository => this<TaxiRadarRepository>();
  IntercityRidesRepository get intercityRidesRepository => this<IntercityRidesRepository>();
  WalletRepository get walletRepository => this<WalletRepository>();
  ReviewsRepository get reviewsRepository => this<ReviewsRepository>();
  DriverNotificationsRepository get notificationsRepository => this<DriverNotificationsRepository>();
  SupportRepository get supportRepository => this<SupportRepository>();
  DriverProfileRepository get profileRepository => this<DriverProfileRepository>();

  AuthBloc createAuthBloc() => this<AuthBloc>();
  VerificationBloc createVerificationBloc() => this<VerificationBloc>();
  HomeBloc createHomeBloc() => this<HomeBloc>();
  TaxiRadarBloc createTaxiRadarBloc() => this<TaxiRadarBloc>();
  IntercityRidesBloc createIntercityRidesBloc() => this<IntercityRidesBloc>();
  WalletBloc createWalletBloc() => this<WalletBloc>();
  ReviewsBloc createReviewsBloc() => this<ReviewsBloc>();
  NotificationsBloc createNotificationsBloc() => this<NotificationsBloc>();
  SupportBloc createSupportBloc() => this<SupportBloc>();
  ProfileBloc createProfileBloc() => this<ProfileBloc>();
}
