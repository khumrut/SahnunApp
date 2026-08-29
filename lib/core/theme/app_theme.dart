import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFF070707);
  static const Color surface = Color(0xFF111111);
  static const Color gold = Color(0xFFD9B43B);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF9A9A9A);

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.dark(
      primary: gold,
      secondary: gold,
      surface: surface,
    ),
    useMaterial3: true,
  );
}
