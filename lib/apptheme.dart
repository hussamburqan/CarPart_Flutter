import 'package:flutter/material.dart';

class AppTheme {
  // Light Theme Colors
  static const Color primaryColor = Color(0xFF2563EB);
  static const Color secondaryColor = Color(0xFF3B82F6);
  static const Color backgroundColor = Colors.white;
  static const Color errorColor = Color(0xFFEF4444);
  static const Color textColor = Color(0xFF1F2937);
  static const Color subtitleColor = Color(0xFF6B7280);
  static const Color borderColor = Color(0xFFE5E7EB);

  // Dark Theme Colors
  static const Color darkPrimaryColor = Color(0xFF60A5FA);
  static const Color darkSecondaryColor = Color(0xFF3B82F6);
  static const Color darkBackgroundColor = Color(0xFF111827);
  static const Color darkSurfaceColor = Color(0xFF1F2937);
  static const Color darkErrorColor = Color(0xFFFCA5A5);
  static const Color darkTextColor = Color(0xFFF9FAFB);
  static const Color darkSubtitleColor = Color(0xFF9CA3AF);
  static const Color darkBorderColor = Color(0xFF374151);

  static ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
      background: backgroundColor,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onError: Colors.white,
      onBackground: textColor,
      onSurface: textColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        minimumSize: const Size(double.infinity, 56),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor),
      ),
      labelStyle: const TextStyle(color: subtitleColor),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: borderColor),
      ),
      color: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundColor,
      foregroundColor: textColor,
      elevation: 0,
      centerTitle: true,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: textColor),
      titleMedium: TextStyle(color: textColor),
      titleSmall: TextStyle(color: textColor),
      bodyLarge: TextStyle(color: textColor),
      bodyMedium: TextStyle(color: textColor),
      bodySmall: TextStyle(color: subtitleColor),
    ),
    dividerTheme: const DividerThemeData(
      color: borderColor,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    primaryColor: darkPrimaryColor,
    scaffoldBackgroundColor: darkBackgroundColor,
    colorScheme: const ColorScheme.dark(
      primary: darkPrimaryColor,
      secondary: darkSecondaryColor,
      error: darkErrorColor,
      background: darkBackgroundColor,
      surface: darkSurfaceColor,
      onPrimary: darkBackgroundColor,
      onSecondary: darkBackgroundColor,
      onError: darkBackgroundColor,
      onBackground: darkTextColor,
      onSurface: darkTextColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkPrimaryColor,
        foregroundColor: darkBackgroundColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        minimumSize: const Size(double.infinity, 56),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurfaceColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkPrimaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkErrorColor),
      ),
      labelStyle: const TextStyle(color: darkSubtitleColor),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: darkBorderColor),
      ),
      color: darkSurfaceColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackgroundColor,
      foregroundColor: darkTextColor,
      elevation: 0,
      centerTitle: true,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: darkTextColor),
      titleMedium: TextStyle(color: darkTextColor),
      titleSmall: TextStyle(color: darkTextColor),
      bodyLarge: TextStyle(color: darkTextColor),
      bodyMedium: TextStyle(color: darkTextColor),
      bodySmall: TextStyle(color: darkSubtitleColor),
    ),
    dividerTheme: const DividerThemeData(
      color: darkBorderColor,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkSurfaceColor,
      selectedItemColor: darkPrimaryColor,
      unselectedItemColor: darkSubtitleColor,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return darkPrimaryColor;
        }
        return darkSubtitleColor;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return darkPrimaryColor.withOpacity(0.5);
        }
        return darkSubtitleColor.withOpacity(0.5);
      }),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return darkPrimaryColor;
        }
        return darkSubtitleColor;
      }),
      checkColor: MaterialStateProperty.all(darkBackgroundColor),
    ),
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return darkPrimaryColor;
        }
        return darkSubtitleColor;
      }),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: darkSurfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: darkSurfaceColor,
      contentTextStyle: const TextStyle(color: darkTextColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

