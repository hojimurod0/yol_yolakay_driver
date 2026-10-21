/// Production-grade Exception hierarchy for Yol-Yolakay.
/// Conforms to Passenger App Clean Architecture standard.
abstract class AppException implements Exception {
  const AppException({
    required this.message,
    this.statusCode,
    this.code,
    this.details,
  });

  final String message;
  final int? statusCode;
  final String? code;
  final dynamic details;

  @override
  String toString() => '$runtimeType: $message (status: $statusCode, code: $code)';
}

/// 400 Bad Request / Validation Failure
class ValidationException extends AppException {
  const ValidationException([
    String message = 'Kiritilgan ma\'lumotlar yaroqsiz',
    int statusCode = 400,
    String code = 'VALIDATION_ERROR',
    dynamic details,
  ]) : super(
          message: message,
          statusCode: statusCode,
          code: code,
          details: details,
        );
}

/// 401 Unauthorized / Expired Session
class AuthException extends AppException {
  const AuthException([
    String message = 'Sessiya muddati tugadi. Iltimos, qaytadan kiring.',
    int statusCode = 401,
    String code = 'UNAUTHENTICATED',
    dynamic details,
  ]) : super(
          message: message,
          statusCode: statusCode,
          code: code,
          details: details,
        );
}

/// 403 Forbidden
class ForbiddenException extends AppException {
  const ForbiddenException([
    String message = 'Ushbu amalni bajarish uchun ruxsat berilmagan',
    int statusCode = 403,
    String code = 'FORBIDDEN',
    dynamic details,
  ]) : super(
          message: message,
          statusCode: statusCode,
          code: code,
          details: details,
        );
}

/// 404 Not Found
class NotFoundException extends AppException {
  const NotFoundException([
    String message = 'Ma\'lumot topilmadi',
    int statusCode = 404,
    String code = 'NOT_FOUND',
    dynamic details,
  ]) : super(
          message: message,
          statusCode: statusCode,
          code: code,
          details: details,
        );
}

/// 409 Conflict
class ConflictException extends AppException {
  const ConflictException([
    String message = 'Ma\'lumotlar to\'qnashuvi yuz berdi',
    int statusCode = 409,
    String code = 'CONFLICT',
    dynamic details,
  ]) : super(
          message: message,
          statusCode: statusCode,
          code: code,
          details: details,
        );
}

/// 429 Rate Limit Exceeded
class RateLimitException extends AppException {
  const RateLimitException([
    String message = 'So\'rovlar soni me\'yordan oshdi. Birozdan so\'ng qayta urinib ko\'ring.',
    int statusCode = 429,
    String code = 'RATE_LIMIT',
    dynamic details,
  ]) : super(
          message: message,
          statusCode: statusCode,
          code: code,
          details: details,
        );
}

/// 500+ Internal Server Error
class ServerException extends AppException {
  const ServerException([
    String message = 'Serverda nosozlik yuz berdi. Iltimos, keyinroq urinib ko\'ring.',
    int statusCode = 500,
    String code = 'SERVER_ERROR',
    dynamic details,
  ]) : super(
          message: message,
          statusCode: statusCode,
          code: code,
          details: details,
        );
}

/// Network connectivity / Timeout issues
class NetworkException extends AppException {
  const NetworkException([
    String message = 'Internet aloqasi mavjud emas yoki juda sekin',
    int? statusCode,
    String code = 'NETWORK_ERROR',
    dynamic details,
  ]) : super(
          message: message,
          statusCode: statusCode,
          code: code,
          details: details,
        );
}

/// Generic API Exception for backward compatibility
class ApiException extends AppException {
  const ApiException({
    required super.message,
    super.statusCode,
    super.code,
    super.details,
  });
}

/// Local storage / Cache Exception
class CacheException extends AppException {
  const CacheException([
    String message = 'Mahalliy xotiradan ma\'lumot o\'qishda xatolik',
    int? statusCode,
    String code = 'CACHE_ERROR',
    dynamic details,
  ]) : super(
          message: message,
          statusCode: statusCode,
          code: code,
          details: details,
        );
}
