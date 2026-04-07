/// Error Message Service - Provides user-friendly and admin-detailed error messages
/// Helps users and admins understand authentication and general errors clearly
library;

class ErrorMessage {
  /// User-friendly message (simple, clear language)
  final String userMessage;

  /// Admin/Developer detailed message (technical details)
  final String adminMessage;

  /// Error category for UI styling (error, warning, info, etc.)
  final String category;

  /// Suggested action for the user
  final String? suggestedAction;

  const ErrorMessage({
    required this.userMessage,
    required this.adminMessage,
    this.category = 'error',
    this.suggestedAction,
  });
}

class ErrorMessageService {
  /// Maps Firebase Auth error codes to user-friendly and admin messages
  static ErrorMessage mapFirebaseAuthError(
    String errorCode, {
    String? originalMessage,
  }) {
    final normalizedInput = errorCode.trim();

    // If we already have a user-facing message (not a Firebase error code),
    // preserve it instead of forcing the generic fallback.
    final isLikelyErrorCode = RegExp(
      r'^[a-z0-9]+(?:[-_][a-z0-9]+)+$',
    ).hasMatch(normalizedInput.toLowerCase());

    if (!isLikelyErrorCode) {
      final message = normalizedInput.isNotEmpty
          ? normalizedInput
          : 'Something Went Wrong';

      final lowered = message.toLowerCase();
      final category =
          lowered.contains('network') || lowered.contains('internet')
          ? 'network'
          : lowered.contains('password') || lowered.contains('email')
          ? 'auth'
          : 'error';

      return ErrorMessage(
        userMessage: message,
        adminMessage:
            'Authentication message received from upstream: $message${originalMessage != null ? ' | $originalMessage' : ''}',
        category: category,
        suggestedAction: category == 'auth'
            ? 'Verify your credentials and try again.'
            : 'Please try again.',
      );
    }

    final normalizedCode = normalizedInput.toLowerCase().replaceFirst(
      'firebase_auth/',
      '',
    );

    switch (normalizedCode) {
      // Network Errors
      case 'network-request-failed':
        return const ErrorMessage(
          userMessage: 'Connect Your Network',
          adminMessage:
              'Network request failed. Check internet connectivity and Firebase configuration.',
          category: 'network',
          suggestedAction: 'Check your internet connection and try again.',
        );

      case 'network_error':
        return const ErrorMessage(
          userMessage: 'Connect Your Network',
          adminMessage:
              'Failed to reach Firebase servers. Network connectivity issue or DNS resolution failed.',
          category: 'network',
          suggestedAction: 'Please check your internet connection.',
        );

      // Credential & Authentication Errors
      case 'wrong-password':
        return const ErrorMessage(
          userMessage: 'Incorrect Password',
          adminMessage:
              'Authentication failed: wrong password provided for valid user account.',
          category: 'auth',
          suggestedAction:
              'Check your password and try again. Use Forgot Password if needed.',
        );

      case 'invalid-credential':
        return const ErrorMessage(
          userMessage: 'Incorrect Email or Password',
          adminMessage:
              'Invalid credentials provided. Email/password combination does not match any account.',
          category: 'auth',
          suggestedAction:
              'Verify your email and password, or create a new account.',
        );

      case 'user-not-found':
        return const ErrorMessage(
          userMessage: 'Account Not Found',
          adminMessage:
              'No user account exists with the provided email address.',
          category: 'auth',
          suggestedAction: 'Check your email address or create a new account.',
        );

      // Email Validation Errors
      case 'invalid-email':
        return const ErrorMessage(
          userMessage: 'Invalid Email Address',
          adminMessage: 'The provided email address format is invalid.',
          category: 'validation',
          suggestedAction:
              'Please enter a valid email address (e.g., user@example.com).',
        );

      case 'missing-email':
        return const ErrorMessage(
          userMessage: 'Email Required',
          adminMessage: 'Email field is empty or missing.',
          category: 'validation',
          suggestedAction: 'Please enter your email address.',
        );

      case 'email-already-in-use':
        return const ErrorMessage(
          userMessage: 'Email Already Registered',
          adminMessage: 'An account already exists with this email address.',
          category: 'auth',
          suggestedAction:
              'Use a different email or sign in to your existing account.',
        );

      // Password Errors
      case 'weak-password':
        return const ErrorMessage(
          userMessage: 'Password Too Weak',
          adminMessage:
              'Password does not meet security requirements (minimum 6 characters recommended).',
          category: 'validation',
          suggestedAction:
              'Use a stronger password with at least 6 characters.',
        );

      case 'operation-not-allowed':
        return const ErrorMessage(
          userMessage: 'Sign-in Method Disabled',
          adminMessage:
              'This authentication method is not enabled for this Firebase project.',
          category: 'config',
          suggestedAction:
              'Contact support if you need this sign-in method enabled.',
        );

      // Account Status Errors
      case 'user-disabled':
        return const ErrorMessage(
          userMessage: 'Account Disabled',
          adminMessage:
              'This user account has been disabled by an administrator.',
          category: 'blocked',
          suggestedAction: 'Contact support for account recovery assistance.',
        );

      // Rate Limiting & Security
      case 'too-many-requests':
        return const ErrorMessage(
          userMessage: 'Too Many Attempts',
          adminMessage:
              'Too many login attempts. Account temporarily locked for security. Try again in a few minutes.',
          category: 'security',
          suggestedAction:
              'Wait a few minutes before trying again, or use password recovery.',
        );

      // Password Reset Errors
      case 'expired-action-code':
        return const ErrorMessage(
          userMessage: 'Reset Link Expired',
          adminMessage:
              'Password reset link has expired (typically after 24 hours).',
          category: 'auth',
          suggestedAction: 'Request a new password reset email.',
        );

      case 'invalid-action-code':
        return const ErrorMessage(
          userMessage: 'Invalid Reset Link',
          adminMessage:
              'The password reset link is invalid or has already been used.',
          category: 'auth',
          suggestedAction: 'Request a new password reset email.',
        );

      // Google Sign-In Errors
      case 'sign-in-cancelled':
        return const ErrorMessage(
          userMessage: 'Sign-in Cancelled',
          adminMessage: 'User cancelled the Google sign-in dialog.',
          category: 'info',
          suggestedAction: 'Try signing in again with Google.',
        );

      case 'network_error_google':
        return const ErrorMessage(
          userMessage: 'Connect Your Network',
          adminMessage:
              'Google sign-in failed due to network connectivity issue.',
          category: 'network',
          suggestedAction: 'Check your internet connection and try again.',
        );

      case 'google_account_not_available':
        return const ErrorMessage(
          userMessage: 'Google Account Unavailable',
          adminMessage: 'No Google account available on this device.',
          category: 'auth',
          suggestedAction:
              'Add a Google account to your device or use email/password login.',
        );

      // Account Blocked/Security
      case 'account_not_found_or_blocked':
        return const ErrorMessage(
          userMessage: 'Account Not Available',
          adminMessage: 'Account was not found or has been blocked.',
          category: 'blocked',
          suggestedAction: 'Contact support for assistance.',
        );

      // Database/Server Errors
      case 'permission-denied':
        return const ErrorMessage(
          userMessage: 'Unable to Access Account',
          adminMessage:
              'Firestore permission denied. User lacks necessary permissions.',
          category: 'error',
          suggestedAction: 'Contact support if this persists.',
        );

      case 'service-unavailable':
        return const ErrorMessage(
          userMessage: 'Service Temporarily Unavailable',
          adminMessage: 'Firebase services are currently unavailable.',
          category: 'error',
          suggestedAction: 'Please try again in a few moments.',
        );

      // Generic/Unknown Errors
      default:
        return ErrorMessage(
          userMessage: 'Something Went Wrong',
          adminMessage:
              'Authentication error: $errorCode${originalMessage != null ? ' - $originalMessage' : ''}',
          category: 'error',
          suggestedAction:
              'Please try again or contact support if the issue persists.',
        );
    }
  }

  /// Maps generic exceptions to error messages
  static ErrorMessage mapGenericError(
    dynamic exception, {
    String errorType = 'unknown',
  }) {
    final errorString = exception.toString().toLowerCase();

    // Network-related errors
    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout')) {
      return ErrorMessage(
        userMessage: 'Connect Your Network',
        adminMessage:
            'Network connectivity issue. Error: ${exception.toString()}',
        category: 'network',
        suggestedAction: 'Check your internet connection and try again.',
      );
    }

    // Permission errors
    if (errorString.contains('permission') || errorString.contains('denied')) {
      return ErrorMessage(
        userMessage: 'Access Denied',
        adminMessage: 'Permission denied. Error: ${exception.toString()}',
        category: 'security',
        suggestedAction: 'Contact support if you believe this is an error.',
      );
    }

    // Default generic error
    return ErrorMessage(
      userMessage: 'Something Went Wrong',
      adminMessage:
          'An unexpected error occurred (Type: $errorType). Details: ${exception.toString()}',
      category: 'error',
      suggestedAction: 'Please try again or contact support.',
    );
  }

  /// Format error message for user display
  static String formatForUser(ErrorMessage error) {
    return error.userMessage;
  }

  /// Format error message for admin/console display
  static String formatForAdmin(ErrorMessage error) {
    return '${error.adminMessage}\n→ Suggested: ${error.suggestedAction ?? "N/A"}';
  }

  /// Format error message for logging
  static String formatForLog(ErrorMessage error) {
    return '[${error.category.toUpperCase()}] Admin: ${error.adminMessage} | User: ${error.userMessage}';
  }
}
