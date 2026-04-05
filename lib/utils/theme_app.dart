import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static const Color bgDeep     = Color(0xFF080C10);
  static const Color bgCard     = Color(0xFF0D1117);
  static const Color bgSurface  = Color(0xFF111820);
  static const Color bgElevated = Color(0xFF161E28);

  static const Color neonGreen  = Color(0xFF00FF87);
  static const Color neonBlue   = Color(0xFF00D4FF);
  static const Color neonRed    = Color(0xFFFF3B5C);
  static const Color neonAmber  = Color(0xFFFFB800);

  static const Color textPrimary   = Color(0xFFE2EAF4);
  static const Color textSecondary = Color(0xFF6B8BA4);
  static const Color textMuted     = Color(0xFF2E4460);
  static const Color borderIdle    = Color(0xFF1E3048);

  static Color colorEstatus(String? status) {
    switch (status) {
      case 'pendiente':  return neonGreen;
      case 'cancelado':  return neonRed;
      case 'completado': return neonBlue;
      default:           return textMuted;
    }
  }

  static IconData iconoEstatus(String? status) {
    switch (status) {
      case 'pendiente':  return Icons.radio_button_checked;
      case 'cancelado':  return Icons.block;
      case 'completado': return Icons.check_circle_outline;
      default:           return Icons.help_outline;
    }
  }

  static ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDeep,
      fontFamily: 'Exo2',
      colorScheme: const ColorScheme.dark(
        primary: neonGreen, secondary: neonBlue, error: neonRed,
        surface: bgCard, onPrimary: bgDeep, onSecondary: bgDeep,
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgDeep, foregroundColor: textPrimary, elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light),
        titleTextStyle: TextStyle(
          fontFamily: 'ShareTechMono', fontSize: 15, color: neonGreen,
          letterSpacing: 2),
      ),
      cardTheme: const CardThemeData(
        color: bgCard, elevation: 0, margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: bgSurface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(
            color: textSecondary, fontFamily: 'ShareTechMono', fontSize: 12),
        hintStyle: const TextStyle(color: textMuted),
        border: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: borderIdle)),
        enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: borderIdle)),
        focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: neonGreen, width: 1.5)),
        prefixIconColor: textSecondary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, foregroundColor: neonGreen,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          side: const BorderSide(color: neonGreen, width: 1.5),
          textStyle: const TextStyle(
              fontFamily: 'ShareTechMono', fontSize: 13, letterSpacing: 2),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textSecondary,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          side: const BorderSide(color: borderIdle),
          textStyle: const TextStyle(
              fontFamily: 'ShareTechMono', fontSize: 11, letterSpacing: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: bgSurface,
        selectedColor: neonGreen.withOpacity(0.15),
        labelStyle: const TextStyle(
            fontFamily: 'ShareTechMono', fontSize: 11, color: textSecondary),
        side: const BorderSide(color: borderIdle),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      dividerTheme:
          const DividerThemeData(color: borderIdle, thickness: 1, space: 1),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: bgElevated,
        contentTextStyle: TextStyle(
            color: textPrimary, fontFamily: 'ShareTechMono', fontSize: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        titleTextStyle: TextStyle(
            fontFamily: 'ShareTechMono', fontSize: 14,
            color: neonGreen, letterSpacing: 1.5),
      ),
    );
  }

}
