import 'package:hive_flutter/hive_flutter.dart';
import '../models/qr_scan_model.dart';
import 'log_service.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  static const String _qrScansBoxName = 'qr_scans';
  Box<QrScanModel>? _qrScansBox;

  Future<void> initialize() async {
    try {
      LogService().info('HiveService başlatılıyor');

      // Hive'ı başlat
      await Hive.initFlutter();

      // Adapter'ları kaydet
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(QrScanModelAdapter());
      }

      // Box'ları aç
      _qrScansBox = await Hive.openBox<QrScanModel>(_qrScansBoxName);

      LogService().info(
        'HiveService başarıyla başlatıldı',
        extra: {'totalScans': _qrScansBox?.length ?? 0},
      );
    } catch (e, stackTrace) {
      LogService().error(
        'HiveService başlatma hatası',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // QR tarama kaydetme
  Future<void> saveQrScan(QrScanModel scan) async {
    try {
      await _qrScansBox?.put(scan.id, scan);
      LogService().info(
        'QR tarama kaydedildi',
        extra: {'id': scan.id, 'type': scan.type, 'data': scan.data},
      );
    } catch (e, stackTrace) {
      LogService().error(
        'QR tarama kaydetme hatası',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Tüm QR taramalarını getir
  List<QrScanModel> getAllQrScans() {
    try {
      final scans = _qrScansBox?.values.toList() ?? [];
      // En yeni taramalar önce gelecek şekilde sırala
      scans.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return scans;
    } catch (e, stackTrace) {
      LogService().error(
        'QR taramaları getirme hatası',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  // Belirli tipte QR taramalarını getir
  List<QrScanModel> getQrScansByType(String type) {
    try {
      final allScans = getAllQrScans();
      return allScans.where((scan) => scan.type == type).toList();
    } catch (e, stackTrace) {
      LogService().error(
        'Tip bazlı QR taramaları getirme hatası',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  // Belirli bir QR taramayı getir
  QrScanModel? getQrScanById(String id) {
    try {
      return _qrScansBox?.get(id);
    } catch (e, stackTrace) {
      LogService().error(
        'ID bazlı QR tarama getirme hatası',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  // QR tarama silme
  Future<void> deleteQrScan(String id) async {
    try {
      await _qrScansBox?.delete(id);
      LogService().info('QR tarama silindi', extra: {'id': id});
    } catch (e, stackTrace) {
      LogService().error(
        'QR tarama silme hatası',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Tüm QR taramalarını sil
  Future<void> deleteAllQrScans() async {
    try {
      await _qrScansBox?.clear();
      LogService().info('Tüm QR taramaları silindi');
    } catch (e, stackTrace) {
      LogService().error(
        'Tüm QR taramaları silme hatası',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // QR tarama güncelleme
  Future<void> updateQrScan(QrScanModel scan) async {
    try {
      await _qrScansBox?.put(scan.id, scan);
      LogService().info('QR tarama güncellendi', extra: {'id': scan.id});
    } catch (e, stackTrace) {
      LogService().error(
        'QR tarama güncelleme hatası',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Arama fonksiyonu
  List<QrScanModel> searchQrScans(String query) {
    try {
      final allScans = getAllQrScans();
      final lowercaseQuery = query.toLowerCase();

      return allScans.where((scan) {
        return scan.data.toLowerCase().contains(lowercaseQuery) ||
            scan.type.toLowerCase().contains(lowercaseQuery) ||
            (scan.title?.toLowerCase().contains(lowercaseQuery) ?? false) ||
            (scan.description?.toLowerCase().contains(lowercaseQuery) ?? false);
      }).toList();
    } catch (e, stackTrace) {
      LogService().error(
        'QR tarama arama hatası',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  // İstatistikler
  Map<String, dynamic> getStatistics() {
    try {
      final allScans = getAllQrScans();
      final typeCounts = <String, int>{};
      int urlCount = 0;

      for (final scan in allScans) {
        typeCounts[scan.type] = (typeCounts[scan.type] ?? 0) + 1;
        if (scan.isUrl) urlCount++;
      }

      return {
        'totalScans': allScans.length,
        'urlScans': urlCount,
        'typeCounts': typeCounts,
        'lastScan': allScans.isNotEmpty ? allScans.first.timestamp : null,
        'firstScan': allScans.isNotEmpty ? allScans.last.timestamp : null,
      };
    } catch (e, stackTrace) {
      LogService().error(
        'İstatistik hesaplama hatası',
        error: e,
        stackTrace: stackTrace,
      );
      return {
        'totalScans': 0,
        'urlScans': 0,
        'typeCounts': <String, int>{},
        'lastScan': null,
        'firstScan': null,
      };
    }
  }

  // Son N taramayı getir
  List<QrScanModel> getRecentQrScans(int limit) {
    try {
      final allScans = getAllQrScans();
      return allScans.take(limit).toList();
    } catch (e, stackTrace) {
      LogService().error(
        'Son QR taramaları getirme hatası',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  // Belirli tarih aralığındaki taramaları getir
  List<QrScanModel> getQrScansByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    try {
      final allScans = getAllQrScans();
      return allScans.where((scan) {
        return scan.timestamp.isAfter(startDate) &&
            scan.timestamp.isBefore(endDate);
      }).toList();
    } catch (e, stackTrace) {
      LogService().error(
        'Tarih aralığı QR taramaları getirme hatası',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  // Box'ı kapat
  Future<void> close() async {
    try {
      await _qrScansBox?.close();
      LogService().info('HiveService kapatıldı');
    } catch (e, stackTrace) {
      LogService().error(
        'HiveService kapatma hatası',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  // Box boyutunu getir
  int get boxSize => _qrScansBox?.length ?? 0;

  // Box'ın boş olup olmadığını kontrol et
  bool get isEmpty => _qrScansBox?.isEmpty ?? true;

  // Box'ın dolu olup olmadığını kontrol et
  bool get isNotEmpty => _qrScansBox?.isNotEmpty ?? false;
}
