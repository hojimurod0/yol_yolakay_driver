import 'package:equatable/equatable.dart';

/// Base class for all Clean Architecture Domain failures.
abstract class Failure extends Equatable {
  const Failure({
    required this.message,
    this.statusCode,
    this.errorCode,
    this.isRetryable = false,
  });

  final String message;
  final int? statusCode;
  final String? errorCode;
  final bool isRetryable;

  /// Returns localized message based on active language code ('uz', 'ru', 'en').
  String localizedMessage(String lang) => message;

  @override
  List<Object?> get props => [message, statusCode, errorCode, isRetryable];
}

/// Thrown on network loss, DNS failure, or connection timeouts.
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = "Internet aloqasi yo'q yoki server javob bermayapti.",
  }) : super(
          errorCode: 'NETWORK_ERROR',
          isRetryable: true,
        );

  @override
  String localizedMessage(String lang) {
    return switch (lang) {
      'ru' => 'Отсутствует подключение к интернету или сервер недоступен.',
      'en' => 'No internet connection or server unreachable.',
      _ => "Internet aloqasi yo'q yoki server javob bermayapti.",
    };
  }
}

/// Thrown on 401 Unauthorized or expired refresh token.
class AuthFailure extends Failure {
  const AuthFailure({
    super.message = "Sessiya muddati tugadi. Iltimos, qaytadan kiring.",
  }) : super(
          statusCode: 401,
          errorCode: 'UNAUTHENTICATED',
          isRetryable: false,
        );

  @override
  String localizedMessage(String lang) {
    return switch (lang) {
      'ru' => 'Сессия истекла. Пожалуйста, войдите снова.',
      'en' => 'Session expired. Please log in again.',
      _ => "Sessiya muddati tugadi. Iltimos, qaytadan kiring.",
    };
  }
}

/// Thrown when an unapproved driver attempts restricted actions.
class DriverNotApprovedFailure extends Failure {
  const DriverNotApprovedFailure({
    super.message = "Haydovchi arizasi hali tasdiqlanmagan.",
  }) : super(
          statusCode: 403,
          errorCode: 'DRIVER_NOT_APPROVED',
          isRetryable: false,
        );

  @override
  String localizedMessage(String lang) {
    return switch (lang) {
      'ru' => 'Ваша заявка водителя еще не одобрена администратором.',
      'en' => 'Your driver application has not been approved yet.',
      _ => "Haydovchi arizasi hali tasdiqlanmagan.",
    };
  }
}

/// Thrown when driver has insufficient balance to accept an order.
class InsufficientBalanceFailure extends Failure {
  const InsufficientBalanceFailure({
    super.message =
        "Hamyoningizda mablag' yetarli emas. Iltimos, hisobingizni to'ldiring.",
  }) : super(
          statusCode: 403,
          errorCode: 'INSUFFICIENT_BALANCE',
          isRetryable: false,
        );

  @override
  String localizedMessage(String lang) {
    return switch (lang) {
      'ru' => 'Недостаточно средств на балансе. Пожалуйста, пополните кошелек.',
      'en' => 'Insufficient balance. Please top up your wallet.',
      _ =>
        "Hamyoningizda mablag' yetarli emas. Iltimos, hisobingizni to'ldiring.",
    };
  }
}

/// Thrown when an order was already accepted or taken by another driver.
class ConflictFailure extends Failure {
  const ConflictFailure({
    super.message =
        "Ushbu buyurtma allaqachon boshqa haydovchi tomonidan qabul qilingan.",
  }) : super(
          statusCode: 409,
          errorCode: 'ORDER_ALREADY_TAKEN',
          isRetryable: false,
        );

  @override
  String localizedMessage(String lang) {
    return switch (lang) {
      'ru' => 'Этот заказ уже принят другим водителем.',
      'en' => 'This order has already been taken by another driver.',
      _ =>
        "Ushbu buyurtma allaqachon boshqa haydovchi tomonidan qabul qilingan.",
    };
  }
}

/// Thrown on 422 Unprocessable Entity with validation details.
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    this.fieldErrors = const {},
  }) : super(
          statusCode: 422,
          errorCode: 'VALIDATION_ERROR',
          isRetryable: false,
        );

  final Map<String, String> fieldErrors;

  @override
  List<Object?> get props => [...super.props, fieldErrors];
}

/// Thrown on 429 Too Many Requests.
class RateLimitFailure extends Failure {
  const RateLimitFailure({
    super.message =
        "So'rovlar soni oshib ketdi. Bir ozdan so'ng qayta urining.",
  }) : super(
          statusCode: 429,
          errorCode: 'TOO_MANY_REQUESTS',
          isRetryable: true,
        );

  @override
  String localizedMessage(String lang) {
    return switch (lang) {
      'ru' => 'Слишком много запросов. Пожалуйста, подождите немного.',
      'en' => 'Too many requests. Please wait a moment and try again.',
      _ => "So'rovlar soni oshib ketdi. Bir ozdan so'ng qayta urining.",
    };
  }
}

/// Thrown on 500, 502, 503, 504 server errors.
class ServerFailure extends Failure {
  const ServerFailure({
    super.message =
        "Serverda vaqtinchalik xatolik yuz berdi. Iltimos, keyinroq urinib ko'ring.",
    super.statusCode = 500,
  }) : super(
          errorCode: 'SERVER_ERROR',
          isRetryable: true,
        );

  @override
  String localizedMessage(String lang) {
    return switch (lang) {
      'ru' => 'Временная ошибка сервера. Пожалуйста, попробуйте позже.',
      'en' => 'Temporary server error. Please try again later.',
      _ =>
        "Serverda vaqtinchalik xatolik yuz berdi. Iltimos, keyinroq urinib ko'ring.",
    };
  }
}
