import 'package:flutter/material.dart';

class AppTheme {
  static const _opsBlue = Color(0xFF1F5FBF);
  static const _opsBlueDark = Color(0xFF133663);
  static const _opsBlueSoft = Color(0xFF4D84D8);
  static const _opsMist = Color(0xFFF3F7FC);
  static const _opsOutline = Color(0xFFD6E1F0);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _opsBlue,
      primary: _opsBlue,
      secondary: _opsBlueSoft,
      surface: Colors.white,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _opsMist,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        foregroundColor: _opsBlueDark,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFFFCFDFF),
        elevation: 0,
        shadowColor: const Color(0x14142F57),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: _opsOutline),
        ),
      ),
      dividerColor: _opsOutline,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: _opsOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: _opsOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: _opsBlue, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _opsBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: const Color(0x221F5FBF),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFEAF2FC),
        side: const BorderSide(color: _opsOutline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          color: _opsBlueDark,
        ),
      ),
    );
  }
}
