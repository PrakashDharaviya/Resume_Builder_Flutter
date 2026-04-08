import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global theme notifier — used by ProfilePage and ResumeIQApp
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

/// Global language notifier — 'English', 'Hindi', 'Gujarati'
final ValueNotifier<String> languageNotifier = ValueNotifier('English');

class AppPreferences {
  static const String _lastReadNotificationsKey =
      'last_read_notifications_time_ms';

  static DateTime? lastReadNotificationsTime;

  static Future<void> loadLastReadTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampMs = prefs.getInt(_lastReadNotificationsKey);
      if (timestampMs != null) {
        lastReadNotificationsTime = DateTime.fromMillisecondsSinceEpoch(
          timestampMs,
        );
      }
    } catch (_) {
      // Ignore errors
    }
  }

  static Future<void> saveLastReadTime(DateTime time) async {
    try {
      lastReadNotificationsTime = time;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        _lastReadNotificationsKey,
        time.millisecondsSinceEpoch,
      );
    } catch (_) {
      // Ignore errors
    }
  }
}
