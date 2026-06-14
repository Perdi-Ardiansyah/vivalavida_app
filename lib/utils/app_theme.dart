import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Colors ---
  static const Color primary = Color(0xFF00694C); // Forest Green
  static const Color background = Color(0xFFF7F9FD); // Cream base
  static const Color surface = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFF3C2A21); // Espresso Brown
  static const Color outline = Color(0xFFE5E7EB); // Light Grey

  // --- Theme Data ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: primary,
        surface: surface,
        background: background,
      ),

      // --- Typography ---
      textTheme: TextTheme(
        // Headlines (Montserrat)
        displayLarge: GoogleFonts.montserrat(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          color: secondaryText,
          letterSpacing: -0.02,
        ),
        headlineLarge: GoogleFonts.montserrat(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: secondaryText,
        ),
        headlineMedium: GoogleFonts.montserrat(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: secondaryText,
        ),
        
        // Body (Inter)
        bodyLarge: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: secondaryText,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: secondaryText,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: secondaryText,
        ),
      ),

      // --- Component Themes ---
      
      // Buttons (Primary: Forest Green, Pill-shaped/rounded-xl)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // xl: 1.5rem (approx 16-24px depending on scale)
          ),
        ),
      ),

      // Inputs (White background, Light Grey border, Green focus)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // rounded-lg
          borderSide: const BorderSide(color: outline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1),
        ),
      ),

      // Cards (White, rounded-2xl, subtle shadow)
      cardTheme: CardThemeData( // <--- Perbaikan (tambah kata "Data")
        color: surface,
        elevation: 1, // Will map to your Level 1 shadow
        shadowColor: const Color(0xFF3C2A21).withOpacity(0.04),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // rounded-2xl
        ),
      ),
    );
  }
}