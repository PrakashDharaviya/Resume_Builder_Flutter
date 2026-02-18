// Base failure class
abstract class Failure {
  final String message;

  const Failure(this.message);
}

// Server failure
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

// Network failure
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network connection failed']);
}

// Auth failure
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed']);
}

// Validation failure
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation failed']);
}

// Cache failure
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred']);
}

// Not found failure
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found']);
}

// Permission failure
class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Permission denied']);
}

// Unknown failure
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unknown error occurred']);
}
