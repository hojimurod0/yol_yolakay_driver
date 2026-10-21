import 'package:dio/dio.dart';
import 'api_response.dart';

/// Base Exception class for all remote API failures.
class ApiException implements Exception {
  ApiException({
    required this.message,
    this.statusCode,
    this.errorCode,
    this.fieldErrors = const [],
    this.rawResponse,
  });

  final String message;
  final int? statusCode;
  final String? errorCode;
  final List<FieldError> fieldErrors;
  final dynamic rawResponse;

  bool get isDriverNotApproved => errorCode == 'DRIVER_NOT_APPROVED';
  bool get isInsufficientBalance => errorCode == 'INSUFFICIENT_BALANCE';
  bool get isOrderAlreadyTaken =>
      errorCode == 'ORDER_ALREADY_TAKEN' ||
      errorCode == 'ORDER_NO_LONGER_AVAILABLE';
  bool get isInvalidOtp => errorCode == 'INVALID_OTP';
  bool get isTooManyRequests =>
      statusCode == 429 || errorCode == 'TOO_MANY_REQUESTS';

  /// Extracts user-friendly error message from API response or DioException.
  factory ApiException.fromDioError(DioException error) {
    if (error.type == DioExceptionType.sendTimeout) {
      return ApiTimeoutException(
        'Fayllarni yuklash vaqti tugadi. Internet aloqasi sekin bo\'lishi mumkin, iltimos qaytadan urinib ko\'ring.',
      );
    }
    if (error.type == DioExceptionType.receiveTimeout) {
      return ApiTimeoutException(
        'Server javob berish vaqti tugadi. Iltimos, qaytadan urinib ko\'ring.',
      );
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.connectionError) {
      return NetworkException(
        'Internet aloqasi yo\'q yoki server bilan bog\'lanib bo\'lmadi',
      );
    }

    final response = error.response;
    final statusCode = response?.statusCode;

    if (statusCode == 401) {
      return AuthException('Sessiya muddati tugadi. Iltimos, qaytadan kiring.');
    }

    String message = 'Serverda xatolik yuz berdi';
    String? errorCode;
    List<FieldError> fieldErrors = [];

    if (response?.data != null && response!.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      if (data['message'] != null && data['message'].toString().isNotEmpty) {
        message = data['message'].toString();
      }

      final errorObj = data['error'];
      if (errorObj is Map<String, dynamic>) {
        final parsed = ApiErrorDetails.fromJson(errorObj);
        errorCode = parsed.code;
        fieldErrors = parsed.details;
      } else if (data['errors'] is Map<String, dynamic>) {
        // Laravel 422 validation error envelope
        final validationMap = data['errors'] as Map<String, dynamic>;
        validationMap.forEach((key, value) {
          if (value is List && value.isNotEmpty) {
            fieldErrors
                .add(FieldError(field: key, message: value.first.toString()));
          }
        });
      }
    }

    // Sanitize technical messages like DioException, MulterError, ValidationPipe, etc.
    final lowerMsg = message.toLowerCase();
    if (lowerMsg.contains('dioexception') ||
        lowerMsg.contains('multererror') ||
        lowerMsg.contains('validationpipe') ||
        lowerMsg.contains('unexpected field') ||
        lowerMsg.contains('socketexception')) {
      if (statusCode == 413 ||
          lowerMsg.contains('file too large') ||
          lowerMsg.contains('limit_file_size')) {
        message =
            'Yuklangan fayl hajmi juda katta (maksimal 8 MB). Iltimos, kichikroq hajmda yuklang.';
      } else if (statusCode == 422 || statusCode == 400) {
        message =
            'Kiritilgan ma\'lumotlar yoki yuklangan fayllar talablarga mos kelmadi.';
      } else {
        message =
            'Server bilan ma\'lumot almashishda xatolik yuz berdi. Iltimos, qayta urinib ko\'ring.';
      }
    } else if (statusCode == 413) {
      message = 'Yuklangan fayl hajmi juda katta (maksimal 8 MB).';
    } else if (statusCode == 409) {
      message = 'Ushbu ma\'lumotlar yoki ariza allaqachon topshirilgan.';
    } else if (statusCode != null && statusCode >= 500) {
      message =
          'Serverda vaqtinchalik nosozlik yuz berdi. Birozdan so\'ng qayta urinib ko\'ring.';
    }

    // Specific typed subclasses
    if (errorCode == 'DRIVER_NOT_APPROVED' || statusCode == 403) {
      return DriverNotApprovedException(
          message: message, statusCode: statusCode);
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      errorCode: errorCode,
      fieldErrors: fieldErrors,
      rawResponse: response?.data,
    );
  }

  @override
  String toString() =>
      'ApiException(status: $statusCode, code: $errorCode, message: $message)';
}

/// Thrown on network drop or connection timeout.
class NetworkException extends ApiException {
  NetworkException([String message = 'Internet aloqasi yo\'q'])
      : super(message: message, errorCode: 'NETWORK_ERROR');
}

/// Thrown on 401 Unauthorized or expired refresh token.
class AuthException extends ApiException {
  AuthException([String message = 'Avtorizatsiyadan o\'tilmagan'])
      : super(message: message, statusCode: 401, errorCode: 'UNAUTHENTICATED');
}

/// Thrown when an unapproved driver attempts restricted actions.
class DriverNotApprovedException extends ApiException {
  DriverNotApprovedException({
    super.message = 'Haydovchi arizasi hali tasdiqlanmagan',
    super.statusCode = 403,
  }) : super(
            errorCode: 'DRIVER_NOT_APPROVED');
}

/// Thrown when driver has insufficient balance to take an order.
class InsufficientBalanceException extends ApiException {
  InsufficientBalanceException(
      [String message = 'Hamyoningizda mablag\' yetarli emas'])
      : super(message: message, errorCode: 'INSUFFICIENT_BALANCE');
}

/// Thrown when an API or upload request times out.
class ApiTimeoutException extends ApiException {
  ApiTimeoutException([String message = 'Server bilan aloqa vaqti tugadi'])
      : super(message: message, errorCode: 'TIMEOUT');
}
