import 'package:intl/intl.dart';

class DateFormatter {
  // Format date to readable string (e.g., "Jan 2024")
  static String formatMonthYear(DateTime date) {
    return DateFormat('MMM yyyy').format(date);
  }

  // Format date to full string (e.g., "January 15, 2024")
  static String formatFullDate(DateTime date) {
    return DateFormat('MMMM dd, yyyy').format(date);
  }

  // Format date to short string (e.g., "01/15/2024")
  static String formatShortDate(DateTime date) {
    return DateFormat('MM/dd/yyyy').format(date);
  }

  // Format date to ISO string (e.g., "2024-01-15")
  static String formatISODate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Format date range (e.g., "Jan 2020 - Dec 2023")
  static String formatDateRange(DateTime start, DateTime? end) {
    final startStr = formatMonthYear(start);
    final endStr = end != null ? formatMonthYear(end) : 'Present';
    return '$startStr - $endStr';
  }

  // Parse string to date
  static DateTime? parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;

    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  // Get relative time (e.g., "2 days ago", "3 months ago")
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      }
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    }
  }

  // Calculate duration in months (for experience)
  static int calculateDurationInMonths(DateTime start, DateTime? end) {
    final endDate = end ?? DateTime.now();
    final months =
        (endDate.year - start.year) * 12 + (endDate.month - start.month);
    return months;
  }

  // Format duration (e.g., "2 years 3 months")
  static String formatDuration(DateTime start, DateTime? end) {
    final months = calculateDurationInMonths(start, end);

    if (months < 12) {
      return '$months month${months > 1 ? 's' : ''}';
    }

    final years = (months / 12).floor();
    final remainingMonths = months % 12;

    if (remainingMonths == 0) {
      return '$years year${years > 1 ? 's' : ''}';
    }

    return '$years year${years > 1 ? 's' : ''} $remainingMonths month${remainingMonths > 1 ? 's' : ''}';
  }
}
