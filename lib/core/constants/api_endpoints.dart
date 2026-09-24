/// Centralized API endpoints for the Yo'l-Yo'lakay Driver application.
/// Complies 100% with openapi.json and BACKEND_TZ_DRIVER.md specifications.
abstract class ApiEndpoints {
  // Base URLs
  static const String prodBaseUrl = 'https://api.yol-yolakay.uz/api/v1';
  static const String devBaseUrl =
      'http://10.0.2.2:8000/api/v1'; // Android emulator localhost
  static const String webSocketUrl = 'wss://api.yol-yolakay.uz/ws';

  // Module 1: Auth
  static const String sendOtp = '/auth/driver/send-otp';
  static const String verifyOtp = '/auth/driver/verify-otp';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';

  // Module 2: Verification & Profile
  static const String cities = '/cities';
  static const String verifyApplication = '/driver/verify-application';
  static const String driverProfile = '/driver/profile';
  static const String uploadAvatar = '/driver/profile/avatar';
  static const String fcmToken = '/driver/fcm-token';

  // Module 3: Home Dashboard, Shift & Location
  static const String driverHome = '/driver/home';
  static const String toggleShift = '/driver/shift/toggle';
  static const String updateLocation = '/driver/location';

  // Module 4: Taxi Orders & Radar
  static const String taxiRadar = '/driver/taxi/radar';
  static const String taxiActiveOrder = '/driver/taxi/orders/active';
  static String taxiAcceptOrder(String orderId) =>
      '/driver/taxi/orders/$orderId/accept';
  static String taxiDeclineOrder(String orderId) =>
      '/driver/taxi/orders/$orderId/decline';
  static String taxiOrderStatus(String orderId) =>
      '/driver/taxi/orders/$orderId/status';
  static String taxiCompleteOrder(String orderId) =>
      '/driver/taxi/orders/$orderId/complete';
  static String taxiCancelOrder(String orderId) =>
      '/driver/taxi/orders/$orderId/cancel';

  // Module 5: Intercity Rides
  static const String rides = '/driver/rides';
  static String rideDetails(String rideId) => '/driver/rides/$rideId';
  static String rideStatus(String rideId) => '/driver/rides/$rideId/status';

  // Module 6: Bookings
  static String bookingAction(String bookingId) =>
      '/driver/bookings/$bookingId/action';
  static String cancelBooking(String bookingId) =>
      '/driver/bookings/$bookingId/cancel';

  // Module 7: Wallet & Earnings
  static const String walletHistory = '/driver/wallet/history';
  static const String walletDeposit = '/driver/wallet/deposit';
  static const String earningsStats = '/driver/earnings/stats';

  // Module 8: Reviews & Rating
  static const String reviews = '/driver/reviews';
  static String ratePassenger(String tripId) =>
      '/driver/trips/$tripId/rate-passenger';

  // Module 9: Notifications & Support
  static const String notifications = '/driver/notifications';
  static const String readAllNotifications = '/driver/notifications/read-all';
  static String readNotification(String id) => '/driver/notifications/$id/read';
  static const String supportFaq = '/driver/support/faq';
  static const String supportTickets = '/driver/support/tickets';

  // Module 10: WebSocket & Broadcasting Auth
  static const String broadcastAuth = '/broadcasting/auth';
  static String driverChannel(String driverId) => 'private-driver.$driverId';
  static String taxiOrderChannel(String orderId) =>
      'private-taxi-order.$orderId';
}
