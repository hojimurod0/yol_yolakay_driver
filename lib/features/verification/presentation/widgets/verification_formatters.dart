import 'package:flutter/services.dart';

/// Formatter that denies all numeric digits, allows only letters, apostrophes, hyphens, and spaces,
/// and automatically capitalizes the first letter of each word.
class NameInputFormatter extends TextInputFormatter {
  static final RegExp _allowedChars = RegExp(
    r"[a-zA-Zа-яА-ЯёЁўқғҳЎҚҒҲʻʼ’'`\s\-]",
  );

  static String capitalizeWords(String input) {
    if (input.isEmpty) return input;
    final buffer = StringBuffer();
    bool capitalizeNext = true;
    for (int i = 0; i < input.length; i++) {
      final char = input[i];
      if (char == ' ' || char == '-') {
        buffer.write(char);
        capitalizeNext = true;
      } else if (capitalizeNext) {
        buffer.write(char.toUpperCase());
        capitalizeNext = false;
      } else {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 1. Strip all digits completely
    final noDigits = newValue.text.replaceAll(RegExp(r'[0-9]'), '');
    if (noDigits.isEmpty && newValue.text.isNotEmpty) {
      return oldValue;
    }

    // 2. Filter only allowed letters and characters
    final filtered = noDigits
        .split('')
        .where((char) => _allowedChars.hasMatch(char))
        .join();

    // 3. Auto capitalize words
    final capitalized = capitalizeWords(filtered);

    final newOffset = capitalized.length < newValue.selection.end
        ? capitalized.length
        : (newValue.selection.end < 0 ? 0 : newValue.selection.end);

    return TextEditingValue(
      text: capitalized,
      selection: TextSelection.collapsed(
        offset: newOffset > capitalized.length ? capitalized.length : newOffset,
      ),
    );
  }
}

/// Central normalizers ensuring UI formatted values and backend raw values never collide.
abstract class VerificationNormalizers {
  /// Normalizes first/last name: trims leading/trailing whitespace, collapses double spaces, capitalizes words
  static String normalizeName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '';
    return trimmed.split(RegExp(r'\s+')).map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + (word.length > 1 ? word.substring(1) : '');
    }).join(' ');
  }

  /// Normalizes Passport/ID card: e.g. "AA 1234567" -> "AA1234567"
  static String normalizePassport(String series, String number) {
    final s = series.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    final n = number.replaceAll(RegExp(r'[^0-9]'), '');
    return '$s$n';
  }

  /// Normalizes Driver's License: e.g. "AA 1234567" -> "AA1234567"
  static String normalizeDriverLicense(String series, String number) {
    final s = series.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    final n = number.replaceAll(RegExp(r'[^0-9]'), '');
    return '$s$n';
  }

  /// Normalizes Tech Passport: e.g. "AAF 1234567" -> "AAF1234567"
  static String normalizeTechPassport(String series, String number) {
    final s = series.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    final n = number.replaceAll(RegExp(r'[^0-9]'), '');
    return '$s$n';
  }

  /// Normalizes Uzbekistan vehicle license plate: e.g. "01 A 777 AA" -> "01A777AA"
  static String normalizePlateNumber(String plate) {
    return plate.replaceAll(' ', '').toUpperCase().trim();
  }

  /// Normalizes JSHSHIR (PINFL): strips non-digits
  static String normalizePinfl(String pinfl) {
    return pinfl.replaceAll(RegExp(r'[^0-9]'), '').trim();
  }
}

/// Formatter for Document series (e.g. "AA", "AB", "AAF").
/// Auto-capitalizes and only allows letters up to specified maxLength.
class SeriesInputFormatter extends TextInputFormatter {
  SeriesInputFormatter({this.maxLength = 2});

  final int maxLength;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final lettersOnly = newValue.text
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z]'), '');

    final limited = lettersOnly.length > maxLength
        ? lettersOnly.substring(0, maxLength)
        : lettersOnly;

    return TextEditingValue(
      text: limited,
      selection: TextSelection.collapsed(offset: limited.length),
    );
  }
}

/// Formatter for Digits-only with fixed length (keeps leading zeros, e.g. for JSHSHIR or Doc number).
class DigitsOnlyFormatter extends TextInputFormatter {
  DigitsOnlyFormatter({required this.maxLength});

  final int maxLength;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final limited = digits.length > maxLength
        ? digits.substring(0, maxLength)
        : digits;

    return TextEditingValue(
      text: limited,
      selection: TextSelection.collapsed(offset: limited.length),
    );
  }
}

/// Auto-formats Uzbek Tech Passport number (e.g. "AAF 1234567").
class TechPassportInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw =
        newValue.text.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (raw.isEmpty) {
      return newValue.copyWith(
        text: '',
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    final lettersMatch = RegExp(r'^([A-Z]{1,3})(.*)$').firstMatch(raw);
    if (lettersMatch == null) {
      return newValue.copyWith(
        text: raw,
        selection: TextSelection.collapsed(offset: raw.length),
      );
    }

    final letters = lettersMatch.group(1) ?? '';
    final digits =
        (lettersMatch.group(2) ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    final limitedDigits =
        digits.length > 7 ? digits.substring(0, 7) : digits;

    final formatted = limitedDigits.isNotEmpty
        ? '$letters $limitedDigits'
        : letters;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Auto-formats Uzbek Driver's License number (e.g. "AA 1234567").
class DriverLicenseInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw =
        newValue.text.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (raw.isEmpty) {
      return newValue.copyWith(
        text: '',
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    final lettersMatch = RegExp(r'^([A-Z]{1,2})(.*)$').firstMatch(raw);
    if (lettersMatch == null) {
      return newValue.copyWith(
        text: raw,
        selection: TextSelection.collapsed(offset: raw.length),
      );
    }

    final letters = lettersMatch.group(1) ?? '';
    final digits =
        (lettersMatch.group(2) ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    final limitedDigits =
        digits.length > 7 ? digits.substring(0, 7) : digits;

    final formatted = limitedDigits.isNotEmpty
        ? '$letters $limitedDigits'
        : letters;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Comprehensive, robust Validators for all verification fields.
class VerificationValidators {
  static String? validateFirstName(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'Ismingizni kiriting';
    }
    final clean = val.trim();
    if (RegExp(r'[0-9]').hasMatch(clean)) {
      return 'Ismda raqam bo\'lishi mumkin emas';
    }
    if (clean.length < 2) {
      return 'Ism kamida 2 ta harfdan iborat bo\'lishi kerak';
    }
    if (!RegExp(r"^[\p{L}'ʻʼ’` \-]+$", unicode: true).hasMatch(clean)) {
      return 'Ismda faqat harflar bo\'lishi kerak';
    }
    return null;
  }

  static String? validateLastName(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'Familiyangizni kiriting';
    }
    final clean = val.trim();
    if (RegExp(r'[0-9]').hasMatch(clean)) {
      return 'Familiyada raqam bo\'lishi mumkin emas';
    }
    if (clean.length < 2) {
      return 'Familiya kamida 2 ta harfdan iborat bo\'lishi kerak';
    }
    if (!RegExp(r"^[\p{L}'ʻʼ’` \-]+$", unicode: true).hasMatch(clean)) {
      return 'Familiyada faqat harflar bo\'lishi kerak';
    }
    return null;
  }

  static String? validateMiddleName(String? val) {
    if (val == null || val.trim().isEmpty) {
      return null; // Otasining ismi ixtiyoriy
    }
    final clean = val.trim();
    if (RegExp(r'[0-9]').hasMatch(clean)) {
      return 'Otasining ismida raqam bo\'lishi mumkin emas';
    }
    if (!RegExp(r"^[\p{L}'ʻʼ’` \-]+$", unicode: true).hasMatch(clean)) {
      return 'Faqat harflar kiritilishi kerak';
    }
    return null;
  }

  static String? validateBirthDate(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'Tug\'ilgan sanangizni tanlang';
    }
    final date = DateTime.tryParse(val.trim());
    if (date == null) {
      return 'Sana formati noto\'g\'ri (YYYY-MM-DD)';
    }
    final now = DateTime.now();
    if (date.isAfter(now)) {
      return 'Tug\'ilgan sana kelajakda bo\'lishi mumkin emas';
    }
    int age = now.year - date.year;
    if (now.month < date.month ||
        (now.month == date.month && now.day < date.day)) {
      age--;
    }
    if (age < 18) {
      return 'Haydovchi kamida 18 yoshda bo\'lishi kerak';
    }
    if (age > 80) {
      return 'Tug\'ilgan sana noto\'g\'ri ko\'rsatilgan';
    }
    return null;
  }

  static String? validateDocSeries(String? val, {int expectedLength = 2}) {
    if (val == null || val.trim().isEmpty) {
      return 'Seriya kiritilishi shart';
    }
    final clean = val.trim().toUpperCase();
    if (clean.length != expectedLength || !RegExp(r'^[A-Z]+$').hasMatch(clean)) {
      return '$expectedLength ta lotin harfi (masalan: AA)';
    }
    return null;
  }

  static String? validateDocNumber(String? val, {int expectedLength = 7}) {
    if (val == null || val.trim().isEmpty) {
      return 'Hujjat raqamini kiriting';
    }
    final clean = val.trim();
    if (clean.length != expectedLength || !RegExp(r'^[0-9]+$').hasMatch(clean)) {
      return '$expectedLength ta raqam bo\'lishi kerak';
    }
    return null;
  }

  static String? validateDocIssueDate(String? issueDateStr, {String? birthDateStr}) {
    if (issueDateStr == null || issueDateStr.trim().isEmpty) {
      return 'Berilgan sanani tanlang';
    }
    final issueDate = DateTime.tryParse(issueDateStr.trim());
    if (issueDate == null) {
      return 'Sana formati noto\'g\'ri (YYYY-MM-DD)';
    }
    final now = DateTime.now();
    if (issueDate.isAfter(now)) {
      return 'Berilgan sana kelajakda bo\'lishi mumkin emas';
    }
    if (birthDateStr != null && birthDateStr.isNotEmpty) {
      final birthDate = DateTime.tryParse(birthDateStr.trim());
      if (birthDate != null && issueDate.isBefore(birthDate)) {
        return 'Berilgan sana tug\'ilgan sanadan keyin bo\'lishi kerak';
      }
    }
    return null;
  }

  static String? validateDocExpiryDate(String? expiryDateStr, {String? issueDateStr}) {
    if (expiryDateStr == null || expiryDateStr.trim().isEmpty) {
      return 'Amal qilish muddatini tanlang';
    }
    final expiryDate = DateTime.tryParse(expiryDateStr.trim());
    if (expiryDate == null) {
      return 'Sana formati noto\'g\'ri (YYYY-MM-DD)';
    }
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    if (expiryDate.isBefore(todayDate)) {
      return 'Hujjatning amal qilish muddati tugagan';
    }
    if (issueDateStr != null && issueDateStr.isNotEmpty) {
      final issueDate = DateTime.tryParse(issueDateStr.trim());
      if (issueDate != null && expiryDate.isBefore(issueDate)) {
        return 'Amal qilish muddati berilgan sanadan keyin bo\'lishi kerak';
      }
    }
    return null;
  }

  static String? validatePinfl(String? val) {
    if (val == null || val.trim().isEmpty) {
      return null; // JSHSHIR faqat mavjud bo'lsa
    }
    final clean = val.trim();
    if (clean.length != 14 || !RegExp(r'^[0-9]{14}$').hasMatch(clean)) {
      return 'JSHSHIR aniq 14 ta raqamdan iborat bo\'lishi shart';
    }
    return null;
  }

  static String? validateLicenseSeries(String? val) {
    return validateDocSeries(val, expectedLength: 2);
  }

  static String? validateLicenseNumber(String? val) {
    return validateDocNumber(val, expectedLength: 7);
  }

  static String? validatePlateNumber(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'Avtomobil davlat raqamini kiriting';
    }
    final clean = val.replaceAll(' ', '').toUpperCase();
    final isValid =
        RegExp(r'^(\d{2}[A-Z]\d{3}[A-Z]{2}|\d{5}[A-Z]{3})$').hasMatch(clean);
    if (!isValid) {
      return 'Davlat raqami formati noto\'g\'ri (masalan: 01 A 777 AA yoki 01 777 AAA)';
    }
    return null;
  }

  static String? validateTechPassportSeries(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'Seriyani kiriting';
    }
    final clean = val.trim().toUpperCase();
    if (clean.length < 2 || clean.length > 3 || !RegExp(r'^[A-Z]+$').hasMatch(clean)) {
      return '2 yoki 3 ta lotin harfi (masalan: AAF)';
    }
    return null;
  }

  static String? validateTechPassportNumber(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'Raqamni kiriting';
    }
    final clean = val.trim();
    if (clean.length < 6 || clean.length > 7 || !RegExp(r'^[0-9]+$').hasMatch(clean)) {
      return '6 yoki 7 ta raqam bo\'lishi kerak';
    }
    return null;
  }

  static String? validateTechPassport(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'Tex passport seriya va raqamini kiriting';
    }
    final clean = val.replaceAll(' ', '').toUpperCase();
    if (!RegExp(r'^[A-Z]{2,3}\d{6,8}$').hasMatch(clean)) {
      return 'Tex passport formati noto\'g\'ri (masalan: AAF 1234567)';
    }
    return null;
  }

  static String? validateDriverLicense(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'Haydovchilik guvohnomasi raqamini kiriting';
    }
    final clean = val.replaceAll(' ', '').toUpperCase();
    if (!RegExp(r'^[A-Z]{2,3}\d{6,8}$').hasMatch(clean)) {
      return 'Guvohnoma formati noto\'g\'ri (masalan: AA 1234567)';
    }
    return null;
  }

  static String? validateCarModel(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'Avtomobil rusumini kiriting';
    }
    if (val.trim().length < 2) {
      return 'Rusum nomi kamida 2 ta belgidan iborat bo\'lsin';
    }
    return null;
  }

  static String? validateCarColor(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'Avtomobil rangini kiriting';
    }
    return null;
  }

  static String? validateCarYear(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'Ishlab chiqarilgan yilini kiriting';
    }
    final year = int.tryParse(val.trim());
    final currentYear = DateTime.now().year + 1;
    if (year == null || year < 1990 || year > currentYear) {
      return 'Yil 1990 va $currentYear oralig\'ida bo\'lishi kerak';
    }
    return null;
  }
}
