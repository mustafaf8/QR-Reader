import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../models/qr_scan_model.dart';
import '../services/common_helpers.dart';
import '../services/hive_service.dart';
import 'create_qr_screen.dart';
import 'favorites_screen.dart';
import 'qr_scanner_screen.dart';
import 'scan_history_screen.dart';
import 'settings_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _scannedData;
  String? _scannedType;
  final ImagePicker _imagePicker = ImagePicker();
  final MobileScannerController _imageScannerController =
      MobileScannerController();
  bool _isGalleryProcessing = false;

  @override
  void dispose() {
    _imageScannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: Text(l10n.homeScreenTitle),
        backgroundColor: Theme.of(context).colorScheme.surface,
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
            tooltip: l10n.scanHistory,
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
                      l10n.homeScreenTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.homeScreenSubtitle,
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
                          ).colorScheme.primary.withValues(alpha: 0.3),
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
                                      final result =
                                          await Navigator.push<
                                            Map<String, String?>
                                          >(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const QrScannerScreen(),
                                            ),
                                          );

                                      if (result == null ||
                                          result['data'] == null) {
                                        return;
                                      }

                                      await _processScanResult(
                                        result['data']!,
                                        result['format'],
                                        context,
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.qr_code_scanner,
                                      size: 24,
                                    ),
                                    label: Text(
                                      l10n.scanQrCode,
                                      style: const TextStyle(
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
                                      shadowColor: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.3),
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
                                    onPressed: _scanFromGallery,
                                    icon: const Icon(
                                      Icons.photo_library,
                                      size: 24,
                                    ),
                                    label: Text(
                                      l10n.scanFromGallery,
                                      style: const TextStyle(
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
                                      shadowColor: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withValues(alpha: 0.3),
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
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _getGradientColors(context),
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
                                    color: _getIconBackgroundColor(context),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.check_circle,
                                    color: _getIconColor(context),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    l10n.lastScanResult,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: _getTitleColor(context),
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
                                  color: _getIconBackgroundColor(context),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _scannedType!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: _getTitleColor(context),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey.shade900
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _getBorderColor(context),
                                ),
                              ),
                              child:
                                  _scannedType == 'WiFi' && _scannedData != null
                                  ? _buildWiFiResult(_scannedData!, context)
                                  : SelectableText(
                                      _scannedData!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontFamily: 'monospace',
                                            color:
                                                Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.white
                                                : Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface,
                                          ),
                                    ),
                            ),
                          ],
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

  String _getDataType(String data, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (data.startsWith('http://') || data.startsWith('https://')) {
      return l10n.urlType;
    } else if (data.startsWith('mailto:')) {
      return l10n.emailType;
    } else if (data.startsWith('tel:')) {
      return l10n.phoneType;
    } else if (data.startsWith('sms:')) {
      return l10n.smsType;
    } else if (data.startsWith('geo:')) {
      return l10n.locationType;
    } else if (data.startsWith('WIFI:') || data.startsWith('wifi:')) {
      return l10n.wifiType;
    } else if (data.startsWith('vcard:') || data.startsWith('BEGIN:VCARD')) {
      return l10n.vcardType;
    } else if (data.startsWith('mecard:')) {
      return l10n.mecardType;
    } else if (data.startsWith('otpauth:')) {
      return l10n.otpType;
    } else if (data.startsWith('bitcoin:') || data.startsWith('ethereum:')) {
      return l10n.cryptoType;
    } else {
      return l10n.textType;
    }
  }

  bool _isUrl(String data) {
    return data.startsWith('http://') || data.startsWith('https://');
  }

  Widget _buildWiFiResult(String data, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final rawPassword = QrScanModel.extractWiFiPassword(data);
    final canCopyPassword = rawPassword.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.wifi,
              color: isDark
                  ? colorScheme.primary
                  : colorScheme.primaryContainer,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${l10n.networkName}: ${_extractWiFiSSID(data, context)}',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.lock,
              color: isDark
                  ? colorScheme.secondary
                  : colorScheme.secondaryContainer,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${l10n.password}: ${_extractWiFiPassword(data, context)}',
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: isDark ? Colors.white : colorScheme.onSurface,
                ),
              ),
            ),
            if (canCopyPassword)
              IconButton(
                tooltip: l10n.copyWifiPassword,
                onPressed: () async {
                  await CommonHelpers.copyToClipboard(rawPassword, context);
                },
                icon: Icon(
                  Icons.copy,
                  color: isDark
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant,
                  size: 18,
                ),
              ),
          ],
        ),
      ],
    );
  }

  String _extractWiFiSSID(String data, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    try {
      if (!data.startsWith('WIFI:')) return l10n.wifiNetwork;
      final ssidIndex = data.indexOf('S:');
      if (ssidIndex == -1) return l10n.wifiNetwork;
      final afterSSID = data.substring(ssidIndex + 2);
      final semicolonIndex = afterSSID.indexOf(';');
      if (semicolonIndex == -1) return afterSSID;
      return afterSSID.substring(0, semicolonIndex);
    } catch (e) {
      return l10n.wifiNetwork;
    }
  }

  String _extractWiFiPassword(String data, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    try {
      if (!data.startsWith('WIFI:')) return l10n.wifiNetworkInfo;
      final passwordIndex = data.indexOf('P:');
      if (passwordIndex == -1) return l10n.wifiNetworkInfo;
      final afterPassword = data.substring(passwordIndex + 2);
      final semicolonIndex = afterPassword.indexOf(';');
      if (semicolonIndex == -1) return afterPassword;
      final password = afterPassword.substring(0, semicolonIndex);
      if (password.isEmpty) return l10n.noPassword;
      if (password == l10n.hiddenPassword) return l10n.hiddenPassword;
      return password;
    } catch (e) {
      return l10n.wifiNetworkInfo;
    }
  }

  Future<void> _showUrlDialog(BuildContext context, String url) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.link, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.urlFound),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.openWebPageQuestion,
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
                    Icon(
                      Icons.link,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
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
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.of(context).pop();
                await _launchUrl(url);
              },
              icon: const Icon(Icons.open_in_browser),
              label: Text(AppLocalizations.of(context)!.open),
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
    final l10n = AppLocalizations.of(context)!;
    try {
      String cleanUrl = url.trim();
      if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
        cleanUrl = 'https://$cleanUrl';
      }

      final Uri uri = Uri.parse(cleanUrl);
      final canLaunch = await canLaunchUrl(uri);

      if (canLaunch) {
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return;
        } catch (e) {}

        try {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
          return;
        } catch (e) {}

        try {
          await launchUrl(uri, mode: LaunchMode.inAppWebView);
          return;
        } catch (e) {}
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
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
                      Text(
                        l10n.urlCannotBeOpened,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        l10n.pleaseEnsureBrowser,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.9),
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
              label: l10n.copyAction,
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
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.copy,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.urlCopiedToClipboard,
                          style: const TextStyle(fontWeight: FontWeight.w500),
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
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
                    '${l10n.urlOpenError}: $e',
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

  Future<void> _shareQrData() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      String shareText = l10n.shareAppText;
      shareText += 'Siz de deneyin! 🚀';

      await Share.share(shareText, subject: l10n.shareAppSubject);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
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
                  '${l10n.shareError}: $e',
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

  Future<void> _scanFromGallery() async {
    if (_isGalleryProcessing) return;

    setState(() {
      _isGalleryProcessing = true;
    });

    final l10n = AppLocalizations.of(context)!;

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (!mounted) return;

      if (image == null) {
        return;
      }

      final capture = await _imageScannerController.analyzeImage(image.path);
      final barcodes = capture?.barcodes ?? [];
      Barcode? matched;
      for (final barcode in barcodes) {
        final raw = barcode.rawValue;
        if (raw != null && raw.isNotEmpty) {
          matched = barcode;
          break;
        }
      }

      if (matched == null) {
        _showScanSnackBar(
          context,
          l10n.noQrCodeInImage,
          Colors.red.shade600,
          Icons.error_outline,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      await _processScanResult(matched.rawValue!, matched.format.name, context);
    } catch (e) {
      if (!mounted) return;
      _showScanSnackBar(
        context,
        l10n.errorScanningQr,
        Colors.red.shade600,
        Icons.error_outline,
        duration: const Duration(seconds: 3),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGalleryProcessing = false;
        });
      }
    }
  }

  Future<void> _processScanResult(
    String data,
    String? format,
    BuildContext snackContext,
  ) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(snackContext)!;

    try {
      final scanModel = QrScanModel.fromScan(data: data, format: format);
      final wasSaved = await HiveService().saveQrScan(scanModel);

      if (!mounted) return;

      if (wasSaved) {
        _showScanSnackBar(
          snackContext,
          l10n.qrCodeScannedAndSaved,
          Colors.green.shade600,
          Icons.check_circle,
        );
      } else {
        _showScanSnackBar(
          snackContext,
          l10n.qrCodeAlreadyScanned,
          Colors.orange.shade600,
          Icons.info_outline,
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showScanSnackBar(
        snackContext,
        l10n.errorOccurred,
        Colors.red.shade600,
        Icons.error_outline,
        duration: const Duration(seconds: 3),
      );
    }

    if (!mounted) return;
    setState(() {
      _scannedData = data;
      _scannedType = _getDataType(data, snackContext);
    });

    if (_isUrl(data) && mounted) {
      await _showUrlDialog(snackContext, data);
    }
  }

  void _showScanSnackBar(
    BuildContext context,
    String message,
    Color backgroundColor,
    IconData icon, {
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: duration,
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
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
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.qr_code_scanner,
                                size: 32,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.qrReaderTitle,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.powerfulQrReader,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.qr_code_scanner,
                    title: l10n.scanQrCode,
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.star,
                    title: l10n.favorites,
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
                    title: l10n.scanHistory,
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
                    title: l10n.createQrCode,
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
                    title: l10n.settingsTitle,
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
                    title: l10n.share,
                    onTap: () {
                      Navigator.pop(context);
                      _shareQrData();
                    },
                  ),
                ],
              ),
            ),
            // Watermark - Fixed at bottom
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: Text(
                  'Powered by Zenbit Studio',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
            ).colorScheme.primaryContainer.withValues(alpha: 0.3),
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
        ).colorScheme.primaryContainer.withValues(alpha: 0.1),
        splashColor: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.2),
      ),
    );
  }

  /// Gradient renklerini tema bazlı döndürür
  List<Color> _getGradientColors(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return isDark
        ? [
            colorScheme.primary.withValues(alpha: 0.5),
            colorScheme.primary.withValues(alpha: 0.3),
          ]
        : [
            colorScheme.primaryContainer.withValues(alpha: 0.3),
            colorScheme.primaryContainer.withValues(alpha: 0.2),
          ];
  }

  /// Icon arka plan rengini tema bazlı döndürür
  Color _getIconBackgroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.primaryContainer;
  }

  /// Icon rengini tema bazlı döndürür
  Color _getIconColor(BuildContext context) {
    return Theme.of(context).colorScheme.onPrimaryContainer;
  }

  /// Başlık rengini tema bazlı döndürür
  Color _getTitleColor(BuildContext context) {
    return Theme.of(context).colorScheme.onPrimaryContainer;
  }

  /// Border rengini tema bazlı döndürür
  Color _getBorderColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary.withValues(alpha: 0.5);
  }
}
