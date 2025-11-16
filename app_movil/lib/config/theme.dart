import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData theme = ThemeData(
    primarySwatch: Colors.red,
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.red,
      accentColor: Colors.redAccent,
      cardColor: Colors.white,
      backgroundColor: Colors.grey[200],
      errorColor: Colors.red,
    ).copyWith(
      primary: const Color(0xFF800000), // Rojo granate
      secondary: const Color(0xFFB71C1C),
    ),
    appBarTheme: const AppBarTheme(
      color: Color(0xFF800000), // Rojo granate
      elevation: 4,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: Color(0xFFFFFFFF),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(
          color: Color(0xFF800000), // Rojo granate
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF800000), // Rojo granate
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
      ),
    ),
  );
}
