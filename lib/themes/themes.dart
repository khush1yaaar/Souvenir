import 'package:flutter/material.dart';


class CustomTheme {
  // Light mode colors
  static const Color _lightDominant = Color(0xFFF8F5F2); // Cream White
  static const Color _lightSecondary = Color(0xFF8BA888); // Sage Green
  static const Color _lightAccent = Color(0xFFD17B60); // Terracotta
  static const Color _lightTextPrimary = Color(0xFF333333); // Dark text
  static const Color _lightTextSecondary = Color(0xFF666666); // Lighter text

  // Dark mode colors
  static const Color _darkDominant = Color(0xFF1A1E26); // Dark Charcoal
  static const Color _darkSecondary = Color(0xFF5E8B7E); // Muted Teal
  static const Color _darkAccent = Color(0xFFD77A61); // Soft Coral
  static const Color _darkTextPrimary = Color(0xFFF0F0F0); // Light text
  static const Color _darkTextSecondary = Color(0xFFCCCCCC); // Slightly dimmed text

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: _lightSecondary,
      scaffoldBackgroundColor: _lightDominant,
      appBarTheme: AppBarTheme(
        backgroundColor: _lightDominant,
        titleTextStyle: TextStyle(
          color: _lightTextPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        iconTheme: IconThemeData(color: _lightSecondary),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: _lightTextPrimary,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: _lightTextPrimary,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(color: _lightTextPrimary),
        bodyMedium: TextStyle(color: _lightTextPrimary),
        bodySmall: TextStyle(color: _lightTextSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightSecondary,
          foregroundColor: _lightDominant,
        ),
      ),
      iconTheme: IconThemeData(color: _lightAccent),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _lightAccent,
        foregroundColor: _lightDominant,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: _darkSecondary,
      scaffoldBackgroundColor: _darkDominant,
      appBarTheme: AppBarTheme(
        backgroundColor: _darkDominant,
        titleTextStyle: TextStyle(
          color: _darkTextPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        iconTheme: IconThemeData(color: _darkSecondary),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: _darkTextPrimary,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: _darkTextPrimary,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(color: _darkTextPrimary),
        bodyMedium: TextStyle(color: _darkTextPrimary),
        bodySmall: TextStyle(color: _darkTextSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkSecondary,
          foregroundColor: _darkDominant,
        ),
      ),
      iconTheme: IconThemeData(color: _darkAccent),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _darkAccent,
        foregroundColor: _darkDominant,
      ),
    );
  }
}