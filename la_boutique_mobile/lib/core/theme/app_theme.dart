import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Sand palette
  static const Color sand50 = Color(0xFFFBF8F4);
  static const Color sand100 = Color(0xFFF5EEE2);
  static const Color sand200 = Color(0xFFECDCC6);
  static const Color sand300 = Color(0xFFDABF9B);
  static const Color sand400 = Color(0xFFC9A479);

  // Clay / Terracotta sunset palette
  static const Color clay50 = Color(0xFFFBF1EC);
  static const Color clay100 = Color(0xFFF4DDD0);
  static const Color clay200 = Color(0xFFE9BBA4);
  static const Color clay300 = Color(0xFFDB9B77);
  static const Color clay400 = Color(0xFFCD7F55);
  static const Color clay500 = Color(0xFFBD6638); // Primary brand color
  static const Color clay600 = Color(0xFFA1542E);
  static const Color clay700 = Color(0xFF834427);

  // Ocean / Sage accent
  static const Color ocean500 = Color(0xFF4F7E7C);
  static const Color ocean600 = Color(0xFF3C615F);

  // Neutral / Text
  static const Color ink = Color(0xFF2A2019);
  static const Color mute = Color(0xFF6E5E51);
  static const Color white = Colors.white;
  static const Color border = Color(0xFFECDCC6);
  static const Color cardBg = Colors.white;
  static const Color success = Color(0xFF2E7D32);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.sand50,
      primaryColor: AppColors.clay500,
      colorScheme: ColorScheme.light(
        primary: AppColors.clay500,
        onPrimary: AppColors.white,
        secondary: AppColors.clay600,
        onSecondary: AppColors.white,
        surface: AppColors.sand50,
        onSurface: AppColors.ink,
        error: Colors.red.shade700,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.sand50,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.ink),
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: AppColors.ink,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(
          color: AppColors.ink,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          color: AppColors.ink,
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.playfairDisplay(
          color: AppColors.ink,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: GoogleFonts.montserrat(
          color: AppColors.ink,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.montserrat(
          color: AppColors.ink,
          fontSize: 15,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.montserrat(
          color: AppColors.mute,
          fontSize: 13,
          fontWeight: FontWeight.w400,
          height: 1.4,
        ),
        labelLarge: GoogleFonts.montserrat(
          color: AppColors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.clay500,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.clay500,
          side: const BorderSide(color: AppColors.clay500, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.sand200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.sand200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.clay500, width: 1.5),
        ),
        hintStyle: GoogleFonts.montserrat(
          color: AppColors.mute.withOpacity(0.6),
          fontSize: 14,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.sand200, width: 0.8),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.clay500,
        unselectedItemColor: AppColors.mute,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
