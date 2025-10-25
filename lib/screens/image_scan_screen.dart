import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.galleryScan),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Theme.of(
          context,
        ).colorScheme.shadow.withValues(alpha: 0.1),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                // Modern Başlık
                Text(
                  l10n.scanFromGalleryTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.scanFromGallerySubtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 40),
                // Modern Aksiyon Butonu
                Card(
                  elevation: 8,
                  shadowColor: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading
                                ? null
                                : () =>
                                      _pickImageFromSource(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library, size: 24),
                            label: Text(
                              l10n.selectImageFromGallery,
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
                              ).colorScheme.primary.withValues(alpha: 0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Modern Yükleme göstergesi
                if (_isLoading)
                  Card(
                    elevation: 4,
                    shadowColor: Theme.of(
                      context,
                    ).colorScheme.shadow.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.imageAnalyzing,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Modern Seçilen resim önizlemesi
                if (_selectedImage != null && !_isLoading) ...[
                  const SizedBox(height: 20),
                  Card(
                    elevation: 6,
                    shadowColor: Theme.of(
                      context,
                    ).colorScheme.shadow.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.3,
                        minHeight: 150,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.contain,
                          width: double.infinity,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Modern Tarama sonucu
                if (_scanResult != null && !_isLoading) ...[
                  const SizedBox(height: 20),
                  Card(
                    elevation: 6,
                    shadowColor:
                        _scanResult!.contains('hata') ||
                            _scanResult!.contains(l10n.notFound)
                        ? Colors.red.withValues(alpha: 0.2)
                        : Colors.green.withValues(alpha: 0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors:
                              _scanResult!.contains('hata') ||
                                  _scanResult!.contains(l10n.notFound)
                              ? [
                                  Colors.red.shade50,
                                  Colors.red.shade100.withValues(alpha: 0.3),
                                ]
                              : [
                                  Colors.green.shade50,
                                  Colors.green.shade100.withValues(alpha: 0.3),
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
                                  color:
                                      (_scanResult!.contains('hata') ||
                                          _scanResult!.contains(l10n.notFound)
                                      ? Colors.red.shade100
                                      : Colors.green.shade100),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _scanResult!.contains('hata') ||
                                          _scanResult!.contains(l10n.notFound)
                                      ? Icons.error_outline
                                      : Icons.check_circle,
                                  color:
                                      _scanResult!.contains('hata') ||
                                          _scanResult!.contains(l10n.notFound)
                                      ? Colors.red.shade600
                                      : Colors.green.shade600,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _scanResult!.contains('hata') ||
                                          _scanResult!.contains(l10n.notFound)
                                      ? l10n.scanResult
                                      : l10n.qrCodeFound,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            _scanResult!.contains('hata') ||
                                                _scanResult!.contains(
                                                  l10n.notFound,
                                                )
                                            ? Colors.red.shade700
                                            : Colors.green.shade700,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color:
                                    (_scanResult!.contains('hata') ||
                                        _scanResult!.contains(l10n.notFound)
                                    ? Colors.red.shade200
                                    : Colors.green.shade200),
                              ),
                            ),
                            child: SelectableText(
                              _scanResult!,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontFamily: 'monospace'),
                            ),
                          ),
                          if (!_scanResult!.contains('hata') &&
                              !_scanResult!.contains(l10n.notFound)) ...[
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () =>
                                        _copyToClipboard(_scanResult!),
                                    icon: const Icon(Icons.copy),
                                    label: Text(
                                      AppLocalizations.of(context)!.copyAction,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      foregroundColor: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _launchUrl(_scanResult!),
                                    icon: const Icon(Icons.open_in_new),
                                    label: Text(
                                      AppLocalizations.of(context)!.open,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(
                                        context,
                                      ).colorScheme.secondary,
                                      foregroundColor: Theme.of(
                                        context,
                                      ).colorScheme.onSecondary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Galeriden resim seçer
  Future<void> _pickImageFromSource(ImageSource source) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      setState(() {
        _isLoading = true;
        _scanResult = null;
      });

      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });

        // QR kod tarama
        await _scanImageForQrCode(_selectedImage!);
      }
    } catch (e) {
      setState(() {
        _scanResult = l10n.errorSelectingImage;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Resimdeki QR kodu tarar
  Future<void> _scanImageForQrCode(File imageFile) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final BarcodeCapture? capture = await _scannerController.analyzeImage(
        imageFile.path,
      );
      final List<Barcode> barcodes = capture?.barcodes ?? [];

      if (barcodes.isNotEmpty) {
        final String qrData = barcodes.first.rawValue ?? '';
        setState(() {
          _scanResult = qrData;
        });

        // QR kod verisini kaydet
        await _saveQrData(qrData);
      } else {
        setState(() {
          _scanResult = l10n.noQrCodeInImage;
        });
      }
    } catch (e) {
      setState(() {
        _scanResult = l10n.errorScanningQr;
      });
    }
  }

  /// QR kod verisini kaydeder
  Future<void> _saveQrData(String data) async {
    try {
      final qrScan = QrScanModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        data: data,
        timestamp: DateTime.now(),
        type: _determineQrType(data, context),
      );

      await HiveService().saveQrScan(qrScan);
    } catch (e) {
      // Hata durumunda sessizce devam et
    }
  }

  /// QR kod tipini belirler
  String _determineQrType(String data, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (data.startsWith('http://') || data.startsWith('https://')) {
      return 'URL';
    } else if (data.startsWith('mailto:')) {
      return 'Email';
    } else if (data.startsWith('tel:')) {
      return 'Telefon';
    } else if (data.startsWith('sms:')) {
      return 'SMS';
    } else if (data.startsWith('WIFI:')) {
      return 'WiFi';
    } else if (data.startsWith('BEGIN:VCARD')) {
      return l10n.contact;
    } else if (data.startsWith('BEGIN:VEVENT')) {
      return 'Takvim';
    } else {
      return 'Metin';
    }
  }

  /// Panoya kopyalar
  Future<void> _copyToClipboard(String text) async {
    final l10n = AppLocalizations.of(context)!;
    await Clipboard.setData(ClipboardData(text: text));
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
                child: const Icon(Icons.copy, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.copiedToClipboard,
                  style: const TextStyle(fontWeight: FontWeight.w500),
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
    }
  }

  /// URL'yi açar
  Future<void> _launchUrl(String url) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      // URL'ye https:// ekle eğer yoksa
      String finalUrl = url;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        finalUrl = 'https://$url';
      }

      final Uri uri = Uri.parse(finalUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
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
                      l10n.urlCannotBeOpenedError,
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
              duration: const Duration(seconds: 2),
            ),
          );
        }
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
                    l10n.urlOpeningError,
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
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
