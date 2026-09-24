import 'dart:async';
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../storage/secure_storage_service.dart';
import '../utils/app_logger.dart';
import 'api_exception.dart';
import 'api_response.dart';
import 'auth_interceptor.dart';
import 'network_info.dart';

/// Centralized, production-grade Dio HTTP client for Yo'l-Yo'lakay Driver.
class ApiClient {
  ApiClient({
    required SecureStorageService secureStorage,
    NetworkInfo? networkInfo,
    String? baseUrl,
    VoidCallback? onSessionExpired,
  })  : _secureStorage = secureStorage,
        _networkInfo = networkInfo ?? NetworkInfoImpl() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? AppConfig.activeBaseUrl,
        connectTimeout: const Duration(milliseconds: AppConfig.connectTimeout),
        receiveTimeout: const Duration(milliseconds: AppConfig.receiveTimeout),
        sendTimeout: const Duration(milliseconds: AppConfig.sendTimeout),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'X-App-Version': AppConfig.appVersion,
        },
      ),
    );

    _dio.interceptors.addAll([
      AuthInterceptor(_secureStorage, onSessionExpired: onSessionExpired),
      InterceptorsWrapper(
        onRequest: (options, handler) {
          AppLogger.debug(
            '--> ${options.method} ${options.baseUrl}${options.path}',
            module: LogModule.api,
            data: {
              'query': options.queryParameters,
              'headers': options.headers,
            },
          );
          handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.debug(
            '<-- [${response.statusCode}] ${response.requestOptions.path}',
            module: LogModule.api,
            data: {'status': response.statusCode},
          );
          handler.next(response);
        },
        onError: (DioException error, handler) {
          AppLogger.error(
            'API Error [${error.response?.statusCode}] on ${error.requestOptions.path}: ${error.message}',
            module: LogModule.api,
            error: error.response?.data ?? error.error,
          );
          handler.next(error);
        },
      ),
    ]);
  }

  late final Dio _dio;
  final SecureStorageService _secureStorage;
  final NetworkInfo _networkInfo;

  Dio get dio => _dio;

  Future<void> _checkConnectivity() async {
    final connected = await _networkInfo.isConnected;
    if (!connected) {
      throw NetworkException('Internetga ulanmagansiz. Aloqani tekshiring.');
    }
  }

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic dataJson)? fromData,
  }) async {
    try {
      await _checkConnectivity();
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return ApiResponse<T>.fromJson(
          response.data as Map<String, dynamic>, fromData);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  static String generateIdempotencyKey() =>
      'idemp-${DateTime.now().millisecondsSinceEpoch}-${_idCounter++}';
  static int _idCounter = 0;

  Options _mergeIdempotency(Options? options, String? idempotencyKey) {
    if (idempotencyKey == null) return options ?? Options();
    final opt = options ?? Options();
    opt.headers = {
      ...?opt.headers,
      'Idempotency-Key': idempotencyKey,
    };
    return opt;
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    String? idempotencyKey,
    T Function(dynamic dataJson)? fromData,
  }) async {
    try {
      await _checkConnectivity();
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _mergeIdempotency(options, idempotencyKey),
        cancelToken: cancelToken,
      );
      return ApiResponse<T>.fromJson(
          response.data as Map<String, dynamic>, fromData);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    String? idempotencyKey,
    T Function(dynamic dataJson)? fromData,
  }) async {
    try {
      await _checkConnectivity();
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _mergeIdempotency(options, idempotencyKey),
        cancelToken: cancelToken,
      );
      return ApiResponse<T>.fromJson(
          response.data as Map<String, dynamic>, fromData);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    String? idempotencyKey,
    T Function(dynamic dataJson)? fromData,
  }) async {
    try {
      await _checkConnectivity();
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _mergeIdempotency(options, idempotencyKey),
        cancelToken: cancelToken,
      );
      return ApiResponse<T>.fromJson(
          response.data as Map<String, dynamic>, fromData);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    String? idempotencyKey,
    T Function(dynamic dataJson)? fromData,
  }) async {
    try {
      await _checkConnectivity();
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _mergeIdempotency(options, idempotencyKey),
        cancelToken: cancelToken,
      );
      return ApiResponse<T>.fromJson(
          response.data as Map<String, dynamic>, fromData);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
