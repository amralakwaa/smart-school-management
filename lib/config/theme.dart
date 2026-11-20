// ثيم التطبيق - App Theme
// تصميم عربي احترافي

import 'package:flutter/material.dart';

class AppTheme {
  // الألوان الرئيسية
  static const Color primaryColor = Color(0xFF1565C0); // أزرق داكن
  static const Color secondaryColor = Color(0xFF42A5F5); // أزرق فاتح
  static const Color accentColor = Color(0xFFFF9800); // برتقالي

  // ألوان الأدوار
  static const Color adminColor = Color(0xFFE53935); // أحمر
  static const Color teacherColor = Color(0xFFFF9800); // برتقالي
  static const Color studentColor = Color(0xFF1E88E5); // أزرق

  // ألوان الحالات
  static const Color successColor = Color(0xFF4CAF50); // أخضر
  static const Color errorColor = Color(0xFFF44336); // أحمر
  static const Color warningColor = Color(0xFFFF9800); // برتقالي
  static const Color infoColor = Color(0xFF2196F3); // أزرق

  // ألوان الخلفية
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color darkBackground = Color(0xFF121212);

  /// الثيم الفاتح
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Cairo',

    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    // Cards
    cardTheme: const CardThemeData(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    // Text Fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: const TextStyle(fontFamily: 'Cairo'),
      hintStyle: TextStyle(fontFamily: 'Cairo', color: Colors.grey[500]),
    ),

    // Floating Action Button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentColor,
      foregroundColor: Colors.white,
    ),

    // Bottom Navigation
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(
        fontFamily: 'Cairo',
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: TextStyle(fontFamily: 'Cairo'),
    ),

    // Dialogs
    dialogTheme: const DialogThemeData(
      titleTextStyle: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    ),

    // Snackbar
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),

    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
      displayMedium: TextStyle(
        fontFamily: 'Cairo',
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
      headlineLarge: TextStyle(
        fontFamily: 'Cairo',
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Cairo',
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Cairo',
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
      titleMedium: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
      titleSmall: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontFamily: 'Cairo'),
      bodyMedium: TextStyle(fontFamily: 'Cairo'),
      bodySmall: TextStyle(fontFamily: 'Cairo'),
      labelLarge: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
      labelMedium: TextStyle(fontFamily: 'Cairo'),
      labelSmall: TextStyle(fontFamily: 'Cairo'),
    ),
  );

  /// لون حسب الدور
  static Color getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return adminColor;
      case 'teacher':
        return teacherColor;
      case 'student':
        return studentColor;
      default:
        return primaryColor;
    }
  }

  /// أيقونة حسب الدور
  static IconData getRoleIcon(String role) {
    switch (role) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'teacher':
        return Icons.school;
      case 'student':
        return Icons.person;
      default:
        return Icons.person;
    }
  }
}
