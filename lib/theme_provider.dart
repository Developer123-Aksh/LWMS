import 'package:flutter/material.dart';

enum UserRole {
  admin,
  manager,
  supervisor,
  labour,
  guest, // default / logged out
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  UserRole _role = UserRole.guest;

  ThemeMode get themeMode => _themeMode;
  UserRole get role => _role;

  void toggleTheme() {
    _themeMode =
    _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void setRole(UserRole role) {
    if (_role == role) return;
    _role = role;
    notifyListeners();
  }

  /// 🔥 MUST be called on logout
  void resetToGuest() {
    _role = UserRole.guest;
    _themeMode = ThemeMode.system;
    notifyListeners();
  }
}

/// ======================================================
/// APP THEME DEFINITIONS
/// ======================================================
class AppTheme {
  /// ---------- LIGHT ----------
  static ThemeData lightTheme(UserRole role) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor(role),
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _primaryColor(role),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _primaryColor(role),
      ),
    );
  }

  /// ---------- DARK ----------
  static ThemeData darkTheme(UserRole role) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor(role),
        brightness: Brightness.dark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[900],
        foregroundColor: _primaryColor(role),
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _primaryColor(role),
      ),
    );
  }

  /// ---------- ROLE COLORS ----------
  static Color _primaryColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return const Color(0xFF1976D2); // Blue
      case UserRole.manager:
        return const Color(0xFF7B1FA2); // Purple
      case UserRole.supervisor:
        return const Color(0xFF388E3C); // Green
      case UserRole.labour:
        return const Color(0xFFE64A19); // Orange
      case UserRole.guest:
        return const Color(0xFF607D8B); // Blue Grey (default)
    }
  }
}
