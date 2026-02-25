import 'package:flutter/material.dart';

/// OnlyCars design system — Arabic-first, RTL-aware.
///
/// Brand colors:
/// - Primary: Deep crimson (#8B1A1A) → luxury, power
/// - Secondary: Gold accent (#D4A437) → premium, trust
/// - Surface: Near-black (#0D0D0D) → sleek dark mode
/// - Background: True dark (#121212)

class OcColors {
  OcColors._();

  // Brand
  static const Color primary = Color(0xFF8B1A1A);
  static const Color primaryLight = Color(0xFFB22222);
  static const Color primaryDark = Color(0xFF5C1111);
  static const Color secondary = Color(0xFFD4A437);
  static const Color secondaryLight = Color(0xFFE8C96A);
  static const Color secondaryDark = Color(0xFFA07D2A);

  // Neutrals
  static const Color surface = Color(0xFF1A1A1A);
  static const Color surfaceLight = Color(0xFF2A2A2A);
  static const Color surfaceCard = Color(0xFF1E1E1E);
  static const Color background = Color(0xFF121212);
  static const Color backgroundLight = Color(0xFFF8F8F8);

  // Text
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textDarkSecondary = Color(0xFF666666);

  // Status
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFF9A825);
  static const Color info = Color(0xFF1976D2);

  // Borders
  static const Color border = Color(0xFF333333);
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFF2A2A2A);
}

class OcSpacing {
  OcSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

class OcRadius {
  OcRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 100;
}

class OcShadows {
  OcShadows._();

  static List<BoxShadow> get card => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.2),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get elevated => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}
