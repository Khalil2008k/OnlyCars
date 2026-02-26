import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tokens.dart';

/// OnlyCars v2 Theme — light-first, clean, minimal.
class OcTheme {
  OcTheme._();

  // ── LIGHT THEME (PRIMARY) ────────────────────────────
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: OcColors.background,
    colorScheme: const ColorScheme.light(
      primary: OcColors.accent,
      primaryContainer: OcColors.accentDark,
      secondary: OcColors.accent,
      secondaryContainer: OcColors.secondaryLight,
      surface: OcColors.surface,
      error: OcColors.error,
      onPrimary: OcColors.onAccent,
      onSecondary: OcColors.onAccent,
      onSurface: OcColors.textPrimary,
      onError: OcColors.textOnPrimary,
    ),
    textTheme: _textTheme,

    // App bar — clean white, no shadow
    appBarTheme: const AppBarTheme(
      backgroundColor: OcColors.background,
      foregroundColor: OcColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: OcColors.textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
      ),
    ),

    // Cards — no border, subtle background
    cardTheme: CardThemeData(
      color: OcColors.background,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(OcRadius.card),
      ),
    ),

    // Primary button — lime green pill
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: OcColors.accent,
        foregroundColor: OcColors.onAccent,
        minimumSize: const Size(double.infinity, 52),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OcRadius.lg),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),

    // Outlined button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: OcColors.textPrimary,
        minimumSize: const Size(double.infinity, 52),
        side: const BorderSide(color: OcColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OcRadius.lg),
        ),
      ),
    ),

    // Inputs — light gray fill, rounded, no visible border
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: OcColors.surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(OcRadius.searchBar),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(OcRadius.searchBar),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(OcRadius.searchBar),
        borderSide: const BorderSide(color: OcColors.accent, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: OcColors.textMuted, fontSize: 15),
    ),

    // Chips — pill shape
    chipTheme: ChipThemeData(
      backgroundColor: OcColors.chipInactive,
      selectedColor: OcColors.chipActive,
      labelStyle: const TextStyle(color: OcColors.textPrimary, fontSize: 13),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(OcRadius.chip),
        side: const BorderSide(color: OcColors.chipBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: OcColors.divider,
      thickness: 0.5,
    ),

    // Snackbar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: OcColors.navBar,
      contentTextStyle: const TextStyle(color: OcColors.textOnPrimary),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(OcRadius.md)),
    ),

    // Bottom nav — we'll use a custom widget, but set defaults
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
  );

  // ── DARK THEME ───────────────────────────────────────
  // Keep dark for backward compatibility but now secondary
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: const ColorScheme.dark(
      primary: OcColors.accent,
      primaryContainer: OcColors.accentDark,
      secondary: OcColors.accent,
      surface: Color(0xFF1A1A1A),
      error: OcColors.error,
      onPrimary: OcColors.onAccent,
      onSecondary: OcColors.onAccent,
      onSurface: Color(0xFFF5F5F5),
      onError: OcColors.textOnPrimary,
    ),
    textTheme: _textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A1A1A),
      foregroundColor: Color(0xFFF5F5F5),
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(OcRadius.card),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: OcColors.accent,
        foregroundColor: OcColors.onAccent,
        minimumSize: const Size(double.infinity, 52),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OcRadius.lg),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(OcRadius.searchBar),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(OcRadius.searchBar),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(OcRadius.searchBar),
        borderSide: const BorderSide(color: OcColors.accent, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );

  // ── TYPOGRAPHY ───────────────────────────────────────
  static TextTheme get _textTheme => GoogleFonts.tajawalTextTheme(
    const TextTheme(
      displayLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: OcColors.textPrimary),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: OcColors.textPrimary),
      displaySmall:  TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: OcColors.textPrimary),
      headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: OcColors.textPrimary),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: OcColors.textPrimary),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: OcColors.textPrimary),
      titleLarge:    TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: OcColors.textPrimary),
      titleMedium:   TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: OcColors.textPrimary),
      titleSmall:    TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: OcColors.textPrimary),
      bodyLarge:     TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: OcColors.textPrimary),
      bodyMedium:    TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: OcColors.textPrimary),
      bodySmall:     TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: OcColors.textDarkSecondary),
      labelLarge:    TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: OcColors.textPrimary),
      labelMedium:   TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: OcColors.textDarkSecondary),
      labelSmall:    TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: OcColors.textDarkSecondary),
    ),
  );
}
