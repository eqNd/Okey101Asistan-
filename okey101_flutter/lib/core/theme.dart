// lib/core/theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static const bg = Color(0xFF080C14);
  static const surface = Color(0xFF0F1520);
  static const surface2 = Color(0xFF161E2E);
  static const surface3 = Color(0xFF1C2640);
  static const border = Color(0xFF1F2D45);
  static const accent = Color(0xFFFF3D5A);
  static const accent2 = Color(0xFF00D4FF);
  static const accent3 = Color(0xFFFFB800);
  static const green = Color(0xFF00E676);
  static const textPrimary = Color(0xFFE8EDF5);
  static const textSecondary = Color(0xFF7A8BA8);

  // Tile colors
  static const tileRed = Color(0xFFD63031);
  static const tileBlue = Color(0xFF0984E3);
  static const tileYellow = Color(0xFFF9CA24);
  static const tileBlack = Color(0xFF636E72);

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.dark(
      primary: accent,
      secondary: accent2,
      surface: surface,
      background: bg,
      onPrimary: Colors.white,
      onSurface: textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: bg,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: 'Orbitron',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
        color: textPrimary,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      indicatorColor: accent2.withOpacity(0.15),
      labelTextStyle: MaterialStateProperty.all(
        const TextStyle(fontSize: 10, fontFamily: 'SpaceMono', letterSpacing: 0.5),
      ),
    ),
    cardTheme: CardTheme(
      color: surface2,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: border),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        textStyle: const TextStyle(
          fontFamily: 'Rajdhani', fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 1,
        ),
      ),
    ),
  );
}
