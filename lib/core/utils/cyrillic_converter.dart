import '../../features/booking/domain/entities/booking_entity.dart';
import '../../features/trips/domain/entities/trip_entity.dart';

/// Comprehensive, robust Cyrillic transliteration and Russian localization utility.
/// Ensures NO Latin letters remain when the Russian language (or Cyrillic mode) is active.
abstract class CyrillicConverter {
  /// Direct dictionary for known words, car brands, models, colors, locations, and common phrases.
  static const Map<String, String> _dictionary = {
    // App & Brands
    'YolYolakay': 'Йўл-Йўлакай',
    'Yol-Yolakay': 'Йўл-Йўлакай',
    'Yo\'l-Yo\'lakay': 'Йўл-Йўлакай',
    'Chevrolet': 'Шевроле',
    'BYD': 'БИД',
    'Cobalt': 'Кобальт',
    'Gentra': 'Гентра',
    'Lacetti': 'Ласетти',
    'Nexia 3': 'Нексия 3',
    'Nexia': 'Нексия',
    'Tracker 2': 'Трекер 2',
    'Tracker': 'Трекер',
    'Onix Premier': 'Оникс Премьер',
    'Onix': 'Оникс',
    'Monza': 'Монза',
    'Malibu 2': 'Малибу 2',
    'Malibu': 'Малибу',
    'Damas': 'Дамас',
    'Song Plus EV': 'Сонг Плюс',
    'Song Plus': 'Сонг Плюс',
    'Spark': 'Спарк',
    'Tahoe': 'Тахо',
    'Traverse': 'Траверс',
    'Equinox': 'Эквинокс',
    'Kia': 'Киа',
    'K5': 'К5',
    'Sonata': 'Соната',
    'Elantra': 'Элантра',
    'Hyundai': 'Хюндай',
    'Cherry': 'Чери',
    'Tiggo': 'Тигго',
    'Haval': 'Хавал',
    'Jolion': 'Джолион',

    // Colors
    'Oq (White)': 'Белый',
    'Oq': 'Белый',
    'Qora (Black)': 'Черный',
    'Qora': 'Черный',
    'Kulrang (Grey)': 'Серый',
    'Kulrang': 'Серый',
    'Kumush (Silver)': 'Серебристый',
    'Kumush': 'Серебристый',
    'Qizil (Red)': 'Красный',
    'Qizil': 'Красный',
    'To\'q ko\'k (Navy)': 'Темно-синий',
    'To\'q ko\'k': 'Темно-синий',
    'Ko\'k': 'Синий',
    'Yashil': 'Зеленый',
    'Sariq': 'Желтый',
    'Jigarrang': 'Коричневый',
    'Moviy': 'Голубой',

    // Common Locations & Landmarks
    'Markaziy Avtoshohbekati': 'Центральный автовокзал',
    'Kirish pyatagi (Asosiy chorraha)': 'Въездной пятак (Главный перекресток)',
    'Markaz (Bozor oldi)': 'Центр (Рядом с базаром)',
    'Katta yo\'l yoqasi': 'Обочина главной дороги',
    'Chilonzor metro bekati': 'Станция метро Чиланзар',
    'Avtovokzal oldidagi kutish joyi': 'Место ожидания возле автовокзала',
    'Registon maydoni': 'Площадь Регистан',
    'Markaziy maydon': 'Центральная площадь',
    'Buxoro Temiryo\'l Vokzali': 'Железнодорожный вокзал Бухара',
    'Kogon shahrida': 'В городе Каган',
    'Uy (Toshkent)': 'Дом (Ташкент)',
    'Chilonzor tumani, 9-mavze, 12-uy':
        'Чиланзарский район, 9-й квартал, дом 12',
    'Ishxona (Samarqand)': 'Работа (Самарканд)',
    'Registon ko\'chasi, 45-bino': 'ул. Регистан, дом 45',

    // Regions
    'Toshkent': 'Ташкент',
    'Toshkent shahri': 'город Ташкент',
    'Toshkent viloyati': 'Ташкентская область',
    'Samarqand': 'Самарканд',
    'Samarqand viloyati': 'Самаркандская область',
    'Buxoro': 'Бухара',
    'Buxoro viloyati': 'Бухарская область',
    'Andijon': 'Андижан',
    'Andijon viloyati': 'Андижанская область',
    'Farg\'ona': 'Фергана',
    'Farg\'ona viloyati': 'Ферганская область',
    'Namangan': 'Наманган',
    'Namangan viloyati': 'Наманганская область',
    'Qashqadaryo': 'Кашкадарья',
    'Qashqadaryo viloyati': 'Кашкадарьинская область',
    'Surxondaryo': 'Сурхандарья',
    'Surxondaryo viloyati': 'Сурхандарьинская область',
    'Xorazm': 'Хорезм',
    'Xorazm viloyati': 'Хорезмская область',
    'Qoraqalpog\'iston': 'Каракалпакстан',
    'Qoraqalpog\'iston Respublikasi': 'Республика Каракалпакстан',
    'Navoiy': 'Навои',
    'Navoiy viloyati': 'Навоийская область',
    'Jizzax': 'Джизак',
    'Jizzax viloyati': 'Джизакская область',
    'Sirdaryo': 'Сырдарья',
    'Sirdaryo viloyati': 'Сырдарьинская область',

    // Driver Names
    'Azizbek Rahimov': 'Азизбек Рахимов',
    'Sherzod Aliyev': 'Шерзод Алиев',
    'Jahongir Qodirov': 'Жахонгир Кадыров',
    'Dilshodbek Normatov': 'Дильшодбек Норматов',
    'Dilshod Normatov': 'Дильшод Норматов',
    'Rustamjon Ismoilov': 'Рустамжон Исмоилов',
    'Otabek Mirzayev': 'Отабек Мирзаев',
    'Rizo Karimov': 'Ризо Каримов',

    // Amenities & Terms
    'Konditsioner': 'Кондиционер',
    'Yukxona': 'Большой багажник',
    'Wi-Fi': 'Вай-фай',
    'Chekish taqiqlangan': 'Курение запрещено',
    'Click': 'Клик',
    'Payme': 'Пайме',
    'Uzum Bank': 'Узум Банк',
    'Naqd pul': 'Наличные',
    'UZS': 'сум',
    'som': 'сум',
    'so\'m': 'сум',
    'ta joy': 'мест',
  };

  /// Main entry point: converts a given string to Russian/Cyrillic if languageCode is 'ru'.
  static String toCyrillic(String input) {
    if (input.trim().isEmpty) return input;

    // Check direct dictionary match first
    final direct = _dictionary[input.trim()];
    if (direct != null) return direct;

    // Multi-word / partial replacements for dictionary keys
    String result = input;
    _dictionary.forEach((key, val) {
      if (result.contains(key)) {
        result = result.replaceAll(key, val);
      }
    });

    // If still contains Latin characters, perform phonetic transliteration
    if (_hasLatinCharacters(result)) {
      result = _phoneticTransliterate(result);
    }

    return result;
  }

  /// Conditional converter that only transliterates if locale is 'ru'.
  static String maybeConvert(String input, String languageCode) {
    if (languageCode == 'ru') {
      return toCyrillic(input);
    }
    return input;
  }

  static bool _hasLatinCharacters(String s) {
    return RegExp(r'[a-zA-Z]').hasMatch(s);
  }

  /// Uzbek Latin to Cyrillic phonetic transliteration algorithm.
  static String _phoneticTransliterate(String input) {
    String text = input;

    // Two-letter compound combinations
    final multiMap = <String, String>{
      'sh': 'ш',
      'Sh': 'Ш',
      'SH': 'Ш',
      'ch': 'ч',
      'Ch': 'Ч',
      'CH': 'Ч',
      'yo\'': 'йў',
      'Yo\'': 'Йў',
      'YO\'': 'ЙЎ',
      'yo‘': 'йў',
      'Yo‘': 'Йў',
      'YO‘': 'ЙЎ',
      'yo': 'ё',
      'Yo': 'Ё',
      'YO': 'Ё',
      'yu': 'ю',
      'Yu': 'Ю',
      'YU': 'Ю',
      'ya': 'я',
      'Ya': 'Я',
      'YA': 'Я',
      'ye': 'е',
      'Ye': 'Е',
      'YE': 'Е',
      'o\'': 'ў',
      'O\'': 'Ў',
      'o‘': 'ў',
      'O‘': 'Ў',
      'o`': 'ў',
      'O`': 'Ў',
      'g\'': 'ғ',
      'G\'': 'Ғ',
      'g‘': 'ғ',
      'G‘': 'Ғ',
      'g`': 'ғ',
      'G`': 'Ғ',
      'ts': 'ц',
      'Ts': 'Ц',
      'TS': 'Ц',
    };

    multiMap.forEach((latin, cyrillic) {
      text = text.replaceAll(latin, cyrillic);
    });

    // Single character map
    final singleMap = <String, String>{
      'a': 'а',
      'A': 'А',
      'b': 'б',
      'B': 'Б',
      'd': 'д',
      'D': 'Д',
      'e': 'е',
      'E': 'Е',
      'f': 'ф',
      'F': 'Ф',
      'g': 'г',
      'G': 'Г',
      'h': 'ҳ',
      'H': 'Ҳ',
      'i': 'и',
      'I': 'И',
      'j': 'ж',
      'J': 'Ж',
      'k': 'к',
      'K': 'К',
      'l': 'л',
      'L': 'Л',
      'm': 'м',
      'M': 'М',
      'n': 'н',
      'N': 'Н',
      'o': 'о',
      'O': 'О',
      'p': 'п',
      'P': 'П',
      'q': 'қ',
      'Q': 'Қ',
      'r': 'р',
      'R': 'Р',
      's': 'с',
      'S': 'С',
      't': 'т',
      'T': 'Т',
      'u': 'у',
      'U': 'У',
      'v': 'в',
      'V': 'В',
      'x': 'х',
      'X': 'Х',
      'y': 'й',
      'Y': 'Й',
      'z': 'з',
      'Z': 'З',
      'c': 'к',
      'C': 'К',
      'w': 'в',
      'W': 'В',
    };

    singleMap.forEach((latin, cyrillic) {
      text = text.replaceAll(latin, cyrillic);
    });

    return text;
  }

  /// Localized booking status badge text.
  static String localizedBookingStatus(
      BookingStatus status, String languageCode) {
    if (languageCode == 'ru') {
      switch (status) {
        case BookingStatus.active:
          return 'Активный';
        case BookingStatus.confirmed:
          return 'Ожидается';
        case BookingStatus.completed:
          return 'Завершен';
        case BookingStatus.cancelled:
          return 'Отменен';
      }
    } else if (languageCode == 'en') {
      switch (status) {
        case BookingStatus.active:
          return 'Active';
        case BookingStatus.confirmed:
          return 'Confirmed';
        case BookingStatus.completed:
          return 'Completed';
        case BookingStatus.cancelled:
          return 'Cancelled';
      }
    }
    switch (status) {
      case BookingStatus.active:
        return 'Faol';
      case BookingStatus.confirmed:
        return 'Kutilmoqda';
      case BookingStatus.completed:
        return 'Tugallangan';
      case BookingStatus.cancelled:
        return 'Bekor qilingan';
    }
  }

  /// Localized trip tracking stage title and description.
  static Map<String, String> localizedTripStage(
    TripProgressStatus status,
    String languageCode,
  ) {
    if (languageCode == 'ru') {
      switch (status) {
        case TripProgressStatus.bookingConfirmed:
          return {
            'title': 'Бронь подтверждена',
            'desc': 'Ваш заказ принят',
          };
        case TripProgressStatus.driverPreparing:
          return {
            'title': 'Водитель готовится к выезду',
            'desc': 'Проверка авто и выезд на маршрут',
          };
        case TripProgressStatus.driverArrived:
          return {
            'title': 'Водитель прибыл на место',
            'desc': 'Ожидает в точке посадки',
          };
        case TripProgressStatus.passengerPickedUp:
          return {
            'title': 'Пассажир в машине',
            'desc': 'Все пассажиры разместились',
          };
        case TripProgressStatus.tripStarted:
          return {
            'title': 'Поездка началась',
            'desc': 'Движение по междугородней трассе',
          };
        case TripProgressStatus.nearDestination:
          return {
            'title': 'Подъезжаем к месту назначения',
            'desc': 'До прибытия осталось 15-20 минут',
          };
        case TripProgressStatus.tripCompleted:
          return {
            'title': 'Поездка завершена',
            'desc': 'Успешное и безопасное прибытие',
          };
      }
    } else if (languageCode == 'en') {
      switch (status) {
        case TripProgressStatus.bookingConfirmed:
          return {
            'title': 'Booking confirmed',
            'desc': 'Your order is accepted',
          };
        case TripProgressStatus.driverPreparing:
          return {
            'title': 'Driver is preparing',
            'desc': 'Inspecting car and departing',
          };
        case TripProgressStatus.driverArrived:
          return {
            'title': 'Driver arrived',
            'desc': 'Waiting at pickup location',
          };
        case TripProgressStatus.passengerPickedUp:
          return {
            'title': 'Passenger picked up',
            'desc': 'Everyone is seated',
          };
        case TripProgressStatus.tripStarted:
          return {
            'title': 'Trip started',
            'desc': 'Driving on the intercity highway',
          };
        case TripProgressStatus.nearDestination:
          return {
            'title': 'Near destination',
            'desc': 'Approx 15-20 minutes remaining',
          };
        case TripProgressStatus.tripCompleted:
          return {
            'title': 'Trip completed',
            'desc': 'Arrived safely',
          };
      }
    }

    switch (status) {
      case TripProgressStatus.bookingConfirmed:
        return {
          'title': 'Band qilish tasdiqlandi',
          'desc': 'Buyurtmangiz qabul qilindi',
        };
      case TripProgressStatus.driverPreparing:
        return {
          'title': 'Haydovchi tayyorlanmoqda',
          'desc': 'Avtomobil tekshirilib, yo\'lga chiqilmoqda',
        };
      case TripProgressStatus.driverArrived:
        return {
          'title': 'Haydovchi yetib keldi',
          'desc': 'Chiqish nuqtasida kutmoqda',
        };
      case TripProgressStatus.passengerPickedUp:
        return {
          'title': 'Yo\'lovchi olindi',
          'desc': 'Hamma joylashdi',
        };
      case TripProgressStatus.tripStarted:
        return {
          'title': 'Safar boshlandi',
          'desc': 'Shaharlararo trassa bo\'ylab harakatlanmoqda',
        };
      case TripProgressStatus.nearDestination:
        return {
          'title': 'Manzilga oz qoldi',
          'desc': 'Yetib borishga 15-20 daqiqa qoldi',
        };
      case TripProgressStatus.tripCompleted:
        return {
          'title': 'Safar yakunlandi',
          'desc': 'Xavfsiz yetib kelindi',
        };
    }
  }
}
