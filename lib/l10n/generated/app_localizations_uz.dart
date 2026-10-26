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
  String get verificationUnderReviewTitle => 'Admin tekshiruvida (12 soat)';

  @override
  String get verificationUnderReviewSubtitle =>
      'Hujjatlaringiz adminga yuborildi va 12 soat ichida tekshiriladi. Hozircha sinov rejimida ilovadan to\'liq foydalanishingiz mumkin.';

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

  @override
  String get appearance => 'Ko\'rinish';

  @override
  String get themeLightShort => 'Yorug\'';

  @override
  String get themeDarkShort => 'Qorong\'i';

  @override
  String get themeAuto => 'Avto';

  @override
  String get themeLightHint => 'kunduzgi';

  @override
  String get themeDarkHint => 'tungi';

  @override
  String get themeAutoHint => 'telefon bo\'yicha';

  @override
  String get languageLatinScript => 'lotin yozuvi';

  @override
  String get languageCyrillicScript => 'kirill yozuvi';

  @override
  String get languageRussianHint => 'rus tili';

  @override
  String get menuTitle => 'Menyu';

  @override
  String get menuSettingsHint => 'Til, ko\'rinish';

  @override
  String get menuHelp => 'Yordam';

  @override
  String get menuHelpHint => 'Qo\'llab-quvvatlash';

  @override
  String get menuLogout => 'Chiqish';

  @override
  String get mapMyLocation => 'Joylashuvimga qaytish';

  @override
  String get mapNotifications => 'Bildirishnomalar';

  @override
  String get driverTodayEarnings => 'Bugungi daromad';

  @override
  String driverTodayPill(String amount) {
    return 'Bugun: $amount';
  }

  @override
  String get menuEarnings => 'Daromad';

  @override
  String get menuEarningsHint => 'Kun, hafta, oy';

  @override
  String get menuTripHistory => 'Safarlar tarixi';

  @override
  String get menuProfileCar => 'Profil va mashina';

  @override
  String get menuProfileCarHint => 'Hujjatlar holati';

  @override
  String get driverLastRoute => 'Oxirgi yo\'nalish';

  @override
  String get driverOpenAgain => 'Bugun ham ochish';

  @override
  String get driverOpenRoute => 'Yo\'nalish ochish';

  @override
  String get driverNoRouteYet =>
      'Yo\'nalish oching — yo\'lovchilar sizni ko\'radi va joy band qiladi';

  @override
  String get driverChangeTimePrice => 'Vaqt yoki narxni o\'zgartirish';

  @override
  String get driverOnline => 'Liniyada';

  @override
  String get driverOffline => 'Liniyadan tashqari';

  @override
  String get driverDocsPending => 'Hujjatlaringiz tekshirilmoqda';

  @override
  String get driverDocsAction => 'Holatni ko\'rish';

  @override
  String get driverActiveTrip => 'Sizda faol safar bor';

  @override
  String get statRating => 'reyting';

  @override
  String get statTrips => 'safar';

  @override
  String get statInApp => 'ilovada';

  @override
  String statMonths(int count) {
    return '$count oy';
  }

  @override
  String get dateToday => 'Bugun';

  @override
  String get dateYesterday => 'Kecha';

  @override
  String get histCompleted => 'Yakunlandi';

  @override
  String get histCancelled => 'Bekor qilindi';

  @override
  String get histActive => 'Faol';

  @override
  String histPassengers(int count) {
    return '$count yo\'lovchi';
  }

  @override
  String get profileCar => 'Mashina';

  @override
  String get profileDocuments => 'Hujjatlar';

  @override
  String get docLicense => 'Haydovchilik guvohnomasi';

  @override
  String get docVehicle => 'Texnik pasport va mashina rasmlari';

  @override
  String get docApproved => 'Tasdiqlangan';

  @override
  String get docPending => 'Tekshirilmoqda';

  @override
  String get docRejected => 'Qayta yuboring';

  @override
  String get carFourSeats => '4 o\'rinli yengil mashina';

  @override
  String get profilePhone => 'Telefon';

  @override
  String get dpOpenRoute => 'Yo\'nalish ochish';

  @override
  String get dpToCity => 'Shaharga';

  @override
  String get dpToHome => 'Uyga';

  @override
  String get dpDepartureTime => 'Jo\'nash vaqti';

  @override
  String get dpWhenFull => 'To\'lsa';

  @override
  String get dpPricePerSeat => 'Narx · 1 o\'rin (20–30 ming)';

  @override
  String get dpFourSeats => 'Mashina har doim 4 o\'rinli';

  @override
  String dpFullCarTotal(String amount) {
    return '4 o\'rin to\'lsa: $amount';
  }

  @override
  String get dpOpen => 'Yo\'nalishni ochish';

  @override
  String get dpNewRequest => 'YANGI SO\'ROV';

  @override
  String dpPeople(int count) {
    return '$count kishi';
  }

  @override
  String get dpToPassenger => 'yo\'lovchigacha';

  @override
  String get dpAccept => 'Qabul qilish';

  @override
  String get dpSkip => 'O\'tkazib yuborish';

  @override
  String get dpPickupTitle => 'Yo\'lovchilarni olish';

  @override
  String dpSeatsTaken(int taken, int total) {
    return '$taken / $total o\'rin band';
  }

  @override
  String get dpPickedUp => 'olindi';

  @override
  String dpSlidePickedUp(String name) {
    return 'Surib tasdiqlang: ${name}ni oldim';
  }

  @override
  String get dpDepart => 'Jo\'nash';

  @override
  String get dpWaitMore => 'Yana kutish';

  @override
  String get dpNoPassengersYet =>
      'Hali yo\'lovchi yo\'q. Yangi so\'rovlar shu yerda chiqadi.';

  @override
  String get dpOnTheWay => 'Yo\'ldasiz';

  @override
  String get dpCollected => 'Yig\'ildi';

  @override
  String get dpOpenNavigator => 'Navigatorda ochish';

  @override
  String get dpSlideArrived => 'Surib tasdiqlang: Yetib keldik';

  @override
  String get dpTripDone => 'Safar yakunlandi';

  @override
  String dpEarned(String amount) {
    return 'Bu safar: $amount';
  }

  @override
  String get dpReturnTitle => 'Qaytishni ochasizmi?';

  @override
  String get dpOpenReturn => 'Qaytishni ochish';

  @override
  String get dpNotToday => 'Bugun qaytmayman';

  @override
  String get dpActionFailed =>
      'Amal bajarilmadi. Internetni tekshirib, qayta urinib ko\'ring.';

  @override
  String get dpCall => 'Qo\'ng\'iroq';

  @override
  String get dpPassenger => 'Yo\'lovchi';

  @override
  String get dpPickupPoint => 'Olib ketish joyi';

  @override
  String get daBadge => 'HAYDOVCHI';

  @override
  String get daPhoneTitle => 'Haydovchi sifatida kirish';

  @override
  String get daPhoneBody => 'Telefon raqamingizga SMS kod yuboramiz';

  @override
  String get daGetCode => 'Kod olish';

  @override
  String get daTermsNote =>
      'Davom etib, foydalanish shartlariga rozilik bildirasiz';

  @override
  String get daPhoneInvalid =>
      'To\'g\'ri telefon raqam kiriting (masalan: 93 456 78 90)';

  @override
  String get daWithPassword => 'Parol bilan kirish';

  @override
  String get daOtpTitle => 'Kodni kiriting';

  @override
  String daOtpSentTo(String phone) {
    return '$phone raqamiga yuborildi';
  }

  @override
  String get daChange => 'O\'zgartirish';

  @override
  String daResendIn(String time) {
    return 'Qayta yuborish: $time';
  }

  @override
  String get daResend => 'Kodni qayta yuborish';

  @override
  String get daOtpAuto =>
      'Yangi raqam — hujjatlarga, ro\'yxatdan o\'tgan haydovchi — bosh ekranga';

  @override
  String dpPendingBanner(int count) {
    return '$count ta yangi so\'rov javob kutmoqda';
  }

  @override
  String get dpPendingAction => 'Ko\'rish';
}

/// The translations for Uzbek, using the Cyrillic script (`uz_Cyrl`).
class AppLocalizationsUzCyrl extends AppLocalizationsUz {
  AppLocalizationsUzCyrl() : super('uz_Cyrl');

  @override
  String get appName => 'Йўл-Йўлакай';

  @override
  String get appTagline => 'Шаҳарлараро қулай ва тезкор сафарлар';

  @override
  String get skip => 'Ўтказиб юбориш';

  @override
  String get next => 'Кейингиси';

  @override
  String get getStarted => 'Бошлаш';

  @override
  String get continueText => 'Давом этиш';

  @override
  String get confirm => 'Тасдиқлаш';

  @override
  String get cancel => 'Бекор қилиш';

  @override
  String get save => 'Сақлаш';

  @override
  String get edit => 'Таҳрирлаш';

  @override
  String get delete => 'Ўчириш';

  @override
  String get close => 'Ёпиш';

  @override
  String get search => 'Қидириш';

  @override
  String get filter => 'Филтр';

  @override
  String get sort => 'Саралаш';

  @override
  String get clear => 'Тозалаш';

  @override
  String get apply => 'Қўллаш';

  @override
  String get back => 'Орқага';

  @override
  String get retry => 'Қайта уриниш';

  @override
  String get done => 'Тайёр';

  @override
  String get onboarding1Title => 'Шаҳарлараро сафарлар осонлашди';

  @override
  String get onboarding1Desc =>
      'Ўзбекистоннинг исталган шаҳрига ишончли ва қулай такси топинг.';

  @override
  String get onboarding2Title => 'Қулай ва хавфсиз автомобиллар';

  @override
  String get onboarding2Desc =>
      'Тажрибали ва тасдиқланган ҳайдовчилар билан хавфсиз саёҳат қилинг.';

  @override
  String get onboarding3Title => 'Ўз жойингизни осон банд қилинг';

  @override
  String get onboarding3Desc =>
      'Сизга мос вақт, нарх ва қулайликдаги жойни бир неча босқичда банд қилинг.';

  @override
  String get onboarding4Title => 'Сафарингизни жонли кузатинг';

  @override
  String get onboarding4Desc =>
      'Ҳайдовчи қаердалигини харитада кўринг ва сафар тафсилотларидан доим хабардор бўлинг.';

  @override
  String get welcomeTitle => 'Йўл-Йўлакайга хуш келибсиз!';

  @override
  String get welcomeSubtitle => 'Шаҳарлараро сафарларингиз учун ишончли ҳамкор';

  @override
  String get loginOrRegister => 'Кириш ёки рўйхатдан ўтиш';

  @override
  String get enterPhoneNumber => 'Телефон рақамингизни киритинг';

  @override
  String get phoneLabel => 'Телефон рақами';

  @override
  String get phoneHint => '90 123 45 67';

  @override
  String get sendOtp => 'Кодни юбориш';

  @override
  String otpSentTo(String phone) {
    return 'Тасдиқлаш коди $phone рақамига юборилди';
  }

  @override
  String get enterOtp => 'Тасдиқлаш кодини киритинг';

  @override
  String get resendOtp => 'Кодни қайта юбориш';

  @override
  String resendIn(int seconds) {
    return 'Қайта юбориш: $seconds сония';
  }

  @override
  String get createProfileTitle => 'Профилингизни тўлдиринг';

  @override
  String get createProfileSubtitle =>
      'Ҳайдовчилар сизни таниши учун маълумотларингизни киритинг';

  @override
  String get firstName => 'Исм';

  @override
  String get firstNameHint => 'Исмингизни киритинг';

  @override
  String get lastName => 'Фамилия';

  @override
  String get lastNameHint => 'Фамилиянгизни киритинг';

  @override
  String get email => 'Эмаил (ихтиёрий)';

  @override
  String get emailHint => 'эхампле@маил.сом';

  @override
  String get completeRegistration => 'Рўйхатдан ўтишни якунлаш';

  @override
  String get navHome => 'Асосий';

  @override
  String get navTrips => 'Сафарларим';

  @override
  String get navNotifications => 'Билдиришномалар';

  @override
  String get navProfile => 'Профил';

  @override
  String greeting(String name) {
    return 'Салом, $name!';
  }

  @override
  String get whereToGo => 'Қаерга бормоқчисиз?';

  @override
  String get from => 'Қаердан';

  @override
  String get to => 'Қаерга';

  @override
  String get selectDepartureCity => 'Кетиш шаҳрини танланг';

  @override
  String get selectDestinationCity => 'Бориш шаҳрини танланг';

  @override
  String get travelDate => 'Сана';

  @override
  String get today => 'Бугун';

  @override
  String get tomorrow => 'Эртага';

  @override
  String get passengerCount => 'Йўловчилар сони';

  @override
  String passengers(int count) {
    return '$count йўловчи';
  }

  @override
  String get searchRides => 'Қатновларни қидириш';

  @override
  String get swapCities => 'Шаҳарларни алмаштириш';

  @override
  String get recentSearches => 'Сўнгги қидирувлар';

  @override
  String get popularRoutes => 'Машҳур йўналишлар';

  @override
  String get savedRoutes => 'Сақланган йўналишлар';

  @override
  String get noRecentSearches => 'Сўнгги қидирувлар мавжуд эмас';

  @override
  String get selectCityTitle => 'Шаҳарни танланг';

  @override
  String get searchCityHint => 'Шаҳар номини ёзинг...';

  @override
  String get popularCities => 'Машҳур шаҳарлар';

  @override
  String get allCities => 'Барча шаҳарлар';

  @override
  String get currentLocation => 'Жорий жойлашув';

  @override
  String get availableRides => 'Мавжуд қатновлар';

  @override
  String ridesFound(int count) {
    return '$count та қатнов топилди';
  }

  @override
  String get noRidesFound => 'Афсуски, қатновлар топилмади';

  @override
  String get noRidesDesc => 'Бошқа сана ёки йўналишни танлаб кўринг';

  @override
  String get sortCheapest => 'Энг арзон';

  @override
  String get sortEarliest => 'Энг эртанги';

  @override
  String get sortFastest => 'Энг тез';

  @override
  String get sortRating => 'Юқори рейтингли';

  @override
  String get filterPrice => 'Нарх бўйича';

  @override
  String get filterCarType => 'Автомобил тури';

  @override
  String get filterSeats => 'Бўш жойлар сони';

  @override
  String get filterRating => 'Ҳайдовчи рейтинги';

  @override
  String pricePerSeat(String price) {
    return '$price / ўрин';
  }

  @override
  String seatsAvailable(int available, int total) {
    return '$available / $total та бўш';
  }

  @override
  String durationApprox(String hours) {
    return '~$hours соат';
  }

  @override
  String get rideDetails => 'Қатнов тафсилотлари';

  @override
  String get schedule => 'Жадвал';

  @override
  String get departureTime => 'Жўнаш вақти';

  @override
  String get estimatedArrival => 'Тахминий етиб бориш';

  @override
  String get driver => 'Ҳайдовчи';

  @override
  String get verifiedDriver => 'Тасдиқланган ҳайдовчи';

  @override
  String completedTripsCount(int count) {
    return '$count та муваффақиятли сафар';
  }

  @override
  String get vehicle => 'Автомобил';

  @override
  String get pickupLocation => 'Чиқиш жойи';

  @override
  String get dropoffLocation => 'Тушиш жойи';

  @override
  String get amenities => 'Қулайликлар';

  @override
  String get amenityAc => 'Кондитсионер';

  @override
  String get amenityLuggage => 'Катта юкхона';

  @override
  String get amenityWifi => 'Ви-Фи';

  @override
  String get amenitySmoking => 'Чекиш мумкин эмас';

  @override
  String get bookSeat => 'Жойни банд қилиш';

  @override
  String get contactDriver => 'Ҳайдовчи билан боғланиш';

  @override
  String get shareTrip => 'Сафарни улашиш';

  @override
  String get bookingTitle => 'Банд қилиш';

  @override
  String get stepSelectSeats => '1. Жойлар сони';

  @override
  String get stepPassengerInfo => '2. Йўловчи маълумотлари';

  @override
  String get stepPickup => '3. Чиқиш нуқтаси';

  @override
  String get stepReview => '4. Текшириш';

  @override
  String selectedSeats(int count) {
    return 'Танланган жойлар: $count';
  }

  @override
  String get totalPrice => 'Жами тўлов';

  @override
  String get cancellationPolicy => 'Бекор қилиш қоидалари';

  @override
  String get cancellationPolicyDesc =>
      'Сафар бошланишига 2 соат қолгунча бепул бекор қилиш мумкин.';

  @override
  String get confirmBooking => 'Банд қилишни тасдиқлаш';

  @override
  String get paymentMethod => 'Тўлов усули';

  @override
  String get paymentCash => 'Ҳайдовчига нақд тўлаш';

  @override
  String get paymentClick => 'Click орқали тўлаш';

  @override
  String get paymentPayme => 'Payme орқали тўлаш';

  @override
  String get paymentUzum => 'Uzum Банк орқали тўлаш';

  @override
  String get bookingSuccessTitle => 'Муваффақиятли банд қилинди!';

  @override
  String get bookingSuccessDesc =>
      'Сизнинг буюртмангиз қабул қилинди. Ҳайдовчи сиз билан боғланади.';

  @override
  String get bookingId => 'Буюртма ID';

  @override
  String get viewTrip => 'Сафарни кўриш';

  @override
  String get backToHome => 'Бош саҳифага';

  @override
  String get tabUpcoming => 'Кутилаётган';

  @override
  String get tabActive => 'Фаол';

  @override
  String get tabCompleted => 'Тугалланган';

  @override
  String get tabCancelled => 'Бекор қилинган';

  @override
  String get noTripsTitle => 'Қатновлар тарихи бўш';

  @override
  String get noTripsDesc => 'Сизда ушбу бўлимда ҳеч қандай сафар йўқ.';

  @override
  String get tripDetails => 'Сафар тафсилотлари';

  @override
  String get trackingTitle => 'Сафарни кузатиш';

  @override
  String get statusBookingConfirmed => 'Банд қилиш тасдиқланди';

  @override
  String get statusDriverPreparing => 'Ҳайдовчи йўлга чиқишга тайёрланмоқда';

  @override
  String get statusDriverArrived => 'Ҳайдовчи етиб келди';

  @override
  String get statusPassengerPickedUp => 'Йўловчи олинди';

  @override
  String get statusTripStarted => 'Сафар бошланди';

  @override
  String get statusNearDestination => 'Манзилга оз қолди';

  @override
  String get statusTripCompleted => 'Сафар якунланди';

  @override
  String get notificationsTitle => 'Билдиришномалар';

  @override
  String get markAllAsRead => 'Барчасини ўқилган қилиш';

  @override
  String get noNotificationsTitle => 'Билдиришномалар йўқ';

  @override
  String get noNotificationsDesc =>
      'Янги хабарлар пайдо бўлганда шу ерда кўринади.';

  @override
  String get profileTitle => 'Профил';

  @override
  String get editProfile => 'Профилни таҳрирлаш';

  @override
  String get personalInfo => 'Шахсий маълумотлар';

  @override
  String get myActivity => 'Менинг фаоллигим';

  @override
  String get totalTrips => 'Жами сафарлар';

  @override
  String get savedPlaces => 'Сақланган манзиллар';

  @override
  String get homePlace => 'Уй';

  @override
  String get workPlace => 'Иш';

  @override
  String get addPlace => 'Манзил қўшиш';

  @override
  String get settings => 'Созламалар';

  @override
  String get language => 'Тил';

  @override
  String get theme => 'Мавзу';

  @override
  String get themeSystem => 'Тизим созламаси';

  @override
  String get themeLight => 'Ёруғ мавзу';

  @override
  String get themeDark => 'Қоронғи мавзу';

  @override
  String get support => 'Ёрдам ва қўллаб-қувватлаш';

  @override
  String get helpCenter => 'Ёрдам маркази';

  @override
  String get faq => 'Кўп бериладиган саволлар';

  @override
  String get contactSupport => 'Қўллаб-қувватлаш хизмати';

  @override
  String get reportProblem => 'Муаммо ҳақида хабар бериш';

  @override
  String get termsOfService => 'Фойдаланиш шартлари';

  @override
  String get privacyPolicy => 'Махфийлик сиёсати';

  @override
  String get logout => 'Чиқиш';

  @override
  String get logoutConfirm => 'Ҳақиқатан ҳам ҳисобингиздан чиқмоқчимисиз?';

  @override
  String get deleteAccount => 'Ҳисобни ўчириш';

  @override
  String get ratingTitle => 'Сафарингиз қандай ўтди?';

  @override
  String get ratingSubtitle =>
      'Ҳайдовчига баҳо беринг ва хизмат сифатини оширишга ёрдам беринг';

  @override
  String get ratingFeedbackHint => 'Фикрингизни қолдиринг (ихтиёрий)...';

  @override
  String get submitRating => 'Баҳолашни юбориш';

  @override
  String get tagCleanCar => 'Тоза автомобил';

  @override
  String get tagFriendlyDriver => 'Хушмуомала ҳайдовчи';

  @override
  String get tagOnTime => 'Ўз вақтида';

  @override
  String get tagComfortable => 'Қулай';

  @override
  String get tagSafeDriving => 'Хавфсиз ҳайдаш';

  @override
  String get cancelTripTitle => 'Сафарни бекор қилиш';

  @override
  String get cancelTripDesc =>
      'Ҳақиқатан ҳам ушбу сафарни бекор қилмоқчимисиз?';

  @override
  String get cancelReason => 'Бекор қилиш сабаби';

  @override
  String get reasonChangePlans => 'Режаларим ўзгарди';

  @override
  String get reasonFoundAnother => 'Бошқа транспорт топдим';

  @override
  String get reasonDriverAsked => 'Ҳайдовчи бекор қилишни сўради';

  @override
  String get reasonOther => 'Бошқа сабаб';

  @override
  String get confirmCancel => 'Бекор қилишни тасдиқлаш';

  @override
  String get offlineTitle => 'Интернет алоқаси йўқ';

  @override
  String get offlineDesc =>
      'Илтимос, интернет уланишини текширинг ва қайта уриниб кўринг.';

  @override
  String get errorGeneric =>
      'Кутилмаган хатолик юз берди. Қайта уриниб кўринг.';

  @override
  String get errorPhoneInvalid => 'Телефон рақами нотўғри киритилди';

  @override
  String get errorOtpInvalid => 'Тасдиқлаш коди нотўғри';

  @override
  String get errorOtpExpired => 'Тасдиқлаш коди муддати тугаган';

  @override
  String get onboardingSlide1Badge => 'Шаҳарлараро қатновлар';

  @override
  String get onboardingSlide1Title =>
      'Ўзбекистон бўйлаб\nқулай ва тезкор сафарлар';

  @override
  String get onboardingSlide1Desc =>
      'Тошкент, Самарқанд, Андижон, Фарғона, Бухоро ва барча вилоятлар бўйлаб ишончли таксилар.';

  @override
  String get onboardingSlide2Badge => 'Сунъий йўлдош харитаси';

  @override
  String get onboardingSlide2Title =>
      'Харитадан манзилни\nосон ва аниқ танланг';

  @override
  String get onboardingSlide2Desc =>
      'Ўзбекистоннинг барча шаҳар ва туманларини сунъий йўлдош харитасидан танланг ва масофани кўринг.';

  @override
  String get onboardingSlide3Badge => 'Ҳамёнбоп ва шаффоф';

  @override
  String get onboardingSlide3Title =>
      'Шаффоф нархлар ва\nтасдиқланган ҳайдовчилар';

  @override
  String get onboardingSlide3Desc =>
      'Ҳар бир километр учун адолатли нархлар, қулай автомобиллар ва хавфсиз саёҳат кафолати.';

  @override
  String get satelliteMode => 'Сунъий йўлдош';

  @override
  String get standardMode => 'Стандарт харита';

  @override
  String get searchCityDistrictHint => 'Шаҳар ёки туманни қидиринг...';

  @override
  String get allRegions => 'Барчаси';

  @override
  String get tashkentRegion => 'Тошкент';

  @override
  String get ferganaValley => 'Фарғона водийси';

  @override
  String get samarkandRegion => 'Самарқанд';

  @override
  String get bukharaRegion => 'Бухоро';

  @override
  String get southernRegion => 'Қашқадарйо / Сурхондарйо';

  @override
  String get westernRegion => 'Хоразм / Қорақалпоғистон';

  @override
  String get notificationsAll => 'Барчаси';

  @override
  String get notificationsTrips => 'Сафарлар';

  @override
  String get notificationsPromo => 'Аксиялар';

  @override
  String get notificationsSystem => 'Тизим';

  @override
  String get clearAll => 'Тозалаш';

  @override
  String get phoneCall => 'Қўнғироқ қилиш';

  @override
  String tripLinkCopied(String route) {
    return 'Сафар ҳаволаси нусхаланди: $route';
  }

  @override
  String callingDriver(String phone) {
    return 'Ҳайдовчига қўнғироқ қилинмоқда: $phone';
  }

  @override
  String get appVersion => 'Илова версияси';

  @override
  String get selectLanguage => 'Тилни танланг';

  @override
  String get selectTheme => 'Мавзуни танланг';

  @override
  String get themeDarkDesc => 'Қоронғи режим, кўзга қулай';

  @override
  String get themeLightDesc => 'Ёруғ ва тиниқ интерфейс';

  @override
  String get themeSystemDesc => 'Тизим созламасига мослашади';

  @override
  String get comfortAndSafety => 'Қулайлик ва хавфсизлик';

  @override
  String get statusPending => 'Кутилмоқда';

  @override
  String get statusApproved => 'Тасдиқланган';

  @override
  String get statusRejected => 'Рад этилган';

  @override
  String get statusCompleted => 'Якунланган';

  @override
  String get statusCancelled => 'Бекор қилинган';

  @override
  String get statusActive => 'Фаол';

  @override
  String get statusInProgress => 'Жараёнда';

  @override
  String get statusArrived => 'Етиб келди';

  @override
  String get statusAccepted => 'Қабул қилинди';

  @override
  String get statusOnline => 'Онлайн';

  @override
  String get statusOffline => 'Офлайн';

  @override
  String get statusOnTrip => 'Сафарда';

  @override
  String get driverHomeTitle => 'Йўл-Йўлакай Ҳайдовчи';

  @override
  String get shiftOnlineTitle => 'Сиз сменадасиз (Онлайн)';

  @override
  String get shiftOfflineTitle => 'Смена ўчирилган (Офлайн)';

  @override
  String get shiftOnlineSubtitle => 'Буюртмаларни қабул қилишга тайёрсиз';

  @override
  String get shiftOfflineSubtitle => 'Буюртмалар олиш учун сменани ёқинг';

  @override
  String get startShift => 'Сменани бошлаш';

  @override
  String get endShift => 'Сменани тугатиш';

  @override
  String get todayPerformance => 'Бугунги кўрсаткичлар';

  @override
  String get dailyLabel => 'Кунлик';

  @override
  String get todayEarnings => 'Кунлик даромад';

  @override
  String get completedTrips => 'Бажарилган сафарлар';

  @override
  String get onlineHours => 'Онлайн вақт';

  @override
  String get acceptanceRate => 'Қабул қилиш кўрсаткичи';

  @override
  String get walletBalance => 'Ҳамён баланси';

  @override
  String get topUpBalance => 'Балансни тўлдириш';

  @override
  String get activeTaxiOrderBanner => 'Фаол тезкор такси буюртмаси мавжуд';

  @override
  String get activeIntercityTripBanner => 'Фаол шаҳарлараро қатновингиз мавжуд';

  @override
  String get viewDetails => 'Кўриш';

  @override
  String get radarOrdersTitle => 'Буюртмалар Радари';

  @override
  String get noRadarOrdersTitle => 'Ҳозирча янги буюртмалар йўқ';

  @override
  String get noRadarOrdersDesc =>
      'Янги буюртмалар пайдо бўлганда бу ерда кўринади ва сигнал берилади.';

  @override
  String get orderIncoming => 'Янги такси буюртмаси';

  @override
  String get acceptOrder => 'Қабул қилиш';

  @override
  String get declineOrder => 'Рад этиш';

  @override
  String get driverAssignedStatus => 'Йўловчи томон ҳаракатланмоқдасиз';

  @override
  String get driverArrivedStatus => 'Етиб келдингиз. Йўловчи кутиляпти';

  @override
  String get finishTrip => 'Сафарни якунлаш';

  @override
  String get finalAmountPrompt => 'Якуний тўлов миқдори (сўмда):';

  @override
  String get cancelOrderPrompt => 'Буюртмани бекор қилиш';

  @override
  String netEarningsLabel(String amount) {
    return 'Сизнинг соф даромадингиз: $amount';
  }

  @override
  String commissionDeductedLabel(String amount) {
    return 'Ушлаб қолинган комиссия: $amount';
  }

  @override
  String get backToRadarAction => 'Радарга қайтиш';

  @override
  String get markArrived => 'Етиб келдим';

  @override
  String get startTrip => 'Сафарни бошлаш';

  @override
  String get callPassenger => 'Қўнғироқ қилиш';

  @override
  String get intercityTripsTitle => 'Шаҳарлараро қатновлар';

  @override
  String get publishTrip => 'Қатнов эълон қилиш';

  @override
  String get emptyTripsHistory => 'Қатновлар тарихи бўш';

  @override
  String get emptyTripsActiveDesc =>
      'Сизда ҳозирча фаол қатнов йўқ. Янги қатнов эълон қилишингиз мумкин.';

  @override
  String get emptyTripsGeneralDesc => 'Ушбу бўлимда қатновлар мавжуд эмас.';

  @override
  String get tripDetailsTitle => 'Қатнов тафсилотлари';

  @override
  String get createTripTitle => 'Янги қатнов эълон қилиш';

  @override
  String get departureCity => 'Жўнаш шаҳри';

  @override
  String get destinationCity => 'Етиб бориш шаҳри';

  @override
  String get totalSeats => 'Ўринлар сони';

  @override
  String get tripAmenities => 'Қулайликлар';

  @override
  String get hasAc => 'Кондитсионер';

  @override
  String get allowLuggage => 'Юк жойи';

  @override
  String get allowSmoking => 'Чекишга рухсат';

  @override
  String get womenOnly => 'Фақат аёллар учун';

  @override
  String get publishAction => 'Қатновни эълон қилиш';

  @override
  String get tripPublishedSuccess => 'Қатнов муваффақиятли эълон қилинди!';

  @override
  String get walletAndEarnings => 'Ҳамён ва Даромадлар';

  @override
  String get currentBalance => 'Жорий баланс';

  @override
  String get mainWallet => 'Асосий ҳамён';

  @override
  String get lowBalanceWarning =>
      'Балансингиз минимал миқдордан кам. Буюртмаларни қабул қилиш учун тўлдиринг.';

  @override
  String get depositTitle => 'Ҳисобни тўлдириш';

  @override
  String get selectPaymentSystem => 'Тўлов тизимини танланг:';

  @override
  String get amountInSum => 'Миқдор (сўмда):';

  @override
  String get todayTab => 'Бугун';

  @override
  String get weeklyTab => 'Ҳафта';

  @override
  String get monthlyTab => 'Ой';

  @override
  String get totalEarnings => 'Жами даромад';

  @override
  String get tripsCount => 'Сафарлар сони';

  @override
  String get totalDistance => 'Масофа';

  @override
  String get totalHours => 'Онлайн вақт';

  @override
  String get dailyChart => 'Кунлик график';

  @override
  String get transactionHistory => 'Транзаксиялар тарихи';

  @override
  String get noTransactions => 'Ҳозирча транзаксиялар йўқ';

  @override
  String get noTransactionsDesc =>
      'Бажарилган сафарлар ва ҳисоб тўлдиришлар шу ерда акс этади.';

  @override
  String get paymentProcessing => 'Тўлов жараёни';

  @override
  String get paymentVerifying => 'Сервер орқали текширилмоқда...';

  @override
  String get verifyPayment => 'Тўловни текшириш';

  @override
  String get reopenPayment => 'Қайта очиш';

  @override
  String get paymentSuccessMessage =>
      'Тўлов муваффақиятли қабул қилинди ва баланс янгиланди!';

  @override
  String get paymentPendingMessage =>
      'Тўлов ҳали тасдиқланмади. Қайта уриниб кўринг ёки бироз кутинг.';

  @override
  String get driverProfileTitle => 'Ҳайдовчи профили';

  @override
  String get vehicleInfo => 'Автомобил маълумотлари';

  @override
  String get documentsVerification => 'Ҳужжатлар верификатсияси';

  @override
  String get logoutConfirmTitle => 'Тизимдан чиқиш';

  @override
  String get logoutConfirmDesc => 'Ҳақиқатан ҳам ҳисобингиздан чиқмоқчимисиз?';

  @override
  String get logoutAction => 'Чиқиш';

  @override
  String tripsCountPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count та сафар',
      one: '1 та сафар',
    );
    return '$_temp0';
  }

  @override
  String seatsCountPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count та ўрин',
      one: '1 та ўрин',
    );
    return '$_temp0';
  }

  @override
  String get refresh => 'Янгилаш';

  @override
  String get daily => 'Кунлик';

  @override
  String get topUp => 'Тўлдириш';

  @override
  String get genericErrorMessage => 'Хатолик юз берди';

  @override
  String fieldRequiredError(String field) {
    return '$field тўлдирилиши мажбурий';
  }

  @override
  String get homeTitle => 'Йўл-Йўлакай Ҳайдовчи';

  @override
  String get todayStats => 'Бугунги кўрсаткичлар';

  @override
  String get statEarnings => 'Даромад';

  @override
  String get statTripsCount => 'Сафарлар сони';

  @override
  String get statOnlineTime => 'Онлайн вақт';

  @override
  String get statAcceptanceRate => 'Қабул даражаси';

  @override
  String get activeTaxiOrderAlert => 'Фаол такси буюртмангиз бор!';

  @override
  String get activeTaxiOrderDesc => 'Сафар саҳифасига ўтиш учун босинг';

  @override
  String get activeIntercityTripAlert => 'Фаол шаҳарлараро қатновингиз бор!';

  @override
  String get activeIntercityTripDesc =>
      'Қатнов тафсилотларини кўриш учун босинг';

  @override
  String tripsCountUnit(int count) {
    return '$count та';
  }

  @override
  String hours(int count) {
    return '$count соат';
  }

  @override
  String get tripPrice => 'Сафар нархи:';

  @override
  String get arrivedAtPickupAction => 'Етиб келдим (Манзилдаман)';

  @override
  String get startRideAction => 'Йўлга чиқдик (Сафарни бошлаш)';

  @override
  String get completeRideAction => 'Сафарни якунлаш';

  @override
  String get cancelOrderAction => 'Буюртмани бекор қилиш';

  @override
  String get completeRideModalTitle => 'Сафарни якунлаш';

  @override
  String get finalPaymentAmountLabel => 'Якуний тўлов миқдори (сўмда):';

  @override
  String get completeAction => 'Якунлаш';

  @override
  String get cancelReasonPassengerNoShow => 'Йўловчи алоқага чиқмади';

  @override
  String get cancelReasonPassengerTookAnother =>
      'Йўловчи бошқа машина билан кетди';

  @override
  String get cancelReasonCarIssue => 'Автомобил носозлиги';

  @override
  String get cancelReasonOther => 'Бошқа сабаб';

  @override
  String acceptWithTimer(int seconds) {
    return 'Қабул қилиш ($seconds с)';
  }

  @override
  String get tripsPageTitle => 'Шаҳарлараро қатновлар';

  @override
  String get createTripAction => 'Қатнов эълон қилиш';

  @override
  String get noActiveTripsDesc =>
      'Сизда ҳозирча фаол қатнов йўқ. Янги қатнов эълон қилишингиз мумкин.';

  @override
  String get noTripsHistoryDesc => 'Ушбу бўлимда қатновлар мавжуд эмас.';

  @override
  String seatsDetail(int booked, int available, int total) {
    return 'Ўринлар: $booked та банд, $available та бўш (Жами: $total)';
  }

  @override
  String passengersCount(int count) {
    return 'Йўловчилар ($count та)';
  }

  @override
  String get noPassengersBooked => 'Ҳозирча йўловчилар брон қилмаган.';

  @override
  String get markRideStartedAction => 'Сафар бошланди деб белгилаш';

  @override
  String get cancelTripAction => 'Қатновни бекор қилиш';

  @override
  String passengerSeatsDetail(int seats, String price) {
    return '$seats та ўрин • $price';
  }

  @override
  String get defaultCancelTripReason => 'Техник сабабларга кўра';

  @override
  String get cancelTripReasonPrompt =>
      'Бекор қилиш сабаби йўловчиларга юборилади:';

  @override
  String get selectCitiesPrompt =>
      'Илтимос, жўнаш ва етиб бориш шаҳарларини танланг';

  @override
  String get citiesMustBeDifferentPrompt =>
      'Жўнаш ва бориш шаҳарлари бир хил бўлиши мумкин эмас';

  @override
  String get tripCreatedSuccess => 'Қатнов муваффақиятли эълон қилинди!';

  @override
  String get fromCityLabel => 'Қаердан (Жўнаш шаҳри)';

  @override
  String get toCityLabel => 'Қаерга (Бориш шаҳри)';

  @override
  String get departureDateLabel => 'Жўнаш санаси ва вақти';

  @override
  String get pricePerSeatLabel => 'Бир ўрин нархи (сўм)';

  @override
  String seatsOption(int count) {
    return '$count ўрин';
  }

  @override
  String get pickupAddressLabel => 'Кутиб олиш манзили (Мўлжал)';

  @override
  String get dropoffAddressLabel => 'Етказиб қўйиш манзили';

  @override
  String get amenitiesSectionTitle => 'Қулайликлар ва қоидалар';

  @override
  String get hasAcLabel => 'Кондитсионер бор';

  @override
  String get allowLuggageLabel => 'Багаж жойи бор';

  @override
  String get womenOnlyLabel => 'Фақат аёллар учун';

  @override
  String get additionalCommentLabel => 'Қўшимча изоҳ (ихтиёрий)';

  @override
  String get publishTripAction => 'Қатновни эълон қилиш';

  @override
  String get logoutTitle => 'Тизимдан чиқиш';

  @override
  String get logoutConfirmPrompt =>
      'Ҳақиқатан ҳам ҳисобингиздан чиқмоқчимисиз?';

  @override
  String get avatarUpdatedSuccess => 'Аватар муваффақиятли янгиланди';

  @override
  String get verificationApprovedTitle => 'Тасдиқланган ҳайдовчи';

  @override
  String get verificationApprovedSubtitle =>
      'Барча хизматлардан чекловларсиз фойдаланишингиз мумкин.';

  @override
  String get verificationUnderReviewTitle => 'Админ текширувида (12 соат)';

  @override
  String get verificationUnderReviewSubtitle =>
      'Ҳужжатларингиз админга юборилди ва 12 соат ичида текширилади. Ҳозирча синов режимида иловадан тўлиқ фойдаланишингиз мумкин.';

  @override
  String get verificationRejectedTitle => 'Аризангиз рад этилган';

  @override
  String get verificationRejectedSubtitle =>
      'Ҳужжатларни қайта юклаш учун босинг.';

  @override
  String get verificationMissingTitle => 'Ҳужжатлар топширилмаган';

  @override
  String get verificationMissingSubtitle =>
      'Буюртма олишни бошлаш учун верификатсиядан ўтинг.';

  @override
  String get vehicleInfoTitle => 'Автомобил маълумотлари';

  @override
  String vehicleYearAndColor(int year, String color) {
    return 'Йили: $year • Ранги: $color';
  }

  @override
  String get reviewsAndRatingMenu => 'Шарҳлар ва Рейтинг';

  @override
  String get walletAndEarningsMenu => 'Ҳамён ва Даромадлар';

  @override
  String get notificationsMenu => 'Билдиришномалар';

  @override
  String get supportMenu => 'Қўллаб-қувватлаш';

  @override
  String get driverVerificationTitle => 'Ҳайдовчи верификатсияси';

  @override
  String get verificationBannerText =>
      'Буюртмаларни қабул қилиш учун шахсингиз ва автомобилингиз ҳужжатларини тасдиқланг.';

  @override
  String get personalInfoSectionTitle => '1. Шахсий маълумотлар';

  @override
  String get vehicleInfoSectionTitle => '2. Автомобил маълумотлари';

  @override
  String get documentsAndPhotosSectionTitle =>
      '3. Ҳужжат ва автомобил фотосуратлари';

  @override
  String get submitApplicationAction => 'Ҳужжатларни текширишга юбориш';

  @override
  String get cameraOption => 'Камерадан олиш';

  @override
  String get galleryOption => 'Галереядан танлаш';

  @override
  String get uploadAllPhotosPrompt =>
      'Илтимос, барча 6 та ҳужжат ва автомобил расмларини юкланг!';

  @override
  String get applicationSubmittedModalTitle => 'Аризангиз қабул қилинди!';

  @override
  String get goToHomeAction => 'Бош саҳифага ўтиш';

  @override
  String get locationPermissionRequired => 'Жойлашув рухсати талаб қилинади';

  @override
  String get backgroundLocationRequired =>
      'Фонда жойлашув рухсати талаб қилинади';

  @override
  String get enableLocationServices => 'GPS хизматини ёқинг';

  @override
  String get notificationPermissionDisabled =>
      'Билдиришномалар рухсати ўчирилган';

  @override
  String get cameraPermissionRequired => 'Камера рухсати талаб қилинади';

  @override
  String get photoPermissionRequired =>
      'Фотосуратларга кириш рухсати талаб қилинади';

  @override
  String get permissionDenied => 'Рухсат берилмади';

  @override
  String get permissionPermanentlyDenied => 'Рухсат бутунлай рад этилди';

  @override
  String get openSettings => 'Созламаларни очиш';

  @override
  String get notNow => 'Кейинроқ';

  @override
  String get tryAgain => 'Қайта уриниш';

  @override
  String get continueAction => 'Давом этиш';

  @override
  String get someFeaturesUnavailable =>
      'Баъзи функсиялар тўлиқ ишламаслиги мумкин';

  @override
  String get accountBlockedTitle => 'Ҳисоб блокланган';

  @override
  String get accountBlockedMessage =>
      'Ҳисобингиз маъмурият томонидан тўхтатилган ёки блокланган. Қўллаб-қувватлаш хизмати билан боғланинг.';

  @override
  String get verificationRequiredTitle => 'Верификатсия талаб қилинади';

  @override
  String get verificationRequiredMessage =>
      'Буюртмаларни қабул қилиш учун шахсингиз ва автомобил ҳужжатлари тасдиқланиши керак.';

  @override
  String get appearance => 'Кўриниш';

  @override
  String get themeLightShort => 'Ёруғ';

  @override
  String get themeDarkShort => 'Қоронғи';

  @override
  String get themeAuto => 'Авто';

  @override
  String get themeLightHint => 'кундузги';

  @override
  String get themeDarkHint => 'тунги';

  @override
  String get themeAutoHint => 'телефон бўйича';

  @override
  String get languageLatinScript => 'лотин ёзуви';

  @override
  String get languageCyrillicScript => 'кирилл ёзуви';

  @override
  String get languageRussianHint => 'рус тили';

  @override
  String get menuTitle => 'Меню';

  @override
  String get menuSettingsHint => 'Тил, кўриниш';

  @override
  String get menuHelp => 'Ёрдам';

  @override
  String get menuHelpHint => 'Қўллаб-қувватлаш';

  @override
  String get menuLogout => 'Чиқиш';

  @override
  String get mapMyLocation => 'Жойлашувимга қайтиш';

  @override
  String get mapNotifications => 'Билдиришномалар';

  @override
  String get driverTodayEarnings => 'Бугунги даромад';

  @override
  String driverTodayPill(String amount) {
    return 'Бугун: $amount';
  }

  @override
  String get menuEarnings => 'Даромад';

  @override
  String get menuEarningsHint => 'Кун, ҳафта, ой';

  @override
  String get menuTripHistory => 'Сафарлар тарихи';

  @override
  String get menuProfileCar => 'Профил ва машина';

  @override
  String get menuProfileCarHint => 'Ҳужжатлар ҳолати';

  @override
  String get driverLastRoute => 'Охирги йўналиш';

  @override
  String get driverOpenAgain => 'Бугун ҳам очиш';

  @override
  String get driverOpenRoute => 'Йўналиш очиш';

  @override
  String get driverNoRouteYet =>
      'Йўналиш очинг — йўловчилар сизни кўради ва жой банд қилади';

  @override
  String get driverChangeTimePrice => 'Вақт ёки нархни ўзгартириш';

  @override
  String get driverOnline => 'Линияда';

  @override
  String get driverOffline => 'Линиядан ташқари';

  @override
  String get driverDocsPending => 'Ҳужжатларингиз текширилмоқда';

  @override
  String get driverDocsAction => 'Ҳолатни кўриш';

  @override
  String get driverActiveTrip => 'Сизда фаол сафар бор';

  @override
  String get statRating => 'рейтинг';

  @override
  String get statTrips => 'сафар';

  @override
  String get statInApp => 'иловада';

  @override
  String statMonths(int count) {
    return '$count ой';
  }

  @override
  String get dateToday => 'Бугун';

  @override
  String get dateYesterday => 'Кеча';

  @override
  String get histCompleted => 'Якунланди';

  @override
  String get histCancelled => 'Бекор қилинди';

  @override
  String get histActive => 'Фаол';

  @override
  String histPassengers(int count) {
    return '$count йўловчи';
  }

  @override
  String get profileCar => 'Машина';

  @override
  String get profileDocuments => 'Ҳужжатлар';

  @override
  String get docLicense => 'Ҳайдовчилик гувоҳномаси';

  @override
  String get docVehicle => 'Техник паспорт ва машина расмлари';

  @override
  String get docApproved => 'Тасдиқланган';

  @override
  String get docPending => 'Текширилмоқда';

  @override
  String get docRejected => 'Қайта юборинг';

  @override
  String get carFourSeats => '4 ўринли енгил машина';

  @override
  String get profilePhone => 'Телефон';

  @override
  String get dpOpenRoute => 'Йўналиш очиш';

  @override
  String get dpToCity => 'Шаҳарга';

  @override
  String get dpToHome => 'Уйга';

  @override
  String get dpDepartureTime => 'Жўнаш вақти';

  @override
  String get dpWhenFull => 'Тўлса';

  @override
  String get dpPricePerSeat => 'Нарх · 1 ўрин (20–30 минг)';

  @override
  String get dpFourSeats => 'Машина ҳар доим 4 ўринли';

  @override
  String dpFullCarTotal(String amount) {
    return '4 ўрин тўлса: $amount';
  }

  @override
  String get dpOpen => 'Йўналишни очиш';

  @override
  String get dpNewRequest => 'ЯНГИ СЎРОВ';

  @override
  String dpPeople(int count) {
    return '$count киши';
  }

  @override
  String get dpToPassenger => 'йўловчигача';

  @override
  String get dpAccept => 'Қабул қилиш';

  @override
  String get dpSkip => 'Ўтказиб юбориш';

  @override
  String get dpPickupTitle => 'Йўловчиларни олиш';

  @override
  String dpSeatsTaken(int taken, int total) {
    return '$taken / $total ўрин банд';
  }

  @override
  String get dpPickedUp => 'олинди';

  @override
  String dpSlidePickedUp(String name) {
    return 'Суриб тасдиқланг: $nameни олдим';
  }

  @override
  String get dpDepart => 'Жўнаш';

  @override
  String get dpWaitMore => 'Яна кутиш';

  @override
  String get dpNoPassengersYet =>
      'Ҳали йўловчи йўқ. Янги сўровлар шу ерда чиқади.';

  @override
  String get dpOnTheWay => 'Йўлдасиз';

  @override
  String get dpCollected => 'Йиғилди';

  @override
  String get dpOpenNavigator => 'Навигаторда очиш';

  @override
  String get dpSlideArrived => 'Суриб тасдиқланг: Етиб келдик';

  @override
  String get dpTripDone => 'Сафар якунланди';

  @override
  String dpEarned(String amount) {
    return 'Бу сафар: $amount';
  }

  @override
  String get dpReturnTitle => 'Қайтишни очасизми?';

  @override
  String get dpOpenReturn => 'Қайтишни очиш';

  @override
  String get dpNotToday => 'Бугун қайтмайман';

  @override
  String get dpActionFailed =>
      'Амал бажарилмади. Интернетни текшириб, қайта уриниб кўринг.';

  @override
  String get dpCall => 'Қўнғироқ';

  @override
  String get dpPassenger => 'Йўловчи';

  @override
  String get dpPickupPoint => 'Олиб кетиш жойи';

  @override
  String get daBadge => 'ҲАЙДОВЧИ';

  @override
  String get daPhoneTitle => 'Ҳайдовчи сифатида кириш';

  @override
  String get daPhoneBody => 'Телефон рақамингизга SMS код юборамиз';

  @override
  String get daGetCode => 'Код олиш';

  @override
  String get daTermsNote =>
      'Давом этиб, фойдаланиш шартларига розилик билдирасиз';

  @override
  String get daPhoneInvalid =>
      'Тўғри телефон рақам киритинг (масалан: 93 456 78 90)';

  @override
  String get daWithPassword => 'Парол билан кириш';

  @override
  String get daOtpTitle => 'Кодни киритинг';

  @override
  String daOtpSentTo(String phone) {
    return '$phone рақамига юборилди';
  }

  @override
  String get daChange => 'Ўзгартириш';

  @override
  String daResendIn(String time) {
    return 'Қайта юбориш: $time';
  }

  @override
  String get daResend => 'Кодни қайта юбориш';

  @override
  String get daOtpAuto =>
      'Янги рақам — ҳужжатларга, рўйхатдан ўтган ҳайдовчи — бош экранга';

  @override
  String dpPendingBanner(int count) {
    return '$count та янги сўров жавоб кутмоқда';
  }

  @override
  String get dpPendingAction => 'Кўриш';
}
