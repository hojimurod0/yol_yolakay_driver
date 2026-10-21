/// Centralized form and input validation helpers.
abstract class AppValidator {
  static bool isValidUzPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length == 9) return true; // e.g. 901234567
    if (cleaned.length == 12 && cleaned.startsWith('998')) {
      return true; // e.g. 998901234567
    }
    return false;
  }

  static String formatUzPhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    final suffix = digits.startsWith('998') ? digits.substring(3) : digits;
    if (suffix.length != 9) return raw;
    // Format: +998 (90) 123-45-67
    return '+998 (${suffix.substring(0, 2)}) ${suffix.substring(2, 5)}-${suffix.substring(5, 7)}-${suffix.substring(7, 9)}';
  }

  static bool isValidEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return true; // Email is optional in profile
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email.trim());
  }

  static bool isValidName(String? name) {
    if (name == null || name.trim().length < 2) return false;
    return true;
  }
}
