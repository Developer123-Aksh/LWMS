import 'package:flutter/material.dart';

// Theme Provider for managing dark/light mode
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  UserRole? _role;
  
  ThemeMode get themeMode => _themeMode;
  UserRole? get role => _role;

  
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
  
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
  void setRole(UserRole role) {
    if (_role == role) return;
    _role = role;
    notifyListeners();
  }
  void clearRole() {
    _role = null;
    notifyListeners();
  }
}

// Role-based color schemes
enum UserRole { admin, manager, supervisor, labour,guest }

class RoleColors {
  static const Map<UserRole, Color> primaryColors = {
    UserRole.admin: Color(0xFF1976D2), // Blue
    UserRole.manager: Color(0xFF7B1FA2), // Purple
    UserRole.supervisor: Color(0xFF388E3C), // Green
    UserRole.labour: Color(0xFFE64A19), // Orange
    UserRole.guest: Color(0xFF607D8B), // Blue Grey
  };
  
  static const Map<UserRole, Color> darkPrimaryColors = {
    UserRole.admin: Color(0xFF42A5F5), // Light Blue
    UserRole.manager: Color(0xFFAB47BC), // Light Purple
    UserRole.supervisor: Color(0xFF66BB6A), // Light Green
    UserRole.labour: Color(0xFFFF7043), // Light Orange
    UserRole.guest: Color(0xFF90A4AE), // Light Blue Grey
  };
  
  static Color getPrimaryColor(UserRole role, bool isDark) {
    return isDark ? darkPrimaryColors[role]! : primaryColors[role]!;
  }
}

// Theme configuration
class AppTheme {
  static ThemeData lightTheme(UserRole role) {
    final primaryColor = RoleColors.primaryColors[role]!;
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
  
  static ThemeData darkTheme(UserRole role) {
    final primaryColor = RoleColors.darkPrimaryColors[role]!;
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: const Color(0xFF1E1E1E),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: primaryColor,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: Color(0xFF1E1E1E),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}