import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'liturgical_colors.dart';

class AppTheme {
  AppTheme._();

  // Color primario de acento por defecto: Dorado Litúrgico
  static const Color primaryGold = Color(0xFFC9A227);
  static const Color burgundyDeep = Color(0xFF5B1425);
  static const Color darkBg = Color(0xFF121316);
  static const Color darkSurface = Color(0xFF1E2024);
  static const Color darkCard = Color(0xFF26292E);

  static const Color lightBg = Color(0xFFF9F7F2); // Tono marfil/pergamino suave
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF3EEE6);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryGold,
      scaffoldBackgroundColor: lightBg,
      colorScheme: ColorScheme.light(
        primary: primaryGold,
        secondary: LiturgicalColors.verde,
        surface: lightSurface,
        surfaceContainerHighest: lightCard,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: const Color(0xFF1A1A1A),
      ),
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.cinzel(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1F1B16),
          letterSpacing: 0.5,
        ),
        headlineMedium: GoogleFonts.cinzel(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1F1B16),
        ),
        titleLarge: GoogleFonts.cinzel(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1F1B16),
        ),
        bodyLarge: GoogleFonts.merriweather(
          fontSize: 17,
          height: 1.65,
          color: const Color(0xFF232323),
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          height: 1.5,
          color: const Color(0xFF4B4B4B),
        ),
        labelLarge: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightBg,
        foregroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cinzel(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1A1A1A),
        ),
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightSurface,
        selectedItemColor: primaryGold,
        unselectedItemColor: Color(0xFF888888),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryGold,
      scaffoldBackgroundColor: darkBg,
      colorScheme: ColorScheme.dark(
        primary: primaryGold,
        secondary: LiturgicalColors.verde,
        surface: darkSurface,
        surfaceContainerHighest: darkCard,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: const Color(0xFFEDE8DF),
      ),
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.cinzel(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFF2ECE1),
          letterSpacing: 0.5,
        ),
        headlineMedium: GoogleFonts.cinzel(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFF2ECE1),
        ),
        titleLarge: GoogleFonts.cinzel(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFF2ECE1),
        ),
        bodyLarge: GoogleFonts.merriweather(
          fontSize: 17,
          height: 1.65,
          color: const Color(0xFFE2DDD5),
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          height: 1.5,
          color: const Color(0xFFAFAFAF),
        ),
        labelLarge: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBg,
        foregroundColor: const Color(0xFFF2ECE1),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cinzel(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFF2ECE1),
        ),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: primaryGold,
        unselectedItemColor: Color(0xFF757575),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
