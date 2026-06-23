import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Brand & Accent
  static const Color primary = Color(0xFFE91D2A); // Dell Red
  static const Color yellowSticker = Color(0xFFFCC20F); // Dell Yellow
  static const Color purpleStripe = Color(0xFF6A26A4); // Dell Purple
  
  // Surface
  static const Color frameInk = Color(0xFF000000); // Pure Black
  static const Color canvas = Color(0xFFFFFFFF); // Pure White
  
  // Text & Links
  static const Color ink = Color(0xFF000000); // Pure Black
  static const Color link = Color(0xFF0000EE); // Classic blue
  
  // Ribbon-Card Tint Family
  static const Color tintOlive = Color(0xFF8E8A25);
  static const Color tintSage = Color(0xFFB3BD95);
  static const Color tintSalmon = Color(0xFFD77A7A);
  static const Color tintPeach = Color(0xFFE6915D);
  static const Color tintLime = Color(0xFFC0D4A7);
  static const Color tintSky = Color(0xFF9AB6C8);
  static const Color tintSteel = Color(0xFFA5B8C0);
  static const Color tintPeriwinkle = Color(0xFF8C9AE0);

  // Modern flutter theme compatibility aliases to avoid compilation failures
  static const Color background = canvas;
  static const Color surface = canvas;
  static const Color surfaceContainerLow = canvas;
  static const Color surfaceContainer = canvas;
  static const Color surfaceContainerHigh = canvas;
  static const Color surfaceContainerHighest = canvas;
  static const Color surfaceVariant = canvas;
  static const Color surfaceBright = canvas;
  static const Color surfaceDim = canvas;
  static const Color onSurface = ink;
  static const Color onSurfaceVariant = ink;
  static const Color onBackground = ink;
  static const Color outline = frameInk;
  static const Color outlineVariant = frameInk;
  static const Color onPrimary = canvas;
  static const Color error = primary;
}

class AppTheme {
  static ThemeData get darkTheme {
    // Keep the getter name for compatibility with main.dart, but configure it as the retro theme
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.canvas,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.canvas,
        secondary: AppColors.yellowSticker,
        onSecondary: AppColors.ink,
        surface: AppColors.canvas,
        onSurface: AppColors.ink,
        error: AppColors.primary,
        onError: AppColors.canvas,
        outline: AppColors.frameInk,
      ),
      // Typography: Arimo (Arial clone) for UI/headings, Tinos (Times New Roman clone) for body
      textTheme: TextTheme(
        // Display - Arial Black (using Arimo w900)
        displayLarge: GoogleFonts.arimo(
          fontSize: 36,
          fontWeight: FontWeight.w900,
          height: 1.0,
          color: AppColors.ink,
        ),
        displayMedium: GoogleFonts.arimo(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          height: 1.0,
          color: AppColors.ink,
        ),
        displaySmall: GoogleFonts.arimo(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          height: 1.05,
          color: AppColors.ink,
        ),
        
        // Headings - Helvetica/Arial Bold
        headlineLarge: GoogleFonts.arimo(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 1.2,
          color: AppColors.ink,
        ),
        headlineMedium: GoogleFonts.arimo(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          height: 1.2,
          color: AppColors.ink,
        ),
        headlineSmall: GoogleFonts.arimo(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          height: 1.2,
          color: AppColors.ink,
        ),
        
        // Body - Times New Roman (using Tinos)
        bodyLarge: GoogleFonts.tinos(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.4,
          color: AppColors.ink,
        ),
        bodyMedium: GoogleFonts.tinos(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.4,
          color: AppColors.ink,
        ),
        bodySmall: GoogleFonts.tinos(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.4,
          color: AppColors.ink,
        ),
        
        // Button & Labels - Helvetica/Arial Bold
        labelLarge: GoogleFonts.arimo(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          height: 1.0,
          color: AppColors.ink,
        ),
        labelMedium: GoogleFonts.arimo(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          height: 1.0,
          color: AppColors.ink,
        ),
        labelSmall: GoogleFonts.arimo(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          height: 1.0,
          color: AppColors.ink,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.canvas,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.frameInk, width: 1.0),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.frameInk, width: 1.0),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.frameInk, width: 2.0),
        ),
        labelStyle: GoogleFonts.tinos(color: AppColors.ink, fontSize: 14),
        hintStyle: GoogleFonts.tinos(color: Colors.grey[600], fontSize: 14),
      ),
      buttonTheme: const ButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.frameInk,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.canvas),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        color: AppColors.canvas,
      ),
    );
  }

  static TextStyle get monoData => GoogleFonts.tinos(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w400,
        color: AppColors.ink,
      );
}
