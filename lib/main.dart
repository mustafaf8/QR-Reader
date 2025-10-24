import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'services/hive_service.dart';
import 'screens/scan_history_screen.dart';
import 'screens/image_scan_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/create_qr_screen.dart';
import 'screens/settings_screen.dart';
import 'models/qr_scan_model.dart';

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
        ],
      ),
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = constraints.maxWidth < 600;
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 16 : 24,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 32),
                    // Ana başlık
                    Text(
                      'QR Okuyucu',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'QR kodları ve barkodları kolayca tarayın',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Ana Aksiyon Butonları
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isSmallScreen = constraints.maxWidth < 600;
                        return Card(
                          elevation: 8,
                          shadowColor: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                            child: Column(
                              children: [
                                // QR Kod Tara butonu
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      // Log removed

                                      final currentContext = context;
                                      final isMounted = mounted;

                                      try {
                                        final result =
                                            await Navigator.push<String>(
                                              currentContext,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const QrScannerScreen(),
                                              ),
                                            );

                                        if (result != null && isMounted) {
                                          // QR kod başarıyla tarandı

                                          // Taramayı geçmişe kaydet (tekrar edenleri filtrele)
                                          try {
                                            final scanModel =
                                                QrScanModel.fromScan(
                                                  data: result,
                                                );
                                            final wasSaved = await HiveService()
                                                .saveQrScan(scanModel);

                                            if (wasSaved) {
                                              // QR tarama geçmişe kaydedildi
                                              // Başarı mesajı göster
                                              ScaffoldMessenger.of(
                                                currentContext,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Row(
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              8,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Colors.white
                                                              .withOpacity(0.2),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                        ),
                                                        child: const Icon(
                                                          Icons.check_circle,
                                                          color: Colors.white,
                                                          size: 20,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      const Expanded(
                                                        child: Text(
                                                          'QR kod tarandı ve kaydedildi!',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  backgroundColor:
                                                      Colors.green.shade600,
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  margin: const EdgeInsets.all(
                                                    16,
                                                  ),
                                                  duration: const Duration(
                                                    seconds: 2,
                                                  ),
                                                ),
                                              );
                                            } else {
                                              // Tekrar eden QR tarama, kaydedilmedi
                                              // Tekrar eden tarama mesajı göster
                                              ScaffoldMessenger.of(
                                                currentContext,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Row(
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              8,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Colors.white
                                                              .withOpacity(0.2),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                        ),
                                                        child: const Icon(
                                                          Icons.info_outline,
                                                          color: Colors.white,
                                                          size: 20,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      const Expanded(
                                                        child: Text(
                                                          'Bu QR kod daha önce taranmış!',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  backgroundColor:
                                                      Colors.orange.shade600,
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  margin: const EdgeInsets.all(
                                                    16,
                                                  ),
                                                  duration: const Duration(
                                                    seconds: 2,
                                                  ),
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            // QR tarama geçmişe kaydetme hatası
                                          }

                                          setState(() {
                                            _scannedData = result;
                                            _scannedType = _getDataType(result);
                                          });

                                          // Eğer URL ise kullanıcıya açmak isteyip istemediğini sor
                                          if (_isUrl(result) && mounted) {
                                            // URL algılandı, kullanıcıya onay soruluyor
                                            await _showUrlDialog(
                                              currentContext,
                                              result,
                                            );
                                          }
                                        } else {
                                          // QR tarama iptal edildi veya başarısız
                                        }
                                      } catch (e) {
                                        // QR tarama sırasında hata
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.qr_code_scanner,
                                      size: 24,
                                    ),
                                    label: const Text(
                                      'QR Kod Tara',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      foregroundColor: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                      elevation: 4,
                                      shadowColor: Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(0.3),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Galeriden Seç butonu
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      // Log removed

                                      try {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ImageScanScreen(),
                                          ),
                                        );
                                      } catch (e) {
                                        // Galeri tarama sırasında hata
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.photo_library,
                                      size: 24,
                                    ),
                                    label: const Text(
                                      'Galeriden Seç',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(
                                        context,
                                      ).colorScheme.secondary,
                                      foregroundColor: Theme.of(
                                        context,
                                      ).colorScheme.onSecondary,
                                      elevation: 4,
                                      shadowColor: Theme.of(
                                        context,
                                      ).colorScheme.secondary.withOpacity(0.3),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    if (_scannedData != null) ...[
                      const SizedBox(height: 32),
                      Card(
                        elevation: 6,
                        shadowColor: Colors.green.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.green.shade50,
                                Colors.green.shade100.withOpacity(0.3),
                              ],
                            ),
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.check_circle,
                                      color: Colors.green.shade600,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Son Tarama Sonucu',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green.shade700,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (_scannedType != null) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _scannedType!,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.green.shade200,
                                  ),
                                ),
                                child:
                                    _scannedType == 'WiFi' &&
                                        _scannedData != null
                                    ? _buildWiFiResult(_scannedData!)
                                    : Text(
                                        _scannedData!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(fontFamily: 'monospace'),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
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
    // Log removed

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
                // Log removed
                Navigator.of(context).pop();
              },
              child: const Text('İptal'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                // Log removed
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
      // Log removed

      // URL formatını kontrol et ve düzelt
      String cleanUrl = url.trim();
      if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
        cleanUrl = 'https://$cleanUrl';
        // URL formatı düzeltildi
      }

      final Uri uri = Uri.parse(cleanUrl);

      // Önce canLaunchUrl kontrolü
      final canLaunch = await canLaunchUrl(uri);
      // canLaunchUrl sonucu kontrol edildi

      if (canLaunch) {
        // İlk deneme: externalApplication
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          // URL başarıyla açıldı (externalApplication)
          return;
        } catch (e) {
          // externalApplication başarısız, platformDefault deneniyor
        }

        // İkinci deneme: platformDefault
        try {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
          // URL başarıyla açıldı (platformDefault)
          return;
        } catch (e) {
          // platformDefault başarısız, inAppWebView deneniyor
        }

        // Üçüncü deneme: inAppWebView
        try {
          await launchUrl(uri, mode: LaunchMode.inAppWebView);
          // URL başarıyla açıldı (inAppWebView)
          return;
        } catch (e) {
          // Tüm URL açma yöntemleri başarısız
        }
      } else {
        // canLaunchUrl false döndü
      }

      // Tüm yöntemler başarısız oldu
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'URL açılamadı',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Lütfen cihazınızda bir web tarayıcısı olduğundan emin olun.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Kopyala',
              textColor: Colors.white,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: cleanUrl));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.copy,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'URL panoya kopyalandı',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.blue.shade600,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.all(16),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      // URL açma hatası
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'URL açma hatası: $e',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  /// Uygulamayı paylaşır
  Future<void> _shareQrData() async {
    try {
      String shareText = 'QR Okuyucu uygulamasını kullanıyorum! 📱\n\n';
      shareText += 'QR kodları ve barkodları kolayca tarayabilir, ';
      shareText += 'yeni QR kodlar oluşturabilirsiniz.\n\n';
      shareText += 'Siz de deneyin! 🚀';

      await Share.share(shareText, subject: 'QR Okuyucu Uygulaması');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Paylaşım hatası: $e',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Drawer menüsünü oluşturur
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Modern Drawer Header
            Container(
              height: 220,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primaryContainer,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.qr_code_scanner,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'QR Okuyucu',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Güçlü QR kod okuyucu',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
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
              icon: Icons.add_box,
              title: 'QR Oluştur',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateQrScreen(),
                  ),
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
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),

            _buildDrawerItem(
              context: context,
              icon: Icons.share,
              title: 'Paylaş',
              onTap: () {
                Navigator.pop(context);
                _shareQrData();
              },
            ),

            _buildDrawerItem(
              context: context,
              icon: Icons.block,
              title: 'Reklamları Kaldır',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Reklamları kaldır özelliği yakında eklenecek',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.blue.shade600,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.all(16),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        hoverColor: Theme.of(
          context,
        ).colorScheme.primaryContainer.withOpacity(0.1),
        splashColor: Theme.of(
          context,
        ).colorScheme.primaryContainer.withOpacity(0.2),
      ),
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
    // Log removed
  }

  @override
  void dispose() {
    // Log removed
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
              // Log removed
              cameraController.toggleTorch();
            },
            icon: const Icon(Icons.flash_on),
          ),
          IconButton(
            onPressed: () {
              // Log removed
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
    // QR kod algılandı

    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        // QR kod başarıyla okundu

        setState(() {
          _isScanning = false;
        });

        // Kamerayı durdur
        cameraController.stop();
        // Log removed

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
