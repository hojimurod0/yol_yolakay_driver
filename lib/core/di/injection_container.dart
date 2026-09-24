import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/verification/data/datasources/verification_remote_data_source.dart';
import '../../features/verification/data/repositories/verification_repository_impl.dart';
import '../../features/verification/domain/repositories/verification_repository.dart';
import '../../features/verification/domain/usecases/verification_usecases.dart';
import '../../features/verification/presentation/bloc/verification_bloc.dart';

import '../../features/home/data/datasources/home_remote_data_source.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/home_usecases.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';

import '../../features/taxi_radar/data/datasources/taxi_radar_remote_data_source.dart';
import '../../features/taxi_radar/data/repositories/taxi_radar_repository_impl.dart';
import '../../features/taxi_radar/domain/repositories/taxi_radar_repository.dart';
import '../../features/taxi_radar/domain/usecases/taxi_radar_usecases.dart';
import '../../features/taxi_radar/presentation/bloc/taxi_radar_bloc.dart';

import '../../features/intercity_rides/data/datasources/intercity_rides_remote_data_source.dart';
import '../../features/intercity_rides/data/repositories/intercity_rides_repository_impl.dart';
import '../../features/intercity_rides/domain/repositories/intercity_rides_repository.dart';
import '../../features/intercity_rides/domain/usecases/intercity_rides_usecases.dart';
import '../../features/intercity_rides/presentation/bloc/intercity_rides_bloc.dart';

import '../../features/wallet/data/datasources/wallet_remote_data_source.dart';
import '../../features/wallet/data/repositories/wallet_repository_impl.dart';
import '../../features/wallet/domain/repositories/wallet_repository.dart';
import '../../features/wallet/domain/usecases/wallet_usecases.dart';
import '../../features/wallet/presentation/bloc/wallet_bloc.dart';

import '../../features/reviews/data/datasources/reviews_remote_data_source.dart';
import '../../features/reviews/data/repositories/reviews_repository_impl.dart';
import '../../features/reviews/domain/repositories/reviews_repository.dart';
import '../../features/reviews/domain/usecases/reviews_usecases.dart';
import '../../features/reviews/presentation/bloc/reviews_bloc.dart';

import '../../features/notifications/data/datasources/driver_notifications_remote_data_source.dart';
import '../../features/notifications/data/repositories/driver_notifications_repository_impl.dart';
import '../../features/notifications/domain/repositories/driver_notifications_repository.dart';
import '../../features/notifications/domain/usecases/driver_notifications_usecases.dart';
import '../../features/notifications/presentation/bloc/notifications_bloc.dart';

import '../../features/support/data/datasources/support_remote_data_source.dart';
import '../../features/support/data/repositories/support_repository_impl.dart';
import '../../features/support/domain/repositories/support_repository.dart';
import '../../features/support/domain/usecases/support_usecases.dart';
import '../../features/support/presentation/bloc/support_bloc.dart';

import '../../features/profile/data/datasources/driver_profile_remote_data_source.dart';
import '../../features/profile/data/repositories/driver_profile_repository_impl.dart';
import '../../features/profile/domain/repositories/driver_profile_repository.dart';
import '../../features/profile/domain/usecases/driver_profile_usecases.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';

import '../network/api_client.dart';
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
import '../storage/secure_storage_service.dart';

class InjectionContainer {
  static final InjectionContainer _instance = InjectionContainer._internal();
  factory InjectionContainer() => _instance;
  InjectionContainer._internal();

  // Core
  late final ApiClient apiClient;
  late final SecureStorageService secureStorageService;
  late final LocationService locationService;
  late final WebSocketService webSocketService;
  late final SessionManager sessionManager;
  late final PermissionService permissionService;
  late final LocalNotificationService localNotificationService;
  late final PushNotificationService pushNotificationService;
  late final FeatureFlagService featureFlagService;
  late final ForceUpdateService forceUpdateService;
  late final AnalyticsService analyticsService;
  late final AppLifecycleManager appLifecycleManager;

  // Repositories
  late final AuthRepository authRepository;
  late final VerificationRepository verificationRepository;
  late final HomeRepository homeRepository;
  late final TaxiRadarRepository taxiRadarRepository;
  late final IntercityRidesRepository intercityRidesRepository;
  late final WalletRepository walletRepository;
  late final ReviewsRepository reviewsRepository;
  late final DriverNotificationsRepository notificationsRepository;
  late final SupportRepository supportRepository;
  late final DriverProfileRepository profileRepository;

  void init() {
    secureStorageService = SecureStorageService();
    locationService = LocationService();
    permissionService = PermissionService(locationService: locationService);

    apiClient = ApiClient(
      secureStorage: secureStorageService,
      onSessionExpired: () => sessionManager.handleSessionExpired(),
    );

    webSocketService = WebSocketService(apiClient: apiClient);
    localNotificationService = LocalNotificationService();
    pushNotificationService = PushNotificationService(
      apiClient: apiClient,
      localNotificationService: localNotificationService,
    );
    featureFlagService = FeatureFlagServiceImpl(apiClient: apiClient);
    forceUpdateService = ForceUpdateService();
    analyticsService = AnalyticsServiceImpl();
    appLifecycleManager = AppLifecycleManager(
      webSocketService: webSocketService,
      onAppResumed: () async {
        // Safe refresh on resume
      },
    );
    sessionManager = SessionManager(
      secureStorage: secureStorageService,
      webSocketService: webSocketService,
      locationService: locationService,
      pushNotificationService: pushNotificationService,
    );

    // Module 1: Auth
    final authRemote = AuthRemoteDataSourceImpl(apiClient);
    authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemote,
      secureStorage: secureStorageService,
    );

    // Module 2: Verification
    final verificationRemote = VerificationRemoteDataSourceImpl(apiClient);
    verificationRepository = VerificationRepositoryImpl(verificationRemote);

    // Module 3: Home & Shift
    final homeRemote = HomeRemoteDataSourceImpl(apiClient);
    homeRepository = HomeRepositoryImpl(homeRemote);

    // Module 4: Taxi Radar
    final taxiRadarRemote = TaxiRadarRemoteDataSourceImpl(apiClient);
    taxiRadarRepository = TaxiRadarRepositoryImpl(taxiRadarRemote);

    // Module 5 & 6: Intercity Rides
    final intercityRemote = IntercityRidesRemoteDataSourceImpl(apiClient);
    intercityRidesRepository = IntercityRidesRepositoryImpl(intercityRemote);

    // Module 7: Wallet
    final walletRemote = WalletRemoteDataSourceImpl(apiClient);
    walletRepository = WalletRepositoryImpl(walletRemote);

    // Module 8: Reviews
    final reviewsRemote = ReviewsRemoteDataSourceImpl(apiClient);
    reviewsRepository = ReviewsRepositoryImpl(reviewsRemote);

    // Module 9: Notifications & Support
    final notificationsRemote =
        DriverNotificationsRemoteDataSourceImpl(apiClient);
    notificationsRepository =
        DriverNotificationsRepositoryImpl(notificationsRemote);

    final supportRemote = SupportRemoteDataSourceImpl(apiClient);
    supportRepository = SupportRepositoryImpl(supportRemote);

    // Module 10: Profile
    final profileRemote = DriverProfileRemoteDataSourceImpl(apiClient);
    profileRepository = DriverProfileRepositoryImpl(profileRemote);
  }

  // BLoC Factories
  AuthBloc createAuthBloc() => AuthBloc(
        sendOtpUseCase: SendOtpUseCase(authRepository),
        verifyOtpUseCase: VerifyOtpUseCase(authRepository),
        logoutUseCase: LogoutUseCase(authRepository),
        checkAuthStatusUseCase: CheckAuthStatusUseCase(authRepository),
      );

  VerificationBloc createVerificationBloc() => VerificationBloc(
        getCitiesUseCase: GetCitiesUseCase(verificationRepository),
        submitApplicationUseCase:
            SubmitApplicationUseCase(verificationRepository),
      );

  HomeBloc createHomeBloc() => HomeBloc(
        getHomeDashboardUseCase: GetHomeDashboardUseCase(homeRepository),
        toggleShiftUseCase: ToggleShiftUseCase(homeRepository),
        updateLocationUseCase: UpdateLocationUseCase(homeRepository),
        locationService: locationService,
        webSocketService: webSocketService,
        permissionService: permissionService,
      );

  TaxiRadarBloc createTaxiRadarBloc() => TaxiRadarBloc(
        getRadarOrdersUseCase: GetRadarOrdersUseCase(taxiRadarRepository),
        getActiveTaxiOrderUseCase:
            GetActiveTaxiOrderUseCase(taxiRadarRepository),
        acceptTaxiOrderUseCase: AcceptTaxiOrderUseCase(taxiRadarRepository),
        declineTaxiOrderUseCase: DeclineTaxiOrderUseCase(taxiRadarRepository),
        updateTaxiOrderStatusUseCase:
            UpdateTaxiOrderStatusUseCase(taxiRadarRepository),
        completeTaxiOrderUseCase: CompleteTaxiOrderUseCase(taxiRadarRepository),
        cancelTaxiOrderUseCase: CancelTaxiOrderUseCase(taxiRadarRepository),
        locationService: locationService,
        webSocketService: webSocketService,
      );

  IntercityRidesBloc createIntercityRidesBloc() => IntercityRidesBloc(
        getRidesUseCase: GetRidesUseCase(intercityRidesRepository),
        createRideUseCase: CreateRideUseCase(intercityRidesRepository),
        getRideDetailsUseCase: GetRideDetailsUseCase(intercityRidesRepository),
        updateRideStatusUseCase:
            UpdateRideStatusUseCase(intercityRidesRepository),
        handleBookingActionUseCase:
            HandleBookingActionUseCase(intercityRidesRepository),
        cancelBookingUseCase: CancelBookingUseCase(intercityRidesRepository),
        webSocketService: webSocketService,
      );

  WalletBloc createWalletBloc() => WalletBloc(
        getWalletHistoryUseCase: GetWalletHistoryUseCase(walletRepository),
        depositWalletUseCase: DepositWalletUseCase(walletRepository),
        getEarningsStatsUseCase: GetEarningsStatsUseCase(walletRepository),
      );

  ReviewsBloc createReviewsBloc() => ReviewsBloc(
        getDriverReviewsUseCase: GetDriverReviewsUseCase(reviewsRepository),
        ratePassengerUseCase: RatePassengerUseCase(reviewsRepository),
      );

  NotificationsBloc createNotificationsBloc() => NotificationsBloc(
        getNotificationsUseCase:
            GetDriverNotificationsUseCase(notificationsRepository),
        markReadUseCase: MarkNotificationAsReadUseCase(notificationsRepository),
        markAllReadUseCase:
            MarkAllNotificationsAsReadUseCase(notificationsRepository),
      );

  SupportBloc createSupportBloc() => SupportBloc(
        getFaqsUseCase: GetFaqsUseCase(supportRepository),
        submitTicketUseCase: SubmitSupportTicketUseCase(supportRepository),
      );

  ProfileBloc createProfileBloc() => ProfileBloc(
        getProfileUseCase: GetDriverProfileUseCase(profileRepository),
        uploadAvatarUseCase: UploadDriverAvatarUseCase(profileRepository),
        updateFcmTokenUseCase: UpdateFcmTokenUseCase(profileRepository),
      );
}

final sl = InjectionContainer();
