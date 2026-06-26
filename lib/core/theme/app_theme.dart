import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFF333333);

  static ThemeData get monochromeTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: black,
      primaryColor: white,
      colorScheme: const ColorScheme.dark(
        primary: white,
        secondary: white,
        surface: black,
        error: white,
      ),
      textTheme: GoogleFonts.pressStart2pTextTheme(
        ThemeData.dark().textTheme.apply(
          bodyColor: white,
          displayColor: white,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: black,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: white,
          foregroundColor: black,
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        color: black,
      ),
      dialogTheme: const DialogThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        backgroundColor: black,
      ),
    );
  }
}
