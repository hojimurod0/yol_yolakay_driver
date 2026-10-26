// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'YolYolakay';

  @override
  String get appTagline => 'Comfortable and fast intercity travel';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get Started';

  @override
  String get continueText => 'Continue';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get close => 'Close';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get sort => 'Sort';

  @override
  String get clear => 'Clear';

  @override
  String get apply => 'Apply';

  @override
  String get back => 'Back';

  @override
  String get retry => 'Retry';

  @override
  String get done => 'Done';

  @override
  String get onboarding1Title => 'Intercity travel made easy';

  @override
  String get onboarding1Desc =>
      'Find reliable and comfortable taxis to any city across Uzbekistan.';

  @override
  String get onboarding2Title => 'Comfortable & safe vehicles';

  @override
  String get onboarding2Desc =>
      'Travel safely with experienced and verified background-checked drivers.';

  @override
  String get onboarding3Title => 'Book your seat securely';

  @override
  String get onboarding3Desc =>
      'Choose convenient departure time, seat comfort, and book in just a few taps.';

  @override
  String get onboarding4Title => 'Track your journey live';

  @override
  String get onboarding4Desc =>
      'See your driver\'s location on the map and stay informed of trip progress.';

  @override
  String get welcomeTitle => 'Welcome to YolYolakay!';

  @override
  String get welcomeSubtitle => 'Your trusted partner for intercity journeys';

  @override
  String get loginOrRegister => 'Sign in or Register';

  @override
  String get enterPhoneNumber => 'Enter your phone number';

  @override
  String get phoneLabel => 'Phone Number';

  @override
  String get phoneHint => '90 123 45 67';

  @override
  String get sendOtp => 'Send Verification Code';

  @override
  String otpSentTo(String phone) {
    return 'Verification code sent to $phone';
  }

  @override
  String get enterOtp => 'Enter verification code';

  @override
  String get resendOtp => 'Resend code';

  @override
  String resendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get createProfileTitle => 'Complete your profile';

  @override
  String get createProfileSubtitle =>
      'Add your basic information so drivers can recognize you';

  @override
  String get firstName => 'First Name';

  @override
  String get firstNameHint => 'Enter your first name';

  @override
  String get lastName => 'Last Name';

  @override
  String get lastNameHint => 'Enter your last name';

  @override
  String get email => 'Email (optional)';

  @override
  String get emailHint => 'example@mail.com';

  @override
  String get completeRegistration => 'Complete Registration';

  @override
  String get navHome => 'Home';

  @override
  String get navTrips => 'Trips';

  @override
  String get navNotifications => 'Alerts';

  @override
  String get navProfile => 'Profile';

  @override
  String greeting(String name) {
    return 'Hello, $name!';
  }

  @override
  String get whereToGo => 'Where do you want to go?';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get selectDepartureCity => 'Select departure city';

  @override
  String get selectDestinationCity => 'Select destination city';

  @override
  String get travelDate => 'Date';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get passengerCount => 'Passengers';

  @override
  String passengers(int count) {
    return '$count pass.';
  }

  @override
  String get searchRides => 'Search Rides';

  @override
  String get swapCities => 'Swap cities';

  @override
  String get recentSearches => 'Recent searches';

  @override
  String get popularRoutes => 'Popular routes';

  @override
  String get savedRoutes => 'Saved routes';

  @override
  String get noRecentSearches => 'No recent searches yet';

  @override
  String get selectCityTitle => 'Select City';

  @override
  String get searchCityHint => 'Search city name...';

  @override
  String get popularCities => 'Popular Cities';

  @override
  String get allCities => 'All Cities';

  @override
  String get currentLocation => 'Current Location';

  @override
  String get availableRides => 'Available Rides';

  @override
  String ridesFound(int count) {
    return '$count rides found';
  }

  @override
  String get noRidesFound => 'No rides found';

  @override
  String get noRidesDesc => 'Try selecting another departure date or route';

  @override
  String get sortCheapest => 'Cheapest';

  @override
  String get sortEarliest => 'Earliest departure';

  @override
  String get sortFastest => 'Shortest duration';

  @override
  String get sortRating => 'Highest rated';

  @override
  String get filterPrice => 'Price range';

  @override
  String get filterCarType => 'Vehicle type';

  @override
  String get filterSeats => 'Available seats';

  @override
  String get filterRating => 'Driver rating';

  @override
  String pricePerSeat(String price) {
    return '$price / seat';
  }

  @override
  String seatsAvailable(int available, int total) {
    return '$available / $total free';
  }

  @override
  String durationApprox(String hours) {
    return '~${hours}h';
  }

  @override
  String get rideDetails => 'Ride Details';

  @override
  String get schedule => 'Schedule';

  @override
  String get departureTime => 'Departure Time';

  @override
  String get estimatedArrival => 'Estimated Arrival';

  @override
  String get driver => 'Driver';

  @override
  String get verifiedDriver => 'Verified Driver';

  @override
  String completedTripsCount(int count) {
    return '$count completed trips';
  }

  @override
  String get vehicle => 'Vehicle';

  @override
  String get pickupLocation => 'Pickup Location';

  @override
  String get dropoffLocation => 'Drop-off Location';

  @override
  String get amenities => 'Amenities';

  @override
  String get amenityAc => 'Air Conditioning';

  @override
  String get amenityLuggage => 'Spacious Trunk';

  @override
  String get amenityWifi => 'Free Wi-Fi';

  @override
  String get amenitySmoking => 'No Smoking';

  @override
  String get bookSeat => 'Book Seat';

  @override
  String get contactDriver => 'Contact Driver';

  @override
  String get shareTrip => 'Share Trip';

  @override
  String get bookingTitle => 'Booking';

  @override
  String get stepSelectSeats => '1. Seats';

  @override
  String get stepPassengerInfo => '2. Passenger';

  @override
  String get stepPickup => '3. Pickup Point';

  @override
  String get stepReview => '4. Review';

  @override
  String selectedSeats(int count) {
    return 'Selected seats: $count';
  }

  @override
  String get totalPrice => 'Total Price';

  @override
  String get cancellationPolicy => 'Cancellation Policy';

  @override
  String get cancellationPolicyDesc =>
      'Free cancellation up to 2 hours before scheduled departure.';

  @override
  String get confirmBooking => 'Confirm Booking';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get paymentCash => 'Cash to driver';

  @override
  String get paymentClick => 'Pay with Click';

  @override
  String get paymentPayme => 'Pay with Payme';

  @override
  String get paymentUzum => 'Pay with Uzum Bank';

  @override
  String get bookingSuccessTitle => 'Booking Confirmed!';

  @override
  String get bookingSuccessDesc =>
      'Your ride request has been confirmed. The driver will contact you prior to departure.';

  @override
  String get bookingId => 'Booking ID';

  @override
  String get viewTrip => 'View Trip';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get tabUpcoming => 'Upcoming';

  @override
  String get tabActive => 'Active';

  @override
  String get tabCompleted => 'Completed';

  @override
  String get tabCancelled => 'Cancelled';

  @override
  String get noTripsTitle => 'No trips history';

  @override
  String get noTripsDesc => 'You have no trips in this category.';

  @override
  String get tripDetails => 'Trip Details';

  @override
  String get trackingTitle => 'Trip Tracking';

  @override
  String get statusBookingConfirmed => 'Booking Confirmed';

  @override
  String get statusDriverPreparing => 'Driver Preparing';

  @override
  String get statusDriverArrived => 'Driver Arrived at Pickup';

  @override
  String get statusPassengerPickedUp => 'Passenger Picked Up';

  @override
  String get statusTripStarted => 'Trip in Progress';

  @override
  String get statusNearDestination => 'Approaching Destination';

  @override
  String get statusTripCompleted => 'Trip Completed';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get markAllAsRead => 'Mark all as read';

  @override
  String get noNotificationsTitle => 'No notifications';

  @override
  String get noNotificationsDesc =>
      'Updates about your bookings and trips will appear here.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get myActivity => 'My Activity';

  @override
  String get totalTrips => 'Total Trips';

  @override
  String get savedPlaces => 'Saved Places';

  @override
  String get homePlace => 'Home';

  @override
  String get workPlace => 'Work';

  @override
  String get addPlace => 'Add Place';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Appearance Theme';

  @override
  String get themeSystem => 'System Default';

  @override
  String get themeLight => 'Light Theme';

  @override
  String get themeDark => 'Dark Theme';

  @override
  String get support => 'Help & Support';

  @override
  String get helpCenter => 'Help Center';

  @override
  String get faq => 'Frequently Asked Questions';

  @override
  String get contactSupport => 'Contact Support';

  @override
  String get reportProblem => 'Report a Problem';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get logout => 'Log Out';

  @override
  String get logoutConfirm => 'Are you sure you want to log out?';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get ratingTitle => 'How was your trip?';

  @override
  String get ratingSubtitle =>
      'Rate your driver and help improve our community experience';

  @override
  String get ratingFeedbackHint => 'Leave a review (optional)...';

  @override
  String get submitRating => 'Submit Review';

  @override
  String get tagCleanCar => 'Clean Car';

  @override
  String get tagFriendlyDriver => 'Friendly Driver';

  @override
  String get tagOnTime => 'On Time';

  @override
  String get tagComfortable => 'Comfortable';

  @override
  String get tagSafeDriving => 'Safe Driving';

  @override
  String get cancelTripTitle => 'Cancel Ride';

  @override
  String get cancelTripDesc => 'Are you sure you want to cancel this booking?';

  @override
  String get cancelReason => 'Cancellation Reason';

  @override
  String get reasonChangePlans => 'Plans changed';

  @override
  String get reasonFoundAnother => 'Found alternative transport';

  @override
  String get reasonDriverAsked => 'Driver requested cancellation';

  @override
  String get reasonOther => 'Other reason';

  @override
  String get confirmCancel => 'Confirm Cancellation';

  @override
  String get offlineTitle => 'No Internet Connection';

  @override
  String get offlineDesc => 'Please check your network settings and try again.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorPhoneInvalid => 'Invalid phone number format';

  @override
  String get errorOtpInvalid => 'Invalid verification code';

  @override
  String get errorOtpExpired => 'Verification code has expired';

  @override
  String get onboardingSlide1Badge => 'Intercity Rides';

  @override
  String get onboardingSlide1Title =>
      'Comfortable & Fast Rides\nAcross Uzbekistan';

  @override
  String get onboardingSlide1Desc =>
      'Reliable taxis across Tashkent, Samarkand, Andijan, Fergana, Bukhara and all regions.';

  @override
  String get onboardingSlide2Badge => 'Satellite Map';

  @override
  String get onboardingSlide2Title =>
      'Pick Destination Easily\non Interactive Map';

  @override
  String get onboardingSlide2Desc =>
      'Select any cities and districts of Uzbekistan with satellite view and instant distance calculation.';

  @override
  String get onboardingSlide3Badge => 'Affordable & Fair';

  @override
  String get onboardingSlide3Title => 'Transparent Pricing &\nVerified Drivers';

  @override
  String get onboardingSlide3Desc =>
      'Fair price per kilometer, comfortable vehicles, and guaranteed safe travel.';

  @override
  String get satelliteMode => 'Satellite';

  @override
  String get standardMode => 'Standard Map';

  @override
  String get searchCityDistrictHint => 'Search city or district...';

  @override
  String get allRegions => 'All Regions';

  @override
  String get tashkentRegion => 'Tashkent';

  @override
  String get ferganaValley => 'Fergana Valley';

  @override
  String get samarkandRegion => 'Samarkand';

  @override
  String get bukharaRegion => 'Bukhara';

  @override
  String get southernRegion => 'Kashkadarya / Surkhandarya';

  @override
  String get westernRegion => 'Khorezm / Karakalpakstan';

  @override
  String get notificationsAll => 'All';

  @override
  String get notificationsTrips => 'Trips';

  @override
  String get notificationsPromo => 'Promos';

  @override
  String get notificationsSystem => 'System';

  @override
  String get clearAll => 'Clear All';

  @override
  String get phoneCall => 'Call';

  @override
  String tripLinkCopied(String route) {
    return 'Trip link copied: $route';
  }

  @override
  String callingDriver(String phone) {
    return 'Calling driver: $phone';
  }

  @override
  String get appVersion => 'App version';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get selectTheme => 'Select Theme';

  @override
  String get themeDarkDesc => 'Dark theme, comfortable for eyes';

  @override
  String get themeLightDesc => 'Bright & crisp interface';

  @override
  String get themeSystemDesc => 'Adapts to system settings';

  @override
  String get comfortAndSafety => 'Comfort & Safety';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusApproved => 'Approved';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusActive => 'Active';

  @override
  String get statusInProgress => 'In Progress';

  @override
  String get statusArrived => 'Arrived';

  @override
  String get statusAccepted => 'Accepted';

  @override
  String get statusOnline => 'Online';

  @override
  String get statusOffline => 'Offline';

  @override
  String get statusOnTrip => 'On Trip';

  @override
  String get driverHomeTitle => 'Yo\'l-Yo\'lakay Driver';

  @override
  String get shiftOnlineTitle => 'You are on shift (Online)';

  @override
  String get shiftOfflineTitle => 'Shift is turned off (Offline)';

  @override
  String get shiftOnlineSubtitle => 'You are ready to receive orders';

  @override
  String get shiftOfflineSubtitle => 'Turn on shift to start receiving orders';

  @override
  String get startShift => 'Start Shift';

  @override
  String get endShift => 'End Shift';

  @override
  String get todayPerformance => 'Today\'s Performance';

  @override
  String get dailyLabel => 'Daily';

  @override
  String get todayEarnings => 'Today\'s Earnings';

  @override
  String get completedTrips => 'Completed Trips';

  @override
  String get onlineHours => 'Online Hours';

  @override
  String get acceptanceRate => 'Acceptance Rate';

  @override
  String get walletBalance => 'Wallet Balance';

  @override
  String get topUpBalance => 'Top Up Balance';

  @override
  String get activeTaxiOrderBanner => 'Active taxi order in progress';

  @override
  String get activeIntercityTripBanner => 'Active intercity trip in progress';

  @override
  String get viewDetails => 'View';

  @override
  String get radarOrdersTitle => 'Order Radar';

  @override
  String get noRadarOrdersTitle => 'No new orders yet';

  @override
  String get noRadarOrdersDesc =>
      'New orders will appear here as soon as they become available.';

  @override
  String get orderIncoming => 'New Taxi Order';

  @override
  String get acceptOrder => 'Accept';

  @override
  String get declineOrder => 'Decline';

  @override
  String get driverAssignedStatus => 'Moving towards passenger';

  @override
  String get driverArrivedStatus => 'You arrived. Waiting for passenger';

  @override
  String get finishTrip => 'Complete Trip';

  @override
  String get finalAmountPrompt => 'Final payment amount (UZS):';

  @override
  String get cancelOrderPrompt => 'Cancel Order';

  @override
  String netEarningsLabel(String amount) {
    return 'Your net earnings: $amount';
  }

  @override
  String commissionDeductedLabel(String amount) {
    return 'Commission deducted: $amount';
  }

  @override
  String get backToRadarAction => 'Back to radar';

  @override
  String get markArrived => 'I Have Arrived';

  @override
  String get startTrip => 'Start Trip';

  @override
  String get callPassenger => 'Call Passenger';

  @override
  String get intercityTripsTitle => 'Intercity Trips';

  @override
  String get publishTrip => 'Publish Trip';

  @override
  String get emptyTripsHistory => 'No trips history';

  @override
  String get emptyTripsActiveDesc =>
      'You have no active trips. You can create and publish a new trip.';

  @override
  String get emptyTripsGeneralDesc => 'No trips found in this category.';

  @override
  String get tripDetailsTitle => 'Trip Details';

  @override
  String get createTripTitle => 'Publish New Trip';

  @override
  String get departureCity => 'Departure City';

  @override
  String get destinationCity => 'Destination City';

  @override
  String get totalSeats => 'Total seats';

  @override
  String get tripAmenities => 'Amenities';

  @override
  String get hasAc => 'Air Conditioning';

  @override
  String get allowLuggage => 'Luggage Space';

  @override
  String get allowSmoking => 'Smoking Allowed';

  @override
  String get womenOnly => 'Women Only';

  @override
  String get publishAction => 'Publish Trip';

  @override
  String get tripPublishedSuccess => 'Trip published successfully!';

  @override
  String get walletAndEarnings => 'Wallet & Earnings';

  @override
  String get currentBalance => 'Current Balance';

  @override
  String get mainWallet => 'Main Wallet';

  @override
  String get lowBalanceWarning =>
      'Your balance is below minimum threshold. Please top up to accept orders.';

  @override
  String get depositTitle => 'Top Up Balance';

  @override
  String get selectPaymentSystem => 'Select Payment System:';

  @override
  String get amountInSum => 'Amount (UZS):';

  @override
  String get todayTab => 'Today';

  @override
  String get weeklyTab => 'Week';

  @override
  String get monthlyTab => 'Month';

  @override
  String get totalEarnings => 'Total Earnings';

  @override
  String get tripsCount => 'Trips Count';

  @override
  String get totalDistance => 'Distance';

  @override
  String get totalHours => 'Online Time';

  @override
  String get dailyChart => 'Daily Chart';

  @override
  String get transactionHistory => 'Transaction History';

  @override
  String get noTransactions => 'No transactions yet';

  @override
  String get noTransactionsDesc =>
      'Completed rides and top-up transactions will appear here.';

  @override
  String get paymentProcessing => 'Payment Processing';

  @override
  String get paymentVerifying => 'Verifying with server...';

  @override
  String get verifyPayment => 'Verify Payment';

  @override
  String get reopenPayment => 'Reopen Payment';

  @override
  String get paymentSuccessMessage =>
      'Payment verified successfully and balance updated!';

  @override
  String get paymentPendingMessage =>
      'Payment not confirmed yet. Please retry or wait a moment.';

  @override
  String get driverProfileTitle => 'Driver Profile';

  @override
  String get vehicleInfo => 'Vehicle Information';

  @override
  String get documentsVerification => 'Documents Verification';

  @override
  String get logoutConfirmTitle => 'Log Out';

  @override
  String get logoutConfirmDesc =>
      'Are you sure you want to log out of your driver account?';

  @override
  String get logoutAction => 'Log Out';

  @override
  String tripsCountPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count trips',
      one: '1 trip',
    );
    return '$_temp0';
  }

  @override
  String seatsCountPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seats',
      one: '1 seat',
    );
    return '$_temp0';
  }

  @override
  String get refresh => 'Refresh';

  @override
  String get daily => 'Daily';

  @override
  String get topUp => 'Top-up';

  @override
  String get genericErrorMessage => 'An error occurred';

  @override
  String fieldRequiredError(String field) {
    return '$field is required';
  }

  @override
  String get homeTitle => 'Yol-Yolakay Driver';

  @override
  String get todayStats => 'Today\'s Performance';

  @override
  String get statEarnings => 'Earnings';

  @override
  String get statTripsCount => 'Trips Count';

  @override
  String get statOnlineTime => 'Online Time';

  @override
  String get statAcceptanceRate => 'Acceptance Rate';

  @override
  String get activeTaxiOrderAlert => 'You have an active taxi order!';

  @override
  String get activeTaxiOrderDesc => 'Tap to view trip details';

  @override
  String get activeIntercityTripAlert => 'You have an active intercity trip!';

  @override
  String get activeIntercityTripDesc => 'Tap to view ride details';

  @override
  String tripsCountUnit(int count) {
    return '$count trips';
  }

  @override
  String hours(int count) {
    return '$count hours';
  }

  @override
  String get tripPrice => 'Trip price:';

  @override
  String get arrivedAtPickupAction => 'Arrived at pickup';

  @override
  String get startRideAction => 'Start ride';

  @override
  String get completeRideAction => 'Complete ride';

  @override
  String get cancelOrderAction => 'Cancel order';

  @override
  String get completeRideModalTitle => 'Complete Trip';

  @override
  String get finalPaymentAmountLabel => 'Final payment amount (UZS):';

  @override
  String get completeAction => 'Complete';

  @override
  String get cancelReasonPassengerNoShow => 'Passenger did not respond';

  @override
  String get cancelReasonPassengerTookAnother => 'Passenger took another car';

  @override
  String get cancelReasonCarIssue => 'Car breakdown';

  @override
  String get cancelReasonOther => 'Other reason';

  @override
  String acceptWithTimer(int seconds) {
    return 'Accept ($seconds s)';
  }

  @override
  String get tripsPageTitle => 'Intercity Trips';

  @override
  String get createTripAction => 'Create trip';

  @override
  String get noActiveTripsDesc =>
      'You have no active trips currently. You can publish a new one.';

  @override
  String get noTripsHistoryDesc => 'No trips found in this section.';

  @override
  String seatsDetail(int booked, int available, int total) {
    return 'Seats: $booked booked, $available free (Total: $total)';
  }

  @override
  String passengersCount(int count) {
    return 'Passengers ($count)';
  }

  @override
  String get noPassengersBooked => 'No passengers have booked yet.';

  @override
  String get markRideStartedAction => 'Mark ride started';

  @override
  String get cancelTripAction => 'Cancel trip';

  @override
  String passengerSeatsDetail(int seats, String price) {
    return '$seats seats • $price';
  }

  @override
  String get defaultCancelTripReason => 'Due to technical reasons';

  @override
  String get cancelTripReasonPrompt =>
      'Cancellation reason will be sent to passengers:';

  @override
  String get selectCitiesPrompt =>
      'Please select departure and destination cities';

  @override
  String get citiesMustBeDifferentPrompt =>
      'Departure and destination cities cannot be the same';

  @override
  String get tripCreatedSuccess => 'Trip published successfully!';

  @override
  String get fromCityLabel => 'From (Departure city)';

  @override
  String get toCityLabel => 'To (Destination city)';

  @override
  String get departureDateLabel => 'Departure date and time';

  @override
  String get pricePerSeatLabel => 'Price per seat (UZS)';

  @override
  String seatsOption(int count) {
    return '$count seats';
  }

  @override
  String get pickupAddressLabel => 'Pickup address (Landmark)';

  @override
  String get dropoffAddressLabel => 'Dropoff address';

  @override
  String get amenitiesSectionTitle => 'Amenities & rules';

  @override
  String get hasAcLabel => 'Air conditioning';

  @override
  String get allowLuggageLabel => 'Luggage allowed';

  @override
  String get womenOnlyLabel => 'Women only';

  @override
  String get additionalCommentLabel => 'Additional notes (optional)';

  @override
  String get publishTripAction => 'Publish trip';

  @override
  String get logoutTitle => 'Logout';

  @override
  String get logoutConfirmPrompt =>
      'Are you sure you want to log out of your account?';

  @override
  String get avatarUpdatedSuccess => 'Avatar updated successfully';

  @override
  String get verificationApprovedTitle => 'Verified Driver';

  @override
  String get verificationApprovedSubtitle =>
      'You can access all platform features without limits.';

  @override
  String get verificationUnderReviewTitle => 'Verification Under Review';

  @override
  String get verificationUnderReviewSubtitle =>
      'Your documents are under review by moderators (up to 24h).';

  @override
  String get verificationRejectedTitle => 'Application Rejected';

  @override
  String get verificationRejectedSubtitle =>
      'Tap to re-upload your verification documents.';

  @override
  String get verificationMissingTitle => 'Documents Not Submitted';

  @override
  String get verificationMissingSubtitle =>
      'Complete driver verification to start receiving orders.';

  @override
  String get vehicleInfoTitle => 'Vehicle Information';

  @override
  String vehicleYearAndColor(int year, String color) {
    return 'Year: $year • Color: $color';
  }

  @override
  String get reviewsAndRatingMenu => 'Reviews & Rating';

  @override
  String get walletAndEarningsMenu => 'Wallet & Earnings';

  @override
  String get notificationsMenu => 'Notifications';

  @override
  String get supportMenu => 'Support Service';

  @override
  String get driverVerificationTitle => 'Driver Verification';

  @override
  String get verificationBannerText =>
      'Confirm your identity and vehicle documents to begin receiving orders.';

  @override
  String get personalInfoSectionTitle => '1. Personal Information';

  @override
  String get vehicleInfoSectionTitle => '2. Vehicle Information';

  @override
  String get documentsAndPhotosSectionTitle => '3. Documents & Vehicle Photos';

  @override
  String get submitApplicationAction => 'Submit for Verification';

  @override
  String get cameraOption => 'Take photo';

  @override
  String get galleryOption => 'Choose from gallery';

  @override
  String get uploadAllPhotosPrompt =>
      'Please upload all 6 document and vehicle photos!';

  @override
  String get applicationSubmittedModalTitle => 'Application Submitted!';

  @override
  String get goToHomeAction => 'Go to Home';

  @override
  String get locationPermissionRequired => 'Location permission required';

  @override
  String get backgroundLocationRequired =>
      'Background location permission required';

  @override
  String get enableLocationServices => 'Enable GPS location services';

  @override
  String get notificationPermissionDisabled =>
      'Notification permission disabled';

  @override
  String get cameraPermissionRequired => 'Camera permission required';

  @override
  String get photoPermissionRequired => 'Photo access required';

  @override
  String get permissionDenied => 'Permission denied';

  @override
  String get permissionPermanentlyDenied => 'Permission permanently denied';

  @override
  String get openSettings => 'Open settings';

  @override
  String get notNow => 'Not now';

  @override
  String get tryAgain => 'Try again';

  @override
  String get continueAction => 'Continue';

  @override
  String get someFeaturesUnavailable => 'Some features may not work properly';

  @override
  String get accountBlockedTitle => 'Account suspended';

  @override
  String get accountBlockedMessage =>
      'Your account has been suspended or blocked by administration. Please contact support.';

  @override
  String get verificationRequiredTitle => 'Verification required';

  @override
  String get verificationRequiredMessage =>
      'You must verify your identity and vehicle documents before accepting orders.';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeLightShort => 'Light';

  @override
  String get themeDarkShort => 'Dark';

  @override
  String get themeAuto => 'Auto';

  @override
  String get themeLightHint => 'daytime';

  @override
  String get themeDarkHint => 'night';

  @override
  String get themeAutoHint => 'follows phone';

  @override
  String get languageLatinScript => 'Latin script';

  @override
  String get languageCyrillicScript => 'Cyrillic script';

  @override
  String get languageRussianHint => 'Russian';

  @override
  String get menuTitle => 'Menu';

  @override
  String get menuSettingsHint => 'Language, appearance';

  @override
  String get menuHelp => 'Help';

  @override
  String get menuHelpHint => 'Support';

  @override
  String get menuLogout => 'Log out';

  @override
  String get mapMyLocation => 'My location';

  @override
  String get mapNotifications => 'Notifications';

  @override
  String get driverTodayEarnings => 'Today\'s earnings';

  @override
  String driverTodayPill(String amount) {
    return 'Today: $amount';
  }

  @override
  String get menuEarnings => 'Earnings';

  @override
  String get menuEarningsHint => 'Day, week, month';

  @override
  String get menuTripHistory => 'Trip history';

  @override
  String get menuProfileCar => 'Profile and car';

  @override
  String get menuProfileCarHint => 'Document status';

  @override
  String get driverLastRoute => 'Last route';

  @override
  String get driverOpenAgain => 'Open again today';

  @override
  String get driverOpenRoute => 'Open a route';

  @override
  String get driverNoRouteYet =>
      'Open a route so passengers can see you and book seats';

  @override
  String get driverChangeTimePrice => 'Change time or price';

  @override
  String get driverOnline => 'Online';

  @override
  String get driverOffline => 'Offline';

  @override
  String get driverDocsPending => 'Your documents are being reviewed';

  @override
  String get driverDocsAction => 'View status';

  @override
  String get driverActiveTrip => 'You have an active trip';

  @override
  String get statRating => 'rating';

  @override
  String get statTrips => 'trips';

  @override
  String get statInApp => 'with us';

  @override
  String statMonths(int count) {
    return '$count mo';
  }

  @override
  String get dateToday => 'Today';

  @override
  String get dateYesterday => 'Yesterday';

  @override
  String get histCompleted => 'Completed';

  @override
  String get histCancelled => 'Cancelled';

  @override
  String get histActive => 'Active';

  @override
  String histPassengers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count passengers',
      one: '1 passenger',
    );
    return '$_temp0';
  }

  @override
  String get profileCar => 'Car';

  @override
  String get profileDocuments => 'Documents';

  @override
  String get docLicense => 'Driving licence';

  @override
  String get docVehicle => 'Registration and car photos';

  @override
  String get docApproved => 'Approved';

  @override
  String get docPending => 'In review';

  @override
  String get docRejected => 'Resubmit';

  @override
  String get carFourSeats => '4-seat passenger car';

  @override
  String get profilePhone => 'Phone';

  @override
  String get dpOpenRoute => 'Open a route';

  @override
  String get dpToCity => 'To the city';

  @override
  String get dpToHome => 'Back home';

  @override
  String get dpDepartureTime => 'Departure time';

  @override
  String get dpWhenFull => 'When full';

  @override
  String get dpPricePerSeat => 'Price · 1 seat (20–30k)';

  @override
  String get dpFourSeats => 'The car always has 4 seats';

  @override
  String dpFullCarTotal(String amount) {
    return 'If all 4 seats fill: $amount';
  }

  @override
  String get dpOpen => 'Open the route';

  @override
  String get dpNewRequest => 'NEW REQUEST';

  @override
  String dpPeople(int count) {
    return '$count people';
  }

  @override
  String get dpToPassenger => 'to the passenger';

  @override
  String get dpAccept => 'Accept';

  @override
  String get dpSkip => 'Skip';

  @override
  String get dpPickupTitle => 'Pick up passengers';

  @override
  String dpSeatsTaken(int taken, int total) {
    return '$taken / $total seats taken';
  }

  @override
  String get dpPickedUp => 'picked up';

  @override
  String dpSlidePickedUp(String name) {
    return 'Slide: $name is in the car';
  }

  @override
  String get dpDepart => 'Depart';

  @override
  String get dpWaitMore => 'Wait more';

  @override
  String get dpNoPassengersYet =>
      'No passengers yet. New requests will appear here.';

  @override
  String get dpOnTheWay => 'On the way';

  @override
  String get dpCollected => 'Collected';

  @override
  String get dpOpenNavigator => 'Open in navigator';

  @override
  String get dpSlideArrived => 'Slide: we have arrived';

  @override
  String get dpTripDone => 'Trip finished';

  @override
  String dpEarned(String amount) {
    return 'This trip: $amount';
  }

  @override
  String get dpReturnTitle => 'Open the return trip?';

  @override
  String get dpOpenReturn => 'Open return trip';

  @override
  String get dpNotToday => 'Not returning today';

  @override
  String get dpActionFailed =>
      'That didn\'t work. Check your connection and try again.';

  @override
  String get dpCall => 'Call';

  @override
  String get dpPassenger => 'Passenger';

  @override
  String get dpPickupPoint => 'Pickup point';

  @override
  String get daBadge => 'DRIVER';

  @override
  String get daPhoneTitle => 'Driver sign-in';

  @override
  String get daPhoneBody => 'We\'ll text a code to your number';

  @override
  String get daGetCode => 'Get code';

  @override
  String get daTermsNote => 'By continuing you agree to the terms';

  @override
  String get daPhoneInvalid => 'Enter a valid number (e.g. 93 456 78 90)';

  @override
  String get daWithPassword => 'Sign in with password';

  @override
  String get daOtpTitle => 'Enter the code';

  @override
  String daOtpSentTo(String phone) {
    return 'Sent to $phone';
  }

  @override
  String get daChange => 'Change';

  @override
  String daResendIn(String time) {
    return 'Resend in $time';
  }

  @override
  String get daResend => 'Resend code';

  @override
  String get daOtpAuto =>
      'New number goes to documents; registered drivers go straight home';

  @override
  String dpPendingBanner(int count) {
    return '$count new requests are waiting';
  }

  @override
  String get dpPendingAction => 'Open';
}
