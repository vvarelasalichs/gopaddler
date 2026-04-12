import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF3D3D63); // GoPaddler Navy
const Color secondaryColor = Color(0xFF00A5CC); // Light Blue
const Color accentColor = Color(0xFFFFC107); // Amber

const Color successColor = Color(0xFF4CAF50);
const Color errorColor = Color(0xFFF44336);
const Color warningColor = Color(0xFFFF9800);
const Color infoColor = Color(0xFF2196F3);

const Color backgroundColor = Color(0xFFFAFAFA);
const Color surfaceColor = Color(0xFFFFFFFF);
const Color borderColor = Color(0xFFE0E0E0);

const Color textPrimaryColor = Color(0xFF212121);
const Color textSecondaryColor = Color(0xFF757575);
const Color textTertiaryColor = Color(0xFFBDBDBD);

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  primaryColor: primaryColor,
  scaffoldBackgroundColor: backgroundColor,
  colorScheme: ColorScheme.light(
    primary: primaryColor,
    secondary: secondaryColor,
    tertiary: accentColor,
    error: errorColor,
    surface: surfaceColor,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onError: Colors.white,
    onSurface: textPrimaryColor,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: surfaceColor,
    selectedItemColor: primaryColor,
    unselectedItemColor: textTertiaryColor,
    elevation: 8,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    elevation: 8,
  ),
  cardTheme: CardThemeData(
    color: surfaceColor,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 2,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: primaryColor,
      side: const BorderSide(color: primaryColor),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: borderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: primaryColor, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  primaryColor: primaryColor,
  scaffoldBackgroundColor: const Color(0xFF121212),
  colorScheme: ColorScheme.dark(
    primary: primaryColor,
    secondary: secondaryColor,
    tertiary: accentColor,
    error: errorColor,
    surface: const Color(0xFF1E1E1E),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onError: Colors.black,
    onSurface: Colors.white,
  ),
);
