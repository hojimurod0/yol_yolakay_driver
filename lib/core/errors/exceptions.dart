/// Custom exceptions thrown by network, cache, or authentication services.
class ApiException implements Exception {
  ApiException({required this.message, this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException: $message (code: $statusCode)';
}

class NetworkException implements Exception {
  NetworkException([this.message = 'No network connectivity']);
  final String message;

  @override
  String toString() => 'NetworkException: $message';
}

class AuthException implements Exception {
  AuthException(this.message);
  final String message;

  @override
  String toString() => 'AuthException: $message';
}

class CacheException implements Exception {
  CacheException([this.message = 'Local cache read/write failed']);
  final String message;

  @override
  String toString() => 'CacheException: $message';
}
