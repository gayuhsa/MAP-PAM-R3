import 'package:flutter/material.dart';

class AppTheme {
  // === WARNA DASAR ===
  static const Color background    = Color(0xFFF0F7F5);
  static const Color container     = Color(0xFFF0F7F5);
  static const Color subcontainer  = Color(0xFFF4F6F8);
  static const Color bottomBar     = Color(0xFFFFFFFF);
  static const Color card          = Color(0xFFD8E1D7);
  static const Color cardBorder    = Color(0xFFE0E0E0);
  static const Color chipExpense   = Color(0xFFE09698);
  static const Color chipIncome    = Color(0xFF99b096);
  static const Color authContainer = Color(0xFFF8F9F8);
  static const Color authTextBox   = Color(0xFFFFFFFF);
  static const Color inputField    = Color(0xFFF0F7F5);
  static const Color text          = Color(0xFF21291F);
  static const Color textInverted  = Colors.white;
  static const Color button        = Color(0xFFD8E1D7);
  static const Color button2       = Color(0xFF759470);
  static const Color buttonDanger  = Color(0xFFB83A3C);
  static const Color buttonInactive = Color.fromARGB(119, 255, 255, 255);
  static const Color buttonTextInactive = Color.fromARGB(166, 255, 255, 255);
  static const Color trashButton   = Color(0xFFB83A3C);
  static const Color editButton    = Color(0xFF4D6149);
  static const Color greyButton    = Color(0xFFF0F7F5);

  static ThemeData get themeData => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4d6149),
      surface: const Color(0xFFF3F6F3),
    ),
    scaffoldBackgroundColor: const Color(0xFFF0F7F5),

    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF4d6149),
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),

    bottomAppBarTheme: const BottomAppBarThemeData(color: Color(0xFF4d6149)),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: const Color(0xFF4d6149),
      foregroundColor: Colors.white,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4d6149),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),

    cardTheme: CardThemeData(
      color: Color(0xFF4d6149),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color.fromARGB(255, 255, 255, 255),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF3A4A38), width: 2),
      ),
    ),

    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Color(0xFF4d6149)),
      bodyLarge: TextStyle(color: Color(0xFF4d6149)),
    ),
  );
}
