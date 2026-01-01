import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'theme.light.dart';
import 'theme.dark.dart';

class AppTheme {
  /// Switch theme mode
  static void toggleTheme() {
    if (Get.isDarkMode) {
      Get.changeThemeMode(ThemeMode.light);
    } else {
      Get.changeThemeMode(ThemeMode.dark);
    }
  }

  /// Set light theme
  static void setLightTheme() => Get.changeTheme(lightTheme);

  /// Set dark theme
  static void setDarkTheme() => Get.changeTheme(darkTheme);
}
