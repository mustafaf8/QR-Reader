import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'services/hive_service.dart';
import 'services/theme_service.dart';
import 'providers/locale_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive servisini başlat
  try {
    await HiveService().initialize();
  } catch (e) {
    // Hive başlatma hatası
  }

  // Tema servisini başlat
  final themeService = ThemeService();
  await themeService.initialize();

  // Dil servisini başlat
  final localeProvider = LocaleProvider();
  await localeProvider.initialize();

  // Global hata yakalama
  FlutterError.onError = (FlutterErrorDetails details) {
    // Hata yakalama
  };

  // Platform hata yakalama
  PlatformDispatcher.instance.onError = (error, stack) {
    // Platform hata yakalama
    return true;
  };

  runApp(
    QRReaderApp(themeService: themeService, localeProvider: localeProvider),
  );
}

class QRReaderApp extends StatelessWidget {
  final ThemeService themeService;
  final LocaleProvider localeProvider;

  const QRReaderApp({
    super.key,
    required this.themeService,
    required this.localeProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeService),
        ChangeNotifierProvider.value(value: localeProvider),
      ],
      child: Consumer2<ThemeService, LocaleProvider>(
        builder: (context, themeService, localeProvider, child) {
          return MaterialApp(
            title: 'QR Okuyucu',
            theme: themeService.getThemeData(false),
            darkTheme: themeService.getThemeData(true),
            themeMode: themeService.currentThemeMode == AppThemeMode.light
                ? ThemeMode.light
                : themeService.currentThemeMode == AppThemeMode.dark
                ? ThemeMode.dark
                : ThemeMode.system,
            locale: localeProvider.locale,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: LocaleProvider.supportedLocales,
            home: const HomePage(),
          );
        },
      ),
    );
  }
}
