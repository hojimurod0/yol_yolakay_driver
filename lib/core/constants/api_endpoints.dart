/// Centralized API endpoints for the Yo'l-Yo'lakay Driver application.
/// Complies 100% with openapi.json and BACKEND_TZ_DRIVER.md specifications.
abstract class ApiEndpoints {
  // Base URLs (Haydovchi backend - https://driver.yolyolakay.site)
  static const String serverUrl = 'https://driver.yolyolakay.site';
  static const String swaggerUrl = 'https://driver.yolyolakay.site/api/docs#/';
  static const String prodBaseUrl = 'https://driver.yolyolakay.site/api/v1';
  static const String devBaseUrl = 'https://driver.yolyolakay.site/api/v1';
  static const String webSocketUrl = 'wss://driver.yolyolakay.site/ws';
  static const String prodWebSocketUrl = 'wss://driver.yolyolakay.site/ws';

  // Module 1: Auth
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String setPassword = '/auth/set-password';
  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String logoutAll = '/auth/logout-all';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';

  // Module 2: Locations, Cities & Verification
  static const String cities = '/location/cities';
  static String cityDetails(String id) => '/location/cities/$id';
  static String cityPickupPoints(String cityId) =>
      '/location/cities/$cityId/pickup-points';
  static String deletePickupPoint(String id) => '/location/pickup-points/$id';
  static const String calculateDistance = '/location/calculate-distance';
  static const String nearbyDrivers = '/location/nearby-drivers';

  static const String verifyApplication = '/driver/verify-application';
  static const String driverDocuments = '/driver/documents';
  static const String driverProfile = '/driver/profile';
  static const String uploadAvatar = '/driver/profile/avatar';
  static const String fcmToken = '/driver/fcm-token';

  // Module 3: Home Dashboard, Shift & Location
  static const String driverHome = '/driver/home';
  static const String toggleShift = '/driver/shift/toggle';
  static const String workingMode = '/driver/working-mode';
  static const String updateLocation = '/driver/location';
  static const String driverStats = '/driver/stats';

  // Module 4: Vehicles
  static const String vehicles = '/vehicles';
  static String vehicleDetails(String id) => '/vehicles/$id';
  static String setActiveVehicle(String id) => '/vehicles/$id/set-active';

  // Module 5: Taxi Orders & Radar
  static const String taxiRadar = '/taxi/radar';
  static const String taxiOffers = '/taxi/offers';
  static const String taxiActiveOrder = '/taxi/orders/active';
  static const String taxiOrderHistory = '/taxi/orders/history';
  static String taxiAcceptOrder(String orderId) =>
      '/taxi/orders/$orderId/accept';
  static String taxiDeclineOrder(String orderId) =>
      '/taxi/orders/$orderId/cancel';
  static String taxiOrderStatus(String orderId) =>
      '/taxi/orders/$orderId/status';
  static String taxiArrivedOrder(String orderId) =>
      '/taxi/orders/$orderId/arrived';
  static String taxiStartOrder(String orderId) =>
      '/taxi/orders/$orderId/start';
  static String taxiCompleteOrder(String orderId) =>
      '/taxi/orders/$orderId/complete';
  static String taxiCancelOrder(String orderId) =>
      '/taxi/orders/$orderId/cancel';

  // Module 6: Intercity Rides
  static const String rides = '/rides';
  static const String myRides = '/rides/my';
  static String rideDetails(String rideId) => '/rides/$rideId';
  static String rideStatus(String rideId) => '/rides/$rideId/status';
  static String startRide(String rideId) => '/rides/$rideId/start';
  static String completeRide(String rideId) => '/rides/$rideId/complete';

  // Module 7: Bookings
  static String rideBookings(String rideId) => '/bookings/ride/$rideId';
  static String bookingAction(String bookingId) =>
      '/bookings/$bookingId/action';
  static String cancelBooking(String bookingId) =>
      '/bookings/$bookingId/cancel';
  static String confirmBooking(String bookingId) =>
      '/bookings/$bookingId/confirm';
  static String rejectBooking(String bookingId) =>
      '/bookings/$bookingId/reject';
  static String pickedUpBooking(String bookingId) =>
      '/bookings/$bookingId/picked-up';

  // Module 8: Wallet & Earnings
  static const String walletBalance = '/wallet/balance';
  static const String walletHistory = '/wallet/history';
  static String walletTransaction(String id) => '/wallet/transactions/$id';
  static const String walletDeposit = '/wallet/deposit';
  static const String walletWithdraw = '/wallet/withdraw';
  static const String walletWithdrawals = '/wallet/withdrawals';
  static String cancelWithdrawal(String id) => '/wallet/withdrawals/$id';
  static const String earningsStats = '/earnings/stats';

  // Module 9: Reviews & Rating
  static const String reviews = '/reviews';
  static String reviewDetails(String id) => '/reviews/$id';
  static String ratePassenger(String tripId) =>
      '/reviews/trips/$tripId/rate-passenger';

  // Module 10: Notifications & Support
  static const String notifications = '/notifications';
  static const String readAllNotifications = '/notifications/read-all';
  static const String clearReadNotifications = '/notifications/clear-read';
  static const String notificationsFcmToken = '/notifications/fcm-token';
  static String readNotification(String id) => '/notifications/$id/read';
  static String deleteNotification(String id) => '/notifications/$id';

  static const String supportFaq = '/support/faq';
  static String supportFaqDetails(String id) => '/support/faq/$id';
  static const String supportTickets = '/support/tickets';
  static String supportTicketDetails(String id) => '/support/tickets/$id';

  // Module 11: System & Health
  static const String health = '/health';
}

