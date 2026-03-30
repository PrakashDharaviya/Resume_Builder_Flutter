import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// Global theme notifier — used by ProfilePage and ResumeIQApp
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

/// Global language notifier — 'English', 'Hindi', 'Gujarati'
final ValueNotifier<String> languageNotifier = ValueNotifier('English');

class AppPreferences {
  static DateTime? lastReadNotificationsTime;

  static Future<void> loadLastReadTime() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/last_read_notifications.txt');
      if (await file.exists()) {
        final timestampStr = await file.readAsString();
        lastReadNotificationsTime = DateTime.fromMillisecondsSinceEpoch(
          int.parse(timestampStr),
        );
      }
    } catch (_) {
      // Ignore errors
    }
  }

  static Future<void> saveLastReadTime(DateTime time) async {
    try {
      lastReadNotificationsTime = time;
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/last_read_notifications.txt');
      await file.writeAsString(time.millisecondsSinceEpoch.toString());
    } catch (_) {
      // Ignore errors
    }
  }
}

