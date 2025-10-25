import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';
  Locale _locale = const Locale('en', ''); // Varsayılan dil İngilizce
  bool _isInitialized = false;

  Locale get locale => _locale;
  bool get isInitialized => _isInitialized;

  // Desteklenen diller
  static const List<Locale> supportedLocales = [
    Locale('tr', ''), // Türkçe
    Locale('en', ''), // İngilizce
    Locale('es', ''), // İspanyolca
  ];

  // Dil isimleri
  String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'tr':
        return 'Türkçe';
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      default:
        return 'English';
    }
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final localeCode = prefs.getString(_localeKey);

      if (localeCode != null) {
        final savedLocale = Locale(localeCode);
        if (supportedLocales.contains(savedLocale)) {
          _locale = savedLocale;
        }
      }
    } catch (e) {
      // Varsayılan dili kullan
      _locale = const Locale('en', '');
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
    } catch (e) {
      // Hata durumunda sadece log tut, UI güncellemesini geri alma
    }
  }
}
