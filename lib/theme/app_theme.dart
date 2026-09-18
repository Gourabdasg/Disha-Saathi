import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central design tokens for Disha Saathi (Disha Saathi)
/// Colors extracted from the SIH design mockups: deep navy -> teal gradient.
class AppColors {
  static const Color navyDark = Color(0xFF16305C);
  static const Color navy = Color(0xFF1B3B6F);
  static const Color teal = Color(0xFF1FA383);
  static const Color tealLight = Color(0xFF2FBF9B);
  static const Color bgLight = Color(0xFFF2F5F9);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A2233);
  static const Color textMuted = Color(0xFF6B7686);
  static const Color success = Color(0xFF2FBF6B);
  static const Color warning = Color(0xFFF5A623);
  static const Color danger = Color(0xFFE0503A);
  static const Color purple = Color(0xFF7C5CFF);
  static const Color orange = Color(0xFFF08A3C);

  static const List<Color> primaryGradient = [navyDark, teal];
  static const List<Color> buttonGradient = [Color(0xFF1B3B6F), Color(0xFF1FBF98)];
}

class AppTheme {
  static ThemeData get theme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.navy,
        primary: AppColors.navy,
        secondary: AppColors.teal,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
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
