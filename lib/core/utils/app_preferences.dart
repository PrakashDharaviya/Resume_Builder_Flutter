import 'package:flutter/material.dart';

/// Global theme notifier — used by ProfilePage and ResumeIQApp
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

/// Global language notifier — 'English', 'Hindi', 'Gujarati'
final ValueNotifier<String> languageNotifier = ValueNotifier('English');
