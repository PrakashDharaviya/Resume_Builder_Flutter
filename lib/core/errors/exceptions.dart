// Base exception class
class ServerException implements Exception {
  final String message;

  const ServerException([this.message = 'Server error occurred']);

  @override
  String toString() => 'ServerException: $message';
}

// Network exception
class NetworkException implements Exception {
  final String message;

  const NetworkException([this.message = 'Network connection failed']);

  @override
  String toString() => 'NetworkException: $message';
}

// Auth exception
class AuthException implements Exception {
  final String message;

  const AuthException([this.message = 'Authentication failed']);

  @override
  String toString() => 'AuthException: $message';
}

// Validation exception
class ValidationException implements Exception {
  final String message;

  const ValidationException([this.message = 'Validation failed']);

  @override
  String toString() => 'ValidationException: $message';
}

// Cache exception
class CacheException implements Exception {
  final String message;

  const CacheException([this.message = 'Cache error occurred']);

  @override
  String toString() => 'CacheException: $message';
}

// Not found exception
class NotFoundException implements Exception {
  final String message;

  const NotFoundException([this.message = 'Resource not found']);

  @override
  String toString() => 'NotFoundException: $message';
}
