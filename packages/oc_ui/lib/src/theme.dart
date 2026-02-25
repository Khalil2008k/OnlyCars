import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tokens.dart';

/// OnlyCars MaterialTheme — dark mode, Arabic-first typography.
class OcTheme {
  OcTheme._();

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: OcColors.background,
    colorScheme: const ColorScheme.dark(
      primary: OcColors.primary,
      primaryContainer: OcColors.primaryDark,
      secondary: OcColors.secondary,
      secondaryContainer: OcColors.secondaryDark,
      surface: OcColors.surface,
      error: OcColors.error,
      onPrimary: OcColors.textOnPrimary,
      onSecondary: OcColors.textDark,
      onSurface: OcColors.textPrimary,
      onError: OcColors.textOnPrimary,
    ),
    textTheme: _textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: OcColors.surface,
      foregroundColor: OcColors.textPrimary,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: OcColors.surfaceCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(OcRadius.lg),
        side: const BorderSide(color: OcColors.border, width: 0.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: OcColors.primary,
        foregroundColor: OcColors.textOnPrimary,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OcRadius.md),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: OcColors.primary,
        minimumSize: const Size(double.infinity, 52),
        side: const BorderSide(color: OcColors.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OcRadius.md),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: OcColors.surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(OcRadius.md),
        borderSide: const BorderSide(color: OcColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(OcRadius.md),
        borderSide: const BorderSide(color: OcColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(OcRadius.md),
        borderSide: const BorderSide(color: OcColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: OcColors.textSecondary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: OcColors.surface,
      selectedItemColor: OcColors.primary,
      unselectedItemColor: OcColors.textSecondary,
      type: BottomNavigationBarType.fixed,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: OcColors.surfaceLight,
      selectedColor: OcColors.primary,
      labelStyle: const TextStyle(color: OcColors.textPrimary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(OcRadius.pill),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: OcColors.divider,
      thickness: 0.5,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: OcColors.surfaceLight,
      contentTextStyle: const TextStyle(color: OcColors.textPrimary),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(OcRadius.md)),
    ),
  );

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: OcColors.backgroundLight,
    colorScheme: const ColorScheme.light(
      primary: OcColors.primary,
      primaryContainer: OcColors.primaryLight,
      secondary: OcColors.secondary,
      secondaryContainer: OcColors.secondaryLight,
      surface: Colors.white,
      error: OcColors.error,
      onPrimary: OcColors.textOnPrimary,
      onSecondary: OcColors.textDark,
      onSurface: OcColors.textDark,
      onError: OcColors.textOnPrimary,
    ),
    textTheme: _textTheme.apply(
      bodyColor: OcColors.textDark,
      displayColor: OcColors.textDark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: OcColors.textDark,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(OcRadius.lg),
        side: const BorderSide(color: OcColors.borderLight, width: 0.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: OcColors.primary,
        foregroundColor: OcColors.textOnPrimary,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OcRadius.md),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(OcRadius.md),
        borderSide: const BorderSide(color: OcColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(OcRadius.md),
        borderSide: const BorderSide(color: OcColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(OcRadius.md),
        borderSide: const BorderSide(color: OcColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: OcColors.primary,
      unselectedItemColor: OcColors.textDarkSecondary,
      type: BottomNavigationBarType.fixed,
    ),
  );

  static TextTheme get _textTheme => GoogleFonts.tajawalTextTheme(
    const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
      displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
      headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
    ),
  );
}
