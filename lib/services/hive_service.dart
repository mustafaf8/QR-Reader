import 'package:hive_flutter/hive_flutter.dart';
import '../models/qr_scan_model.dart';

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
      // Log removed

      // Hive'ı başlat
      await Hive.initFlutter();

      // Adapter'ları kaydet
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(QrScanModelAdapter());
      }

      // Box'ları aç
      _qrScansBox = await Hive.openBox<QrScanModel>(_qrScansBoxName);
      _favoritesBox = await Hive.openBox<QrScanModel>(_favoritesBoxName);

      // HiveService başarıyla başlatıldı
    } catch (e) {
      // HiveService başlatma hatası
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
        // Tekrar eden QR tarama tespit edildi, kaydedilmedi
        return false; // Kaydedilmedi
      }

      // Benzersiz tarama, kaydet
      await _qrScansBox?.put(scan.id, scan);
      // QR tarama kaydedildi
      return true; // Kaydedildi
    } catch (e) {
      // QR tarama kaydetme hatası
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
    } catch (e) {
      // QR taramaları getirme hatası
      return [];
    }
  }

  // Belirli tipte QR taramalarını getir
  List<QrScanModel> getQrScansByType(String type) {
    try {
      final allScans = getAllQrScans();
      return allScans.where((scan) => scan.type == type).toList();
    } catch (e) {
      // Tip bazlı QR taramaları getirme hatası
      return [];
    }
  }

  // Belirli bir QR taramayı getir
  QrScanModel? getQrScanById(String id) {
    try {
      return _qrScansBox?.get(id);
    } catch (e) {
      // ID bazlı QR tarama getirme hatası
      return null;
    }
  }

  // QR tarama silme
  Future<void> deleteQrScan(String id) async {
    try {
      await _qrScansBox?.delete(id);
      // QR tarama silindi
    } catch (e) {
      // QR tarama silme hatası
      rethrow;
    }
  }

  // Tüm QR taramalarını sil
  Future<void> deleteAllQrScans() async {
    try {
      await _qrScansBox?.clear();
      // Tüm QR taramaları silindi
    } catch (e) {
      // Tüm QR taramaları silme hatası
      rethrow;
    }
  }

  // QR tarama güncelleme
  Future<void> updateQrScan(QrScanModel scan) async {
    try {
      await _qrScansBox?.put(scan.id, scan);
      // Log removed
    } catch (e) {
      // QR tarama güncelleme hatası
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
    } catch (e) {
      // QR tarama arama hatası
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
    } catch (e) {
      // İstatistik hesaplama hatası
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
    } catch (e) {
      // Son QR taramaları getirme hatası
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
    } catch (e) {
      // Tarih aralığı QR taramaları getirme hatası
      return [];
    }
  }

  // Box'ı kapat
  Future<void> close() async {
    try {
      await _qrScansBox?.close();
      // Log removed
    } catch (e) {
      // HiveService kapatma hatası
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
      // Sık kullanılanlara eklendi
    } catch (e) {
      // Sık kullanılanlara ekleme hatası
      rethrow;
    }
  }

  // Sık kullanılanlardan çıkar
  Future<void> removeFromFavorites(String id) async {
    try {
      await _favoritesBox?.delete(id);
      // Log removed
    } catch (e) {
      // Sık kullanılanlardan çıkarma hatası
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
    } catch (e) {
      // Sık kullanılanları getirme hatası
      return [];
    }
  }

  // Sık kullanılanlarda var mı kontrol et
  bool isFavorite(String id) {
    try {
      return _favoritesBox?.containsKey(id) ?? false;
    } catch (e) {
      // Sık kullanılan kontrol hatası
      return false;
    }
  }

  // Tüm sık kullanılanları sil
  Future<void> clearAllFavorites() async {
    try {
      await _favoritesBox?.clear();
      // Log removed
    } catch (e) {
      // Tüm sık kullanılanları silme hatası
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

      // Tekrar eden taramalar kaldırıldı
    } catch (e) {
      // Tekrar eden taramaları kaldırma hatası
      rethrow;
    }
  }
}
