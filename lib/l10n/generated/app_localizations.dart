import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('uz'),
    Locale.fromSubtags(languageCode: 'uz', scriptCode: 'Cyrl')
  ];

  /// No description provided for @appName.
  ///
  /// In uz, this message translates to:
  /// **'YolYolakay'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In uz, this message translates to:
  /// **'Shaharlararo qulay va tezkor safarlar'**
  String get appTagline;

  /// No description provided for @skip.
  ///
  /// In uz, this message translates to:
  /// **'O\'tkazib yuborish'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In uz, this message translates to:
  /// **'Keyingisi'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In uz, this message translates to:
  /// **'Boshlash'**
  String get getStarted;

  /// No description provided for @continueText.
  ///
  /// In uz, this message translates to:
  /// **'Davom etish'**
  String get continueText;

  /// No description provided for @confirm.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlash'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In uz, this message translates to:
  /// **'Saqlash'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In uz, this message translates to:
  /// **'Tahrirlash'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In uz, this message translates to:
  /// **'O\'chirish'**
  String get delete;

  /// No description provided for @close.
  ///
  /// In uz, this message translates to:
  /// **'Yopish'**
  String get close;

  /// No description provided for @search.
  ///
  /// In uz, this message translates to:
  /// **'Qidirish'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In uz, this message translates to:
  /// **'Filtr'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In uz, this message translates to:
  /// **'Saralash'**
  String get sort;

  /// No description provided for @clear.
  ///
  /// In uz, this message translates to:
  /// **'Tozalash'**
  String get clear;

  /// No description provided for @apply.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'llash'**
  String get apply;

  /// No description provided for @back.
  ///
  /// In uz, this message translates to:
  /// **'Orqaga'**
  String get back;

  /// No description provided for @retry.
  ///
  /// In uz, this message translates to:
  /// **'Qayta urinish'**
  String get retry;

  /// No description provided for @done.
  ///
  /// In uz, this message translates to:
  /// **'Tayyor'**
  String get done;

  /// No description provided for @onboarding1Title.
  ///
  /// In uz, this message translates to:
  /// **'Shaharlararo safarlar osonlashdi'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Desc.
  ///
  /// In uz, this message translates to:
  /// **'O\'zbekistonning istalgan shahriga ishonchli va qulay taksi toping.'**
  String get onboarding1Desc;

  /// No description provided for @onboarding2Title.
  ///
  /// In uz, this message translates to:
  /// **'Qulay va xavfsiz avtomobillar'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Desc.
  ///
  /// In uz, this message translates to:
  /// **'Tajribali va tasdiqlangan haydovchilar bilan xavfsiz sayohat qiling.'**
  String get onboarding2Desc;

  /// No description provided for @onboarding3Title.
  ///
  /// In uz, this message translates to:
  /// **'O\'z joyingizni oson band qiling'**
  String get onboarding3Title;

  /// No description provided for @onboarding3Desc.
  ///
  /// In uz, this message translates to:
  /// **'Sizga mos vaqt, narx va qulaylikdagi joyni bir necha bosqichda band qiling.'**
  String get onboarding3Desc;

  /// No description provided for @onboarding4Title.
  ///
  /// In uz, this message translates to:
  /// **'Safaringizni jonli kuzating'**
  String get onboarding4Title;

  /// No description provided for @onboarding4Desc.
  ///
  /// In uz, this message translates to:
  /// **'Haydovchi qayerdaligini xaritada ko\'ring va safar tafsilotlaridan doim xabardor bo\'ling.'**
  String get onboarding4Desc;

  /// No description provided for @welcomeTitle.
  ///
  /// In uz, this message translates to:
  /// **'YolYolakayga xush kelibsiz!'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Shaharlararo safarlaringiz uchun ishonchli hamkor'**
  String get welcomeSubtitle;

  /// No description provided for @loginOrRegister.
  ///
  /// In uz, this message translates to:
  /// **'Kirish yoki ro\'yxatdan o\'tish'**
  String get loginOrRegister;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In uz, this message translates to:
  /// **'Telefon raqamingizni kiriting'**
  String get enterPhoneNumber;

  /// No description provided for @phoneLabel.
  ///
  /// In uz, this message translates to:
  /// **'Telefon raqami'**
  String get phoneLabel;

  /// No description provided for @phoneHint.
  ///
  /// In uz, this message translates to:
  /// **'90 123 45 67'**
  String get phoneHint;

  /// No description provided for @sendOtp.
  ///
  /// In uz, this message translates to:
  /// **'Kodni yuborish'**
  String get sendOtp;

  /// No description provided for @otpSentTo.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlash kodi {phone} raqamiga yuborildi'**
  String otpSentTo(String phone);

  /// No description provided for @enterOtp.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlash kodini kiriting'**
  String get enterOtp;

  /// No description provided for @resendOtp.
  ///
  /// In uz, this message translates to:
  /// **'Kodni qayta yuborish'**
  String get resendOtp;

  /// No description provided for @resendIn.
  ///
  /// In uz, this message translates to:
  /// **'Qayta yuborish: {seconds} soniya'**
  String resendIn(int seconds);

  /// No description provided for @createProfileTitle.
  ///
  /// In uz, this message translates to:
  /// **'Profilingizni to\'ldiring'**
  String get createProfileTitle;

  /// No description provided for @createProfileSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Haydovchilar sizni tanishi uchun ma\'lumotlaringizni kiriting'**
  String get createProfileSubtitle;

  /// No description provided for @firstName.
  ///
  /// In uz, this message translates to:
  /// **'Ism'**
  String get firstName;

  /// No description provided for @firstNameHint.
  ///
  /// In uz, this message translates to:
  /// **'Ismingizni kiriting'**
  String get firstNameHint;

  /// No description provided for @lastName.
  ///
  /// In uz, this message translates to:
  /// **'Familiya'**
  String get lastName;

  /// No description provided for @lastNameHint.
  ///
  /// In uz, this message translates to:
  /// **'Familiyangizni kiriting'**
  String get lastNameHint;

  /// No description provided for @email.
  ///
  /// In uz, this message translates to:
  /// **'Email (ixtiyoriy)'**
  String get email;

  /// No description provided for @emailHint.
  ///
  /// In uz, this message translates to:
  /// **'example@mail.com'**
  String get emailHint;

  /// No description provided for @completeRegistration.
  ///
  /// In uz, this message translates to:
  /// **'Ro\'yxatdan o\'tishni yakunlash'**
  String get completeRegistration;

  /// No description provided for @navHome.
  ///
  /// In uz, this message translates to:
  /// **'Asosiy'**
  String get navHome;

  /// No description provided for @navTrips.
  ///
  /// In uz, this message translates to:
  /// **'Safarlarim'**
  String get navTrips;

  /// No description provided for @navNotifications.
  ///
  /// In uz, this message translates to:
  /// **'Bildirishnomalar'**
  String get navNotifications;

  /// No description provided for @navProfile.
  ///
  /// In uz, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @greeting.
  ///
  /// In uz, this message translates to:
  /// **'Salom, {name}!'**
  String greeting(String name);

  /// No description provided for @whereToGo.
  ///
  /// In uz, this message translates to:
  /// **'Qayerga bormoqchisiz?'**
  String get whereToGo;

  /// No description provided for @from.
  ///
  /// In uz, this message translates to:
  /// **'Qayerdan'**
  String get from;

  /// No description provided for @to.
  ///
  /// In uz, this message translates to:
  /// **'Qayerga'**
  String get to;

  /// No description provided for @selectDepartureCity.
  ///
  /// In uz, this message translates to:
  /// **'Ketish shahrini tanlang'**
  String get selectDepartureCity;

  /// No description provided for @selectDestinationCity.
  ///
  /// In uz, this message translates to:
  /// **'Borish shahrini tanlang'**
  String get selectDestinationCity;

  /// No description provided for @travelDate.
  ///
  /// In uz, this message translates to:
  /// **'Sana'**
  String get travelDate;

  /// No description provided for @today.
  ///
  /// In uz, this message translates to:
  /// **'Bugun'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In uz, this message translates to:
  /// **'Ertaga'**
  String get tomorrow;

  /// No description provided for @passengerCount.
  ///
  /// In uz, this message translates to:
  /// **'Yo\'lovchilar soni'**
  String get passengerCount;

  /// No description provided for @passengers.
  ///
  /// In uz, this message translates to:
  /// **'{count} yo\'lovchi'**
  String passengers(int count);

  /// No description provided for @searchRides.
  ///
  /// In uz, this message translates to:
  /// **'Qatnovlarni qidirish'**
  String get searchRides;

  /// No description provided for @swapCities.
  ///
  /// In uz, this message translates to:
  /// **'Shaharlarni almashtirish'**
  String get swapCities;

  /// No description provided for @recentSearches.
  ///
  /// In uz, this message translates to:
  /// **'So\'nggi qidiruvlar'**
  String get recentSearches;

  /// No description provided for @popularRoutes.
  ///
  /// In uz, this message translates to:
  /// **'Mashhur yo\'nalishlar'**
  String get popularRoutes;

  /// No description provided for @savedRoutes.
  ///
  /// In uz, this message translates to:
  /// **'Saqlangan yo\'nalishlar'**
  String get savedRoutes;

  /// No description provided for @noRecentSearches.
  ///
  /// In uz, this message translates to:
  /// **'So\'nggi qidiruvlar mavjud emas'**
  String get noRecentSearches;

  /// No description provided for @selectCityTitle.
  ///
  /// In uz, this message translates to:
  /// **'Shaharni tanlang'**
  String get selectCityTitle;

  /// No description provided for @searchCityHint.
  ///
  /// In uz, this message translates to:
  /// **'Shahar nomini yozing...'**
  String get searchCityHint;

  /// No description provided for @popularCities.
  ///
  /// In uz, this message translates to:
  /// **'Mashhur shaharlar'**
  String get popularCities;

  /// No description provided for @allCities.
  ///
  /// In uz, this message translates to:
  /// **'Barcha shaharlar'**
  String get allCities;

  /// No description provided for @currentLocation.
  ///
  /// In uz, this message translates to:
  /// **'Joriy joylashuv'**
  String get currentLocation;

  /// No description provided for @availableRides.
  ///
  /// In uz, this message translates to:
  /// **'Mavjud qatnovlar'**
  String get availableRides;

  /// No description provided for @ridesFound.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta qatnov topildi'**
  String ridesFound(int count);

  /// No description provided for @noRidesFound.
  ///
  /// In uz, this message translates to:
  /// **'Afsuski, qatnovlar topilmadi'**
  String get noRidesFound;

  /// No description provided for @noRidesDesc.
  ///
  /// In uz, this message translates to:
  /// **'Boshqa sana yoki yo\'nalishni tanlab ko\'ring'**
  String get noRidesDesc;

  /// No description provided for @sortCheapest.
  ///
  /// In uz, this message translates to:
  /// **'Eng arzon'**
  String get sortCheapest;

  /// No description provided for @sortEarliest.
  ///
  /// In uz, this message translates to:
  /// **'Eng ertangi'**
  String get sortEarliest;

  /// No description provided for @sortFastest.
  ///
  /// In uz, this message translates to:
  /// **'Eng tez'**
  String get sortFastest;

  /// No description provided for @sortRating.
  ///
  /// In uz, this message translates to:
  /// **'Yuqori reytingli'**
  String get sortRating;

  /// No description provided for @filterPrice.
  ///
  /// In uz, this message translates to:
  /// **'Narx bo\'yicha'**
  String get filterPrice;

  /// No description provided for @filterCarType.
  ///
  /// In uz, this message translates to:
  /// **'Avtomobil turi'**
  String get filterCarType;

  /// No description provided for @filterSeats.
  ///
  /// In uz, this message translates to:
  /// **'Bo\'sh joylar soni'**
  String get filterSeats;

  /// No description provided for @filterRating.
  ///
  /// In uz, this message translates to:
  /// **'Haydovchi reytingi'**
  String get filterRating;

  /// No description provided for @pricePerSeat.
  ///
  /// In uz, this message translates to:
  /// **'{price} / o\'rin'**
  String pricePerSeat(String price);

  /// No description provided for @seatsAvailable.
  ///
  /// In uz, this message translates to:
  /// **'{available} / {total} ta bo\'sh'**
  String seatsAvailable(int available, int total);

  /// No description provided for @durationApprox.
  ///
  /// In uz, this message translates to:
  /// **'~{hours} soat'**
  String durationApprox(String hours);

  /// No description provided for @rideDetails.
  ///
  /// In uz, this message translates to:
  /// **'Qatnov tafsilotlari'**
  String get rideDetails;

  /// No description provided for @schedule.
  ///
  /// In uz, this message translates to:
  /// **'Jadval'**
  String get schedule;

  /// No description provided for @departureTime.
  ///
  /// In uz, this message translates to:
  /// **'Jo\'nash vaqti'**
  String get departureTime;

  /// No description provided for @estimatedArrival.
  ///
  /// In uz, this message translates to:
  /// **'Taxminiy yetib borish'**
  String get estimatedArrival;

  /// No description provided for @driver.
  ///
  /// In uz, this message translates to:
  /// **'Haydovchi'**
  String get driver;

  /// No description provided for @verifiedDriver.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlangan haydovchi'**
  String get verifiedDriver;

  /// No description provided for @completedTripsCount.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta muvaffaqiyatli safar'**
  String completedTripsCount(int count);

  /// No description provided for @vehicle.
  ///
  /// In uz, this message translates to:
  /// **'Avtomobil'**
  String get vehicle;

  /// No description provided for @pickupLocation.
  ///
  /// In uz, this message translates to:
  /// **'Chiqish joyi'**
  String get pickupLocation;

  /// No description provided for @dropoffLocation.
  ///
  /// In uz, this message translates to:
  /// **'Tushish joyi'**
  String get dropoffLocation;

  /// No description provided for @amenities.
  ///
  /// In uz, this message translates to:
  /// **'Qulayliklar'**
  String get amenities;

  /// No description provided for @amenityAc.
  ///
  /// In uz, this message translates to:
  /// **'Konditsioner'**
  String get amenityAc;

  /// No description provided for @amenityLuggage.
  ///
  /// In uz, this message translates to:
  /// **'Katta yukxona'**
  String get amenityLuggage;

  /// No description provided for @amenityWifi.
  ///
  /// In uz, this message translates to:
  /// **'Wi-Fi'**
  String get amenityWifi;

  /// No description provided for @amenitySmoking.
  ///
  /// In uz, this message translates to:
  /// **'Chekish mumkin emas'**
  String get amenitySmoking;

  /// No description provided for @bookSeat.
  ///
  /// In uz, this message translates to:
  /// **'Joyni band qilish'**
  String get bookSeat;

  /// No description provided for @contactDriver.
  ///
  /// In uz, this message translates to:
  /// **'Haydovchi bilan bog\'lanish'**
  String get contactDriver;

  /// No description provided for @shareTrip.
  ///
  /// In uz, this message translates to:
  /// **'Safarni ulashish'**
  String get shareTrip;

  /// No description provided for @bookingTitle.
  ///
  /// In uz, this message translates to:
  /// **'Band qilish'**
  String get bookingTitle;

  /// No description provided for @stepSelectSeats.
  ///
  /// In uz, this message translates to:
  /// **'1. Joylar soni'**
  String get stepSelectSeats;

  /// No description provided for @stepPassengerInfo.
  ///
  /// In uz, this message translates to:
  /// **'2. Yo\'lovchi ma\'lumotlari'**
  String get stepPassengerInfo;

  /// No description provided for @stepPickup.
  ///
  /// In uz, this message translates to:
  /// **'3. Chiqish nuqtasi'**
  String get stepPickup;

  /// No description provided for @stepReview.
  ///
  /// In uz, this message translates to:
  /// **'4. Tekshirish'**
  String get stepReview;

  /// No description provided for @selectedSeats.
  ///
  /// In uz, this message translates to:
  /// **'Tanlangan joylar: {count}'**
  String selectedSeats(int count);

  /// No description provided for @totalPrice.
  ///
  /// In uz, this message translates to:
  /// **'Jami to\'lov'**
  String get totalPrice;

  /// No description provided for @cancellationPolicy.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish qoidalari'**
  String get cancellationPolicy;

  /// No description provided for @cancellationPolicyDesc.
  ///
  /// In uz, this message translates to:
  /// **'Safar boshlanishiga 2 soat qolguncha bepul bekor qilish mumkin.'**
  String get cancellationPolicyDesc;

  /// No description provided for @confirmBooking.
  ///
  /// In uz, this message translates to:
  /// **'Band qilishni tasdiqlash'**
  String get confirmBooking;

  /// No description provided for @paymentMethod.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov usuli'**
  String get paymentMethod;

  /// No description provided for @paymentCash.
  ///
  /// In uz, this message translates to:
  /// **'Haydovchiga naqd to\'lash'**
  String get paymentCash;

  /// No description provided for @paymentClick.
  ///
  /// In uz, this message translates to:
  /// **'Click orqali to\'lash'**
  String get paymentClick;

  /// No description provided for @paymentPayme.
  ///
  /// In uz, this message translates to:
  /// **'Payme orqali to\'lash'**
  String get paymentPayme;

  /// No description provided for @paymentUzum.
  ///
  /// In uz, this message translates to:
  /// **'Uzum Bank orqali to\'lash'**
  String get paymentUzum;

  /// No description provided for @bookingSuccessTitle.
  ///
  /// In uz, this message translates to:
  /// **'Muvaffaqiyatli band qilindi!'**
  String get bookingSuccessTitle;

  /// No description provided for @bookingSuccessDesc.
  ///
  /// In uz, this message translates to:
  /// **'Sizning buyurtmangiz qabul qilindi. Haydovchi siz bilan bog\'lanadi.'**
  String get bookingSuccessDesc;

  /// No description provided for @bookingId.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtma ID'**
  String get bookingId;

  /// No description provided for @viewTrip.
  ///
  /// In uz, this message translates to:
  /// **'Safarni ko\'rish'**
  String get viewTrip;

  /// No description provided for @backToHome.
  ///
  /// In uz, this message translates to:
  /// **'Bosh sahifaga'**
  String get backToHome;

  /// No description provided for @tabUpcoming.
  ///
  /// In uz, this message translates to:
  /// **'Kutilayotgan'**
  String get tabUpcoming;

  /// No description provided for @tabActive.
  ///
  /// In uz, this message translates to:
  /// **'Faol'**
  String get tabActive;

  /// No description provided for @tabCompleted.
  ///
  /// In uz, this message translates to:
  /// **'Tugallangan'**
  String get tabCompleted;

  /// No description provided for @tabCancelled.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilingan'**
  String get tabCancelled;

  /// No description provided for @noTripsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Qatnovlar tarixi bo\'sh'**
  String get noTripsTitle;

  /// No description provided for @noTripsDesc.
  ///
  /// In uz, this message translates to:
  /// **'Sizda ushbu bo\'limda hech qanday safar yo\'q.'**
  String get noTripsDesc;

  /// No description provided for @tripDetails.
  ///
  /// In uz, this message translates to:
  /// **'Safar tafsilotlari'**
  String get tripDetails;

  /// No description provided for @trackingTitle.
  ///
  /// In uz, this message translates to:
  /// **'Safarni kuzatish'**
  String get trackingTitle;

  /// No description provided for @statusBookingConfirmed.
  ///
  /// In uz, this message translates to:
  /// **'Band qilish tasdiqlandi'**
  String get statusBookingConfirmed;

  /// No description provided for @statusDriverPreparing.
  ///
  /// In uz, this message translates to:
  /// **'Haydovchi yo\'lga chiqishga tayyorlanmoqda'**
  String get statusDriverPreparing;

  /// No description provided for @statusDriverArrived.
  ///
  /// In uz, this message translates to:
  /// **'Haydovchi yetib keldi'**
  String get statusDriverArrived;

  /// No description provided for @statusPassengerPickedUp.
  ///
  /// In uz, this message translates to:
  /// **'Yo\'lovchi olindi'**
  String get statusPassengerPickedUp;

  /// No description provided for @statusTripStarted.
  ///
  /// In uz, this message translates to:
  /// **'Safar boshlandi'**
  String get statusTripStarted;

  /// No description provided for @statusNearDestination.
  ///
  /// In uz, this message translates to:
  /// **'Manzilga oz qoldi'**
  String get statusNearDestination;

  /// No description provided for @statusTripCompleted.
  ///
  /// In uz, this message translates to:
  /// **'Safar yakunlandi'**
  String get statusTripCompleted;

  /// No description provided for @notificationsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Bildirishnomalar'**
  String get notificationsTitle;

  /// No description provided for @markAllAsRead.
  ///
  /// In uz, this message translates to:
  /// **'Barchasini o\'qilgan qilish'**
  String get markAllAsRead;

  /// No description provided for @noNotificationsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Bildirishnomalar yo\'q'**
  String get noNotificationsTitle;

  /// No description provided for @noNotificationsDesc.
  ///
  /// In uz, this message translates to:
  /// **'Yangi xabarlar paydo bo\'lganda shu yerda ko\'rinadi.'**
  String get noNotificationsDesc;

  /// No description provided for @profileTitle.
  ///
  /// In uz, this message translates to:
  /// **'Profil'**
  String get profileTitle;

  /// No description provided for @editProfile.
  ///
  /// In uz, this message translates to:
  /// **'Profilni tahrirlash'**
  String get editProfile;

  /// No description provided for @personalInfo.
  ///
  /// In uz, this message translates to:
  /// **'Shaxsiy ma\'lumotlar'**
  String get personalInfo;

  /// No description provided for @myActivity.
  ///
  /// In uz, this message translates to:
  /// **'Mening faolligim'**
  String get myActivity;

  /// No description provided for @totalTrips.
  ///
  /// In uz, this message translates to:
  /// **'Jami safarlar'**
  String get totalTrips;

  /// No description provided for @savedPlaces.
  ///
  /// In uz, this message translates to:
  /// **'Saqlangan manzillar'**
  String get savedPlaces;

  /// No description provided for @homePlace.
  ///
  /// In uz, this message translates to:
  /// **'Uy'**
  String get homePlace;

  /// No description provided for @workPlace.
  ///
  /// In uz, this message translates to:
  /// **'Ish'**
  String get workPlace;

  /// No description provided for @addPlace.
  ///
  /// In uz, this message translates to:
  /// **'Manzil qo\'shish'**
  String get addPlace;

  /// No description provided for @settings.
  ///
  /// In uz, this message translates to:
  /// **'Sozlamalar'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In uz, this message translates to:
  /// **'Til'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In uz, this message translates to:
  /// **'Mavzu'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In uz, this message translates to:
  /// **'Tizim sozlamasi'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In uz, this message translates to:
  /// **'Yorug\' mavzu'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In uz, this message translates to:
  /// **'Qorong\'i mavzu'**
  String get themeDark;

  /// No description provided for @support.
  ///
  /// In uz, this message translates to:
  /// **'Yordam va qo\'llab-quvvatlash'**
  String get support;

  /// No description provided for @helpCenter.
  ///
  /// In uz, this message translates to:
  /// **'Yordam markazi'**
  String get helpCenter;

  /// No description provided for @faq.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'p beriladigan savollar'**
  String get faq;

  /// No description provided for @contactSupport.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'llab-quvvatlash xizmati'**
  String get contactSupport;

  /// No description provided for @reportProblem.
  ///
  /// In uz, this message translates to:
  /// **'Muammo haqida xabar berish'**
  String get reportProblem;

  /// No description provided for @termsOfService.
  ///
  /// In uz, this message translates to:
  /// **'Foydalanish shartlari'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In uz, this message translates to:
  /// **'Maxfiylik siyosati'**
  String get privacyPolicy;

  /// No description provided for @logout.
  ///
  /// In uz, this message translates to:
  /// **'Chiqish'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In uz, this message translates to:
  /// **'Haqiqatan ham hisobingizdan chiqmoqchimisiz?'**
  String get logoutConfirm;

  /// No description provided for @deleteAccount.
  ///
  /// In uz, this message translates to:
  /// **'Hisobni o\'chirish'**
  String get deleteAccount;

  /// No description provided for @ratingTitle.
  ///
  /// In uz, this message translates to:
  /// **'Safaringiz qanday o\'tdi?'**
  String get ratingTitle;

  /// No description provided for @ratingSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Haydovchiga baho bering va xizmat sifatini oshirishga yordam bering'**
  String get ratingSubtitle;

  /// No description provided for @ratingFeedbackHint.
  ///
  /// In uz, this message translates to:
  /// **'Fikringizni qoldiring (ixtiyoriy)...'**
  String get ratingFeedbackHint;

  /// No description provided for @submitRating.
  ///
  /// In uz, this message translates to:
  /// **'Baholashni yuborish'**
  String get submitRating;

  /// No description provided for @tagCleanCar.
  ///
  /// In uz, this message translates to:
  /// **'Toza avtomobil'**
  String get tagCleanCar;

  /// No description provided for @tagFriendlyDriver.
  ///
  /// In uz, this message translates to:
  /// **'Xushmuomala haydovchi'**
  String get tagFriendlyDriver;

  /// No description provided for @tagOnTime.
  ///
  /// In uz, this message translates to:
  /// **'O\'z vaqtida'**
  String get tagOnTime;

  /// No description provided for @tagComfortable.
  ///
  /// In uz, this message translates to:
  /// **'Qulay'**
  String get tagComfortable;

  /// No description provided for @tagSafeDriving.
  ///
  /// In uz, this message translates to:
  /// **'Xavfsiz haydash'**
  String get tagSafeDriving;

  /// No description provided for @cancelTripTitle.
  ///
  /// In uz, this message translates to:
  /// **'Safarni bekor qilish'**
  String get cancelTripTitle;

  /// No description provided for @cancelTripDesc.
  ///
  /// In uz, this message translates to:
  /// **'Haqiqatan ham ushbu safarni bekor qilmoqchimisiz?'**
  String get cancelTripDesc;

  /// No description provided for @cancelReason.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish sababi'**
  String get cancelReason;

  /// No description provided for @reasonChangePlans.
  ///
  /// In uz, this message translates to:
  /// **'Rejalarim o\'zgardi'**
  String get reasonChangePlans;

  /// No description provided for @reasonFoundAnother.
  ///
  /// In uz, this message translates to:
  /// **'Boshqa transport topdim'**
  String get reasonFoundAnother;

  /// No description provided for @reasonDriverAsked.
  ///
  /// In uz, this message translates to:
  /// **'Haydovchi bekor qilishni so\'radi'**
  String get reasonDriverAsked;

  /// No description provided for @reasonOther.
  ///
  /// In uz, this message translates to:
  /// **'Boshqa sabab'**
  String get reasonOther;

  /// No description provided for @confirmCancel.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilishni tasdiqlash'**
  String get confirmCancel;

  /// No description provided for @offlineTitle.
  ///
  /// In uz, this message translates to:
  /// **'Internet aloqasi yo\'q'**
  String get offlineTitle;

  /// No description provided for @offlineDesc.
  ///
  /// In uz, this message translates to:
  /// **'Iltimos, internet ulanishini tekshiring va qayta urinib ko\'ring.'**
  String get offlineDesc;

  /// No description provided for @errorGeneric.
  ///
  /// In uz, this message translates to:
  /// **'Kutilmagan xatolik yuz berdi. Qayta urinib ko\'ring.'**
  String get errorGeneric;

  /// No description provided for @errorPhoneInvalid.
  ///
  /// In uz, this message translates to:
  /// **'Telefon raqami noto\'g\'ri kiritildi'**
  String get errorPhoneInvalid;

  /// No description provided for @errorOtpInvalid.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlash kodi noto\'g\'ri'**
  String get errorOtpInvalid;

  /// No description provided for @errorOtpExpired.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlash kodi muddati tugagan'**
  String get errorOtpExpired;

  /// No description provided for @onboardingSlide1Badge.
  ///
  /// In uz, this message translates to:
  /// **'Shaharlararo qatnovlar'**
  String get onboardingSlide1Badge;

  /// No description provided for @onboardingSlide1Title.
  ///
  /// In uz, this message translates to:
  /// **'O\'zbekiston bo\'ylab\nqulay va tezkor safarlar'**
  String get onboardingSlide1Title;

  /// No description provided for @onboardingSlide1Desc.
  ///
  /// In uz, this message translates to:
  /// **'Toshkent, Samarqand, Andijon, Farg\'ona, Buxoro va barcha viloyatlar bo\'ylab ishonchli taksilar.'**
  String get onboardingSlide1Desc;

  /// No description provided for @onboardingSlide2Badge.
  ///
  /// In uz, this message translates to:
  /// **'Sun\'iy yo\'ldosh xaritasi'**
  String get onboardingSlide2Badge;

  /// No description provided for @onboardingSlide2Title.
  ///
  /// In uz, this message translates to:
  /// **'Xaritadan manzilni\noson va aniq tanlang'**
  String get onboardingSlide2Title;

  /// No description provided for @onboardingSlide2Desc.
  ///
  /// In uz, this message translates to:
  /// **'O\'zbekistonning barcha shahar va tumanlarini sun\'iy yo\'ldosh xaritasidan tanlang va masofani ko\'ring.'**
  String get onboardingSlide2Desc;

  /// No description provided for @onboardingSlide3Badge.
  ///
  /// In uz, this message translates to:
  /// **'Hamyonbop va shaffof'**
  String get onboardingSlide3Badge;

  /// No description provided for @onboardingSlide3Title.
  ///
  /// In uz, this message translates to:
  /// **'Shaffof narxlar va\ntasdiqlangan haydovchilar'**
  String get onboardingSlide3Title;

  /// No description provided for @onboardingSlide3Desc.
  ///
  /// In uz, this message translates to:
  /// **'Har bir kilometr uchun adolatli narxlar, qulay avtomobillar va xavfsiz sayohat kafolati.'**
  String get onboardingSlide3Desc;

  /// No description provided for @satelliteMode.
  ///
  /// In uz, this message translates to:
  /// **'Sun\'iy yo\'ldosh'**
  String get satelliteMode;

  /// No description provided for @standardMode.
  ///
  /// In uz, this message translates to:
  /// **'Standart xarita'**
  String get standardMode;

  /// No description provided for @searchCityDistrictHint.
  ///
  /// In uz, this message translates to:
  /// **'Shahar yoki tumanni qidiring...'**
  String get searchCityDistrictHint;

  /// No description provided for @allRegions.
  ///
  /// In uz, this message translates to:
  /// **'Barchasi'**
  String get allRegions;

  /// No description provided for @tashkentRegion.
  ///
  /// In uz, this message translates to:
  /// **'Toshkent'**
  String get tashkentRegion;

  /// No description provided for @ferganaValley.
  ///
  /// In uz, this message translates to:
  /// **'Farg\'ona vodiysi'**
  String get ferganaValley;

  /// No description provided for @samarkandRegion.
  ///
  /// In uz, this message translates to:
  /// **'Samarqand'**
  String get samarkandRegion;

  /// No description provided for @bukharaRegion.
  ///
  /// In uz, this message translates to:
  /// **'Buxoro'**
  String get bukharaRegion;

  /// No description provided for @southernRegion.
  ///
  /// In uz, this message translates to:
  /// **'Qashqadaryo / Surxondaryo'**
  String get southernRegion;

  /// No description provided for @westernRegion.
  ///
  /// In uz, this message translates to:
  /// **'Xorazm / Qoraqalpog\'iston'**
  String get westernRegion;

  /// No description provided for @notificationsAll.
  ///
  /// In uz, this message translates to:
  /// **'Barchasi'**
  String get notificationsAll;

  /// No description provided for @notificationsTrips.
  ///
  /// In uz, this message translates to:
  /// **'Safarlar'**
  String get notificationsTrips;

  /// No description provided for @notificationsPromo.
  ///
  /// In uz, this message translates to:
  /// **'Aksiyalar'**
  String get notificationsPromo;

  /// No description provided for @notificationsSystem.
  ///
  /// In uz, this message translates to:
  /// **'Tizim'**
  String get notificationsSystem;

  /// No description provided for @clearAll.
  ///
  /// In uz, this message translates to:
  /// **'Tozalash'**
  String get clearAll;

  /// No description provided for @phoneCall.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'ng\'iroq qilish'**
  String get phoneCall;

  /// No description provided for @tripLinkCopied.
  ///
  /// In uz, this message translates to:
  /// **'Safar havolasi nusxalandi: {route}'**
  String tripLinkCopied(String route);

  /// No description provided for @callingDriver.
  ///
  /// In uz, this message translates to:
  /// **'Haydovchiga qo\'ng\'iroq qilinmoqda: {phone}'**
  String callingDriver(String phone);

  /// No description provided for @appVersion.
  ///
  /// In uz, this message translates to:
  /// **'Ilova versiyasi'**
  String get appVersion;

  /// No description provided for @selectLanguage.
  ///
  /// In uz, this message translates to:
  /// **'Tilni tanlang'**
  String get selectLanguage;

  /// No description provided for @selectTheme.
  ///
  /// In uz, this message translates to:
  /// **'Mavzuni tanlang'**
  String get selectTheme;

  /// No description provided for @themeDarkDesc.
  ///
  /// In uz, this message translates to:
  /// **'Qorong\'i rejim, ko\'zga qulay'**
  String get themeDarkDesc;

  /// No description provided for @themeLightDesc.
  ///
  /// In uz, this message translates to:
  /// **'Yorug\' va tiniq interfeys'**
  String get themeLightDesc;

  /// No description provided for @themeSystemDesc.
  ///
  /// In uz, this message translates to:
  /// **'Tizim sozlamasiga moslashadi'**
  String get themeSystemDesc;

  /// No description provided for @comfortAndSafety.
  ///
  /// In uz, this message translates to:
  /// **'Qulaylik va xavfsizlik'**
  String get comfortAndSafety;

  /// No description provided for @statusPending.
  ///
  /// In uz, this message translates to:
  /// **'Kutilmoqda'**
  String get statusPending;

  /// No description provided for @statusApproved.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlangan'**
  String get statusApproved;

  /// No description provided for @statusRejected.
  ///
  /// In uz, this message translates to:
  /// **'Rad etilgan'**
  String get statusRejected;

  /// No description provided for @statusCompleted.
  ///
  /// In uz, this message translates to:
  /// **'Yakunlangan'**
  String get statusCompleted;

  /// No description provided for @statusCancelled.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilingan'**
  String get statusCancelled;

  /// No description provided for @statusActive.
  ///
  /// In uz, this message translates to:
  /// **'Faol'**
  String get statusActive;

  /// No description provided for @statusInProgress.
  ///
  /// In uz, this message translates to:
  /// **'Jarayonda'**
  String get statusInProgress;

  /// No description provided for @statusArrived.
  ///
  /// In uz, this message translates to:
  /// **'Yetib keldi'**
  String get statusArrived;

  /// No description provided for @statusAccepted.
  ///
  /// In uz, this message translates to:
  /// **'Qabul qilindi'**
  String get statusAccepted;

  /// No description provided for @statusOnline.
  ///
  /// In uz, this message translates to:
  /// **'Onlayn'**
  String get statusOnline;

  /// No description provided for @statusOffline.
  ///
  /// In uz, this message translates to:
  /// **'Oflayn'**
  String get statusOffline;

  /// No description provided for @statusOnTrip.
  ///
  /// In uz, this message translates to:
  /// **'Safarda'**
  String get statusOnTrip;

  /// No description provided for @driverHomeTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yo\'l-Yo\'lakay Haydovchi'**
  String get driverHomeTitle;

  /// No description provided for @shiftOnlineTitle.
  ///
  /// In uz, this message translates to:
  /// **'Siz smenadasiz (Onlayn)'**
  String get shiftOnlineTitle;

  /// No description provided for @shiftOfflineTitle.
  ///
  /// In uz, this message translates to:
  /// **'Smena o\'chirilgan (Oflayn)'**
  String get shiftOfflineTitle;

  /// No description provided for @shiftOnlineSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmalarni qabul qilishga tayyorsiz'**
  String get shiftOnlineSubtitle;

  /// No description provided for @shiftOfflineSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmalar olish uchun smenani yoqing'**
  String get shiftOfflineSubtitle;

  /// No description provided for @startShift.
  ///
  /// In uz, this message translates to:
  /// **'Smenani boshlash'**
  String get startShift;

  /// No description provided for @endShift.
  ///
  /// In uz, this message translates to:
  /// **'Smenani tugatish'**
  String get endShift;

  /// No description provided for @todayPerformance.
  ///
  /// In uz, this message translates to:
  /// **'Bugungi ko\'rsatkichlar'**
  String get todayPerformance;

  /// No description provided for @dailyLabel.
  ///
  /// In uz, this message translates to:
  /// **'Kunlik'**
  String get dailyLabel;

  /// No description provided for @todayEarnings.
  ///
  /// In uz, this message translates to:
  /// **'Kunlik daromad'**
  String get todayEarnings;

  /// No description provided for @completedTrips.
  ///
  /// In uz, this message translates to:
  /// **'Bajarilgan safarlar'**
  String get completedTrips;

  /// No description provided for @onlineHours.
  ///
  /// In uz, this message translates to:
  /// **'Onlayn vaqt'**
  String get onlineHours;

  /// No description provided for @acceptanceRate.
  ///
  /// In uz, this message translates to:
  /// **'Qabul qilish ko\'rsatkichi'**
  String get acceptanceRate;

  /// No description provided for @walletBalance.
  ///
  /// In uz, this message translates to:
  /// **'Hamyon balansi'**
  String get walletBalance;

  /// No description provided for @topUpBalance.
  ///
  /// In uz, this message translates to:
  /// **'Balansni to\'ldirish'**
  String get topUpBalance;

  /// No description provided for @activeTaxiOrderBanner.
  ///
  /// In uz, this message translates to:
  /// **'Faol tezkor taksi buyurtmasi mavjud'**
  String get activeTaxiOrderBanner;

  /// No description provided for @activeIntercityTripBanner.
  ///
  /// In uz, this message translates to:
  /// **'Faol shaharlararo qatnovingiz mavjud'**
  String get activeIntercityTripBanner;

  /// No description provided for @viewDetails.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'rish'**
  String get viewDetails;

  /// No description provided for @radarOrdersTitle.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmalar Radari'**
  String get radarOrdersTitle;

  /// No description provided for @noRadarOrdersTitle.
  ///
  /// In uz, this message translates to:
  /// **'Hozircha yangi buyurtmalar yo\'q'**
  String get noRadarOrdersTitle;

  /// No description provided for @noRadarOrdersDesc.
  ///
  /// In uz, this message translates to:
  /// **'Yangi buyurtmalar paydo bo\'lganda bu yerda ko\'rinadi va signal beriladi.'**
  String get noRadarOrdersDesc;

  /// No description provided for @orderIncoming.
  ///
  /// In uz, this message translates to:
  /// **'Yangi taksi buyurtmasi'**
  String get orderIncoming;

  /// No description provided for @acceptOrder.
  ///
  /// In uz, this message translates to:
  /// **'Qabul qilish'**
  String get acceptOrder;

  /// No description provided for @declineOrder.
  ///
  /// In uz, this message translates to:
  /// **'Rad etish'**
  String get declineOrder;

  /// No description provided for @driverAssignedStatus.
  ///
  /// In uz, this message translates to:
  /// **'Yo\'lovchi tomon harakatlanmoqdasiz'**
  String get driverAssignedStatus;

  /// No description provided for @driverArrivedStatus.
  ///
  /// In uz, this message translates to:
  /// **'Yetib keldingiz. Yo\'lovchi kutilyapti'**
  String get driverArrivedStatus;

  /// No description provided for @finishTrip.
  ///
  /// In uz, this message translates to:
  /// **'Safarni yakunlash'**
  String get finishTrip;

  /// No description provided for @finalAmountPrompt.
  ///
  /// In uz, this message translates to:
  /// **'Yakuniy to\'lov miqdori (so\'mda):'**
  String get finalAmountPrompt;

  /// No description provided for @cancelOrderPrompt.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmani bekor qilish'**
  String get cancelOrderPrompt;

  /// No description provided for @netEarningsLabel.
  ///
  /// In uz, this message translates to:
  /// **'Sizning sof daromadingiz: {amount}'**
  String netEarningsLabel(String amount);

  /// No description provided for @commissionDeductedLabel.
  ///
  /// In uz, this message translates to:
  /// **'Ushlab qolingan komissiya: {amount}'**
  String commissionDeductedLabel(String amount);

  /// No description provided for @backToRadarAction.
  ///
  /// In uz, this message translates to:
  /// **'Radarga qaytish'**
  String get backToRadarAction;

  /// No description provided for @markArrived.
  ///
  /// In uz, this message translates to:
  /// **'Yetib keldim'**
  String get markArrived;

  /// No description provided for @startTrip.
  ///
  /// In uz, this message translates to:
  /// **'Safarni boshlash'**
  String get startTrip;

  /// No description provided for @callPassenger.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'ng\'iroq qilish'**
  String get callPassenger;

  /// No description provided for @intercityTripsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Shaharlararo qatnovlar'**
  String get intercityTripsTitle;

  /// No description provided for @publishTrip.
  ///
  /// In uz, this message translates to:
  /// **'Qatnov e\'lon qilish'**
  String get publishTrip;

  /// No description provided for @emptyTripsHistory.
  ///
  /// In uz, this message translates to:
  /// **'Qatnovlar tarixi bo\'sh'**
  String get emptyTripsHistory;

  /// No description provided for @emptyTripsActiveDesc.
  ///
  /// In uz, this message translates to:
  /// **'Sizda hozircha faol qatnov yo\'q. Yangi qatnov e\'lon qilishingiz mumkin.'**
  String get emptyTripsActiveDesc;

  /// No description provided for @emptyTripsGeneralDesc.
  ///
  /// In uz, this message translates to:
  /// **'Ushbu bo\'limda qatnovlar mavjud emas.'**
  String get emptyTripsGeneralDesc;

  /// No description provided for @tripDetailsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Qatnov tafsilotlari'**
  String get tripDetailsTitle;

  /// No description provided for @createTripTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yangi qatnov e\'lon qilish'**
  String get createTripTitle;

  /// No description provided for @departureCity.
  ///
  /// In uz, this message translates to:
  /// **'Jo\'nash shahri'**
  String get departureCity;

  /// No description provided for @destinationCity.
  ///
  /// In uz, this message translates to:
  /// **'Yetib borish shahri'**
  String get destinationCity;

  /// No description provided for @totalSeats.
  ///
  /// In uz, this message translates to:
  /// **'O\'rinlar soni'**
  String get totalSeats;

  /// No description provided for @tripAmenities.
  ///
  /// In uz, this message translates to:
  /// **'Qulayliklar'**
  String get tripAmenities;

  /// No description provided for @hasAc.
  ///
  /// In uz, this message translates to:
  /// **'Konditsioner'**
  String get hasAc;

  /// No description provided for @allowLuggage.
  ///
  /// In uz, this message translates to:
  /// **'Yuk joyi'**
  String get allowLuggage;

  /// No description provided for @allowSmoking.
  ///
  /// In uz, this message translates to:
  /// **'Chekishga ruxsat'**
  String get allowSmoking;

  /// No description provided for @womenOnly.
  ///
  /// In uz, this message translates to:
  /// **'Faqat ayollar uchun'**
  String get womenOnly;

  /// No description provided for @publishAction.
  ///
  /// In uz, this message translates to:
  /// **'Qatnovni e\'lon qilish'**
  String get publishAction;

  /// No description provided for @tripPublishedSuccess.
  ///
  /// In uz, this message translates to:
  /// **'Qatnov muvaffaqiyatli e\'lon qilindi!'**
  String get tripPublishedSuccess;

  /// No description provided for @walletAndEarnings.
  ///
  /// In uz, this message translates to:
  /// **'Hamyon va Daromadlar'**
  String get walletAndEarnings;

  /// No description provided for @currentBalance.
  ///
  /// In uz, this message translates to:
  /// **'Joriy balans'**
  String get currentBalance;

  /// No description provided for @mainWallet.
  ///
  /// In uz, this message translates to:
  /// **'Asosiy hamyon'**
  String get mainWallet;

  /// No description provided for @lowBalanceWarning.
  ///
  /// In uz, this message translates to:
  /// **'Balansingiz minimal miqdordan kam. Buyurtmalarni qabul qilish uchun to\'ldiring.'**
  String get lowBalanceWarning;

  /// No description provided for @depositTitle.
  ///
  /// In uz, this message translates to:
  /// **'Hisobni to\'ldirish'**
  String get depositTitle;

  /// No description provided for @selectPaymentSystem.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov tizimini tanlang:'**
  String get selectPaymentSystem;

  /// No description provided for @amountInSum.
  ///
  /// In uz, this message translates to:
  /// **'Miqdor (so\'mda):'**
  String get amountInSum;

  /// No description provided for @todayTab.
  ///
  /// In uz, this message translates to:
  /// **'Bugun'**
  String get todayTab;

  /// No description provided for @weeklyTab.
  ///
  /// In uz, this message translates to:
  /// **'Hafta'**
  String get weeklyTab;

  /// No description provided for @monthlyTab.
  ///
  /// In uz, this message translates to:
  /// **'Oy'**
  String get monthlyTab;

  /// No description provided for @totalEarnings.
  ///
  /// In uz, this message translates to:
  /// **'Jami daromad'**
  String get totalEarnings;

  /// No description provided for @tripsCount.
  ///
  /// In uz, this message translates to:
  /// **'Safarlar soni'**
  String get tripsCount;

  /// No description provided for @totalDistance.
  ///
  /// In uz, this message translates to:
  /// **'Masofa'**
  String get totalDistance;

  /// No description provided for @totalHours.
  ///
  /// In uz, this message translates to:
  /// **'Onlayn vaqt'**
  String get totalHours;

  /// No description provided for @dailyChart.
  ///
  /// In uz, this message translates to:
  /// **'Kunlik grafik'**
  String get dailyChart;

  /// No description provided for @transactionHistory.
  ///
  /// In uz, this message translates to:
  /// **'Tranzaksiyalar tarixi'**
  String get transactionHistory;

  /// No description provided for @noTransactions.
  ///
  /// In uz, this message translates to:
  /// **'Hozircha tranzaksiyalar yo\'q'**
  String get noTransactions;

  /// No description provided for @noTransactionsDesc.
  ///
  /// In uz, this message translates to:
  /// **'Bajarilgan safarlar va hisob to\'ldirishlar shu yerda aks etadi.'**
  String get noTransactionsDesc;

  /// No description provided for @paymentProcessing.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov jarayoni'**
  String get paymentProcessing;

  /// No description provided for @paymentVerifying.
  ///
  /// In uz, this message translates to:
  /// **'Server orqali tekshirilmoqda...'**
  String get paymentVerifying;

  /// No description provided for @verifyPayment.
  ///
  /// In uz, this message translates to:
  /// **'To\'lovni tekshirish'**
  String get verifyPayment;

  /// No description provided for @reopenPayment.
  ///
  /// In uz, this message translates to:
  /// **'Qayta ochish'**
  String get reopenPayment;

  /// No description provided for @paymentSuccessMessage.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov muvaffaqiyatli qabul qilindi va balans yangilandi!'**
  String get paymentSuccessMessage;

  /// No description provided for @paymentPendingMessage.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov hali tasdiqlanmadi. Qayta urinib ko\'ring yoki biroz kuting.'**
  String get paymentPendingMessage;

  /// No description provided for @driverProfileTitle.
  ///
  /// In uz, this message translates to:
  /// **'Haydovchi profili'**
  String get driverProfileTitle;

  /// No description provided for @vehicleInfo.
  ///
  /// In uz, this message translates to:
  /// **'Avtomobil ma\'lumotlari'**
  String get vehicleInfo;

  /// No description provided for @documentsVerification.
  ///
  /// In uz, this message translates to:
  /// **'Hujjatlar verifikatsiyasi'**
  String get documentsVerification;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In uz, this message translates to:
  /// **'Tizimdan chiqish'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmDesc.
  ///
  /// In uz, this message translates to:
  /// **'Haqiqatan ham hisobingizdan chiqmoqchimisiz?'**
  String get logoutConfirmDesc;

  /// No description provided for @logoutAction.
  ///
  /// In uz, this message translates to:
  /// **'Chiqish'**
  String get logoutAction;

  /// No description provided for @tripsCountPlural.
  ///
  /// In uz, this message translates to:
  /// **'{count, plural, =1{1 ta safar} other{{count} ta safar}}'**
  String tripsCountPlural(int count);

  /// No description provided for @seatsCountPlural.
  ///
  /// In uz, this message translates to:
  /// **'{count, plural, =1{1 ta o\'rin} other{{count} ta o\'rin}}'**
  String seatsCountPlural(int count);

  /// No description provided for @refresh.
  ///
  /// In uz, this message translates to:
  /// **'Yangilash'**
  String get refresh;

  /// No description provided for @daily.
  ///
  /// In uz, this message translates to:
  /// **'Kunlik'**
  String get daily;

  /// No description provided for @topUp.
  ///
  /// In uz, this message translates to:
  /// **'To\'ldirish'**
  String get topUp;

  /// No description provided for @genericErrorMessage.
  ///
  /// In uz, this message translates to:
  /// **'Xatolik yuz berdi'**
  String get genericErrorMessage;

  /// No description provided for @fieldRequiredError.
  ///
  /// In uz, this message translates to:
  /// **'{field} to\'ldirilishi majburiy'**
  String fieldRequiredError(String field);

  /// No description provided for @homeTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yo\'l-Yo\'lakay Haydovchi'**
  String get homeTitle;

  /// No description provided for @todayStats.
  ///
  /// In uz, this message translates to:
  /// **'Bugungi ko\'rsatkichlar'**
  String get todayStats;

  /// No description provided for @statEarnings.
  ///
  /// In uz, this message translates to:
  /// **'Daromad'**
  String get statEarnings;

  /// No description provided for @statTripsCount.
  ///
  /// In uz, this message translates to:
  /// **'Safarlar soni'**
  String get statTripsCount;

  /// No description provided for @statOnlineTime.
  ///
  /// In uz, this message translates to:
  /// **'Onlayn vaqt'**
  String get statOnlineTime;

  /// No description provided for @statAcceptanceRate.
  ///
  /// In uz, this message translates to:
  /// **'Qabul darajasi'**
  String get statAcceptanceRate;

  /// No description provided for @activeTaxiOrderAlert.
  ///
  /// In uz, this message translates to:
  /// **'Faol taksi buyurtmangiz bor!'**
  String get activeTaxiOrderAlert;

  /// No description provided for @activeTaxiOrderDesc.
  ///
  /// In uz, this message translates to:
  /// **'Safar sahifasiga o\'tish uchun bosing'**
  String get activeTaxiOrderDesc;

  /// No description provided for @activeIntercityTripAlert.
  ///
  /// In uz, this message translates to:
  /// **'Faol shaharlararo qatnovingiz bor!'**
  String get activeIntercityTripAlert;

  /// No description provided for @activeIntercityTripDesc.
  ///
  /// In uz, this message translates to:
  /// **'Qatnov tafsilotlarini ko\'rish uchun bosing'**
  String get activeIntercityTripDesc;

  /// No description provided for @tripsCountUnit.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta'**
  String tripsCountUnit(int count);

  /// No description provided for @hours.
  ///
  /// In uz, this message translates to:
  /// **'{count} soat'**
  String hours(int count);

  /// No description provided for @tripPrice.
  ///
  /// In uz, this message translates to:
  /// **'Safar narxi:'**
  String get tripPrice;

  /// No description provided for @arrivedAtPickupAction.
  ///
  /// In uz, this message translates to:
  /// **'Yetib keldim (Manzildaman)'**
  String get arrivedAtPickupAction;

  /// No description provided for @startRideAction.
  ///
  /// In uz, this message translates to:
  /// **'Yo\'lga chiqdik (Safarni boshlash)'**
  String get startRideAction;

  /// No description provided for @completeRideAction.
  ///
  /// In uz, this message translates to:
  /// **'Safarni yakunlash'**
  String get completeRideAction;

  /// No description provided for @cancelOrderAction.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmani bekor qilish'**
  String get cancelOrderAction;

  /// No description provided for @completeRideModalTitle.
  ///
  /// In uz, this message translates to:
  /// **'Safarni yakunlash'**
  String get completeRideModalTitle;

  /// No description provided for @finalPaymentAmountLabel.
  ///
  /// In uz, this message translates to:
  /// **'Yakuniy to\'lov miqdori (so\'mda):'**
  String get finalPaymentAmountLabel;

  /// No description provided for @completeAction.
  ///
  /// In uz, this message translates to:
  /// **'Yakunlash'**
  String get completeAction;

  /// No description provided for @cancelReasonPassengerNoShow.
  ///
  /// In uz, this message translates to:
  /// **'Yo\'lovchi aloqaga chiqmadi'**
  String get cancelReasonPassengerNoShow;

  /// No description provided for @cancelReasonPassengerTookAnother.
  ///
  /// In uz, this message translates to:
  /// **'Yo\'lovchi boshqa mashina bilan ketdi'**
  String get cancelReasonPassengerTookAnother;

  /// No description provided for @cancelReasonCarIssue.
  ///
  /// In uz, this message translates to:
  /// **'Avtomobil nosozligi'**
  String get cancelReasonCarIssue;

  /// No description provided for @cancelReasonOther.
  ///
  /// In uz, this message translates to:
  /// **'Boshqa sabab'**
  String get cancelReasonOther;

  /// No description provided for @acceptWithTimer.
  ///
  /// In uz, this message translates to:
  /// **'Qabul qilish ({seconds} s)'**
  String acceptWithTimer(int seconds);

  /// No description provided for @tripsPageTitle.
  ///
  /// In uz, this message translates to:
  /// **'Shaharlararo qatnovlar'**
  String get tripsPageTitle;

  /// No description provided for @createTripAction.
  ///
  /// In uz, this message translates to:
  /// **'Qatnov e\'lon qilish'**
  String get createTripAction;

  /// No description provided for @noActiveTripsDesc.
  ///
  /// In uz, this message translates to:
  /// **'Sizda hozircha faol qatnov yo\'q. Yangi qatnov e\'lon qilishingiz mumkin.'**
  String get noActiveTripsDesc;

  /// No description provided for @noTripsHistoryDesc.
  ///
  /// In uz, this message translates to:
  /// **'Ushbu bo\'limda qatnovlar mavjud emas.'**
  String get noTripsHistoryDesc;

  /// No description provided for @seatsDetail.
  ///
  /// In uz, this message translates to:
  /// **'O\'rinlar: {booked} ta band, {available} ta bo\'sh (Jami: {total})'**
  String seatsDetail(int booked, int available, int total);

  /// No description provided for @passengersCount.
  ///
  /// In uz, this message translates to:
  /// **'Yo\'lovchilar ({count} ta)'**
  String passengersCount(int count);

  /// No description provided for @noPassengersBooked.
  ///
  /// In uz, this message translates to:
  /// **'Hozircha yo\'lovchilar bron qilmagan.'**
  String get noPassengersBooked;

  /// No description provided for @markRideStartedAction.
  ///
  /// In uz, this message translates to:
  /// **'Safar boshlandi deb belgilash'**
  String get markRideStartedAction;

  /// No description provided for @cancelTripAction.
  ///
  /// In uz, this message translates to:
  /// **'Qatnovni bekor qilish'**
  String get cancelTripAction;

  /// No description provided for @passengerSeatsDetail.
  ///
  /// In uz, this message translates to:
  /// **'{seats} ta o\'rin • {price}'**
  String passengerSeatsDetail(int seats, String price);

  /// No description provided for @defaultCancelTripReason.
  ///
  /// In uz, this message translates to:
  /// **'Texnik sabablarga ko\'ra'**
  String get defaultCancelTripReason;

  /// No description provided for @cancelTripReasonPrompt.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish sababi yo\'lovchilarga yuboriladi:'**
  String get cancelTripReasonPrompt;

  /// No description provided for @selectCitiesPrompt.
  ///
  /// In uz, this message translates to:
  /// **'Iltimos, jo\'nash va yetib borish shaharlarini tanlang'**
  String get selectCitiesPrompt;

  /// No description provided for @citiesMustBeDifferentPrompt.
  ///
  /// In uz, this message translates to:
  /// **'Jo\'nash va borish shaharlari bir xil bo\'lishi mumkin emas'**
  String get citiesMustBeDifferentPrompt;

  /// No description provided for @tripCreatedSuccess.
  ///
  /// In uz, this message translates to:
  /// **'Qatnov muvaffaqiyatli e\'lon qilindi!'**
  String get tripCreatedSuccess;

  /// No description provided for @fromCityLabel.
  ///
  /// In uz, this message translates to:
  /// **'Qayerdan (Jo\'nash shahri)'**
  String get fromCityLabel;

  /// No description provided for @toCityLabel.
  ///
  /// In uz, this message translates to:
  /// **'Qayerga (Borish shahri)'**
  String get toCityLabel;

  /// No description provided for @departureDateLabel.
  ///
  /// In uz, this message translates to:
  /// **'Jo\'nash sanasi va vaqti'**
  String get departureDateLabel;

  /// No description provided for @pricePerSeatLabel.
  ///
  /// In uz, this message translates to:
  /// **'Bir o\'rin narxi (so\'m)'**
  String get pricePerSeatLabel;

  /// No description provided for @seatsOption.
  ///
  /// In uz, this message translates to:
  /// **'{count} o\'rin'**
  String seatsOption(int count);

  /// No description provided for @pickupAddressLabel.
  ///
  /// In uz, this message translates to:
  /// **'Kutib olish manzili (Mo\'ljal)'**
  String get pickupAddressLabel;

  /// No description provided for @dropoffAddressLabel.
  ///
  /// In uz, this message translates to:
  /// **'Yetkazib qo\'yish manzili'**
  String get dropoffAddressLabel;

  /// No description provided for @amenitiesSectionTitle.
  ///
  /// In uz, this message translates to:
  /// **'Qulayliklar va qoidalar'**
  String get amenitiesSectionTitle;

  /// No description provided for @hasAcLabel.
  ///
  /// In uz, this message translates to:
  /// **'Konditsioner bor'**
  String get hasAcLabel;

  /// No description provided for @allowLuggageLabel.
  ///
  /// In uz, this message translates to:
  /// **'Bagaj joyi bor'**
  String get allowLuggageLabel;

  /// No description provided for @womenOnlyLabel.
  ///
  /// In uz, this message translates to:
  /// **'Faqat ayollar uchun'**
  String get womenOnlyLabel;

  /// No description provided for @additionalCommentLabel.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'shimcha izoh (ixtiyoriy)'**
  String get additionalCommentLabel;

  /// No description provided for @publishTripAction.
  ///
  /// In uz, this message translates to:
  /// **'Qatnovni e\'lon qilish'**
  String get publishTripAction;

  /// No description provided for @logoutTitle.
  ///
  /// In uz, this message translates to:
  /// **'Tizimdan chiqish'**
  String get logoutTitle;

  /// No description provided for @logoutConfirmPrompt.
  ///
  /// In uz, this message translates to:
  /// **'Haqiqatan ham hisobingizdan chiqmoqchimisiz?'**
  String get logoutConfirmPrompt;

  /// No description provided for @avatarUpdatedSuccess.
  ///
  /// In uz, this message translates to:
  /// **'Avatar muvaffaqiyatli yangilandi'**
  String get avatarUpdatedSuccess;

  /// No description provided for @verificationApprovedTitle.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlangan haydovchi'**
  String get verificationApprovedTitle;

  /// No description provided for @verificationApprovedSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Barcha xizmatlardan cheklovlarsiz foydalanishingiz mumkin.'**
  String get verificationApprovedSubtitle;

  /// No description provided for @verificationUnderReviewTitle.
  ///
  /// In uz, this message translates to:
  /// **'Admin tekshiruvida (12 soat)'**
  String get verificationUnderReviewTitle;

  /// No description provided for @verificationUnderReviewSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Hujjatlaringiz adminga yuborildi va 12 soat ichida tekshiriladi. Hozircha sinov rejimida ilovadan to\'liq foydalanishingiz mumkin.'**
  String get verificationUnderReviewSubtitle;

  /// No description provided for @verificationRejectedTitle.
  ///
  /// In uz, this message translates to:
  /// **'Arizangiz rad etilgan'**
  String get verificationRejectedTitle;

  /// No description provided for @verificationRejectedSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Hujjatlarni qayta yuklash uchun bosing.'**
  String get verificationRejectedSubtitle;

  /// No description provided for @verificationMissingTitle.
  ///
  /// In uz, this message translates to:
  /// **'Hujjatlar topshirilmagan'**
  String get verificationMissingTitle;

  /// No description provided for @verificationMissingSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtma olishni boshlash uchun verifikatsiyadan o\'ting.'**
  String get verificationMissingSubtitle;

  /// No description provided for @vehicleInfoTitle.
  ///
  /// In uz, this message translates to:
  /// **'Avtomobil ma\'lumotlari'**
  String get vehicleInfoTitle;

  /// No description provided for @vehicleYearAndColor.
  ///
  /// In uz, this message translates to:
  /// **'Yili: {year} • Rangi: {color}'**
  String vehicleYearAndColor(int year, String color);

  /// No description provided for @reviewsAndRatingMenu.
  ///
  /// In uz, this message translates to:
  /// **'Sharhlar va Reyting'**
  String get reviewsAndRatingMenu;

  /// No description provided for @walletAndEarningsMenu.
  ///
  /// In uz, this message translates to:
  /// **'Hamyon va Daromadlar'**
  String get walletAndEarningsMenu;

  /// No description provided for @notificationsMenu.
  ///
  /// In uz, this message translates to:
  /// **'Bildirishnomalar'**
  String get notificationsMenu;

  /// No description provided for @supportMenu.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'llab-quvvatlash'**
  String get supportMenu;

  /// No description provided for @driverVerificationTitle.
  ///
  /// In uz, this message translates to:
  /// **'Haydovchi verifikatsiyasi'**
  String get driverVerificationTitle;

  /// No description provided for @verificationBannerText.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmalarni qabul qilish uchun shaxsingiz va avtomobilingiz hujjatlarini tasdiqlang.'**
  String get verificationBannerText;

  /// No description provided for @personalInfoSectionTitle.
  ///
  /// In uz, this message translates to:
  /// **'1. Shaxsiy ma\'lumotlar'**
  String get personalInfoSectionTitle;

  /// No description provided for @vehicleInfoSectionTitle.
  ///
  /// In uz, this message translates to:
  /// **'2. Avtomobil ma\'lumotlari'**
  String get vehicleInfoSectionTitle;

  /// No description provided for @documentsAndPhotosSectionTitle.
  ///
  /// In uz, this message translates to:
  /// **'3. Hujjat va avtomobil fotosuratlari'**
  String get documentsAndPhotosSectionTitle;

  /// No description provided for @submitApplicationAction.
  ///
  /// In uz, this message translates to:
  /// **'Hujjatlarni tekshirishga yuborish'**
  String get submitApplicationAction;

  /// No description provided for @cameraOption.
  ///
  /// In uz, this message translates to:
  /// **'Kameradan olish'**
  String get cameraOption;

  /// No description provided for @galleryOption.
  ///
  /// In uz, this message translates to:
  /// **'Galereyadan tanlash'**
  String get galleryOption;

  /// No description provided for @uploadAllPhotosPrompt.
  ///
  /// In uz, this message translates to:
  /// **'Iltimos, barcha 6 ta hujjat va avtomobil rasmlarini yuklang!'**
  String get uploadAllPhotosPrompt;

  /// No description provided for @applicationSubmittedModalTitle.
  ///
  /// In uz, this message translates to:
  /// **'Arizangiz qabul qilindi!'**
  String get applicationSubmittedModalTitle;

  /// No description provided for @goToHomeAction.
  ///
  /// In uz, this message translates to:
  /// **'Bosh sahifaga o\'tish'**
  String get goToHomeAction;

  /// No description provided for @locationPermissionRequired.
  ///
  /// In uz, this message translates to:
  /// **'Joylashuv ruxsati talab qilinadi'**
  String get locationPermissionRequired;

  /// No description provided for @backgroundLocationRequired.
  ///
  /// In uz, this message translates to:
  /// **'Fonda joylashuv ruxsati talab qilinadi'**
  String get backgroundLocationRequired;

  /// No description provided for @enableLocationServices.
  ///
  /// In uz, this message translates to:
  /// **'GPS xizmatini yoqing'**
  String get enableLocationServices;

  /// No description provided for @notificationPermissionDisabled.
  ///
  /// In uz, this message translates to:
  /// **'Bildirishnomalar ruxsati o\'chirilgan'**
  String get notificationPermissionDisabled;

  /// No description provided for @cameraPermissionRequired.
  ///
  /// In uz, this message translates to:
  /// **'Kamera ruxsati talab qilinadi'**
  String get cameraPermissionRequired;

  /// No description provided for @photoPermissionRequired.
  ///
  /// In uz, this message translates to:
  /// **'Fotosuratlarga kirish ruxsati talab qilinadi'**
  String get photoPermissionRequired;

  /// No description provided for @permissionDenied.
  ///
  /// In uz, this message translates to:
  /// **'Ruxsat berilmadi'**
  String get permissionDenied;

  /// No description provided for @permissionPermanentlyDenied.
  ///
  /// In uz, this message translates to:
  /// **'Ruxsat butunlay rad etildi'**
  String get permissionPermanentlyDenied;

  /// No description provided for @openSettings.
  ///
  /// In uz, this message translates to:
  /// **'Sozlamalarni ochish'**
  String get openSettings;

  /// No description provided for @notNow.
  ///
  /// In uz, this message translates to:
  /// **'Keyinroq'**
  String get notNow;

  /// No description provided for @tryAgain.
  ///
  /// In uz, this message translates to:
  /// **'Qayta urinish'**
  String get tryAgain;

  /// No description provided for @continueAction.
  ///
  /// In uz, this message translates to:
  /// **'Davom etish'**
  String get continueAction;

  /// No description provided for @someFeaturesUnavailable.
  ///
  /// In uz, this message translates to:
  /// **'Ba\'zi funksiyalar to\'liq ishlamasligi mumkin'**
  String get someFeaturesUnavailable;

  /// No description provided for @accountBlockedTitle.
  ///
  /// In uz, this message translates to:
  /// **'Hisob bloklangan'**
  String get accountBlockedTitle;

  /// No description provided for @accountBlockedMessage.
  ///
  /// In uz, this message translates to:
  /// **'Hisobingiz ma\'muriyat tomonidan to\'xtatilgan yoki bloklangan. Qo\'llab-quvvatlash xizmati bilan bog\'laning.'**
  String get accountBlockedMessage;

  /// No description provided for @verificationRequiredTitle.
  ///
  /// In uz, this message translates to:
  /// **'Verifikatsiya talab qilinadi'**
  String get verificationRequiredTitle;

  /// No description provided for @verificationRequiredMessage.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmalarni qabul qilish uchun shaxsingiz va avtomobil hujjatlari tasdiqlanishi kerak.'**
  String get verificationRequiredMessage;

  /// No description provided for @appearance.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'rinish'**
  String get appearance;

  /// No description provided for @themeLightShort.
  ///
  /// In uz, this message translates to:
  /// **'Yorug\''**
  String get themeLightShort;

  /// No description provided for @themeDarkShort.
  ///
  /// In uz, this message translates to:
  /// **'Qorong\'i'**
  String get themeDarkShort;

  /// No description provided for @themeAuto.
  ///
  /// In uz, this message translates to:
  /// **'Avto'**
  String get themeAuto;

  /// No description provided for @themeLightHint.
  ///
  /// In uz, this message translates to:
  /// **'kunduzgi'**
  String get themeLightHint;

  /// No description provided for @themeDarkHint.
  ///
  /// In uz, this message translates to:
  /// **'tungi'**
  String get themeDarkHint;

  /// No description provided for @themeAutoHint.
  ///
  /// In uz, this message translates to:
  /// **'telefon bo\'yicha'**
  String get themeAutoHint;

  /// No description provided for @languageLatinScript.
  ///
  /// In uz, this message translates to:
  /// **'lotin yozuvi'**
  String get languageLatinScript;

  /// No description provided for @languageCyrillicScript.
  ///
  /// In uz, this message translates to:
  /// **'kirill yozuvi'**
  String get languageCyrillicScript;

  /// No description provided for @languageRussianHint.
  ///
  /// In uz, this message translates to:
  /// **'rus tili'**
  String get languageRussianHint;

  /// No description provided for @menuTitle.
  ///
  /// In uz, this message translates to:
  /// **'Menyu'**
  String get menuTitle;

  /// No description provided for @menuSettingsHint.
  ///
  /// In uz, this message translates to:
  /// **'Til, ko\'rinish'**
  String get menuSettingsHint;

  /// No description provided for @menuHelp.
  ///
  /// In uz, this message translates to:
  /// **'Yordam'**
  String get menuHelp;

  /// No description provided for @menuHelpHint.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'llab-quvvatlash'**
  String get menuHelpHint;

  /// No description provided for @menuLogout.
  ///
  /// In uz, this message translates to:
  /// **'Chiqish'**
  String get menuLogout;

  /// No description provided for @mapMyLocation.
  ///
  /// In uz, this message translates to:
  /// **'Joylashuvimga qaytish'**
  String get mapMyLocation;

  /// No description provided for @mapNotifications.
  ///
  /// In uz, this message translates to:
  /// **'Bildirishnomalar'**
  String get mapNotifications;

  /// No description provided for @driverTodayEarnings.
  ///
  /// In uz, this message translates to:
  /// **'Bugungi daromad'**
  String get driverTodayEarnings;

  /// No description provided for @driverTodayPill.
  ///
  /// In uz, this message translates to:
  /// **'Bugun: {amount}'**
  String driverTodayPill(String amount);

  /// No description provided for @menuEarnings.
  ///
  /// In uz, this message translates to:
  /// **'Daromad'**
  String get menuEarnings;

  /// No description provided for @menuEarningsHint.
  ///
  /// In uz, this message translates to:
  /// **'Kun, hafta, oy'**
  String get menuEarningsHint;

  /// No description provided for @menuTripHistory.
  ///
  /// In uz, this message translates to:
  /// **'Safarlar tarixi'**
  String get menuTripHistory;

  /// No description provided for @menuProfileCar.
  ///
  /// In uz, this message translates to:
  /// **'Profil va mashina'**
  String get menuProfileCar;

  /// No description provided for @menuProfileCarHint.
  ///
  /// In uz, this message translates to:
  /// **'Hujjatlar holati'**
  String get menuProfileCarHint;

  /// No description provided for @driverLastRoute.
  ///
  /// In uz, this message translates to:
  /// **'Oxirgi yo\'nalish'**
  String get driverLastRoute;

  /// No description provided for @driverOpenAgain.
  ///
  /// In uz, this message translates to:
  /// **'Bugun ham ochish'**
  String get driverOpenAgain;

  /// No description provided for @driverOpenRoute.
  ///
  /// In uz, this message translates to:
  /// **'Yo\'nalish ochish'**
  String get driverOpenRoute;

  /// No description provided for @driverNoRouteYet.
  ///
  /// In uz, this message translates to:
  /// **'Yo\'nalish oching — yo\'lovchilar sizni ko\'radi va joy band qiladi'**
  String get driverNoRouteYet;

  /// No description provided for @driverChangeTimePrice.
  ///
  /// In uz, this message translates to:
  /// **'Vaqt yoki narxni o\'zgartirish'**
  String get driverChangeTimePrice;

  /// No description provided for @driverOnline.
  ///
  /// In uz, this message translates to:
  /// **'Liniyada'**
  String get driverOnline;

  /// No description provided for @driverOffline.
  ///
  /// In uz, this message translates to:
  /// **'Liniyadan tashqari'**
  String get driverOffline;

  /// No description provided for @driverDocsPending.
  ///
  /// In uz, this message translates to:
  /// **'Hujjatlaringiz tekshirilmoqda'**
  String get driverDocsPending;

  /// No description provided for @driverDocsAction.
  ///
  /// In uz, this message translates to:
  /// **'Holatni ko\'rish'**
  String get driverDocsAction;

  /// No description provided for @driverActiveTrip.
  ///
  /// In uz, this message translates to:
  /// **'Sizda faol safar bor'**
  String get driverActiveTrip;

  /// No description provided for @statRating.
  ///
  /// In uz, this message translates to:
  /// **'reyting'**
  String get statRating;

  /// No description provided for @statTrips.
  ///
  /// In uz, this message translates to:
  /// **'safar'**
  String get statTrips;

  /// No description provided for @statInApp.
  ///
  /// In uz, this message translates to:
  /// **'ilovada'**
  String get statInApp;

  /// No description provided for @statMonths.
  ///
  /// In uz, this message translates to:
  /// **'{count} oy'**
  String statMonths(int count);

  /// No description provided for @dateToday.
  ///
  /// In uz, this message translates to:
  /// **'Bugun'**
  String get dateToday;

  /// No description provided for @dateYesterday.
  ///
  /// In uz, this message translates to:
  /// **'Kecha'**
  String get dateYesterday;

  /// No description provided for @histCompleted.
  ///
  /// In uz, this message translates to:
  /// **'Yakunlandi'**
  String get histCompleted;

  /// No description provided for @histCancelled.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilindi'**
  String get histCancelled;

  /// No description provided for @histActive.
  ///
  /// In uz, this message translates to:
  /// **'Faol'**
  String get histActive;

  /// No description provided for @histPassengers.
  ///
  /// In uz, this message translates to:
  /// **'{count} yo\'lovchi'**
  String histPassengers(int count);

  /// No description provided for @profileCar.
  ///
  /// In uz, this message translates to:
  /// **'Mashina'**
  String get profileCar;

  /// No description provided for @profileDocuments.
  ///
  /// In uz, this message translates to:
  /// **'Hujjatlar'**
  String get profileDocuments;

  /// No description provided for @docLicense.
  ///
  /// In uz, this message translates to:
  /// **'Haydovchilik guvohnomasi'**
  String get docLicense;

  /// No description provided for @docVehicle.
  ///
  /// In uz, this message translates to:
  /// **'Texnik pasport va mashina rasmlari'**
  String get docVehicle;

  /// No description provided for @docApproved.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlangan'**
  String get docApproved;

  /// No description provided for @docPending.
  ///
  /// In uz, this message translates to:
  /// **'Tekshirilmoqda'**
  String get docPending;

  /// No description provided for @docRejected.
  ///
  /// In uz, this message translates to:
  /// **'Qayta yuboring'**
  String get docRejected;

  /// No description provided for @carFourSeats.
  ///
  /// In uz, this message translates to:
  /// **'4 o\'rinli yengil mashina'**
  String get carFourSeats;

  /// No description provided for @profilePhone.
  ///
  /// In uz, this message translates to:
  /// **'Telefon'**
  String get profilePhone;

  /// No description provided for @dpOpenRoute.
  ///
  /// In uz, this message translates to:
  /// **'Yo\'nalish ochish'**
  String get dpOpenRoute;

  /// No description provided for @dpToCity.
  ///
  /// In uz, this message translates to:
  /// **'Shaharga'**
  String get dpToCity;

  /// No description provided for @dpToHome.
  ///
  /// In uz, this message translates to:
  /// **'Uyga'**
  String get dpToHome;

  /// No description provided for @dpDepartureTime.
  ///
  /// In uz, this message translates to:
  /// **'Jo\'nash vaqti'**
  String get dpDepartureTime;

  /// No description provided for @dpWhenFull.
  ///
  /// In uz, this message translates to:
  /// **'To\'lsa'**
  String get dpWhenFull;

  /// No description provided for @dpPricePerSeat.
  ///
  /// In uz, this message translates to:
  /// **'Narx · 1 o\'rin (20–30 ming)'**
  String get dpPricePerSeat;

  /// No description provided for @dpFourSeats.
  ///
  /// In uz, this message translates to:
  /// **'Mashina har doim 4 o\'rinli'**
  String get dpFourSeats;

  /// No description provided for @dpFullCarTotal.
  ///
  /// In uz, this message translates to:
  /// **'4 o\'rin to\'lsa: {amount}'**
  String dpFullCarTotal(String amount);

  /// No description provided for @dpOpen.
  ///
  /// In uz, this message translates to:
  /// **'Yo\'nalishni ochish'**
  String get dpOpen;

  /// No description provided for @dpNewRequest.
  ///
  /// In uz, this message translates to:
  /// **'YANGI SO\'ROV'**
  String get dpNewRequest;

  /// No description provided for @dpPeople.
  ///
  /// In uz, this message translates to:
  /// **'{count} kishi'**
  String dpPeople(int count);

  /// No description provided for @dpToPassenger.
  ///
  /// In uz, this message translates to:
  /// **'yo\'lovchigacha'**
  String get dpToPassenger;

  /// No description provided for @dpAccept.
  ///
  /// In uz, this message translates to:
  /// **'Qabul qilish'**
  String get dpAccept;

  /// No description provided for @dpSkip.
  ///
  /// In uz, this message translates to:
  /// **'O\'tkazib yuborish'**
  String get dpSkip;

  /// No description provided for @dpPickupTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yo\'lovchilarni olish'**
  String get dpPickupTitle;

  /// No description provided for @dpSeatsTaken.
  ///
  /// In uz, this message translates to:
  /// **'{taken} / {total} o\'rin band'**
  String dpSeatsTaken(int taken, int total);

  /// No description provided for @dpPickedUp.
  ///
  /// In uz, this message translates to:
  /// **'olindi'**
  String get dpPickedUp;

  /// No description provided for @dpSlidePickedUp.
  ///
  /// In uz, this message translates to:
  /// **'Surib tasdiqlang: {name}ni oldim'**
  String dpSlidePickedUp(String name);

  /// No description provided for @dpDepart.
  ///
  /// In uz, this message translates to:
  /// **'Jo\'nash'**
  String get dpDepart;

  /// No description provided for @dpWaitMore.
  ///
  /// In uz, this message translates to:
  /// **'Yana kutish'**
  String get dpWaitMore;

  /// No description provided for @dpNoPassengersYet.
  ///
  /// In uz, this message translates to:
  /// **'Hali yo\'lovchi yo\'q. Yangi so\'rovlar shu yerda chiqadi.'**
  String get dpNoPassengersYet;

  /// No description provided for @dpOnTheWay.
  ///
  /// In uz, this message translates to:
  /// **'Yo\'ldasiz'**
  String get dpOnTheWay;

  /// No description provided for @dpCollected.
  ///
  /// In uz, this message translates to:
  /// **'Yig\'ildi'**
  String get dpCollected;

  /// No description provided for @dpOpenNavigator.
  ///
  /// In uz, this message translates to:
  /// **'Navigatorda ochish'**
  String get dpOpenNavigator;

  /// No description provided for @dpSlideArrived.
  ///
  /// In uz, this message translates to:
  /// **'Surib tasdiqlang: Yetib keldik'**
  String get dpSlideArrived;

  /// No description provided for @dpTripDone.
  ///
  /// In uz, this message translates to:
  /// **'Safar yakunlandi'**
  String get dpTripDone;

  /// No description provided for @dpEarned.
  ///
  /// In uz, this message translates to:
  /// **'Bu safar: {amount}'**
  String dpEarned(String amount);

  /// No description provided for @dpReturnTitle.
  ///
  /// In uz, this message translates to:
  /// **'Qaytishni ochasizmi?'**
  String get dpReturnTitle;

  /// No description provided for @dpOpenReturn.
  ///
  /// In uz, this message translates to:
  /// **'Qaytishni ochish'**
  String get dpOpenReturn;

  /// No description provided for @dpNotToday.
  ///
  /// In uz, this message translates to:
  /// **'Bugun qaytmayman'**
  String get dpNotToday;

  /// No description provided for @dpActionFailed.
  ///
  /// In uz, this message translates to:
  /// **'Amal bajarilmadi. Internetni tekshirib, qayta urinib ko\'ring.'**
  String get dpActionFailed;

  /// No description provided for @dpCall.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'ng\'iroq'**
  String get dpCall;

  /// No description provided for @dpPassenger.
  ///
  /// In uz, this message translates to:
  /// **'Yo\'lovchi'**
  String get dpPassenger;

  /// No description provided for @dpPickupPoint.
  ///
  /// In uz, this message translates to:
  /// **'Olib ketish joyi'**
  String get dpPickupPoint;

  /// No description provided for @daBadge.
  ///
  /// In uz, this message translates to:
  /// **'HAYDOVCHI'**
  String get daBadge;

  /// No description provided for @daPhoneTitle.
  ///
  /// In uz, this message translates to:
  /// **'Haydovchi sifatida kirish'**
  String get daPhoneTitle;

  /// No description provided for @daPhoneBody.
  ///
  /// In uz, this message translates to:
  /// **'Telefon raqamingizga SMS kod yuboramiz'**
  String get daPhoneBody;

  /// No description provided for @daGetCode.
  ///
  /// In uz, this message translates to:
  /// **'Kod olish'**
  String get daGetCode;

  /// No description provided for @daTermsNote.
  ///
  /// In uz, this message translates to:
  /// **'Davom etib, foydalanish shartlariga rozilik bildirasiz'**
  String get daTermsNote;

  /// No description provided for @daPhoneInvalid.
  ///
  /// In uz, this message translates to:
  /// **'To\'g\'ri telefon raqam kiriting (masalan: 93 456 78 90)'**
  String get daPhoneInvalid;

  /// No description provided for @daWithPassword.
  ///
  /// In uz, this message translates to:
  /// **'Parol bilan kirish'**
  String get daWithPassword;

  /// No description provided for @daOtpTitle.
  ///
  /// In uz, this message translates to:
  /// **'Kodni kiriting'**
  String get daOtpTitle;

  /// No description provided for @daOtpSentTo.
  ///
  /// In uz, this message translates to:
  /// **'{phone} raqamiga yuborildi'**
  String daOtpSentTo(String phone);

  /// No description provided for @daChange.
  ///
  /// In uz, this message translates to:
  /// **'O\'zgartirish'**
  String get daChange;

  /// No description provided for @daResendIn.
  ///
  /// In uz, this message translates to:
  /// **'Qayta yuborish: {time}'**
  String daResendIn(String time);

  /// No description provided for @daResend.
  ///
  /// In uz, this message translates to:
  /// **'Kodni qayta yuborish'**
  String get daResend;

  /// No description provided for @daOtpAuto.
  ///
  /// In uz, this message translates to:
  /// **'Yangi raqam — hujjatlarga, ro\'yxatdan o\'tgan haydovchi — bosh ekranga'**
  String get daOtpAuto;

  /// No description provided for @dpPendingBanner.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta yangi so\'rov javob kutmoqda'**
  String dpPendingBanner(int count);

  /// No description provided for @dpPendingAction.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'rish'**
  String get dpPendingAction;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'uz':
      {
        switch (locale.scriptCode) {
          case 'Cyrl':
            return AppLocalizationsUzCyrl();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
