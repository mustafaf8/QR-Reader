import 'dart:ui';
import 'package:flutter/material.dart';
import 'services/hive_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive servisini başlat
  try {
    await HiveService().initialize();
  } catch (e) {
    // Hive başlatma hatası
  }

  // Global hata yakalama
  FlutterError.onError = (FlutterErrorDetails details) {
    // Hata yakalama
  };

  // Platform hata yakalama
  PlatformDispatcher.instance.onError = (error, stack) {
    // Platform hata yakalama
    return true;
  };

  runApp(const QRReaderApp());
}

class QRReaderApp extends StatelessWidget {
  const QRReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Okuyucu',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
