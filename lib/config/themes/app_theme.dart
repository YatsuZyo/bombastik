// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Light Mode
  static const lightPrimary = Color(0xFF86C144);
  static const lightPrimaryVariant = Color(0xFF6EA037);
  static const lightPrimaryContainer = Color(0xFFE8F5E9);
  static const lightSecondary = Color(0xFF4DB6AC);
  static const lightSecondaryVariant = Color(0xFF00897B);
  static const lightTertiary = Color(0xFFFFD54F);
  static const lightBackground = Color(0xFFFFFFFF);
  static const lightSurface = Color(0xFFF5F5F5);
  static const lightError = Color(0xFFE57373);
  static const lightOnPrimary = Color(0xFFFFFFFF);
  static const lightOnBackground = Color(0xFF212121);
  static const lightOnSurface = Color(0xFF424242);

  // Dark Mode
  /*static const darkPrimary = Color(0xFF86C144);
  static const darkPrimaryVariant = Color(0xFFA5D66E);
  static const darkSecondary = Color(0xFF4DB6AC);
  static const darkTertiary = Color(0xFFFFD54F);
  static const darkBackground = Color(0xFF121212);
  static const darkSurface = Color(0xFF1E1E1E);
  static const darkError = Color(0xFFEF5350);
  static const darkOnPrimary = Color(0xFF000000);
  static const darkOnBackground = Color(0xFFFFFFFF);
  static const darkOnSurface = Color(0xFFE0E0E0);*/

  static const darkPrimary = Color(0xFF86C144); // Verde se mantiene
  static const darkPrimaryVariant = Color(0xFFA5D66E);
  static const darkSecondary = Color(0xFF4DB6AC);
  static const darkTertiary = Color(0xFFFFD54F);
  static const darkBackground = Color(0xFF1A2A3A); // Azul oscuro profundo
  static const darkSurface = Color(0xFF243B53); // Azul oscuro más claro
  static const darkError = Color(0xFFEF5350);
  static const darkOnPrimary = Color(0xFF000000);
  static const darkOnBackground = Color(0xFFFFFFFF);
  static const darkOnSurface = Color(0xFFE0E0E0);
  static const darkOutline = Color(0xFF3D5A78); // Borde azul intermedio
}

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: AppColors.lightPrimary,
      primaryContainer: AppColors.lightPrimaryContainer,
      secondary: AppColors.lightSecondary,
      tertiary: AppColors.lightTertiary,
      background: AppColors.lightBackground,
      surface: AppColors.lightSurface,
      error: AppColors.lightError,
      onPrimary: AppColors.lightOnPrimary,
      onBackground: AppColors.lightOnBackground,
      onSurface: AppColors.lightOnSurface,
      outline: AppColors.darkOutline,
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        color: AppColors.lightOnBackground,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 45,
        color: AppColors.lightOnBackground,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        color: AppColors.lightOnBackground,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        color: AppColors.lightOnSurface,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        color: AppColors.lightOnSurface.withOpacity(0.6),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.lightPrimary,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.lightOnPrimary,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.lightSurface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightPrimary,
        foregroundColor: AppColors.lightOnPrimary,
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkPrimary,
      secondary: AppColors.darkSecondary,
      tertiary: AppColors.darkTertiary,
      background: AppColors.darkBackground,
      surface: AppColors.darkSurface,
      error: AppColors.darkError,
      onPrimary: AppColors.darkOnPrimary,
      onBackground: AppColors.darkOnBackground,
      onSurface: AppColors.darkOnSurface,
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        color: AppColors.darkOnBackground,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 45,
        color: AppColors.darkOnBackground,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: AppColors.darkOnBackground,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        color: AppColors.darkOnBackground,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        color: AppColors.darkOnSurface,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        color: AppColors.darkOnSurface.withOpacity(0.6),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.darkOnBackground,
      ),
      iconTheme: IconThemeData(color: AppColors.darkOnBackground),
      systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.darkBackground,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    ),
    cardTheme: CardTheme(
      color: AppColors.darkSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.darkOutline.withOpacity(0.3)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface.withOpacity(0.9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.darkOutline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.darkOutline.withOpacity(0.5)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    dividerTheme: DividerThemeData(
      color: AppColors.darkOutline.withOpacity(0.4),
      thickness: 1,
      space: 1,
    ),
  );
}
