import 'package:flutter/material.dart';
import 'package:resumebuilder/core/services/error_message_service.dart';

/// Enhanced error display widget with user-friendly messages
class ErrorDisplayWidget extends StatelessWidget {
  /// The error message object
  final ErrorMessage error;

  /// Whether to show admin detailed message (for debug mode)
  final bool showAdminDetails;

  /// Custom callback when user wants to retry
  final VoidCallback? onRetry;

  /// Whether to show the retry button
  final bool showRetry;

  /// Custom styling
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;

  const ErrorDisplayWidget({
    super.key,
    required this.error,
    this.showAdminDetails = false,
    this.onRetry,
    this.showRetry = true,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.padding,
  });

  /// Get icon based on error category
  IconData _getIcon() {
    switch (error.category) {
      case 'network':
        return Icons.wifi_off;
      case 'auth':
        return Icons.lock_open;
      case 'validation':
        return Icons.info_outline;
      case 'security':
        return Icons.security;
      case 'blocked':
        return Icons.block;
      case 'config':
        return Icons.settings;
      case 'info':
        return Icons.info_outline;
      default:
        return Icons.error_outline;
    }
  }

  /// Get color based on error category
  Color _getColor() {
    switch (error.category) {
      case 'network':
        return Colors.orange;
      case 'security':
      case 'blocked':
        return Colors.red;
      case 'validation':
        return Colors.amber;
      case 'info':
        return Colors.blue;
      default:
        return Colors.red;
    }
  }

  /// Format suggested action text
  String _formatSuggestedAction() {
    if (error.suggestedAction == null || error.suggestedAction!.isEmpty) {
      return '';
    }
    return '💡 ${error.suggestedAction}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryColor = _getColor();
    final bgColor =
        backgroundColor ?? (isDark ? Colors.grey[900] : Colors.red.shade50);
    final textColorValue =
        textColor ?? (isDark ? Colors.white : Colors.grey[900]);
    final brdColor = borderColor ?? categoryColor.withOpacity(0.3);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: brdColor, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: padding ?? const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Icon and Main Message
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_getIcon(), color: categoryColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User-Friendly Message
                    Text(
                      error.userMessage,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColorValue,
                      ),
                    ),
                    // Suggested Action
                    if (error.suggestedAction != null &&
                        error.suggestedAction!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _formatSuggestedAction(),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: textColorValue?.withOpacity(0.8),
                              ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          // Admin Details (if enabled)
          if (showAdminDetails)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(height: 16, color: categoryColor.withOpacity(0.2)),
                  Text(
                    '[ADMIN / DEBUG]',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: categoryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    error.adminMessage,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: textColorValue?.withOpacity(0.7),
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),

          // Retry Button
          if (showRetry && onRetry != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: categoryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Snackbar for error messages
class ErrorSnackbar {
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> show(
    BuildContext context,
    ErrorMessage error, {
    bool showAdminDetails = false,
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 3),
  }) {
    Color getBackgroundColor() {
      switch (error.category) {
        case 'network':
          return Colors.orange;
        case 'security':
        case 'blocked':
          return Colors.red;
        case 'validation':
          return Colors.amber;
        case 'info':
          return Colors.blue;
        default:
          return Colors.red;
      }
    }

    String getMessage() {
      final userMsg = ErrorMessageService.formatForUser(error);
      if (showAdminDetails) {
        return '❌ $userMsg\n📋 ${error.adminMessage}';
      }
      return userMsg;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    final controller = messenger.showSnackBar(
      SnackBar(
        content: Text(
          getMessage(),
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        backgroundColor: getBackgroundColor(),
        behavior: SnackBarBehavior.floating,
        duration: duration,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: onRetry != null
            ? SnackBarAction(
                label: 'RETRY',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );

    if (duration > Duration.zero) {
      Future<void>.delayed(duration, () {
        controller.close();
      });
    }

    return controller;
  }
}

/// Dialog for critical errors
class ErrorDialog {
  static Future<bool?> show(
    BuildContext context,
    ErrorMessage error, {
    bool showAdminDetails = false,
    String? actionButtonText,
    VoidCallback? onAction,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(_getIcon(error.category), color: _getColor(error.category)),
            const SizedBox(width: 8),
            Expanded(child: Text(error.userMessage)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (error.suggestedAction != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    '💡 ${error.suggestedAction}',
                    style: Theme.of(ctx).textTheme.bodyMedium,
                  ),
                ),
              if (showAdminDetails)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '[Admin Details]',
                        style: Theme.of(ctx).textTheme.labelSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        error.adminMessage,
                        style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx, true);
              onAction?.call();
            },
            child: Text(actionButtonText ?? 'OK'),
          ),
        ],
      ),
    );
  }

  static IconData _getIcon(String category) {
    switch (category) {
      case 'network':
        return Icons.wifi_off;
      case 'security':
      case 'blocked':
        return Icons.security;
      case 'validation':
        return Icons.info_outline;
      default:
        return Icons.error_outline;
    }
  }

  static Color _getColor(String category) {
    switch (category) {
      case 'network':
        return Colors.orange;
      case 'security':
      case 'blocked':
        return Colors.red;
      default:
        return Colors.red;
    }
  }
}
