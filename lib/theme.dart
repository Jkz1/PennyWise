import 'package:flutter/material.dart';

class FinTrackTheme {
  // --- CORE BRAND COLORS ---
  static const Color primaryColor = Color(0xFF00BFA5);   // Emerald/Teal
  static const Color secondaryColor = Color(0xFF64FFDA); // Bright Aquamarine
  static const Color deepIndigo = Color(0xFF1A237E);    // Brand Text/Dark Blue
  static const Color darkBg = Color(0xFF101015);
  static const Color lightBg = Color(0xFFF5F7FA);

  // --- DYNAMIC LOGIC ---

  // Matches your logic: White in dark mode, Deep Indigo in light mode
  static Color getTextColor(bool isDarkMode) {
    return isDarkMode ? Colors.white : deepIndigo;
  }

  // Matches your opacity settings exactly
  static Color getGlassColor(bool isDarkMode) {
    return isDarkMode
        ? Colors.white.withOpacity(0.08)
        : Colors.white.withOpacity(0.6);
  }

  // Matches your border opacity settings
  static Color getGlassBorder(bool isDarkMode) {
    return isDarkMode
        ? Colors.white.withOpacity(0.1)
        : Colors.grey.withOpacity(0.2);
  }

  // --- THEME DATA ---

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: lightBg,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: darkBg,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
    ),
  );
}