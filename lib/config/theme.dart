import 'package:flutter/material.dart';

/// AI Portrait app unified theme configuration.
/// Dark, premium aesthetic optimized for tablet landscape mode.
/// Color scheme: black / white / gold-orange / grey.
class AppTheme {
  AppTheme._();

  // ── Core palette ──────────────────────────────────────────────────────
  static const Color background = Color(0xFF0D0D0D);
  static const Color primary = Color(0xFFF5A623);
  static const Color accent = Color(0xFFFF8C42);
  static const Color card = Color(0xFF1A1A1A);
  static const Color surface = Color(0xFF222222);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF888888);
  static const Color divider = Color(0xFF333333);

  // ── Gradients ─────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFF5A623), Color(0xFFFF8C42)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF8C42), Color(0xFFCC7A3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Dimensions ────────────────────────────────────────────────────────
  static const double borderRadius = 16.0;
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusLarge = 24.0;

  // ── Typography (tablet-optimized sizes) ───────────────────────────────
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.3,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textSecondary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textSecondary,
    height: 1.4,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: 0.5,
  );

  // ── ThemeData ─────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: surface,
        error: Color(0xFFCF6679),
        onPrimary: textPrimary,
        onSecondary: textPrimary,
        onSurface: textPrimary,
        onError: textPrimary,
      ),
      cardColor: card,
      dividerColor: divider,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        iconTheme: IconThemeData(color: textPrimary, size: 28),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          textStyle: labelLarge,
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: labelLarge,
        ),
      ),
      iconTheme: const IconThemeData(color: textPrimary, size: 28),
      textTheme: const TextTheme(
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: card,
        contentTextStyle: bodyMedium.copyWith(color: textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusSmall),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
