import 'package:flutter/material.dart';

class AppColors {
  static const orange = Color(0xFFE87722);
  static const blue = Color(0xFF3DA8D4);
  static const green = Color(0xFF8CC63F);
  static const darkGrey = Color(0xFF4A4A4A);
  static const lightGrey = Color(0xFF757575);
}

ThemeData buildAppTheme() {
  const seed = AppColors.blue;

  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seed,
      primary: AppColors.blue,
      secondary: AppColors.orange,
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.blue,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    ),
  );
}
