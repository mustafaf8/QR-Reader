import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';

enum AppTheme {
  blue,
  teal,
  purple;

  Color get seedColor {
    switch (this) {
      case AppTheme.blue:
        return Colors.blue;
      case AppTheme.teal:
        return Colors.teal;
      case AppTheme.purple:
        return Colors.purple;
    }
  }

  String getDisplayName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case AppTheme.blue:
        return l10n.blueTheme;
      case AppTheme.teal:
        return l10n.tealTheme;
      case AppTheme.purple:
        return l10n.purpleTheme;
    }
  }
}

enum AppThemeMode {
  light,
  dark,
  system;

  String getDisplayName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case AppThemeMode.light:
        return l10n.lightTheme;
      case AppThemeMode.dark:
        return l10n.darkTheme;
      case AppThemeMode.system:
        return l10n.systemTheme;
    }
  }
}

class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'app_theme';
  static const String _themeModeKey = 'app_theme_mode';
  AppTheme _currentTheme = AppTheme.blue;
  AppThemeMode _currentThemeMode = AppThemeMode.system;
  bool _isInitialized = false;

  AppTheme get currentTheme => _currentTheme;
  AppThemeMode get currentThemeMode => _currentThemeMode;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Renk temasını yükle
      final themeIndex = prefs.getInt(_themeKey);
      if (themeIndex != null &&
          themeIndex >= 0 &&
          themeIndex < AppTheme.values.length) {
        _currentTheme = AppTheme.values[themeIndex];
      }

      // Tema modunu yükle
      final themeModeIndex = prefs.getInt(_themeModeKey);
      if (themeModeIndex != null &&
          themeModeIndex >= 0 &&
          themeModeIndex < AppThemeMode.values.length) {
        _currentThemeMode = AppThemeMode.values[themeModeIndex];
      }
    } catch (e) {
      // Varsayılan temaları kullan
      _currentTheme = AppTheme.blue;
      _currentThemeMode = AppThemeMode.system;
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setTheme(AppTheme theme) async {
    if (_currentTheme == theme) return;

    _currentTheme = theme;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, theme.index);
    } catch (e) {
      // Hata durumunda sadece log tut, UI güncellemesini geri alma
    }
  }

  Future<void> setThemeMode(AppThemeMode themeMode) async {
    if (_currentThemeMode == themeMode) return;

    _currentThemeMode = themeMode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeModeKey, themeMode.index);
    } catch (e) {
      // Hata durumunda sadece log tut, UI güncellemesini geri alma
    }
  }

  ThemeData getThemeData(bool isDarkMode) {
    // Tema moduna göre brightness belirle
    Brightness brightness;
    switch (_currentThemeMode) {
      case AppThemeMode.light:
        brightness = Brightness.light;
        break;
      case AppThemeMode.dark:
        brightness = Brightness.dark;
        break;
      case AppThemeMode.system:
        brightness = isDarkMode ? Brightness.dark : Brightness.light;
        break;
    }

    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _currentTheme.seedColor,
        brightness: brightness,
      ),
      useMaterial3: true,
    );
  }
}
