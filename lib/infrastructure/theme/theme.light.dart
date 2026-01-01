import 'package:flutter/material.dart';
import 'package:slims/core/constants/colors.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: MasterColor.primary,
  scaffoldBackgroundColor: MasterColor.dark_10,
  colorScheme: ColorScheme.light(
    primary: MasterColor.primary,
    secondary: MasterColor.secondary,
    surface: MasterColor.white,
    error: MasterColor.danger,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: MasterColor.white,
    foregroundColor: MasterColor.dark,
    elevation: 0,
    titleTextStyle: TextStyle(
      color: MasterColor.dark,
      fontWeight: FontWeight.w700,
      fontSize: 18,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: MasterColor.dark_10,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: MasterColor.primary,
      foregroundColor: MasterColor.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: MasterColor.primary,
  ),
  snackBarTheme: const SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
  ),
);
