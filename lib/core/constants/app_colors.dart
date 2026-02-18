import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF1E3A8A);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1E40AF);

  // Accent Colors
  static const Color accent = Color(0xFF10B981);
  static const Color accentLight = Color(0xFF34D399);
  static const Color accentDark = Color(0xFF059669);

  // Background Colors - Light Mode
  static const Color backgroundLight = Color(0xFFF9FAFB);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);

  // Background Colors - Dark Mode
  static const Color backgroundDark = Color.fromARGB(255, 14, 21, 36);
  static const Color surfaceDark = Color(0xFF1F2937);
  static const Color cardDark = Color(0xFF374151);

  // Text Colors - Light Mode
  static const Color textPrimaryLight = Color(0xFF111827);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textTertiaryLight = Color(0xFF9CA3AF);

  // Text Colors - Dark Mode
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFFD1D5DB);
  static const Color textTertiaryDark = Color(0xFF9CA3AF);

  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  // ATS Score Colors
  static const Color scoreExcellent = Color(0xFF10B981); // 80-100
  static const Color scoreGood = Color(0xFF3B82F6); // 60-79
  static const Color scoreAverage = Color(0xFFF59E0B); // 40-59
  static const Color scorePoor = Color(0xFFEF4444); // 0-39

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadow Colors
  static Color shadowLight = Colors.black.withOpacity(0.08);
  static Color shadowDark = Colors.black.withOpacity(0.3);
}
