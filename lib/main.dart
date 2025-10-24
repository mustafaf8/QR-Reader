import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'services/log_service.dart';
import 'services/hive_service.dart';
import 'screens/log_viewer_screen.dart';
import 'screens/scan_history_screen.dart';
import 'screens/image_scan_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/my_qr_screen.dart';
import 'screens/create_qr_screen.dart';
import 'screens/settings_screen.dart';
import 'models/qr_scan_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Log servisini başlat
  LogService().initialize();

  // Hive servisini başlat
  try {
    await HiveService().initialize();
    LogService().info('HiveService başarıyla başlatıldı');
  } catch (e) {
    LogService().error('HiveService başlatma hatası', error: e);
  }

  // Global hata yakalama
  FlutterError.onError = (FlutterErrorDetails details) {
    LogService().fatal(
      'Flutter Error: ${details.exception}',
      error: details.exception,
      stackTrace: details.stack,
      extra: {
        'library': details.library,
        'context': details.context?.toString(),
      },
    );
  };

  // Platform hata yakalama
  PlatformDispatcher.instance.onError = (error, stack) {
    LogService().fatal(
      'Platform Error: $error',
      error: error,
      stackTrace: stack,
    );
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _scannedData;
  String? _scannedType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: const Text('QR Okuyucu'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ScanHistoryScreen(),
                ),
              );
            },
            icon: const Icon(Icons.history),
            tooltip: 'Tarama Geçmişi',
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LogViewerScreen(),
                ),
              );
            },
            icon: const Icon(Icons.bug_report),
            tooltip: 'Log Görüntüleyici',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.qr_code_scanner,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 32),
              const Text(
                'QR Kod Taramak İçin',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Aşağıdaki butona tıklayarak QR kod taramaya başlayabilirsiniz.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () async {
                  LogService().info('QR tarama başlatıldı');

                  final currentContext = context;
                  final isMounted = mounted;

                  try {
                    final result = await Navigator.push<String>(
                      currentContext,
                      MaterialPageRoute(
                        builder: (context) => const QrScannerScreen(),
                      ),
                    );

                    if (result != null && isMounted) {
                      LogService().info(
                        'QR kod başarıyla tarandı',
                        extra: {'data': result, 'type': _getDataType(result)},
                      );

                      // Taramayı geçmişe kaydet
                      try {
                        final scanModel = QrScanModel.fromScan(data: result);
                        await HiveService().saveQrScan(scanModel);
                        LogService().info(
                          'QR tarama geçmişe kaydedildi',
                          extra: {'id': scanModel.id},
                        );
                      } catch (e) {
                        LogService().error(
                          'QR tarama geçmişe kaydetme hatası',
                          error: e,
                        );
                      }

                      setState(() {
                        _scannedData = result;
                        _scannedType = _getDataType(result);
                      });

                      // Eğer URL ise kullanıcıya açmak isteyip istemediğini sor
                      if (_isUrl(result) && mounted) {
                        LogService().info(
                          'URL algılandı, kullanıcıya onay soruluyor',
                          extra: {'url': result},
                        );
                        await _showUrlDialog(currentContext, result);
                      }
                    } else {
                      LogService().info(
                        'QR tarama iptal edildi veya başarısız',
                      );
                    }
                  } catch (e, stackTrace) {
                    LogService().error(
                      'QR tarama sırasında hata',
                      error: e,
                      stackTrace: stackTrace,
                    );
                  }
                },
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('QR Kod Tara'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
              if (_scannedData != null) ...[
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    border: Border.all(color: Colors.green.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green.shade600,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Son Tarama Sonucu',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_scannedType != null) ...[
                        Text(
                          'Tip: $_scannedType',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                      ],
                      if (_scannedType == 'WiFi' && _scannedData != null) ...[
                        _buildWiFiResult(_scannedData!),
                      ] else ...[
                        Text(
                          _scannedData!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getDataType(String data) {
    if (data.startsWith('http://') || data.startsWith('https://')) {
      return 'URL';
    } else if (data.startsWith('mailto:')) {
      return 'E-posta';
    } else if (data.startsWith('tel:')) {
      return 'Telefon';
    } else if (data.startsWith('sms:')) {
      return 'SMS';
    } else if (data.startsWith('geo:')) {
      return 'Konum';
    } else if (data.startsWith('WIFI:') || data.startsWith('wifi:')) {
      return 'WiFi';
    } else if (data.startsWith('vcard:') || data.startsWith('BEGIN:VCARD')) {
      return 'vCard';
    } else if (data.startsWith('mecard:')) {
      return 'MeCard';
    } else if (data.startsWith('otpauth:')) {
      return 'OTP';
    } else if (data.startsWith('bitcoin:') || data.startsWith('ethereum:')) {
      return 'Kripto Para';
    } else {
      return 'Metin';
    }
  }

  bool _isUrl(String data) {
    return data.startsWith('http://') || data.startsWith('https://');
  }

  /// WiFi QR kodu sonucunu güzel bir şekilde gösterir
  Widget _buildWiFiResult(String data) {
    final ssid = _extractWiFiSSID(data);
    final password = _extractWiFiPassword(data);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.wifi, color: Colors.blue.shade600, size: 16),
            const SizedBox(width: 8),
            Text(
              'Ağ Adı: $ssid',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.lock, color: Colors.orange.shade600, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Şifre: $password',
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
      ],
    );
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.link, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        url,
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'monospace',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                LogService().info('URL açma iptal edildi', extra: {'url': url});
                Navigator.of(context).pop();
              },
              child: const Text('İptal'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                LogService().info('URL açma onaylandı', extra: {'url': url});
                Navigator.of(context).pop();
                await _launchUrl(url);
              },
              icon: const Icon(Icons.open_in_browser),
              label: const Text('Aç'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      LogService().info('URL açma işlemi başlatıldı', extra: {'url': url});

      // URL formatını kontrol et ve düzelt
      String cleanUrl = url.trim();
      if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
        cleanUrl = 'https://$cleanUrl';
        LogService().info(
          'URL formatı düzeltildi',
          extra: {'original': url, 'fixed': cleanUrl},
        );
      }

      final Uri uri = Uri.parse(cleanUrl);

      // Önce canLaunchUrl kontrolü
      final canLaunch = await canLaunchUrl(uri);
      LogService().info(
        'canLaunchUrl sonucu: $canLaunch',
        extra: {'url': cleanUrl},
      );

      if (canLaunch) {
        // İlk deneme: externalApplication
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          LogService().info(
            'URL başarıyla açıldı (externalApplication)',
            extra: {'url': cleanUrl},
          );
          return;
        } catch (e) {
          LogService().warning(
            'externalApplication başarısız, platformDefault deneniyor',
            extra: {'error': e.toString()},
          );
        }

        // İkinci deneme: platformDefault
        try {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
          LogService().info(
            'URL başarıyla açıldı (platformDefault)',
            extra: {'url': cleanUrl},
          );
          return;
        } catch (e) {
          LogService().warning(
            'platformDefault başarısız, inAppWebView deneniyor',
            extra: {'error': e.toString()},
          );
        }

        // Üçüncü deneme: inAppWebView
        try {
          await launchUrl(uri, mode: LaunchMode.inAppWebView);
          LogService().info(
            'URL başarıyla açıldı (inAppWebView)',
            extra: {'url': cleanUrl},
          );
          return;
        } catch (e) {
          LogService().error(
            'Tüm URL açma yöntemleri başarısız',
            error: e,
            extra: {'url': cleanUrl},
          );
        }
      } else {
        LogService().warning(
          'canLaunchUrl false döndü',
          extra: {'url': cleanUrl},
        );
      }

      // Tüm yöntemler başarısız oldu
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'URL açılamadı: $cleanUrl\nLütfen cihazınızda bir web tarayıcısı olduğundan emin olun.',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Kopyala',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: cleanUrl));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('URL panoya kopyalandı'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
        );
      }
    } catch (e, stackTrace) {
      LogService().error(
        'URL açma hatası',
        error: e,
        stackTrace: stackTrace,
        extra: {'url': url},
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('URL açma hatası: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  /// Drawer menüsünü oluşturur
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade600, Colors.blue.shade800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.qr_code_scanner, size: 48, color: Colors.white),
                SizedBox(height: 8),
                Text(
                  'QR Reader',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Güçlü QR kod okuyucu',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // Menü öğeleri
          _buildDrawerItem(
            context: context,
            icon: Icons.qr_code_scanner,
            title: 'Tara',
            onTap: () {
              Navigator.pop(context);
            },
          ),

          _buildDrawerItem(
            context: context,
            icon: Icons.image_search,
            title: 'Görüntü Tarama',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ImageScanScreen(),
                ),
              );
            },
          ),

          _buildDrawerItem(
            context: context,
            icon: Icons.star,
            title: 'Sık Kullanılanlar',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritesScreen(),
                ),
              );
            },
          ),

          _buildDrawerItem(
            context: context,
            icon: Icons.history,
            title: 'Geçmiş',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ScanHistoryScreen(),
                ),
              );
            },
          ),

          _buildDrawerItem(
            context: context,
            icon: Icons.person,
            title: 'Benim QR\'ım',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyQrScreen()),
              );
            },
          ),

          _buildDrawerItem(
            context: context,
            icon: Icons.add_box,
            title: 'QR Oluştur',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateQrScreen()),
              );
            },
          ),

          const Divider(),

          _buildDrawerItem(
            context: context,
            icon: Icons.settings,
            title: 'Ayarlar',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),

          _buildDrawerItem(
            context: context,
            icon: Icons.share,
            title: 'Paylaş',
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Paylaş özelliği yakında eklenecek'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),

          _buildDrawerItem(
            context: context,
            icon: Icons.apps,
            title: 'Uygulamalarımız',
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Uygulamalarımız özelliği yakında eklenecek'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),

          _buildDrawerItem(
            context: context,
            icon: Icons.block,
            title: 'Reklamları Kaldır',
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reklamları kaldır özelliği yakında eklenecek'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Drawer menü öğesi oluşturur
  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade600),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
      hoverColor: Colors.blue.shade50,
    );
  }
}

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = true;

  @override
  void initState() {
    super.initState();
    LogService().info('QR Scanner ekranı açıldı');
  }

  @override
  void dispose() {
    LogService().info('QR Scanner ekranı kapatıldı');
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Kod Tara'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              LogService().info('Fener durumu değiştiriliyor');
              cameraController.toggleTorch();
            },
            icon: const Icon(Icons.flash_on),
          ),
          IconButton(
            onPressed: () {
              LogService().info('Kamera değiştiriliyor');
              cameraController.switchCamera();
            },
            icon: const Icon(Icons.camera_front),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Kamera görüntüsü
          MobileScanner(controller: cameraController, onDetect: _onDetect),

          // Tarama overlay'i
          if (_isScanning) _buildScannerOverlay(),

          // Alt kısımda talimatlar
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'QR kodu kameranın önüne tutun',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 3,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return Container(
      decoration: ShapeDecoration(
        shape: QrScannerOverlayShape(
          borderColor: Colors.white,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: 250,
        ),
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    LogService().debug(
      'QR kod algılandı',
      extra: {'barcodeCount': barcodes.length, 'isScanning': _isScanning},
    );

    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        LogService().info(
          'QR kod başarıyla okundu',
          extra: {'rawValue': barcode.rawValue, 'format': barcode.format.name},
        );

        setState(() {
          _isScanning = false;
        });

        // Kamerayı durdur
        cameraController.stop();
        LogService().info('Kamera durduruldu');

        // Sonucu ana sayfaya gönder
        Navigator.pop(context, barcode.rawValue);
        break;
      }
    }
  }
}

class QrScannerOverlayShape extends ShapeBorder {
  const QrScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    double? cutOutSize,
  }) : cutOutSize = cutOutSize ?? 250;

  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top + borderRadius)
        ..quadraticBezierTo(
          rect.left,
          rect.top,
          rect.left + borderRadius,
          rect.top,
        )
        ..lineTo(rect.right, rect.top);
    }

    return getLeftTopPath(rect)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.top);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;
    final borderOffset = borderWidth / 2;
    final cutOutWidth = cutOutSize < width ? cutOutSize : width - borderOffset;
    final cutOutHeight = cutOutSize < height
        ? cutOutSize
        : height - borderOffset;

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final cutOutRect = Rect.fromLTWH(
      rect.left + width / 2 - cutOutWidth / 2 + borderOffset,
      rect.top + height / 2 - cutOutHeight / 2 + borderOffset,
      cutOutWidth - borderOffset * 2,
      cutOutHeight - borderOffset * 2,
    );

    canvas
      ..saveLayer(rect, backgroundPaint)
      ..drawRect(rect, backgroundPaint)
      ..drawRRect(
        RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)),
        Paint()..blendMode = BlendMode.clear,
      )
      ..restore();

    // Köşe çizgileri
    final path = Path();

    // Sol üst köşe
    path.moveTo(cutOutRect.left - borderOffset, cutOutRect.top + borderLength);
    path.lineTo(cutOutRect.left - borderOffset, cutOutRect.top + borderRadius);
    path.quadraticBezierTo(
      cutOutRect.left - borderOffset,
      cutOutRect.top - borderOffset,
      cutOutRect.left + borderRadius,
      cutOutRect.top - borderOffset,
    );
    path.lineTo(cutOutRect.left + borderLength, cutOutRect.top - borderOffset);

    // Sağ üst köşe
    path.moveTo(cutOutRect.right + borderOffset, cutOutRect.top + borderLength);
    path.lineTo(cutOutRect.right + borderOffset, cutOutRect.top + borderRadius);
    path.quadraticBezierTo(
      cutOutRect.right + borderOffset,
      cutOutRect.top - borderOffset,
      cutOutRect.right - borderRadius,
      cutOutRect.top - borderOffset,
    );
    path.lineTo(cutOutRect.right - borderLength, cutOutRect.top - borderOffset);

    // Sol alt köşe
    path.moveTo(
      cutOutRect.left - borderOffset,
      cutOutRect.bottom - borderLength,
    );
    path.lineTo(
      cutOutRect.left - borderOffset,
      cutOutRect.bottom - borderRadius,
    );
    path.quadraticBezierTo(
      cutOutRect.left - borderOffset,
      cutOutRect.bottom + borderOffset,
      cutOutRect.left + borderRadius,
      cutOutRect.bottom + borderOffset,
    );
    path.lineTo(
      cutOutRect.left + borderLength,
      cutOutRect.bottom + borderOffset,
    );

    // Sağ alt köşe
    path.moveTo(
      cutOutRect.right + borderOffset,
      cutOutRect.bottom - borderLength,
    );
    path.lineTo(
      cutOutRect.right + borderOffset,
      cutOutRect.bottom - borderRadius,
    );
    path.quadraticBezierTo(
      cutOutRect.right + borderOffset,
      cutOutRect.bottom + borderOffset,
      cutOutRect.right - borderRadius,
      cutOutRect.bottom + borderOffset,
    );
    path.lineTo(
      cutOutRect.right - borderLength,
      cutOutRect.bottom + borderOffset,
    );

    canvas.drawPath(path, borderPaint);
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}
