import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

enum LogLevel { debug, info, warning, error, fatal }

class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final String? error;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? extra;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.error,
    this.stackTrace,
    this.extra,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'level': level.name,
      'message': message,
      'error': error,
      'stackTrace': stackTrace?.toString(),
      'extra': extra,
    };
  }

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      timestamp: DateTime.parse(json['timestamp']),
      level: LogLevel.values.firstWhere(
        (e) => e.name == json['level'],
        orElse: () => LogLevel.info,
      ),
      message: json['message'],
      error: json['error'],
      stackTrace: json['stackTrace'] != null
          ? StackTrace.fromString(json['stackTrace'])
          : null,
      extra: json['extra'],
    );
  }

  String get formattedMessage {
    final timeStr = timestamp.toLocal().toString().substring(11, 19);
    final levelStr = level.name.toUpperCase().padRight(7);
    return '[$timeStr] $levelStr: $message';
  }
}

class LogService {
  static final LogService _instance = LogService._internal();
  factory LogService() => _instance;
  LogService._internal();

  late Logger _logger;
  final List<LogEntry> _logs = [];
  static const int _maxLogs = 1000; // Maksimum log sayısı
  static const String _logFileName = 'qr_reader_logs.json';

  void initialize() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
    );

    // Uygulama başlangıcında log
    info('LogService initialized');
  }

  void debug(String message, {Map<String, dynamic>? extra}) {
    _addLog(LogLevel.debug, message, extra: extra);
    _logger.d(message);
  }

  void info(String message, {Map<String, dynamic>? extra}) {
    _addLog(LogLevel.info, message, extra: extra);
    _logger.i(message);
  }

  void warning(String message, {Map<String, dynamic>? extra}) {
    _addLog(LogLevel.warning, message, extra: extra);
    _logger.w(message);
  }

  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  }) {
    _addLog(
      LogLevel.error,
      message,
      error: error?.toString(),
      stackTrace: stackTrace,
      extra: extra,
    );
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  void fatal(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  }) {
    _addLog(
      LogLevel.fatal,
      message,
      error: error?.toString(),
      stackTrace: stackTrace,
      extra: extra,
    );
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  void _addLog(
    LogLevel level,
    String message, {
    String? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  }) {
    final logEntry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
      error: error,
      stackTrace: stackTrace,
      extra: extra,
    );

    _logs.add(logEntry);

    // Maksimum log sayısını aşarsa eski logları sil
    if (_logs.length > _maxLogs) {
      _logs.removeRange(0, _logs.length - _maxLogs);
    }

    // Dosyaya kaydet (asenkron)
    _saveToFile(logEntry);
  }

  Future<void> _saveToFile(LogEntry logEntry) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_logFileName');

      // Mevcut logları oku
      List<LogEntry> existingLogs = [];
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final List<dynamic> jsonList = jsonDecode(content);
          existingLogs = jsonList
              .map((json) => LogEntry.fromJson(json))
              .toList();
        }
      }

      // Yeni logu ekle
      existingLogs.add(logEntry);

      // Maksimum log sayısını kontrol et
      if (existingLogs.length > _maxLogs) {
        existingLogs = existingLogs.sublist(existingLogs.length - _maxLogs);
      }

      // Dosyaya yaz
      final jsonList = existingLogs.map((log) => log.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      // Dosya yazma hatası - sadece konsola yazdır
      if (kDebugMode) {
        print('Log dosyası yazma hatası: $e');
      }
    }
  }

  List<LogEntry> getLogs({LogLevel? level, int? limit}) {
    List<LogEntry> filteredLogs = _logs;

    if (level != null) {
      filteredLogs = filteredLogs.where((log) => log.level == level).toList();
    }

    if (limit != null && limit > 0) {
      filteredLogs = filteredLogs.take(limit).toList();
    }

    return filteredLogs.reversed.toList(); // En yeni loglar önce
  }

  Future<List<LogEntry>> getLogsFromFile({LogLevel? level, int? limit}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_logFileName');

      if (!await file.exists()) {
        return [];
      }

      final content = await file.readAsString();
      if (content.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(content);
      List<LogEntry> logs = jsonList
          .map((json) => LogEntry.fromJson(json))
          .toList();

      if (level != null) {
        logs = logs.where((log) => log.level == level).toList();
      }

      if (limit != null && limit > 0) {
        logs = logs.take(limit).toList();
      }

      return logs.reversed.toList(); // En yeni loglar önce
    } catch (e) {
      error('Log dosyası okuma hatası', error: e);
      return [];
    }
  }

  Future<void> clearLogs() async {
    _logs.clear();

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_logFileName');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      error('Log dosyası silme hatası', error: e);
    }
  }

  Future<String> exportLogs() async {
    try {
      final logs = await getLogsFromFile();
      final jsonString = jsonEncode(logs.map((log) => log.toJson()).toList());
      return jsonString;
    } catch (e) {
      error('Log export hatası', error: e);
      return '{}';
    }
  }

  int get logCount => _logs.length;

  List<LogEntry> get recentLogs => getLogs(limit: 50);
}
