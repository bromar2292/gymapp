import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color primaryColor = Color(0xFF5B67CA);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color shadowColor = Color(0x1A000000);
  static const Color textColor = Colors.black;
  static const Color subtitleColor = Color(0xFF9E9E9E);
  static const Color inputBackgroundColor = Color(0xFFE8E8F5);

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: _buildColorScheme(),
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: _buildAppBarTheme(),
        cardTheme: _buildCardTheme(),
        elevatedButtonTheme: _buildElevatedButtonTheme(),
        outlinedButtonTheme: _buildOutlinedButtonTheme(),
        inputDecorationTheme: _buildInputDecorationTheme(),
      );

  static ColorScheme _buildColorScheme() {
    return ColorScheme.fromSeed(
      seedColor: primaryColor,
    );
  }

  static AppBarTheme _buildAppBarTheme() {
    return const AppBarTheme(
      backgroundColor: backgroundColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  static CardTheme _buildCardTheme() {
    return CardTheme(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textColor,
        side: const BorderSide(
          color: textColor,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }

  static InputDecorationTheme _buildInputDecorationTheme() {
    return InputDecorationTheme(
      filled: true,
      fillColor: inputBackgroundColor,
      border: _buildDefaultInputBorder(),
      enabledBorder: _buildDefaultInputBorder(),
      focusedBorder: _buildFocusedInputBorder(),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
    );
  }

  static OutlineInputBorder _buildDefaultInputBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    );
  }

  static OutlineInputBorder _buildFocusedInputBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(
        color: primaryColor,
        width: 2,
      ),
    );
  }
}
