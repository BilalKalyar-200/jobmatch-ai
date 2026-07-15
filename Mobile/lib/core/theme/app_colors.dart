import 'package:flutter/material.dart';

/// Color tokens for the JobMatch premium design system.
class AppColors {
  // Brand — indigo to violet. This gradient is the app's one signature
  // accent: used only for the score ring and the active nav tab.
  static const brand600 = Color(0xFF4F46E5);
  static const brand700 = Color(0xFF6D28D9);
  static const accent = Color(0xFF8B7CFF);

  static const surface = Color(0xFFF5F5FC);
  static const surfaceElevated = Color(0xFFFFFFFF);
  static const surfaceDark = Color(0xFF0A0A12);
  static const cardDark = Color(0xFF15141F);
  static const borderDark = Color(0xFF26243A);

  static const slate900 = Color(0xFF0F172A);
  static const slate700 = Color(0xFF334155);
  static const slate600 = Color(0xFF475569);
  static const slate500 = Color(0xFF64748B);
  static const slate400 = Color(0xFF94A3B8);
  static const slate300 = Color(0xFFCBD5E1);
  static const slate200 = Color(0xFFE2E8F0);
  static const slate100 = Color(0xFFF1F5F9);
  static const slate50 = Color(0xFFF8FAFC);

  static const green50 = Color(0xFFF0FDF4);
  static const green200 = Color(0xFFBBF7D0);
  static const green800 = Color(0xFF166534);
  static const amber50 = Color(0xFFFFFBEB);
  static const amber200 = Color(0xFFFDE68A);
  static const amber800 = Color(0xFF92400E);
  static const red600 = Color(0xFFDC2626);

  /// The one signature gradient in the app, adapted per theme brightness.
  static LinearGradient primaryGradient(bool isDark) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark ? [accent, brand700] : [brand600, brand700],
    );
  }
}
