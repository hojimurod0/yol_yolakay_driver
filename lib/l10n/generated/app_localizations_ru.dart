// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Йўл-Йўлакай';

  @override
  String get appTagline => 'Удобные и быстрые междугородние поездки';

  @override
  String get skip => 'Пропустить';

  @override
  String get next => 'Далее';

  @override
  String get getStarted => 'Начать';

  @override
  String get continueText => 'Продолжить';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';

  @override
  String get edit => 'Редактировать';

  @override
  String get delete => 'Удалить';

  @override
  String get close => 'Закрыть';

  @override
  String get search => 'Поиск';

  @override
  String get filter => 'Фильтр';

  @override
  String get sort => 'Сортировка';

  @override
  String get clear => 'Очистить';

  @override
  String get apply => 'Применить';

  @override
  String get back => 'Назад';

  @override
  String get retry => 'Повторить';

  @override
  String get done => 'Готово';

  @override
  String get onboarding1Title => 'Междугородние поездки стали проще';

  @override
  String get onboarding1Desc =>
      'Находите надежные и комфортные такси в любой город Узбекистана.';

  @override
  String get onboarding2Title => 'Комфортные и безопасные авто';

  @override
  String get onboarding2Desc =>
      'Путешествуйте безопасно с опытными и проверенными водителями.';

  @override
  String get onboarding3Title => 'Бронируйте места легко';

  @override
  String get onboarding3Desc =>
      'Выберите удобное время, цену и комфорт и забронируйте за пару шагов.';

  @override
  String get onboarding4Title => 'Отслеживайте поездку онлайн';

  @override
  String get onboarding4Desc =>
      'Смотрите местоположение водителя на карте и будьте в курсе деталей поездки.';

  @override
  String get welcomeTitle => 'Добро пожаловать в Йўл-Йўлакай!';

  @override
  String get welcomeSubtitle => 'Ваш надежный спутник в междугородних поездках';

  @override
  String get loginOrRegister => 'Вход или регистрация';

  @override
  String get enterPhoneNumber => 'Введите ваш номер телефона';

  @override
  String get phoneLabel => 'Номер телефона';

  @override
  String get phoneHint => '90 123 45 67';

  @override
  String get sendOtp => 'Отправить код';

  @override
  String otpSentTo(String phone) {
    return 'Код подтверждения отправлен на номер $phone';
  }

  @override
  String get enterOtp => 'Введите проверочный код';

  @override
  String get resendOtp => 'Отправить код повторно';

  @override
  String resendIn(int seconds) {
    return 'Повторная отправка через $seconds сек';
  }

  @override
  String get createProfileTitle => 'Заполните профиль';

  @override
  String get createProfileSubtitle =>
      'Укажите ваши данные, чтобы водитель мог с вами связаться';

  @override
  String get firstName => 'Имя';

  @override
  String get firstNameHint => 'Введите ваше имя';

  @override
  String get lastName => 'Фамилия';

  @override
  String get lastNameHint => 'Введите вашу фамилию';

  @override
  String get email => 'Эл. почта (необязательно)';

  @override
  String get emailHint => 'почта@mail.ru';

  @override
  String get completeRegistration => 'Завершить регистрацию';

  @override
  String get navHome => 'Главная';

  @override
  String get navTrips => 'Поездки';

  @override
  String get navNotifications => 'Уведомления';

  @override
  String get navProfile => 'Профиль';

  @override
  String greeting(String name) {
    return 'Привет, $name!';
  }

  @override
  String get whereToGo => 'Куда вы хотите поехать?';

  @override
  String get from => 'Откуда';

  @override
  String get to => 'Куда';

  @override
  String get selectDepartureCity => 'Выберите город отправления';

  @override
  String get selectDestinationCity => 'Выберите город назначения';

  @override
  String get travelDate => 'Дата';

  @override
  String get today => 'Сегодня';

  @override
  String get tomorrow => 'Завтра';

  @override
  String get passengerCount => 'Количество пассажиров';

  @override
  String passengers(int count) {
    return '$count пасс.';
  }

  @override
  String get searchRides => 'Найти поездки';

  @override
  String get swapCities => 'Поменять города местами';

  @override
  String get recentSearches => 'Недавние поиски';

  @override
  String get popularRoutes => 'Популярные маршруты';

  @override
  String get savedRoutes => 'Сохраненные маршруты';

  @override
  String get noRecentSearches => 'Нет недавних поисков';

  @override
  String get selectCityTitle => 'Выберите город';

  @override
  String get searchCityHint => 'Название города...';

  @override
  String get popularCities => 'Популярные города';

  @override
  String get allCities => 'Все города';

  @override
  String get currentLocation => 'Текущее местоположение';

  @override
  String get availableRides => 'Доступные поездки';

  @override
  String ridesFound(int count) {
    return 'Найдено поездок: $count';
  }

  @override
  String get noRidesFound => 'Поездки не найдены';

  @override
  String get noRidesDesc => 'Попробуйте выбрать другую дату или маршрут';

  @override
  String get sortCheapest => 'Сначала дешевые';

  @override
  String get sortEarliest => 'Сначала ранние';

  @override
  String get sortFastest => 'Самые быстрые';

  @override
  String get sortRating => 'Высокий рейтинг';

  @override
  String get filterPrice => 'По цене';

  @override
  String get filterCarType => 'Тип автомобиля';

  @override
  String get filterSeats => 'Количество мест';

  @override
  String get filterRating => 'Рейтинг водителя';

  @override
  String pricePerSeat(String price) {
    return '$price / место';
  }

  @override
  String seatsAvailable(int available, int total) {
    return '$available / $total свободно';
  }

  @override
  String durationApprox(String hours) {
    return '~$hours ч.';
  }

  @override
  String get rideDetails => 'Детали поездки';

  @override
  String get schedule => 'Расписание';

  @override
  String get departureTime => 'Время отправления';

  @override
  String get estimatedArrival => 'Примерное прибытие';

  @override
  String get driver => 'Водитель';

  @override
  String get verifiedDriver => 'Проверенный водитель';

  @override
  String completedTripsCount(int count) {
    return '$count успешных поездок';
  }

  @override
  String get vehicle => 'Автомобиль';

  @override
  String get pickupLocation => 'Место посадки';

  @override
  String get dropoffLocation => 'Место высадки';

  @override
  String get amenities => 'Удобства';

  @override
  String get amenityAc => 'Кондиционер';

  @override
  String get amenityLuggage => 'Большой багажник';

  @override
  String get amenityWifi => 'Вай-фай';

  @override
  String get amenitySmoking => 'Курение запрещено';

  @override
  String get bookSeat => 'Забронировать место';

  @override
  String get contactDriver => 'Связаться с водителем';

  @override
  String get shareTrip => 'Поделиться поездкой';

  @override
  String get bookingTitle => 'Бронирование';

  @override
  String get stepSelectSeats => '1. Количество мест';

  @override
  String get stepPassengerInfo => '2. Данные пассажиров';

  @override
  String get stepPickup => '3. Точка посадки';

  @override
  String get stepReview => '4. Проверка';

  @override
  String selectedSeats(int count) {
    return 'Выбрано мест: $count';
  }

  @override
  String get totalPrice => 'Итого к оплате';

  @override
  String get cancellationPolicy => 'Правила отмены';

  @override
  String get cancellationPolicyDesc =>
      'Бесплатная отмена за 2 часа до начала поездки.';

  @override
  String get confirmBooking => 'Подтвердить бронирование';

  @override
  String get paymentMethod => 'Способ оплаты';

  @override
  String get paymentCash => 'Наличными водителю';

  @override
  String get paymentClick => 'Оплата через Клик';

  @override
  String get paymentPayme => 'Оплата через Пайме';

  @override
  String get paymentUzum => 'Оплата через Узум Банк';

  @override
  String get bookingSuccessTitle => 'Успешно забронировано!';

  @override
  String get bookingSuccessDesc =>
      'Ваш заказ принят. Водитель свяжется с вами перед отправлением.';

  @override
  String get bookingId => 'Номер брони';

  @override
  String get viewTrip => 'Посмотреть поездку';

  @override
  String get backToHome => 'На главную';

  @override
  String get tabUpcoming => 'Предстоящие';

  @override
  String get tabActive => 'Активные';

  @override
  String get tabCompleted => 'Завершенные';

  @override
  String get tabCancelled => 'Отмененные';

  @override
  String get noTripsTitle => 'История поездок пуста';

  @override
  String get noTripsDesc => 'В этом разделе пока нет поездок.';

  @override
  String get tripDetails => 'Детали поездки';

  @override
  String get trackingTitle => 'Отслеживание поездки';

  @override
  String get statusBookingConfirmed => 'Бронь подтверждена';

  @override
  String get statusDriverPreparing => 'Водитель готовится к выезду';

  @override
  String get statusDriverArrived => 'Водитель прибыл на место';

  @override
  String get statusPassengerPickedUp => 'Пассажир в машине';

  @override
  String get statusTripStarted => 'Поездка началась';

  @override
  String get statusNearDestination => 'Подъезжаем к месту назначения';

  @override
  String get statusTripCompleted => 'Поездка завершена';

  @override
  String get notificationsTitle => 'Уведомления';

  @override
  String get markAllAsRead => 'Прочитать все';

  @override
  String get noNotificationsTitle => 'Нет уведомлений';

  @override
  String get noNotificationsDesc =>
      'Здесь появятся новые оповещения о ваших поездках.';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get editProfile => 'Редактировать профиль';

  @override
  String get personalInfo => 'Личная информация';

  @override
  String get myActivity => 'Моя активность';

  @override
  String get totalTrips => 'Всего поездок';

  @override
  String get savedPlaces => 'Сохраненные адреса';

  @override
  String get homePlace => 'Дом';

  @override
  String get workPlace => 'Работа';

  @override
  String get addPlace => 'Добавить адрес';

  @override
  String get settings => 'Настройки';

  @override
  String get language => 'Язык';

  @override
  String get theme => 'Тема оформления';

  @override
  String get themeSystem => 'Системная';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Темная';

  @override
  String get support => 'Помощь и поддержка';

  @override
  String get helpCenter => 'Центр помощи';

  @override
  String get faq => 'Частые вопросы';

  @override
  String get contactSupport => 'Служба поддержки';

  @override
  String get reportProblem => 'Сообщить о проблеме';

  @override
  String get termsOfService => 'Условия использования';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get logout => 'Выйти';

  @override
  String get logoutConfirm => 'Вы уверены, что хотите выйти из аккаунта?';

  @override
  String get deleteAccount => 'Удалить аккаунт';

  @override
  String get ratingTitle => 'Как прошла поездка?';

  @override
  String get ratingSubtitle => 'Оцените поездку и помогите улучшить сервис';

  @override
  String get ratingFeedbackHint => 'Оставьте отзыв (необязательно)...';

  @override
  String get submitRating => 'Отправить оценку';

  @override
  String get tagCleanCar => 'Чистый салон';

  @override
  String get tagFriendlyDriver => 'Вежливый водитель';

  @override
  String get tagOnTime => 'Вовремя';

  @override
  String get tagComfortable => 'Комфортно';

  @override
  String get tagSafeDriving => 'Безопасное вождение';

  @override
  String get cancelTripTitle => 'Отмена поездки';

  @override
  String get cancelTripDesc => 'Вы уверены, что хотите отменить эту поездку?';

  @override
  String get cancelReason => 'Причина отмены';

  @override
  String get reasonChangePlans => 'Изменились планы';

  @override
  String get reasonFoundAnother => 'Нашел другой транспорт';

  @override
  String get reasonDriverAsked => 'Водитель попросил отменить';

  @override
  String get reasonOther => 'Другая причина';

  @override
  String get confirmCancel => 'Подтвердить отмену';

  @override
  String get offlineTitle => 'Нет подключения к интернету';

  @override
  String get offlineDesc =>
      'Пожалуйста, проверьте подключение к сети и попробуйте снова.';

  @override
  String get errorGeneric =>
      'Произошла непредвиденная ошибка. Попробуйте еще раз.';

  @override
  String get errorPhoneInvalid => 'Неверный формат номера телефона';

  @override
  String get errorOtpInvalid => 'Неверный код подтверждения';

  @override
  String get errorOtpExpired => 'Срок действия кода истек';

  @override
  String get onboardingSlide1Badge => 'Междугородние поездки';

  @override
  String get onboardingSlide1Title =>
      'Удобные и быстрые поездки\nпо всему Узбекистану';

  @override
  String get onboardingSlide1Desc =>
      'Надежные такси по Ташкенту, Самарканду, Андижану, Фергане, Бухаре и всем регионам страны.';

  @override
  String get onboardingSlide2Badge => 'Спутниковая карта';

  @override
  String get onboardingSlide2Title => 'Легко выбирайте адрес\nпрямо на карте';

  @override
  String get onboardingSlide2Desc =>
      'Выбирайте любые города и районы Узбекистана со спутника и сразу видите маршрут и расстояние.';

  @override
  String get onboardingSlide3Badge => 'Доступно и прозрачно';

  @override
  String get onboardingSlide3Title => 'Прозрачные цены и\nпроверенные водители';

  @override
  String get onboardingSlide3Desc =>
      'Справедливая цена за километр, комфортные автомобили и гарантия безопасной поездки.';

  @override
  String get satelliteMode => 'Спутник';

  @override
  String get standardMode => 'Обычная карта';

  @override
  String get searchCityDistrictHint => 'Поиск города или района...';

  @override
  String get allRegions => 'Все регионы';

  @override
  String get tashkentRegion => 'Ташкент';

  @override
  String get ferganaValley => 'Ферганская долина';

  @override
  String get samarkandRegion => 'Самарканд';

  @override
  String get bukharaRegion => 'Бухара';

  @override
  String get southernRegion => 'Кашкадарья / Сурхандарья';

  @override
  String get westernRegion => 'Хорезм / Каракалпакстан';

  @override
  String get notificationsAll => 'Все';

  @override
  String get notificationsTrips => 'Поездки';

  @override
  String get notificationsPromo => 'Акции';

  @override
  String get notificationsSystem => 'Система';

  @override
  String get clearAll => 'Очистить всё';

  @override
  String get phoneCall => 'Позвонить';

  @override
  String tripLinkCopied(String route) {
    return 'Ссылка на поездку скопирована: $route';
  }

  @override
  String callingDriver(String phone) {
    return 'Звонок водителю: $phone';
  }

  @override
  String get appVersion => 'Версия приложения';

  @override
  String get selectLanguage => 'Выберите язык';

  @override
  String get selectTheme => 'Выберите тему';

  @override
  String get themeDarkDesc => 'Темная тема, бережет глаза';

  @override
  String get themeLightDesc => 'Светлая и яркая тема';

  @override
  String get themeSystemDesc => 'Автоматически по системе';

  @override
  String get comfortAndSafety => 'Комфорт и безопасность';

  @override
  String get statusPending => 'Ожидается';

  @override
  String get statusApproved => 'Одобрено';

  @override
  String get statusRejected => 'Отклонено';

  @override
  String get statusCompleted => 'Завершено';

  @override
  String get statusCancelled => 'Отменено';

  @override
  String get statusActive => 'Активный';

  @override
  String get statusInProgress => 'В пути';

  @override
  String get statusArrived => 'Прибыл';

  @override
  String get statusAccepted => 'Принят';

  @override
  String get statusOnline => 'На линии';

  @override
  String get statusOffline => 'Не на линии';

  @override
  String get statusOnTrip => 'В рейсе';

  @override
  String get driverHomeTitle => 'Yo\'l-Yo\'lakay Водитель';

  @override
  String get shiftOnlineTitle => 'Вы на смене (Онлайн)';

  @override
  String get shiftOfflineTitle => 'Смена выключена (Офлайн)';

  @override
  String get shiftOnlineSubtitle => 'Вы готовы принимать заказы';

  @override
  String get shiftOfflineSubtitle => 'Включите смену, чтобы получать заказы';

  @override
  String get startShift => 'Начать смену';

  @override
  String get endShift => 'Завершить смену';

  @override
  String get todayPerformance => 'Показатели за сегодня';

  @override
  String get dailyLabel => 'За день';

  @override
  String get todayEarnings => 'Дневной заработок';

  @override
  String get completedTrips => 'Завершенные поездки';

  @override
  String get onlineHours => 'Время на линии';

  @override
  String get acceptanceRate => 'Уровень принятия';

  @override
  String get walletBalance => 'Баланс кошелька';

  @override
  String get topUpBalance => 'Пополнить баланс';

  @override
  String get activeTaxiOrderBanner => 'Есть активный заказ такси';

  @override
  String get activeIntercityTripBanner => 'Есть активная междугородняя поездка';

  @override
  String get viewDetails => 'Смотреть';

  @override
  String get radarOrdersTitle => 'Радар заказов';

  @override
  String get noRadarOrdersTitle => 'Пока нет новых заказов';

  @override
  String get noRadarOrdersDesc =>
      'Новые заказы появятся здесь и прозвучит сигнал.';

  @override
  String get orderIncoming => 'Новый заказ такси';

  @override
  String get acceptOrder => 'Принять';

  @override
  String get declineOrder => 'Отклонить';

  @override
  String get driverAssignedStatus => 'Вы движетесь к пассажиру';

  @override
  String get driverArrivedStatus => 'Вы прибыли. Ожидание пассажира';

  @override
  String get finishTrip => 'Завершить поездку';

  @override
  String get finalAmountPrompt => 'Итоговая сумма (в сумах):';

  @override
  String get cancelOrderPrompt => 'Отменить заказ';

  @override
  String netEarningsLabel(String amount) {
    return 'Ваш чистый доход: $amount';
  }

  @override
  String commissionDeductedLabel(String amount) {
    return 'Удержанная комиссия: $amount';
  }

  @override
  String get backToRadarAction => 'Вернуться в радар';

  @override
  String get markArrived => 'Я прибыл';

  @override
  String get startTrip => 'Начать поездку';

  @override
  String get callPassenger => 'Позвонить';

  @override
  String get intercityTripsTitle => 'Междугородние поездки';

  @override
  String get publishTrip => 'Создать поездку';

  @override
  String get emptyTripsHistory => 'История поездок пуста';

  @override
  String get emptyTripsActiveDesc =>
      'У вас пока нет активных поездок. Вы можете создать новую поездку.';

  @override
  String get emptyTripsGeneralDesc => 'В этом разделе нет поездок.';

  @override
  String get tripDetailsTitle => 'Детали поездки';

  @override
  String get createTripTitle => 'Опубликовать новую поездку';

  @override
  String get departureCity => 'Город отправления';

  @override
  String get destinationCity => 'Город прибытия';

  @override
  String get totalSeats => 'Количество мест';

  @override
  String get tripAmenities => 'Удобства';

  @override
  String get hasAc => 'Кондиционер';

  @override
  String get allowLuggage => 'Багаж';

  @override
  String get allowSmoking => 'Разрешено курить';

  @override
  String get womenOnly => 'Только для женщин';

  @override
  String get publishAction => 'Опубликовать поездку';

  @override
  String get tripPublishedSuccess => 'Поездка успешно опубликована!';

  @override
  String get walletAndEarnings => 'Кошелек и доходы';

  @override
  String get currentBalance => 'Текущий баланс';

  @override
  String get mainWallet => 'Основной кошелек';

  @override
  String get lowBalanceWarning =>
      'Ваш баланс ниже минимума. Пополните счет для приема заказов.';

  @override
  String get depositTitle => 'Пополнение счета';

  @override
  String get selectPaymentSystem => 'Выберите платежную систему:';

  @override
  String get amountInSum => 'Сумма (в сумах):';

  @override
  String get todayTab => 'Сегодня';

  @override
  String get weeklyTab => 'Неделя';

  @override
  String get monthlyTab => 'Месяц';

  @override
  String get totalEarnings => 'Общий доход';

  @override
  String get tripsCount => 'Количество поездок';

  @override
  String get totalDistance => 'Расстояние';

  @override
  String get totalHours => 'Время онлайн';

  @override
  String get dailyChart => 'График за день';

  @override
  String get transactionHistory => 'История транзакций';

  @override
  String get noTransactions => 'Транзакций пока нет';

  @override
  String get noTransactionsDesc =>
      'Здесь будут отображаться поездки и пополнения.';

  @override
  String get paymentProcessing => 'Процесс оплаты';

  @override
  String get paymentVerifying => 'Проверка через сервер...';

  @override
  String get verifyPayment => 'Проверить оплату';

  @override
  String get reopenPayment => 'Открыть снова';

  @override
  String get paymentSuccessMessage =>
      'Оплата успешно подтверждена и баланс обновлен!';

  @override
  String get paymentPendingMessage =>
      'Оплата еще не подтверждена. Попробуйте еще раз или подождите немного.';

  @override
  String get driverProfileTitle => 'Профиль водителя';

  @override
  String get vehicleInfo => 'Данные автомобиля';

  @override
  String get documentsVerification => 'Верификация документов';

  @override
  String get logoutConfirmTitle => 'Выход из системы';

  @override
  String get logoutConfirmDesc => 'Вы действительно хотите выйти из аккаунта?';

  @override
  String get logoutAction => 'Выйти';

  @override
  String tripsCountPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count поездок',
      few: '$count поездки',
      one: '1 поездка',
    );
    return '$_temp0';
  }

  @override
  String seatsCountPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count мест',
      few: '$count места',
      one: '1 место',
    );
    return '$_temp0';
  }

  @override
  String get refresh => 'Обновить';

  @override
  String get daily => 'Дневной';

  @override
  String get topUp => 'Пополнить';

  @override
  String get genericErrorMessage => 'Произошла ошибка';

  @override
  String fieldRequiredError(String field) {
    return 'Поле $field обязательно для заполнения';
  }

  @override
  String get homeTitle => 'Yo\'l-Yo\'lakay Водитель';

  @override
  String get todayStats => 'Показатели за сегодня';

  @override
  String get statEarnings => 'Доход';

  @override
  String get statTripsCount => 'Количество поездок';

  @override
  String get statOnlineTime => 'Время онлайн';

  @override
  String get statAcceptanceRate => 'Уровень принятия';

  @override
  String get activeTaxiOrderAlert => 'У вас есть активный заказ такси!';

  @override
  String get activeTaxiOrderDesc => 'Нажмите для перехода к поездке';

  @override
  String get activeIntercityTripAlert =>
      'У вас есть активная междугородняя поездка!';

  @override
  String get activeIntercityTripDesc => 'Нажмите для просмотра деталей';

  @override
  String tripsCountUnit(int count) {
    return '$count';
  }

  @override
  String hours(int count) {
    return '$count ч.';
  }

  @override
  String get tripPrice => 'Стоимость поездки:';

  @override
  String get arrivedAtPickupAction => 'Я на месте';

  @override
  String get startRideAction => 'Поехали (Начать поездку)';

  @override
  String get completeRideAction => 'Завершить поездку';

  @override
  String get cancelOrderAction => 'Отменить заказ';

  @override
  String get completeRideModalTitle => 'Завершить поездку';

  @override
  String get finalPaymentAmountLabel => 'Итоговая сумма оплаты (в сумах):';

  @override
  String get completeAction => 'Завершить';

  @override
  String get cancelReasonPassengerNoShow => 'Пассажир не вышел на связь';

  @override
  String get cancelReasonPassengerTookAnother =>
      'Пассажир уехал на другой машине';

  @override
  String get cancelReasonCarIssue => 'Неисправность автомобиля';

  @override
  String get cancelReasonOther => 'Другая причина';

  @override
  String acceptWithTimer(int seconds) {
    return 'Принять ($seconds с)';
  }

  @override
  String get tripsPageTitle => 'Междугородние поездки';

  @override
  String get createTripAction => 'Создать поездку';

  @override
  String get noActiveTripsDesc =>
      'У вас пока нет активных поездок. Вы можете создать новую поездку.';

  @override
  String get noTripsHistoryDesc => 'В этом разделе нет поездок.';

  @override
  String seatsDetail(int booked, int available, int total) {
    return 'Места: $booked занято, $available свободно (Всего: $total)';
  }

  @override
  String passengersCount(int count) {
    return 'Пассажиры ($count)';
  }

  @override
  String get noPassengersBooked => 'Пока нет забронированных пассажиров.';

  @override
  String get markRideStartedAction => 'Отметить начало поездки';

  @override
  String get cancelTripAction => 'Отменить поездку';

  @override
  String passengerSeatsDetail(int seats, String price) {
    return '$seats мест • $price';
  }

  @override
  String get defaultCancelTripReason => 'По техническим причинам';

  @override
  String get cancelTripReasonPrompt =>
      'Причина отмены будет отправлена пассажирам:';

  @override
  String get selectCitiesPrompt =>
      'Пожалуйста, выберите города отправления и назначения';

  @override
  String get citiesMustBeDifferentPrompt =>
      'Города отправления и назначения не могут совпадать';

  @override
  String get tripCreatedSuccess => 'Поездка успешно опубликована!';

  @override
  String get fromCityLabel => 'Откуда (Город отправления)';

  @override
  String get toCityLabel => 'Куда (Город назначения)';

  @override
  String get departureDateLabel => 'Дата и время отправления';

  @override
  String get pricePerSeatLabel => 'Цена за одно место (сум)';

  @override
  String seatsOption(int count) {
    return '$count мест';
  }

  @override
  String get pickupAddressLabel => 'Место посадки (Ориентир)';

  @override
  String get dropoffAddressLabel => 'Место высадки';

  @override
  String get amenitiesSectionTitle => 'Удобства и правила';

  @override
  String get hasAcLabel => 'Кондиционер';

  @override
  String get allowLuggageLabel => 'Багаж';

  @override
  String get womenOnlyLabel => 'Только для женщин';

  @override
  String get additionalCommentLabel =>
      'Дополнительный комментарий (необязательно)';

  @override
  String get publishTripAction => 'Опубликовать поездку';

  @override
  String get logoutTitle => 'Выход из системы';

  @override
  String get logoutConfirmPrompt =>
      'Вы действительно хотите выйти из своего аккаунта?';

  @override
  String get avatarUpdatedSuccess => 'Аватар успешно обновлен';

  @override
  String get verificationApprovedTitle => 'Верифицированный водитель';

  @override
  String get verificationApprovedSubtitle =>
      'Вы можете пользоваться всеми услугами без ограничений.';

  @override
  String get verificationUnderReviewTitle => 'Верификация на проверке';

  @override
  String get verificationUnderReviewSubtitle =>
      'Ваши документы проверяются модераторами (до 24 часов).';

  @override
  String get verificationRejectedTitle => 'Заявка отклонена';

  @override
  String get verificationRejectedSubtitle =>
      'Нажмите для повторной загрузки документов.';

  @override
  String get verificationMissingTitle => 'Документы не поданы';

  @override
  String get verificationMissingSubtitle =>
      'Пройдите верификацию, чтобы начать принимать заказы.';

  @override
  String get vehicleInfoTitle => 'Данные автомобиля';

  @override
  String vehicleYearAndColor(int year, String color) {
    return 'Год: $year • Цвет: $color';
  }

  @override
  String get reviewsAndRatingMenu => 'Отзывы и Рейтинг';

  @override
  String get walletAndEarningsMenu => 'Кошелек и Доходы';

  @override
  String get notificationsMenu => 'Уведомления';

  @override
  String get supportMenu => 'Служба поддержки';

  @override
  String get driverVerificationTitle => 'Верификация водителя';

  @override
  String get verificationBannerText =>
      'Подтвердите личность и документы на автомобиль, чтобы принимать заказы.';

  @override
  String get personalInfoSectionTitle => '1. Личные данные';

  @override
  String get vehicleInfoSectionTitle => '2. Данные автомобиля';

  @override
  String get documentsAndPhotosSectionTitle =>
      '3. Фото документов и автомобиля';

  @override
  String get submitApplicationAction => 'Отправить документы на проверку';

  @override
  String get cameraOption => 'Сделать фото';

  @override
  String get galleryOption => 'Выбрать из галереи';

  @override
  String get uploadAllPhotosPrompt =>
      'Пожалуйста, загрузите все 6 фото документов и авто!';

  @override
  String get applicationSubmittedModalTitle => 'Ваша заявка принята!';

  @override
  String get goToHomeAction => 'Перейти на главную';

  @override
  String get locationPermissionRequired => 'Требуется разрешение на геолокацию';

  @override
  String get backgroundLocationRequired =>
      'Требуется доступ к геолокации в фоновом режиме';

  @override
  String get enableLocationServices => 'Включите службы геолокации GPS';

  @override
  String get notificationPermissionDisabled =>
      'Разрешение на уведомления отключено';

  @override
  String get cameraPermissionRequired => 'Требуется доступ к камере';

  @override
  String get photoPermissionRequired => 'Требуется доступ к фотографиям';

  @override
  String get permissionDenied => 'В разрешении отказано';

  @override
  String get permissionPermanentlyDenied => 'Разрешение навсегда отклонено';

  @override
  String get openSettings => 'Открыть настройки';

  @override
  String get notNow => 'Не сейчас';

  @override
  String get tryAgain => 'Попробовать снова';

  @override
  String get continueAction => 'Продолжить';

  @override
  String get someFeaturesUnavailable =>
      'Некоторые функции могут быть недоступны';

  @override
  String get accountBlockedTitle => 'Аккаунт заблокирован';

  @override
  String get accountBlockedMessage =>
      'Ваш аккаунт приостановлен или заблокирован администрацией. Пожалуйста, обратитесь в службу поддержки.';

  @override
  String get verificationRequiredTitle => 'Требуется верификация';

  @override
  String get verificationRequiredMessage =>
      'Для приема заказов необходимо подтвердить личность и документы на автомобиль.';

  @override
  String get appearance => 'Внешний вид';

  @override
  String get themeLightShort => 'Светлая';

  @override
  String get themeDarkShort => 'Тёмная';

  @override
  String get themeAuto => 'Авто';

  @override
  String get themeLightHint => 'дневная';

  @override
  String get themeDarkHint => 'ночная';

  @override
  String get themeAutoHint => 'как в телефоне';

  @override
  String get languageLatinScript => 'латиница';

  @override
  String get languageCyrillicScript => 'кириллица';

  @override
  String get languageRussianHint => 'русский язык';

  @override
  String get menuTitle => 'Меню';

  @override
  String get menuSettingsHint => 'Язык, внешний вид';

  @override
  String get menuHelp => 'Помощь';

  @override
  String get menuHelpHint => 'Поддержка';

  @override
  String get menuLogout => 'Выйти';

  @override
  String get mapMyLocation => 'К моему местоположению';

  @override
  String get mapNotifications => 'Уведомления';

  @override
  String get driverTodayEarnings => 'Доход за сегодня';

  @override
  String driverTodayPill(String amount) {
    return 'Сегодня: $amount';
  }

  @override
  String get menuEarnings => 'Доход';

  @override
  String get menuEarningsHint => 'День, неделя, месяц';

  @override
  String get menuTripHistory => 'История поездок';

  @override
  String get menuProfileCar => 'Профиль и машина';

  @override
  String get menuProfileCarHint => 'Статус документов';

  @override
  String get driverLastRoute => 'Последний маршрут';

  @override
  String get driverOpenAgain => 'Открыть и сегодня';

  @override
  String get driverOpenRoute => 'Открыть маршрут';

  @override
  String get driverNoRouteYet =>
      'Откройте маршрут — пассажиры увидят вас и забронируют места';

  @override
  String get driverChangeTimePrice => 'Изменить время или цену';

  @override
  String get driverOnline => 'На линии';

  @override
  String get driverOffline => 'Не на линии';

  @override
  String get driverDocsPending => 'Документы на проверке';

  @override
  String get driverDocsAction => 'Посмотреть статус';

  @override
  String get driverActiveTrip => 'У вас есть активная поездка';

  @override
  String get statRating => 'рейтинг';

  @override
  String get statTrips => 'поездок';

  @override
  String get statInApp => 'в приложении';

  @override
  String statMonths(int count) {
    return '$count мес.';
  }

  @override
  String get dateToday => 'Сегодня';

  @override
  String get dateYesterday => 'Вчера';

  @override
  String get histCompleted => 'Завершена';

  @override
  String get histCancelled => 'Отменена';

  @override
  String get histActive => 'Активна';

  @override
  String histPassengers(int count) {
    return '$count пасс.';
  }

  @override
  String get profileCar => 'Машина';

  @override
  String get profileDocuments => 'Документы';

  @override
  String get docLicense => 'Водительское удостоверение';

  @override
  String get docVehicle => 'Техпаспорт и фото машины';

  @override
  String get docApproved => 'Подтверждено';

  @override
  String get docPending => 'На проверке';

  @override
  String get docRejected => 'Отправьте заново';

  @override
  String get carFourSeats => 'Легковая машина, 4 места';

  @override
  String get profilePhone => 'Телефон';

  @override
  String get dpOpenRoute => 'Открыть направление';

  @override
  String get dpToCity => 'В город';

  @override
  String get dpToHome => 'Домой';

  @override
  String get dpDepartureTime => 'Время выезда';

  @override
  String get dpWhenFull => 'Когда заполнится';

  @override
  String get dpPricePerSeat => 'Цена · 1 место (20–30 тыс.)';

  @override
  String get dpFourSeats => 'В машине всегда 4 места';

  @override
  String dpFullCarTotal(String amount) {
    return 'Если 4 места заполнятся: $amount';
  }

  @override
  String get dpOpen => 'Открыть направление';

  @override
  String get dpNewRequest => 'НОВЫЙ ЗАПРОС';

  @override
  String dpPeople(int count) {
    return '$count чел.';
  }

  @override
  String get dpToPassenger => 'до пассажира';

  @override
  String get dpAccept => 'Принять';

  @override
  String get dpSkip => 'Пропустить';

  @override
  String get dpPickupTitle => 'Забрать пассажиров';

  @override
  String dpSeatsTaken(int taken, int total) {
    return 'Занято $taken из $total';
  }

  @override
  String get dpPickedUp => 'в машине';

  @override
  String dpSlidePickedUp(String name) {
    return 'Сдвиньте: $name в машине';
  }

  @override
  String get dpDepart => 'Поехали';

  @override
  String get dpWaitMore => 'Ещё подождать';

  @override
  String get dpNoPassengersYet =>
      'Пассажиров пока нет. Новые запросы появятся здесь.';

  @override
  String get dpOnTheWay => 'В пути';

  @override
  String get dpCollected => 'Собрано';

  @override
  String get dpOpenNavigator => 'Открыть в навигаторе';

  @override
  String get dpSlideArrived => 'Сдвиньте: мы приехали';

  @override
  String get dpTripDone => 'Поездка завершена';

  @override
  String dpEarned(String amount) {
    return 'За поездку: $amount';
  }

  @override
  String get dpReturnTitle => 'Открыть обратный рейс?';

  @override
  String get dpOpenReturn => 'Открыть обратный рейс';

  @override
  String get dpNotToday => 'Сегодня не вернусь';

  @override
  String get dpActionFailed =>
      'Не получилось. Проверьте интернет и попробуйте снова.';

  @override
  String get dpCall => 'Позвонить';

  @override
  String get dpPassenger => 'Пассажир';

  @override
  String get dpPickupPoint => 'Место посадки';

  @override
  String get daBadge => 'ВОДИТЕЛЬ';

  @override
  String get daPhoneTitle => 'Вход для водителя';

  @override
  String get daPhoneBody => 'Пришлём SMS-код на ваш номер';

  @override
  String get daGetCode => 'Получить код';

  @override
  String get daTermsNote => 'Продолжая, вы соглашаетесь с условиями';

  @override
  String get daPhoneInvalid => 'Введите верный номер (например: 93 456 78 90)';

  @override
  String get daWithPassword => 'Войти по паролю';

  @override
  String get daOtpTitle => 'Введите код';

  @override
  String daOtpSentTo(String phone) {
    return 'Отправлен на $phone';
  }

  @override
  String get daChange => 'Изменить';

  @override
  String daResendIn(String time) {
    return 'Повторно через $time';
  }

  @override
  String get daResend => 'Отправить код ещё раз';

  @override
  String get daOtpAuto =>
      'Новый номер — к документам, зарегистрированный водитель — на главный экран';

  @override
  String dpPendingBanner(int count) {
    return 'Новых запросов ждут ответа: $count';
  }

  @override
  String get dpPendingAction => 'Открыть';
}
