import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide theme state. Same light/dark colors on every page (home, dashboard, etc.).
class ThemeProvider extends ChangeNotifier {
  static const String _keyDarkMode = 'app_is_dark_mode';

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_keyDarkMode) ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, _isDarkMode);
    notifyListeners();
  }

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  // Shared colors used across app (home, dashboard, etc.)
  static const Color barColor = Color(0xFF111827);
  static const Color scaffoldDark = Color(0xFF0F172A);
  static const Color scaffoldLight = Color(0xFFFEFCF8);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color cardLight = Colors.white;
  static const Color surfaceDark = Color(0xFF353535);
  static const Color surfaceLight = Color(0xFFF5F7FA);
  static const Color textPrimaryDark = Colors.white;
  static const Color textPrimaryLight = Color(0xFF1A2332);
  static const Color textSecondaryDark = Colors.white70;
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color primary = Color(0xFF21C8B1);

  ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: scaffoldLight,
        colorScheme: ColorScheme.light(
          primary: primary,
          surface: surfaceLight,
          onSurface: textPrimaryLight,
          onSurfaceVariant: textSecondaryLight,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: barColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: cardLight,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: cardLight,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

  ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: scaffoldDark,
        colorScheme: ColorScheme.dark(
          primary: primary,
          surface: surfaceDark,
          onSurface: textPrimaryDark,
          onSurfaceVariant: textSecondaryDark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: barColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: cardDark,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: cardDark,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
}
