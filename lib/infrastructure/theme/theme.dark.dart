import 'package:flutter/material.dart';
import 'package:slims/core/constants/colors.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: MasterColor.primary,
  colorScheme: ColorScheme.dark(
    primary: MasterColor.primary,
    secondary: MasterColor.secondary,
    surface: MasterColor.dark_80,
    error: MasterColor.danger,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: MasterColor.dark_80,
    foregroundColor: MasterColor.white,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: MasterColor.dark_70,
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
);
