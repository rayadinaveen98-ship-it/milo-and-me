import 'package:flutter/material.dart';

abstract final class Brand {
  static const name = 'Milo & Me';
  static const defaultPet = 'Milo';
  static const tagline = 'Little adventures. A lovely friendship.';
  static const cream = Color(0xFFFFF8EA);
  static const ink = Color(0xFF344A46);
  static const sage = Color(0xFF638A72);
  static const mint = Color(0xFFDCEBDC);
  static const peach = Color(0xFFF3BA9A);
  static const lavender = Color(0xFFDDD8ED);
  static const gold = Color(0xFFF4CD71);
  static const sky = Color(0xFFD2E5EC);
  static const petColors = [
    Color(0xFFF0BD85),
    Color(0xFFA8C5AE),
    Color(0xFFB9ACD4),
  ];
  static ThemeData theme() => ThemeData(
    fontFamily: 'Roboto',
    useMaterial3: true,
    scaffoldBackgroundColor: cream,
    colorScheme: ColorScheme.fromSeed(
      seedColor: sage,
      surface: cream,
      onSurface: ink,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: ink,
        height: 1.12,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: ink,
      ),
      titleLarge: TextStyle(
        fontSize: 23,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      bodyLarge: TextStyle(fontSize: 18, color: ink, height: 1.5),
      bodyMedium: TextStyle(fontSize: 16, color: ink, height: 1.45),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: cream,
      foregroundColor: ink,
      centerTitle: true,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: ink,
        foregroundColor: cream,
        minimumSize: const Size(56, 58),
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
        textStyle: const TextStyle(fontFamily: 'Roboto', fontSize: 18, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
    ),
  );
}
