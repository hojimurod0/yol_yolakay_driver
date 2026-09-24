// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppLocalizationsUz extends AppLocalizations {
  AppLocalizationsUz([String locale = 'uz']) : super(locale);

  @override
  String get appName => 'YolYolakay';

  @override
  String get appTagline => 'Shaharlararo qulay va tezkor safarlar';

  @override
  String get skip => 'O\'tkazib yuborish';

  @override
  String get next => 'Keyingisi';

  @override
  String get getStarted => 'Boshlash';

  @override
  String get continueText => 'Davom etish';

  @override
  String get confirm => 'Tasdiqlash';

  @override
  String get cancel => 'Bekor qilish';

  @override
  String get save => 'Saqlash';

  @override
  String get edit => 'Tahrirlash';

  @override
  String get delete => 'O\'chirish';

  @override
  String get close => 'Yopish';

  @override
  String get search => 'Qidirish';

  @override
  String get filter => 'Filtr';

  @override
  String get sort => 'Saralash';

  @override
  String get clear => 'Tozalash';

  @override
  String get apply => 'Qo\'llash';

  @override
  String get back => 'Orqaga';

  @override
  String get retry => 'Qayta urinish';

  @override
  String get done => 'Tayyor';

  @override
  String get onboarding1Title => 'Shaharlararo safarlar osonlashdi';

  @override
  String get onboarding1Desc =>
      'O\'zbekistonning istalgan shahriga ishonchli va qulay taksi toping.';

  @override
  String get onboarding2Title => 'Qulay va xavfsiz avtomobillar';

  @override
  String get onboarding2Desc =>
      'Tajribali va tasdiqlangan haydovchilar bilan xavfsiz sayohat qiling.';

  @override
  String get onboarding3Title => 'O\'z joyingizni oson band qiling';

  @override
  String get onboarding3Desc =>
      'Sizga mos vaqt, narx va qulaylikdagi joyni bir necha bosqichda band qiling.';

  @override
  String get onboarding4Title => 'Safaringizni jonli kuzating';

  @override
  String get onboarding4Desc =>
      'Haydovchi qayerdaligini xaritada ko\'ring va safar tafsilotlaridan doim xabardor bo\'ling.';

  @override
  String get welcomeTitle => 'YolYolakayga xush kelibsiz!';

  @override
  String get welcomeSubtitle =>
      'Shaharlararo safarlaringiz uchun ishonchli hamkor';

  @override
  String get loginOrRegister => 'Kirish yoki ro\'yxatdan o\'tish';

  @override
  String get enterPhoneNumber => 'Telefon raqamingizni kiriting';

  @override
  String get phoneLabel => 'Telefon raqami';

  @override
  String get phoneHint => '90 123 45 67';

  @override
  String get sendOtp => 'Kodni yuborish';

  @override
  String otpSentTo(String phone) {
    return 'Tasdiqlash kodi $phone raqamiga yuborildi';
  }

  @override
  String get enterOtp => 'Tasdiqlash kodini kiriting';

  @override
  String get resendOtp => 'Kodni qayta yuborish';

  @override
  String resendIn(int seconds) {
    return 'Qayta yuborish: $seconds soniya';
  }

  @override
  String get createProfileTitle => 'Profilingizni to\'ldiring';

  @override
  String get createProfileSubtitle =>
      'Haydovchilar sizni tanishi uchun ma\'lumotlaringizni kiriting';

  @override
  String get firstName => 'Ism';

  @override
  String get firstNameHint => 'Ismingizni kiriting';

  @override
  String get lastName => 'Familiya';

  @override
  String get lastNameHint => 'Familiyangizni kiriting';

  @override
  String get email => 'Email (ixtiyoriy)';

  @override
  String get emailHint => 'example@mail.com';

  @override
  String get completeRegistration => 'Ro\'yxatdan o\'tishni yakunlash';

  @override
  String get navHome => 'Asosiy';

  @override
  String get navTrips => 'Safarlarim';

  @override
  String get navNotifications => 'Bildirishnomalar';

  @override
  String get navProfile => 'Profil';

  @override
  String greeting(String name) {
    return 'Salom, $name!';
  }

  @override
  String get whereToGo => 'Qayerga bormoqchisiz?';

  @override
  String get from => 'Qayerdan';

  @override
  String get to => 'Qayerga';

  @override
  String get selectDepartureCity => 'Ketish shahrini tanlang';

  @override
  String get selectDestinationCity => 'Borish shahrini tanlang';

  @override
  String get travelDate => 'Sana';

  @override
  String get today => 'Bugun';

  @override
  String get tomorrow => 'Ertaga';

  @override
  String get passengerCount => 'Yo\'lovchilar soni';

  @override
  String passengers(int count) {
    return '$count yo\'lovchi';
  }

  @override
  String get searchRides => 'Qatnovlarni qidirish';

  @override
  String get swapCities => 'Shaharlarni almashtirish';

  @override
  String get recentSearches => 'So\'nggi qidiruvlar';

  @override
  String get popularRoutes => 'Mashhur yo\'nalishlar';

  @override
  String get savedRoutes => 'Saqlangan yo\'nalishlar';

  @override
  String get noRecentSearches => 'So\'nggi qidiruvlar mavjud emas';

  @override
  String get selectCityTitle => 'Shaharni tanlang';

  @override
  String get searchCityHint => 'Shahar nomini yozing...';

  @override
  String get popularCities => 'Mashhur shaharlar';

  @override
  String get allCities => 'Barcha shaharlar';

  @override
  String get currentLocation => 'Joriy joylashuv';

  @override
  String get availableRides => 'Mavjud qatnovlar';

  @override
  String ridesFound(int count) {
    return '$count ta qatnov topildi';
  }

  @override
  String get noRidesFound => 'Afsuski, qatnovlar topilmadi';

  @override
  String get noRidesDesc => 'Boshqa sana yoki yo\'nalishni tanlab ko\'ring';

  @override
  String get sortCheapest => 'Eng arzon';

  @override
  String get sortEarliest => 'Eng ertangi';

  @override
  String get sortFastest => 'Eng tez';

  @override
  String get sortRating => 'Yuqori reytingli';

  @override
  String get filterPrice => 'Narx bo\'yicha';

  @override
  String get filterCarType => 'Avtomobil turi';

  @override
  String get filterSeats => 'Bo\'sh joylar soni';

  @override
  String get filterRating => 'Haydovchi reytingi';

  @override
  String pricePerSeat(String price) {
    return '$price / o\'rin';
  }

  @override
  String seatsAvailable(int available, int total) {
    return '$available / $total ta bo\'sh';
  }

  @override
  String durationApprox(String hours) {
    return '~$hours soat';
  }

  @override
  String get rideDetails => 'Qatnov tafsilotlari';

  @override
  String get schedule => 'Jadval';

  @override
  String get departureTime => 'Jo\'nash vaqti';

  @override
  String get estimatedArrival => 'Taxminiy yetib borish';

  @override
  String get driver => 'Haydovchi';

  @override
  String get verifiedDriver => 'Tasdiqlangan haydovchi';

  @override
  String completedTripsCount(int count) {
    return '$count ta muvaffaqiyatli safar';
  }

  @override
  String get vehicle => 'Avtomobil';

  @override
  String get pickupLocation => 'Chiqish joyi';

  @override
  String get dropoffLocation => 'Tushish joyi';

  @override
  String get amenities => 'Qulayliklar';

  @override
  String get amenityAc => 'Konditsioner';

  @override
  String get amenityLuggage => 'Katta yukxona';

  @override
  String get amenityWifi => 'Wi-Fi';

  @override
  String get amenitySmoking => 'Chekish mumkin emas';

  @override
  String get bookSeat => 'Joyni band qilish';

  @override
  String get contactDriver => 'Haydovchi bilan bog\'lanish';

  @override
  String get shareTrip => 'Safarni ulashish';

  @override
  String get bookingTitle => 'Band qilish';

  @override
  String get stepSelectSeats => '1. Joylar soni';

  @override
  String get stepPassengerInfo => '2. Yo\'lovchi ma\'lumotlari';

  @override
  String get stepPickup => '3. Chiqish nuqtasi';

  @override
  String get stepReview => '4. Tekshirish';

  @override
  String selectedSeats(int count) {
    return 'Tanlangan joylar: $count';
  }

  @override
  String get totalPrice => 'Jami to\'lov';

  @override
  String get cancellationPolicy => 'Bekor qilish qoidalari';

  @override
  String get cancellationPolicyDesc =>
      'Safar boshlanishiga 2 soat qolguncha bepul bekor qilish mumkin.';

  @override
  String get confirmBooking => 'Band qilishni tasdiqlash';

  @override
  String get paymentMethod => 'To\'lov usuli';

  @override
  String get paymentCash => 'Haydovchiga naqd to\'lash';

  @override
  String get paymentClick => 'Click orqali to\'lash';

  @override
  String get paymentPayme => 'Payme orqali to\'lash';

  @override
  String get paymentUzum => 'Uzum Bank orqali to\'lash';

  @override
  String get bookingSuccessTitle => 'Muvaffaqiyatli band qilindi!';

  @override
  String get bookingSuccessDesc =>
      'Sizning buyurtmangiz qabul qilindi. Haydovchi siz bilan bog\'lanadi.';

  @override
  String get bookingId => 'Buyurtma ID';

  @override
  String get viewTrip => 'Safarni ko\'rish';

  @override
  String get backToHome => 'Bosh sahifaga';

  @override
  String get tabUpcoming => 'Kutilayotgan';

  @override
  String get tabActive => 'Faol';

  @override
  String get tabCompleted => 'Tugallangan';

  @override
  String get tabCancelled => 'Bekor qilingan';

  @override
  String get noTripsTitle => 'Qatnovlar tarixi bo\'sh';

  @override
  String get noTripsDesc => 'Sizda ushbu bo\'limda hech qanday safar yo\'q.';

  @override
  String get tripDetails => 'Safar tafsilotlari';

  @override
  String get trackingTitle => 'Safarni kuzatish';

  @override
  String get statusBookingConfirmed => 'Band qilish tasdiqlandi';

  @override
  String get statusDriverPreparing =>
      'Haydovchi yo\'lga chiqishga tayyorlanmoqda';

  @override
  String get statusDriverArrived => 'Haydovchi yetib keldi';

  @override
  String get statusPassengerPickedUp => 'Yo\'lovchi olindi';

  @override
  String get statusTripStarted => 'Safar boshlandi';

  @override
  String get statusNearDestination => 'Manzilga oz qoldi';

  @override
  String get statusTripCompleted => 'Safar yakunlandi';

  @override
  String get notificationsTitle => 'Bildirishnomalar';

  @override
  String get markAllAsRead => 'Barchasini o\'qilgan qilish';

  @override
  String get noNotificationsTitle => 'Bildirishnomalar yo\'q';

  @override
  String get noNotificationsDesc =>
      'Yangi xabarlar paydo bo\'lganda shu yerda ko\'rinadi.';

  @override
  String get profileTitle => 'Profil';

  @override
  String get editProfile => 'Profilni tahrirlash';

  @override
  String get personalInfo => 'Shaxsiy ma\'lumotlar';

  @override
  String get myActivity => 'Mening faolligim';

  @override
  String get totalTrips => 'Jami safarlar';

  @override
  String get savedPlaces => 'Saqlangan manzillar';

  @override
  String get homePlace => 'Uy';

  @override
  String get workPlace => 'Ish';

  @override
  String get addPlace => 'Manzil qo\'shish';

  @override
  String get settings => 'Sozlamalar';

  @override
  String get language => 'Til';

  @override
  String get theme => 'Mavzu';

  @override
  String get themeSystem => 'Tizim sozlamasi';

  @override
  String get themeLight => 'Yorug\' mavzu';

  @override
  String get themeDark => 'Qorong\'i mavzu';

  @override
  String get support => 'Yordam va qo\'llab-quvvatlash';

  @override
  String get helpCenter => 'Yordam markazi';

  @override
  String get faq => 'Ko\'p beriladigan savollar';

  @override
  String get contactSupport => 'Qo\'llab-quvvatlash xizmati';

  @override
  String get reportProblem => 'Muammo haqida xabar berish';

  @override
  String get termsOfService => 'Foydalanish shartlari';

  @override
  String get privacyPolicy => 'Maxfiylik siyosati';

  @override
  String get logout => 'Chiqish';

  @override
  String get logoutConfirm => 'Haqiqatan ham hisobingizdan chiqmoqchimisiz?';

  @override
  String get deleteAccount => 'Hisobni o\'chirish';

  @override
  String get ratingTitle => 'Safaringiz qanday o\'tdi?';

  @override
  String get ratingSubtitle =>
      'Haydovchiga baho bering va xizmat sifatini oshirishga yordam bering';

  @override
  String get ratingFeedbackHint => 'Fikringizni qoldiring (ixtiyoriy)...';

  @override
  String get submitRating => 'Baholashni yuborish';

  @override
  String get tagCleanCar => 'Toza avtomobil';

  @override
  String get tagFriendlyDriver => 'Xushmuomala haydovchi';

  @override
  String get tagOnTime => 'O\'z vaqtida';

  @override
  String get tagComfortable => 'Qulay';

  @override
  String get tagSafeDriving => 'Xavfsiz haydash';

  @override
  String get cancelTripTitle => 'Safarni bekor qilish';

  @override
  String get cancelTripDesc =>
      'Haqiqatan ham ushbu safarni bekor qilmoqchimisiz?';

  @override
  String get cancelReason => 'Bekor qilish sababi';

  @override
  String get reasonChangePlans => 'Rejalarim o\'zgardi';

  @override
  String get reasonFoundAnother => 'Boshqa transport topdim';

  @override
  String get reasonDriverAsked => 'Haydovchi bekor qilishni so\'radi';

  @override
  String get reasonOther => 'Boshqa sabab';

  @override
  String get confirmCancel => 'Bekor qilishni tasdiqlash';

  @override
  String get offlineTitle => 'Internet aloqasi yo\'q';

  @override
  String get offlineDesc =>
      'Iltimos, internet ulanishini tekshiring va qayta urinib ko\'ring.';

  @override
  String get errorGeneric =>
      'Kutilmagan xatolik yuz berdi. Qayta urinib ko\'ring.';

  @override
  String get errorPhoneInvalid => 'Telefon raqami noto\'g\'ri kiritildi';

  @override
  String get errorOtpInvalid => 'Tasdiqlash kodi noto\'g\'ri';

  @override
  String get errorOtpExpired => 'Tasdiqlash kodi muddati tugagan';

  @override
  String get onboardingSlide1Badge => 'Shaharlararo qatnovlar';

  @override
  String get onboardingSlide1Title =>
      'O\'zbekiston bo\'ylab\nqulay va tezkor safarlar';

  @override
  String get onboardingSlide1Desc =>
      'Toshkent, Samarqand, Andijon, Farg\'ona, Buxoro va barcha viloyatlar bo\'ylab ishonchli taksilar.';

  @override
  String get onboardingSlide2Badge => 'Sun\'iy yo\'ldosh xaritasi';

  @override
  String get onboardingSlide2Title =>
      'Xaritadan manzilni\noson va aniq tanlang';

  @override
  String get onboardingSlide2Desc =>
      'O\'zbekistonning barcha shahar va tumanlarini sun\'iy yo\'ldosh xaritasidan tanlang va masofani ko\'ring.';

  @override
  String get onboardingSlide3Badge => 'Hamyonbop va shaffof';

  @override
  String get onboardingSlide3Title =>
      'Shaffof narxlar va\ntasdiqlangan haydovchilar';

  @override
  String get onboardingSlide3Desc =>
      'Har bir kilometr uchun adolatli narxlar, qulay avtomobillar va xavfsiz sayohat kafolati.';

  @override
  String get satelliteMode => 'Sun\'iy yo\'ldosh';

  @override
  String get standardMode => 'Standart xarita';

  @override
  String get searchCityDistrictHint => 'Shahar yoki tumanni qidiring...';

  @override
  String get allRegions => 'Barchasi';

  @override
  String get tashkentRegion => 'Toshkent';

  @override
  String get ferganaValley => 'Farg\'ona vodiysi';

  @override
  String get samarkandRegion => 'Samarqand';

  @override
  String get bukharaRegion => 'Buxoro';

  @override
  String get southernRegion => 'Qashqadaryo / Surxondaryo';

  @override
  String get westernRegion => 'Xorazm / Qoraqalpog\'iston';

  @override
  String get notificationsAll => 'Barchasi';

  @override
  String get notificationsTrips => 'Safarlar';

  @override
  String get notificationsPromo => 'Aksiyalar';

  @override
  String get notificationsSystem => 'Tizim';

  @override
  String get clearAll => 'Tozalash';

  @override
  String get phoneCall => 'Qo\'ng\'iroq qilish';

  @override
  String tripLinkCopied(String route) {
    return 'Safar havolasi nusxalandi: $route';
  }

  @override
  String callingDriver(String phone) {
    return 'Haydovchiga qo\'ng\'iroq qilinmoqda: $phone';
  }

  @override
  String get appVersion => 'Ilova versiyasi';

  @override
  String get selectLanguage => 'Tilni tanlang';

  @override
  String get selectTheme => 'Mavzuni tanlang';

  @override
  String get themeDarkDesc => 'Qorong\'i rejim, ko\'zga qulay';

  @override
  String get themeLightDesc => 'Yorug\' va tiniq interfeys';

  @override
  String get themeSystemDesc => 'Tizim sozlamasiga moslashadi';

  @override
  String get comfortAndSafety => 'Qulaylik va xavfsizlik';

  @override
  String get statusPending => 'Kutilmoqda';

  @override
  String get statusApproved => 'Tasdiqlangan';

  @override
  String get statusRejected => 'Rad etilgan';

  @override
  String get statusCompleted => 'Yakunlangan';

  @override
  String get statusCancelled => 'Bekor qilingan';

  @override
  String get statusActive => 'Faol';

  @override
  String get statusInProgress => 'Jarayonda';

  @override
  String get statusArrived => 'Yetib keldi';

  @override
  String get statusAccepted => 'Qabul qilindi';

  @override
  String get statusOnline => 'Onlayn';

  @override
  String get statusOffline => 'Oflayn';

  @override
  String get statusOnTrip => 'Safarda';

  @override
  String get driverHomeTitle => 'Yo\'l-Yo\'lakay Haydovchi';

  @override
  String get shiftOnlineTitle => 'Siz smenadasiz (Onlayn)';

  @override
  String get shiftOfflineTitle => 'Smena o\'chirilgan (Oflayn)';

  @override
  String get shiftOnlineSubtitle => 'Buyurtmalarni qabul qilishga tayyorsiz';

  @override
  String get shiftOfflineSubtitle => 'Buyurtmalar olish uchun smenani yoqing';

  @override
  String get startShift => 'Smenani boshlash';

  @override
  String get endShift => 'Smenani tugatish';

  @override
  String get todayPerformance => 'Bugungi ko\'rsatkichlar';

  @override
  String get dailyLabel => 'Kunlik';

  @override
  String get todayEarnings => 'Kunlik daromad';

  @override
  String get completedTrips => 'Bajarilgan safarlar';

  @override
  String get onlineHours => 'Onlayn vaqt';

  @override
  String get acceptanceRate => 'Qabul qilish ko\'rsatkichi';

  @override
  String get walletBalance => 'Hamyon balansi';

  @override
  String get topUpBalance => 'Balansni to\'ldirish';

  @override
  String get activeTaxiOrderBanner => 'Faol tezkor taksi buyurtmasi mavjud';

  @override
  String get activeIntercityTripBanner =>
      'Faol shaharlararo qatnovingiz mavjud';

  @override
  String get viewDetails => 'Ko\'rish';

  @override
  String get radarOrdersTitle => 'Buyurtmalar Radari';

  @override
  String get noRadarOrdersTitle => 'Hozircha yangi buyurtmalar yo\'q';

  @override
  String get noRadarOrdersDesc =>
      'Yangi buyurtmalar paydo bo\'lganda bu yerda ko\'rinadi va signal beriladi.';

  @override
  String get orderIncoming => 'Yangi taksi buyurtmasi';

  @override
  String get acceptOrder => 'Qabul qilish';

  @override
  String get declineOrder => 'Rad etish';

  @override
  String get driverAssignedStatus => 'Yo\'lovchi tomon harakatlanmoqdasiz';

  @override
  String get driverArrivedStatus => 'Yetib keldingiz. Yo\'lovchi kutilyapti';

  @override
  String get finishTrip => 'Safarni yakunlash';

  @override
  String get finalAmountPrompt => 'Yakuniy to\'lov miqdori (so\'mda):';

  @override
  String get cancelOrderPrompt => 'Buyurtmani bekor qilish';

  @override
  String netEarningsLabel(String amount) {
    return 'Sizning sof daromadingiz: $amount';
  }

  @override
  String commissionDeductedLabel(String amount) {
    return 'Ushlab qolingan komissiya: $amount';
  }

  @override
  String get backToRadarAction => 'Radarga qaytish';

  @override
  String get markArrived => 'Yetib keldim';

  @override
  String get startTrip => 'Safarni boshlash';

  @override
  String get callPassenger => 'Qo\'ng\'iroq qilish';

  @override
  String get intercityTripsTitle => 'Shaharlararo qatnovlar';

  @override
  String get publishTrip => 'Qatnov e\'lon qilish';

  @override
  String get emptyTripsHistory => 'Qatnovlar tarixi bo\'sh';

  @override
  String get emptyTripsActiveDesc =>
      'Sizda hozircha faol qatnov yo\'q. Yangi qatnov e\'lon qilishingiz mumkin.';

  @override
  String get emptyTripsGeneralDesc => 'Ushbu bo\'limda qatnovlar mavjud emas.';

  @override
  String get tripDetailsTitle => 'Qatnov tafsilotlari';

  @override
  String get createTripTitle => 'Yangi qatnov e\'lon qilish';

  @override
  String get departureCity => 'Jo\'nash shahri';

  @override
  String get destinationCity => 'Yetib borish shahri';

  @override
  String get totalSeats => 'O\'rinlar soni';

  @override
  String get tripAmenities => 'Qulayliklar';

  @override
  String get hasAc => 'Konditsioner';

  @override
  String get allowLuggage => 'Yuk joyi';

  @override
  String get allowSmoking => 'Chekishga ruxsat';

  @override
  String get womenOnly => 'Faqat ayollar uchun';

  @override
  String get publishAction => 'Qatnovni e\'lon qilish';

  @override
  String get tripPublishedSuccess => 'Qatnov muvaffaqiyatli e\'lon qilindi!';

  @override
  String get walletAndEarnings => 'Hamyon va Daromadlar';

  @override
  String get currentBalance => 'Joriy balans';

  @override
  String get mainWallet => 'Asosiy hamyon';

  @override
  String get lowBalanceWarning =>
      'Balansingiz minimal miqdordan kam. Buyurtmalarni qabul qilish uchun to\'ldiring.';

  @override
  String get depositTitle => 'Hisobni to\'ldirish';

  @override
  String get selectPaymentSystem => 'To\'lov tizimini tanlang:';

  @override
  String get amountInSum => 'Miqdor (so\'mda):';

  @override
  String get todayTab => 'Bugun';

  @override
  String get weeklyTab => 'Hafta';

  @override
  String get monthlyTab => 'Oy';

  @override
  String get totalEarnings => 'Jami daromad';

  @override
  String get tripsCount => 'Safarlar soni';

  @override
  String get totalDistance => 'Masofa';

  @override
  String get totalHours => 'Onlayn vaqt';

  @override
  String get dailyChart => 'Kunlik grafik';

  @override
  String get transactionHistory => 'Tranzaksiyalar tarixi';

  @override
  String get noTransactions => 'Hozircha tranzaksiyalar yo\'q';

  @override
  String get noTransactionsDesc =>
      'Bajarilgan safarlar va hisob to\'ldirishlar shu yerda aks etadi.';

  @override
  String get paymentProcessing => 'To\'lov jarayoni';

  @override
  String get paymentVerifying => 'Server orqali tekshirilmoqda...';

  @override
  String get verifyPayment => 'To\'lovni tekshirish';

  @override
  String get reopenPayment => 'Qayta ochish';

  @override
  String get paymentSuccessMessage =>
      'To\'lov muvaffaqiyatli qabul qilindi va balans yangilandi!';

  @override
  String get paymentPendingMessage =>
      'To\'lov hali tasdiqlanmadi. Qayta urinib ko\'ring yoki biroz kuting.';

  @override
  String get driverProfileTitle => 'Haydovchi profili';

  @override
  String get vehicleInfo => 'Avtomobil ma\'lumotlari';

  @override
  String get documentsVerification => 'Hujjatlar verifikatsiyasi';

  @override
  String get logoutConfirmTitle => 'Tizimdan chiqish';

  @override
  String get logoutConfirmDesc =>
      'Haqiqatan ham hisobingizdan chiqmoqchimisiz?';

  @override
  String get logoutAction => 'Chiqish';

  @override
  String tripsCountPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta safar',
      one: '1 ta safar',
    );
    return '$_temp0';
  }

  @override
  String seatsCountPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta o\'rin',
      one: '1 ta o\'rin',
    );
    return '$_temp0';
  }

  @override
  String get refresh => 'Yangilash';

  @override
  String get daily => 'Kunlik';

  @override
  String get topUp => 'To\'ldirish';

  @override
  String get genericErrorMessage => 'Xatolik yuz berdi';

  @override
  String fieldRequiredError(String field) {
    return '$field to\'ldirilishi majburiy';
  }

  @override
  String get homeTitle => 'Yo\'l-Yo\'lakay Haydovchi';

  @override
  String get todayStats => 'Bugungi ko\'rsatkichlar';

  @override
  String get statEarnings => 'Daromad';

  @override
  String get statTripsCount => 'Safarlar soni';

  @override
  String get statOnlineTime => 'Onlayn vaqt';

  @override
  String get statAcceptanceRate => 'Qabul darajasi';

  @override
  String get activeTaxiOrderAlert => 'Faol taksi buyurtmangiz bor!';

  @override
  String get activeTaxiOrderDesc => 'Safar sahifasiga o\'tish uchun bosing';

  @override
  String get activeIntercityTripAlert => 'Faol shaharlararo qatnovingiz bor!';

  @override
  String get activeIntercityTripDesc =>
      'Qatnov tafsilotlarini ko\'rish uchun bosing';

  @override
  String tripsCountUnit(int count) {
    return '$count ta';
  }

  @override
  String hours(int count) {
    return '$count soat';
  }

  @override
  String get tripPrice => 'Safar narxi:';

  @override
  String get arrivedAtPickupAction => 'Yetib keldim (Manzildaman)';

  @override
  String get startRideAction => 'Yo\'lga chiqdik (Safarni boshlash)';

  @override
  String get completeRideAction => 'Safarni yakunlash';

  @override
  String get cancelOrderAction => 'Buyurtmani bekor qilish';

  @override
  String get completeRideModalTitle => 'Safarni yakunlash';

  @override
  String get finalPaymentAmountLabel => 'Yakuniy to\'lov miqdori (so\'mda):';

  @override
  String get completeAction => 'Yakunlash';

  @override
  String get cancelReasonPassengerNoShow => 'Yo\'lovchi aloqaga chiqmadi';

  @override
  String get cancelReasonPassengerTookAnother =>
      'Yo\'lovchi boshqa mashina bilan ketdi';

  @override
  String get cancelReasonCarIssue => 'Avtomobil nosozligi';

  @override
  String get cancelReasonOther => 'Boshqa sabab';

  @override
  String acceptWithTimer(int seconds) {
    return 'Qabul qilish ($seconds s)';
  }

  @override
  String get tripsPageTitle => 'Shaharlararo qatnovlar';

  @override
  String get createTripAction => 'Qatnov e\'lon qilish';

  @override
  String get noActiveTripsDesc =>
      'Sizda hozircha faol qatnov yo\'q. Yangi qatnov e\'lon qilishingiz mumkin.';

  @override
  String get noTripsHistoryDesc => 'Ushbu bo\'limda qatnovlar mavjud emas.';

  @override
  String seatsDetail(int booked, int available, int total) {
    return 'O\'rinlar: $booked ta band, $available ta bo\'sh (Jami: $total)';
  }

  @override
  String passengersCount(int count) {
    return 'Yo\'lovchilar ($count ta)';
  }

  @override
  String get noPassengersBooked => 'Hozircha yo\'lovchilar bron qilmagan.';

  @override
  String get markRideStartedAction => 'Safar boshlandi deb belgilash';

  @override
  String get cancelTripAction => 'Qatnovni bekor qilish';

  @override
  String passengerSeatsDetail(int seats, String price) {
    return '$seats ta o\'rin • $price';
  }

  @override
  String get defaultCancelTripReason => 'Texnik sabablarga ko\'ra';

  @override
  String get cancelTripReasonPrompt =>
      'Bekor qilish sababi yo\'lovchilarga yuboriladi:';

  @override
  String get selectCitiesPrompt =>
      'Iltimos, jo\'nash va yetib borish shaharlarini tanlang';

  @override
  String get citiesMustBeDifferentPrompt =>
      'Jo\'nash va borish shaharlari bir xil bo\'lishi mumkin emas';

  @override
  String get tripCreatedSuccess => 'Qatnov muvaffaqiyatli e\'lon qilindi!';

  @override
  String get fromCityLabel => 'Qayerdan (Jo\'nash shahri)';

  @override
  String get toCityLabel => 'Qayerga (Borish shahri)';

  @override
  String get departureDateLabel => 'Jo\'nash sanasi va vaqti';

  @override
  String get pricePerSeatLabel => 'Bir o\'rin narxi (so\'m)';

  @override
  String seatsOption(int count) {
    return '$count o\'rin';
  }

  @override
  String get pickupAddressLabel => 'Kutib olish manzili (Mo\'ljal)';

  @override
  String get dropoffAddressLabel => 'Yetkazib qo\'yish manzili';

  @override
  String get amenitiesSectionTitle => 'Qulayliklar va qoidalar';

  @override
  String get hasAcLabel => 'Konditsioner bor';

  @override
  String get allowLuggageLabel => 'Bagaj joyi bor';

  @override
  String get womenOnlyLabel => 'Faqat ayollar uchun';

  @override
  String get additionalCommentLabel => 'Qo\'shimcha izoh (ixtiyoriy)';

  @override
  String get publishTripAction => 'Qatnovni e\'lon qilish';

  @override
  String get logoutTitle => 'Tizimdan chiqish';

  @override
  String get logoutConfirmPrompt =>
      'Haqiqatan ham hisobingizdan chiqmoqchimisiz?';

  @override
  String get avatarUpdatedSuccess => 'Avatar muvaffaqiyatli yangilandi';

  @override
  String get verificationApprovedTitle => 'Tasdiqlangan haydovchi';

  @override
  String get verificationApprovedSubtitle =>
      'Barcha xizmatlardan cheklovlarsiz foydalanishingiz mumkin.';

  @override
  String get verificationUnderReviewTitle => 'Verifikatsiya tekshirilmoqda';

  @override
  String get verificationUnderReviewSubtitle =>
      'Hujjatlaringiz moderatorlar tomonidan ko\'rib chiqilmoqda (24 soatgacha).';

  @override
  String get verificationRejectedTitle => 'Arizangiz rad etilgan';

  @override
  String get verificationRejectedSubtitle =>
      'Hujjatlarni qayta yuklash uchun bosing.';

  @override
  String get verificationMissingTitle => 'Hujjatlar topshirilmagan';

  @override
  String get verificationMissingSubtitle =>
      'Buyurtma olishni boshlash uchun verifikatsiyadan o\'ting.';

  @override
  String get vehicleInfoTitle => 'Avtomobil ma\'lumotlari';

  @override
  String vehicleYearAndColor(int year, String color) {
    return 'Yili: $year • Rangi: $color';
  }

  @override
  String get reviewsAndRatingMenu => 'Sharhlar va Reyting';

  @override
  String get walletAndEarningsMenu => 'Hamyon va Daromadlar';

  @override
  String get notificationsMenu => 'Bildirishnomalar';

  @override
  String get supportMenu => 'Qo\'llab-quvvatlash';

  @override
  String get driverVerificationTitle => 'Haydovchi verifikatsiyasi';

  @override
  String get verificationBannerText =>
      'Buyurtmalarni qabul qilish uchun shaxsingiz va avtomobilingiz hujjatlarini tasdiqlang.';

  @override
  String get personalInfoSectionTitle => '1. Shaxsiy ma\'lumotlar';

  @override
  String get vehicleInfoSectionTitle => '2. Avtomobil ma\'lumotlari';

  @override
  String get documentsAndPhotosSectionTitle =>
      '3. Hujjat va avtomobil fotosuratlari';

  @override
  String get submitApplicationAction => 'Hujjatlarni tekshirishga yuborish';

  @override
  String get cameraOption => 'Kameradan olish';

  @override
  String get galleryOption => 'Galereyadan tanlash';

  @override
  String get uploadAllPhotosPrompt =>
      'Iltimos, barcha 6 ta hujjat va avtomobil rasmlarini yuklang!';

  @override
  String get applicationSubmittedModalTitle => 'Arizangiz qabul qilindi!';

  @override
  String get goToHomeAction => 'Bosh sahifaga o\'tish';

  @override
  String get locationPermissionRequired => 'Joylashuv ruxsati talab qilinadi';

  @override
  String get backgroundLocationRequired =>
      'Fonda joylashuv ruxsati talab qilinadi';

  @override
  String get enableLocationServices => 'GPS xizmatini yoqing';

  @override
  String get notificationPermissionDisabled =>
      'Bildirishnomalar ruxsati o\'chirilgan';

  @override
  String get cameraPermissionRequired => 'Kamera ruxsati talab qilinadi';

  @override
  String get photoPermissionRequired =>
      'Fotosuratlarga kirish ruxsati talab qilinadi';

  @override
  String get permissionDenied => 'Ruxsat berilmadi';

  @override
  String get permissionPermanentlyDenied => 'Ruxsat butunlay rad etildi';

  @override
  String get openSettings => 'Sozlamalarni ochish';

  @override
  String get notNow => 'Keyinroq';

  @override
  String get tryAgain => 'Qayta urinish';

  @override
  String get continueAction => 'Davom etish';

  @override
  String get someFeaturesUnavailable =>
      'Ba\'zi funksiyalar to\'liq ishlamasligi mumkin';

  @override
  String get accountBlockedTitle => 'Hisob bloklangan';

  @override
  String get accountBlockedMessage =>
      'Hisobingiz ma\'muriyat tomonidan to\'xtatilgan yoki bloklangan. Qo\'llab-quvvatlash xizmati bilan bog\'laning.';

  @override
  String get verificationRequiredTitle => 'Verifikatsiya talab qilinadi';

  @override
  String get verificationRequiredMessage =>
      'Buyurtmalarni qabul qilish uchun shaxsingiz va avtomobil hujjatlari tasdiqlanishi kerak.';
}
