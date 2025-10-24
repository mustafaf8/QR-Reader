import 'package:hive_flutter/hive_flutter.dart';
import '../models/qr_scan_model.dart';
import 'log_service.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  static const String _qrScansBoxName = 'qr_scans';
  static const String _favoritesBoxName = 'favorites';
  Box<QrScanModel>? _qrScansBox;
  Box<QrScanModel>? _favoritesBox;

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
      _favoritesBox = await Hive.openBox<QrScanModel>(_favoritesBoxName);

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

  // QR tarama kaydetme (tekrar edenleri otomatik filtrele)
  Future<bool> saveQrScan(QrScanModel scan) async {
    try {
      // Aynı data'ya sahip tarama var mı kontrol et
      final existingScans = getAllQrScans();
      final duplicateScan = existingScans.firstWhere(
        (existingScan) => existingScan.data == scan.data,
        orElse: () =>
            QrScanModel(id: '', data: '', type: '', timestamp: DateTime.now()),
      );

      // Eğer aynı data'ya sahip tarama varsa, kaydetme
      if (duplicateScan.data.isNotEmpty) {
        LogService().info(
          'Tekrar eden QR tarama tespit edildi, kaydedilmedi',
          extra: {
            'existingId': duplicateScan.id,
            'newId': scan.id,
            'data': scan.data,
            'type': scan.type,
          },
        );
        return false; // Kaydedilmedi
      }

      // Benzersiz tarama, kaydet
      await _qrScansBox?.put(scan.id, scan);
      LogService().info(
        'QR tarama kaydedildi',
        extra: {'id': scan.id, 'type': scan.type, 'data': scan.data},
      );
      return true; // Kaydedildi
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

  // ========== SIK KULLANILANLAR METODLARI ==========

  // Sık kullanılanlara ekle
  Future<void> addToFavorites(QrScanModel scan) async {
    try {
      // Yeni bir instance oluştur (aynı objeyi iki box'ta saklayamayız)
      final favoriteScan = QrScanModel.copy(
        id: scan.id,
        timestamp: scan.timestamp,
        data: scan.data,
        type: scan.type,
        title: scan.title,
        description: scan.description,
        format: scan.format,
        isUrl: scan.isUrl,
      );

      await _favoritesBox?.put(scan.id, favoriteScan);
      LogService().info(
        'Sık kullanılanlara eklendi',
        extra: {'id': scan.id, 'type': scan.type, 'data': scan.data},
      );
    } catch (e, stackTrace) {
      LogService().error(
        'Sık kullanılanlara ekleme hatası',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Sık kullanılanlardan çıkar
  Future<void> removeFromFavorites(String id) async {
    try {
      await _favoritesBox?.delete(id);
      LogService().info('Sık kullanılanlardan çıkarıldı', extra: {'id': id});
    } catch (e, stackTrace) {
      LogService().error(
        'Sık kullanılanlardan çıkarma hatası',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Tüm sık kullanılanları getir
  List<QrScanModel> getAllFavorites() {
    try {
      final favorites = _favoritesBox?.values.toList() ?? [];
      // En yeni eklenenler önce gelecek şekilde sırala
      favorites.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return favorites;
    } catch (e, stackTrace) {
      LogService().error(
        'Sık kullanılanları getirme hatası',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  // Sık kullanılanlarda var mı kontrol et
  bool isFavorite(String id) {
    try {
      return _favoritesBox?.containsKey(id) ?? false;
    } catch (e, stackTrace) {
      LogService().error(
        'Sık kullanılan kontrol hatası',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  // Tüm sık kullanılanları sil
  Future<void> clearAllFavorites() async {
    try {
      await _favoritesBox?.clear();
      LogService().info('Tüm sık kullanılanlar silindi');
    } catch (e, stackTrace) {
      LogService().error(
        'Tüm sık kullanılanları silme hatası',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Sık kullanılanlar sayısını getir
  int get favoritesCount => _favoritesBox?.length ?? 0;

  // Tekrar eden taramaları kaldır
  Future<void> removeDuplicateScans() async {
    try {
      final allScans = getAllQrScans();
      final uniqueScans = <String, QrScanModel>{};

      // Aynı data'ya sahip taramaları grupla, en yenisini tut
      for (final scan in allScans) {
        if (!uniqueScans.containsKey(scan.data) ||
            scan.timestamp.isAfter(uniqueScans[scan.data]!.timestamp)) {
          uniqueScans[scan.data] = scan;
        }
      }

      // Tüm taramaları sil
      await _qrScansBox?.clear();

      // Benzersiz taramaları tekrar ekle
      for (final scan in uniqueScans.values) {
        await _qrScansBox?.put(scan.id, scan);
      }

      LogService().info(
        'Tekrar eden taramalar kaldırıldı',
        extra: {
          'originalCount': allScans.length,
          'uniqueCount': uniqueScans.length,
          'removedCount': allScans.length - uniqueScans.length,
        },
      );
    } catch (e, stackTrace) {
      LogService().error(
        'Tekrar eden taramaları kaldırma hatası',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
