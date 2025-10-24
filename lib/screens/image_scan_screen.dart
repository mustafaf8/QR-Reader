import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/log_service.dart';
import '../services/hive_service.dart';
import '../models/qr_scan_model.dart';

class ImageScanScreen extends StatefulWidget {
  const ImageScanScreen({super.key});

  @override
  State<ImageScanScreen> createState() => _ImageScanScreenState();
}

class _ImageScanScreenState extends State<ImageScanScreen> {
  final ImagePicker _picker = ImagePicker();
  final MobileScannerController _scannerController = MobileScannerController();

  bool _isLoading = false;
  File? _selectedImage;
  String? _scanResult;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Görüntü Tarama'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Başlık
            const Text(
              'Galeriden QR Kod Tara',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Galerinizden bir resim seçin ve içindeki QR kodu tarayın',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Resim seç butonu
            ElevatedButton.icon(
              onPressed: _isLoading
                  ? null
                  : () => _pickImageFromSource(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Galeriden Resim Seç'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Yükleme göstergesi
            if (_isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Resim analiz ediliyor...'),
                  ],
                ),
              ),

            // Seçilen resim önizlemesi
            if (_selectedImage != null && !_isLoading) ...[
              Container(
                constraints: const BoxConstraints(
                  maxHeight: 200,
                  minHeight: 150,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _selectedImage!,
                    fit: BoxFit.contain,
                    width: double.infinity,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Tarama sonucu
            if (_scanResult != null && !_isLoading) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      _scanResult!.contains('hata') ||
                          _scanResult!.contains('bulunamadı')
                      ? Colors.red.shade50
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        _scanResult!.contains('hata') ||
                            _scanResult!.contains('bulunamadı')
                        ? Colors.red.shade200
                        : Colors.green.shade200,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _scanResult!.contains('hata') ||
                                  _scanResult!.contains('bulunamadı')
                              ? Icons.error
                              : Icons.check_circle,
                          color:
                              _scanResult!.contains('hata') ||
                                  _scanResult!.contains('bulunamadı')
                              ? Colors.red.shade600
                              : Colors.green.shade600,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _scanResult!.contains('hata') ||
                                  _scanResult!.contains('bulunamadı')
                              ? 'Tarama Sonucu'
                              : 'QR Kod Bulundu!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                _scanResult!.contains('hata') ||
                                    _scanResult!.contains('bulunamadı')
                                ? Colors.red.shade700
                                : Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      _scanResult!,
                      style: const TextStyle(fontSize: 14),
                    ),
                    if (!_scanResult!.contains('hata') &&
                        !_scanResult!.contains('bulunamadı')) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _copyToClipboard(_scanResult!),
                              icon: const Icon(Icons.copy),
                              label: const Text('Kopyala'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade600,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (_isUrl(_scanResult!))
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    _showUrlDialog(context, _scanResult!),
                                icon: const Icon(Icons.open_in_browser),
                                label: const Text('Aç'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade600,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Bilgi metni
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Column(
                children: [
                  Icon(Icons.info, color: Colors.blue),
                  SizedBox(height: 8),
                  Text(
                    'İpucu',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'QR kod içeren resimleri galeriden seçin. Desteklenen formatlar: JPG, PNG, GIF',
                    style: TextStyle(fontSize: 12, color: Colors.blue),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Belirtilen kaynaktan resim seçer ve QR kodunu tarar
  Future<void> _pickImageFromSource(ImageSource source) async {
    LogService().info(
      'Resim seçme başlatıldı',
      extra: {'source': source.toString()},
    );

    setState(() {
      _isLoading = true;
      _selectedImage = null;
      _scanResult = null;
    });

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });

        await _analyzeImage(pickedFile.path);
      } else {
        LogService().info('Resim seçme iptal edildi');
        setState(() {
          _scanResult = 'Resim seçimi iptal edildi.';
        });
      }
    } catch (e, stackTrace) {
      LogService().error(
        'Resim seçme hatası',
        error: e,
        stackTrace: stackTrace,
      );

      String errorMessage = 'Resim seçilirken hata: $e';

      // PlatformException için özel mesaj
      if (e.toString().contains('PlatformException')) {
        errorMessage =
            'Galeri erişim hatası. Lütfen uygulama izinlerini kontrol edin.';
      }

      setState(() {
        _scanResult = errorMessage;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Seçilen resmi analiz eder ve QR kodunu tarar
  Future<void> _analyzeImage(String path) async {
    try {
      LogService().info('Resim analizi başlatıldı', extra: {'path': path});

      final BarcodeCapture? capture = await _scannerController.analyzeImage(
        path,
      );

      if (capture != null &&
          capture.barcodes.isNotEmpty &&
          capture.barcodes.first.rawValue != null) {
        final String result = capture.barcodes.first.rawValue!;
        LogService().info(
          'Görüntüden QR kod başarıyla okundu',
          extra: {'result': result},
        );

        await _handleScanResult(result);
      } else {
        setState(() {
          _scanResult = 'Seçilen resimde QR kod bulunamadı.';
        });
        LogService().warning('Görüntüde QR kod bulunamadı');
      }
    } catch (e, stackTrace) {
      LogService().error(
        'Görüntü analiz hatası',
        error: e,
        stackTrace: stackTrace,
      );
      setState(() {
        _scanResult = 'Görüntü analiz edilirken hata: $e';
      });
    }
  }

  /// Tarama sonucunu işler ve kaydeder
  Future<void> _handleScanResult(String data) async {
    try {
      // QR scan model oluştur ve kaydet (tekrar edenleri filtrele)
      final QrScanModel scanModel = QrScanModel.fromScan(data: data);
      final wasSaved = await HiveService().saveQrScan(scanModel);

      // WiFi QR kodu ise özel gösterim yap
      if (data.startsWith('WIFI:') || data.startsWith('wifi:')) {
        final ssid = _extractWiFiSSID(data);
        final password = _extractWiFiPassword(data);

        setState(() {
          _scanResult = 'WiFi Ağı: $ssid\nŞifre: $password';
        });
      } else {
        setState(() {
          _scanResult = data;
        });
      }

      // Kaydetme durumuna göre mesaj göster
      if (wasSaved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR kod başarıyla tarandı ve kaydedildi!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        LogService().info('QR kod başarıyla kaydedildi', extra: {'data': data});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bu QR kod daha önce taranmış!'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        LogService().info(
          'Tekrar eden QR tarama, kaydedilmedi',
          extra: {'data': data},
        );
      }
    } catch (e, stackTrace) {
      LogService().error(
        'QR kod kaydetme hatası',
        error: e,
        stackTrace: stackTrace,
      );
      setState(() {
        _scanResult = 'QR kod kaydedilirken hata: $e';
      });
    }
  }

  /// WiFi QR kodundan SSID'i çıkarır
  String _extractWiFiSSID(String data) {
    try {
      if (!data.startsWith('WIFI:')) return 'WiFi Ağı';

      final ssidIndex = data.indexOf('S:');
      if (ssidIndex == -1) return 'WiFi Ağı';

      final afterSSID = data.substring(ssidIndex + 2);
      final semicolonIndex = afterSSID.indexOf(';');
      if (semicolonIndex == -1) return afterSSID;

      return afterSSID.substring(0, semicolonIndex);
    } catch (e) {
      return 'WiFi Ağı';
    }
  }

  /// WiFi QR kodundan şifreyi çıkarır
  String _extractWiFiPassword(String data) {
    try {
      if (!data.startsWith('WIFI:')) return 'WiFi ağ bilgileri';

      final passwordIndex = data.indexOf('P:');
      if (passwordIndex == -1) return 'WiFi ağ bilgileri';

      final afterPassword = data.substring(passwordIndex + 2);
      final semicolonIndex = afterPassword.indexOf(';');
      if (semicolonIndex == -1) return afterPassword;

      final password = afterPassword.substring(0, semicolonIndex);

      if (password.isEmpty) return 'Şifre yok';
      if (password == 'HIDDEN') return 'Gizli şifre';

      return password;
    } catch (e) {
      return 'WiFi ağ bilgileri';
    }
  }

  /// URL kontrolü yapar
  bool _isUrl(String data) {
    return data.startsWith('http://') || data.startsWith('https://');
  }

  /// URL dialog gösterir
  Future<void> _showUrlDialog(BuildContext context, String url) async {
    LogService().info('URL dialog gösteriliyor', extra: {'url': url});

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.link, color: Colors.blue),
              SizedBox(width: 8),
              Text('URL Bulundu'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'QR kodda bir web adresi bulundu. Bu sayfayı açmak istiyor musunuz?',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  url,
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _copyToClipboard(url);
              },
              child: const Text('Kopyala'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _launchUrl(url);
              },
              child: const Text('Aç'),
            ),
          ],
        );
      },
    );
  }

  /// URL'yi açar
  Future<void> _launchUrl(String url) async {
    try {
      LogService().info('URL açma denemesi', extra: {'url': url});

      // URL'ye https:// ekle eğer yoksa
      String finalUrl = url;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        finalUrl = 'https://$url';
      }

      final Uri uri = Uri.parse(finalUrl);

      // Farklı launch mode'ları dene
      bool launched = false;

      // Önce external application ile dene
      try {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (launched) {
          LogService().info(
            'URL başarıyla açıldı (external)',
            extra: {'url': finalUrl},
          );
          return;
        }
      } catch (e) {
        LogService().warning(
          'External application ile açılamadı',
          extra: {'error': e.toString()},
        );
      }

      // Platform default ile dene
      try {
        launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
        if (launched) {
          LogService().info(
            'URL başarıyla açıldı (platform default)',
            extra: {'url': finalUrl},
          );
          return;
        }
      } catch (e) {
        LogService().warning(
          'Platform default ile açılamadı',
          extra: {'error': e.toString()},
        );
      }

      // In-app web view ile dene
      try {
        launched = await launchUrl(uri, mode: LaunchMode.inAppWebView);
        if (launched) {
          LogService().info(
            'URL başarıyla açıldı (in-app web view)',
            extra: {'url': finalUrl},
          );
          return;
        }
      } catch (e) {
        LogService().warning(
          'In-app web view ile açılamadı',
          extra: {'error': e.toString()},
        );
      }

      // Hiçbiri çalışmazsa hata göster
      if (!launched) {
        throw Exception('URL açılamadı');
      }
    } catch (e, stackTrace) {
      LogService().error('URL açma hatası', error: e, stackTrace: stackTrace);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('URL açılamadı: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Kopyala',
            onPressed: () => _copyToClipboard(url),
          ),
        ),
      );
    }
  }

  /// Metni panoya kopyalar
  void _copyToClipboard(String text) {
    String textToCopy = text;
    String message = 'Panoya kopyalandı';

    // WiFi QR kodu ise sadece şifreyi kopyala
    if (text.contains('WiFi Ağı:') && text.contains('Şifre:')) {
      final lines = text.split('\n');
      if (lines.length >= 2) {
        final passwordLine = lines[1];
        if (passwordLine.startsWith('Şifre: ')) {
          textToCopy = passwordLine.substring(7); // "Şifre: " kısmını çıkar
          message = 'WiFi şifresi panoya kopyalandı';
        }
      }
    }

    Clipboard.setData(ClipboardData(text: textToCopy));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}
