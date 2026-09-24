import 'dart:io';
import 'package:dio/dio.dart';
import 'exceptions.dart';
import '../utils/app_logger.dart';

/// Localized, user-friendly error message representation.
class AppErrorMessage {
  final String title;
  final String message;
  final bool isNetworkError;
  final bool isAuthError;

  const AppErrorMessage({
    required this.title,
    required this.message,
    this.isNetworkError = false,
    this.isAuthError = false,
  });
}

/// Centralized error translator that converts technical exceptions (Dio, Socket, HTTP, ApiException)
/// into user-friendly, respectful messages for the UI in Uzbek, Russian, and English.
class AppErrorHandler {
  AppErrorHandler._();

  static AppErrorMessage parse(dynamic error, {String languageCode = 'uz'}) {
    AppLogger.error('Parsing application error',
        module: LogModule.system, error: error);

    final isRu = languageCode == 'ru';
    final isEn = languageCode == 'en';

    if (error is SocketException ||
        (error is DioException &&
            (error.type == DioExceptionType.connectionError ||
                error.type == DioExceptionType.connectionTimeout ||
                error.type == DioExceptionType.receiveTimeout ||
                error.type == DioExceptionType.sendTimeout))) {
      return AppErrorMessage(
        title: isRu
            ? 'Нет связи'
            : (isEn ? 'No Connection' : 'Internet aloqasi yo\'q'),
        message: isRu
            ? 'Пожалуйста, проверьте подключение к интернету и повторите попытку.'
            : (isEn
                ? 'Please check your internet connection and try again.'
                : 'Iltimos, internet aloqangizni tekshirib, qaytadan urinib ko\'ring.'),
        isNetworkError: true,
      );
    }

    if (error is NetworkException) {
      return AppErrorMessage(
        title:
            isRu ? 'Ошибка сети' : (isEn ? 'Network Error' : 'Tarmoq xatoligi'),
        message: isRu
            ? 'Не удалось установить соединение с сервером.'
            : (isEn
                ? 'Could not establish connection with the server.'
                : 'Server bilan aloqa o\'rnatib bo\'lmadi.'),
        isNetworkError: true,
      );
    }

    if (error is AuthException) {
      return AppErrorMessage(
        title:
            isRu ? 'Авторизация' : (isEn ? 'Authentication' : 'Kirish xatosi'),
        message: isRu
            ? 'Время сессии истекло. Пожалуйста, войдите снова.'
            : (isEn
                ? 'Your session has expired. Please log in again.'
                : 'Sessiya muddati tugadi. Iltimos, qaytadan kiring.'),
        isAuthError: true,
      );
    }

    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        return AppErrorMessage(
          title: isRu
              ? 'Доступ ограничен'
              : (isEn ? 'Unauthorized' : 'Ruxsat berilmagan'),
          message: isRu
              ? 'Сессия истекла. Пожалуйста, авторизуйтесь.'
              : (isEn
                  ? 'Session expired. Please log in again.'
                  : 'Sessiya tugagan. Iltimos, hisobingizga kiring.'),
          isAuthError: true,
        );
      }

      if (statusCode != null && statusCode >= 500) {
        return AppErrorMessage(
          title: isRu
              ? 'Ошибка сервера'
              : (isEn ? 'Server Error' : 'Server xatoligi'),
          message: isRu
              ? 'На сервере ведутся технические работы. Попробуйте чуть позже.'
              : (isEn
                  ? 'The server is undergoing maintenance. Please try again later.'
                  : 'Serverda texnik ishlar olib borilmoqda. Birozdan so\'ng urinib ko\'ring.'),
        );
      }

      final serverMsg = error.response?.data?['message']?.toString();
      if (serverMsg != null && serverMsg.isNotEmpty) {
        return AppErrorMessage(
          title: isRu ? 'Внимание' : (isEn ? 'Notice' : 'Diqqat'),
          message: serverMsg,
        );
      }
    }

    if (error is ApiException) {
      return AppErrorMessage(
        title: isRu
            ? 'Ошибка запроса'
            : (isEn ? 'Request Error' : 'So\'rov xatoligi'),
        message: error.message,
      );
    }

    // Generic fallback: NEVER display raw stack trace or "TypeError" to the user
    return AppErrorMessage(
      title: isRu
          ? 'Что-то пошло не так'
          : (isEn ? 'Something went wrong' : 'Kutilmagan xatolik'),
      message: isRu
          ? 'Произошла непредвиденная ошибка. Пожалуйста, повторите действие.'
          : (isEn
              ? 'An unexpected error occurred. Please try again.'
              : 'Kutilmagan xatolik yuz berdi. Iltimos, qaytadan urinib ko\'ring.'),
    );
  }
}
