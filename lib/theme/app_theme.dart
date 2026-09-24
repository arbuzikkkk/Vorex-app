import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// VOREX design tokens — Luxury Y2K / dark glassmorphism.
class VorexColors {
  static const Color bgDeep = Color(0xFF050505);
  static const Color bgPanel = Color(0xFF111111);
  static const Color accent = Color(0xFF8A0F16);
  static const Color accentBright = Color(0xFFB8151D);
  static const Color white = Color(0xFFFFFFFF);
  static const Color greyText = Color(0xFF9A9A9A);
  static const Color glassBorder = Color(0x22FFFFFF);
  static const Color success = Color(0xFF2ECC71);
  static const Color danger = Color(0xFFE74C3C);
}

class AppTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: VorexColors.bgDeep,
      colorScheme: base.colorScheme.copyWith(
        primary: VorexColors.accent,
        secondary: VorexColors.accentBright,
        surface: VorexColors.bgPanel,
        error: VorexColors.danger,
      ),
      textTheme: GoogleFonts.manropeTextTheme(base.textTheme).apply(
        bodyColor: VorexColors.white,
        displayColor: VorexColors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: VorexColors.bgPanel,
        selectedItemColor: VorexColors.accentBright,
        unselectedItemColor: VorexColors.greyText,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: VorexColors.accent,
          foregroundColor: VorexColors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: VorexColors.bgPanel,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: VorexColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: VorexColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: VorexColors.accentBright, width: 1.4),
        ),
        hintStyle: const TextStyle(color: VorexColors.greyText),
      ),
    );
  }
}
