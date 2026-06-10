import 'package:flutter/material.dart';

class AppTheme {
  // === WARNA DASAR ===
  static const Color background = Color(0xFFD6E8E4);
  static const Color container = Color(0xFFFFFFFF);
  static const Color subcontainer = Color(0xFFF4F6F8);
  static const Color bottomBar = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE0E0E0);
  static const Color chipExpense = Color(0xFFF2A6A6);
  static const Color chipIncome = Color(0xFFA6D4A8);
  static const Color authContainer = Color(0xFFFFFFFF);
  static const Color authTextBox = Color(0xFFFFFFFF);
  static const Color inputField = Color(0xFFF0F7F5);
  static const Color text = Color(0xFF1C2D42);
  static const Color textInverted = Colors.white;
  static const Color button = Color(0xFF0D5C52);
  static const Color buttonDanger = Color(0xFFB83A3C);
  static const Color trashButton = Color(0xFFB83A3C);
  static const Color editButton = Color(0xFF0D5C52);
  static const Color greyButton = Color(0xFFF0F7F5);

  // === THEME DATA ===
  static ThemeData get themeData => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF0D5C52),
      surface: const Color(0xFFF0F7F5),
    ),
    scaffoldBackgroundColor: const Color(0xFFD6E8E4),

    // AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF5FA8A8),
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),

    // Bottom Nav
    bottomAppBarTheme: const BottomAppBarThemeData(color: Color(0xFFFFFFFF)),

    // FAB
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: const Color(0xFF0D5C52),
      foregroundColor: Colors.white,
    ),

    // ElevatedButton
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0D5C52),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),

    // Card
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
    ),

    // InputDecoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF0F7F5),
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
        borderSide: const BorderSide(color: Color(0xFF0D5C52), width: 2),
      ),
    ),

    // Teks default
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Color(0xFF1C2D42)),
      bodyLarge: TextStyle(color: Color(0xFF1C2D42)),
    ),
  );
}
