import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central design tokens for Disha Saathi (Disha Saathi)
/// Updated to a clean, professional Material Royal Blue & White palette.
class AppColors {
  static const Color navyDark = Color(0xFF0D47A1);  // Deep royal blue header
  static const Color navy = Color(0xFF1565C0);      // Primary medium royal blue
  static const Color teal = Color(0xFF1976D2);      // Vibrant royal blue accent
  static const Color tealLight = Color(0xFF2196F3); // Brighter blue highlight / progress
  static const Color bgLight = Color(0xFFFFFFFF);   // Clean white background
  static const Color cardWhite = Color(0xFFFFFFFF); // White card
  static const Color textDark = Color(0xFF1A1A2E);  // Dark near-black text
  static const Color textMuted = Color(0xFF6B7280); // Muted gray text
  static const Color success = Color(0xFF2E7D32);   // Standard green checkmarks
  static const Color warning = Color(0xFFF9A825);   // Standard amber/orange warning
  static const Color danger = Color(0xFFD32F2F);    // Standard red error/danger
  static const Color purple = Color(0xFF1E88E5);    // Soft blue tag
  static const Color orange = Color(0xFFF9A825);    // Accent amber

  // Flat blue & subtle royal blue gradients
  static const List<Color> primaryGradient = [Color(0xFF0D47A1), Color(0xFF1976D2)];
  static const List<Color> buttonGradient = [Color(0xFF1565C0), Color(0xFF2196F3)];
}

class AppTheme {
  static ThemeData get theme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.navy,
        primary: AppColors.navy,
        secondary: AppColors.teal,
        surface: AppColors.bgLight,
      ),
      scaffoldBackgroundColor: AppColors.bgLight,
      fontFamily: GoogleFonts.poppins().fontFamily,
    );

    return base.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textDark,
        displayColor: AppColors.textDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFFE5E7EB), width: 1), // Subtle light gray card border
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.navy, width: 1.5),
        ),
        hintStyle: const TextStyle(color: AppColors.textMuted),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.navy,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }
}

/// Reusable gradient background used on splash, onboarding headers, login header.
class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  const GradientBackground({super.key, required this.child, this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors ?? AppColors.primaryGradient,
        ),
      ),
      child: child,
    );
  }
}
