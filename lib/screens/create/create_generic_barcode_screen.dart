import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class CreateGenericBarcodeScreen extends StatefulWidget {
  final String title;
  final Barcode barcode;
  final String? hintText;
  final String? prefix;
  final String? suffix;
  final TextInputType? inputType;
  final int? maxLength;
  final bool isClipboard;

  const CreateGenericBarcodeScreen({
    super.key,
    required this.title,
    required this.barcode,
    this.hintText,
    this.prefix,
    this.suffix,
    this.inputType,
    this.maxLength,
    this.isClipboard = false,
  });

  @override
  State<CreateGenericBarcodeScreen> createState() =>
      _CreateGenericBarcodeScreenState();
}

class _CreateGenericBarcodeScreenState
    extends State<CreateGenericBarcodeScreen> {
  final TextEditingController _controller = TextEditingController();
  String _currentData = '';
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    if (widget.isClipboard) {
      _loadFromClipboard();
    }
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text != null && clipboardData!.text!.isNotEmpty) {
        _controller.text = clipboardData.text!;
        _onTextChanged();
      }
    } catch (e) {
      // Clipboard erişim hatası - sessizce devam et
    }
  }

  void _onTextChanged() {
    setState(() {
      _currentData = _controller.text;
      _hasError = false;
      _errorMessage = '';
    });
  }

  String _getFormattedData() {
    if (_currentData.isEmpty) return '';

    String data = _currentData;

    // Prefix ekle
    if (widget.prefix != null && !data.startsWith(widget.prefix!)) {
      data = '${widget.prefix!}$data';
    }

    // Suffix ekle
    if (widget.suffix != null) {
      data = '$data${widget.suffix!}';
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
        actions: [
          if (_currentData.isNotEmpty && !_hasError)
            IconButton(
              onPressed: _saveBarcode,
              icon: const Icon(Icons.save),
              tooltip: 'Kaydet',
            ),
        ],
      ),
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen = constraints.maxWidth < 600;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 32),
                    // Modern Giriş alanı
                    Card(
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Veri Girişi',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _controller,
                              keyboardType:
                                  widget.inputType ?? TextInputType.text,
                              maxLength: widget.maxLength,
                              inputFormatters:
                                  widget.inputType == TextInputType.number
                                  ? [FilteringTextInputFormatter.digitsOnly]
                                  : null,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                              decoration: InputDecoration(
                                hintText: widget.hintText ?? 'Veri girin',
                                hintStyle: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                                filled: true,
                                fillColor: Theme.of(
                                  context,
                                ).colorScheme.surfaceVariant.withOpacity(0.3),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline.withOpacity(0.3),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline.withOpacity(0.3),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                                prefixText: widget.prefix,
                                prefixStyle: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                suffixText: widget.suffix,
                                suffixStyle: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            if (widget.prefix != null ||
                                widget.suffix != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                      .withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Önizleme: ${_getFormattedData()}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                        fontFamily: 'monospace',
                                      ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Modern Barkod önizlemesi
                    Card(
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Önizleme',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: Container(
                                padding: EdgeInsets.all(
                                  isSmallScreen ? 16 : 20,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: _currentData.isEmpty
                                    ? Column(
                                        children: [
                                          Icon(
                                            Icons.qr_code,
                                            size: 64,
                                            color: Colors.grey.shade400,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Veri girin',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      )
                                    : _hasError
                                    ? Column(
                                        children: [
                                          Icon(
                                            Icons.error_outline,
                                            size: 64,
                                            color: Colors.red.shade400,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            _errorMessage,
                                            style: TextStyle(
                                              color: Colors.red.shade600,
                                              fontSize: 14,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      )
                                    : BarcodeWidget(
                                        barcode: widget.barcode,
                                        data: _getFormattedData(),
                                        width: 200,
                                        height: 200,
                                        errorBuilder: (context, error) {
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                                setState(() {
                                                  _hasError = true;
                                                  _errorMessage =
                                                      'Geçersiz veri formatı';
                                                });
                                              });
                                          return Container(
                                            width: 200,
                                            height: 200,
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade50,
                                              border: Border.all(
                                                color: Colors.red.shade200,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.error_outline,
                                                  color: Colors.red.shade400,
                                                  size: 48,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Hata',
                                                  style: TextStyle(
                                                    color: Colors.red.shade600,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ),
                            // Kaydetme ve Paylaşma Butonları
                            if (_currentData.isNotEmpty && !_hasError) ...[
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _saveBarcode,
                                      icon: const Icon(Icons.save),
                                      label: const Text('Kaydet'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        foregroundColor: Theme.of(
                                          context,
                                        ).colorScheme.onPrimary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _shareBarcode,
                                      icon: const Icon(Icons.share),
                                      label: const Text('Paylaş'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                        foregroundColor: Theme.of(
                                          context,
                                        ).colorScheme.onSecondary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
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

                    const SizedBox(height: 24),

                    // Bilgi kartı
                    Card(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Bilgi',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getInfoText(),
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  String _getInfoText() {
    if (widget.barcode == Barcode.qrCode()) {
      return 'QR kodlar herhangi bir metin, URL, telefon numarası veya diğer veri türlerini içerebilir.';
    } else if (widget.barcode == Barcode.ean13()) {
      return 'EAN-13 kodu tam olarak 12 haneli sayı olmalıdır. Son hane otomatik hesaplanır.';
    } else if (widget.barcode == Barcode.ean8()) {
      return 'EAN-8 kodu tam olarak 7 haneli sayı olmalıdır. Son hane otomatik hesaplanır.';
    } else if (widget.barcode == Barcode.upcA()) {
      return 'UPC-A kodu tam olarak 11 haneli sayı olmalıdır. Son hane otomatik hesaplanır.';
    } else if (widget.barcode == Barcode.upcE()) {
      return 'UPC-E kodu tam olarak 6 haneli sayı olmalıdır.';
    } else if (widget.barcode == Barcode.code39()) {
      return 'CODE-39 sadece büyük harfler, sayılar ve bazı özel karakterleri destekler.';
    } else if (widget.barcode == Barcode.code93()) {
      return 'CODE-93 gelişmiş alfanumerik karakter desteği sunar.';
    } else if (widget.barcode == Barcode.code128()) {
      return 'CODE-128 yüksek yoğunluklu veri depolama sağlar.';
    } else if (widget.barcode == Barcode.itf()) {
      return 'ITF sadece sayısal karakterleri destekler.';
    } else if (widget.barcode == Barcode.pdf417()) {
      return 'PDF-417 iki boyutlu barkod formatıdır ve büyük miktarda veri saklayabilir.';
    } else if (widget.barcode == Barcode.codabar()) {
      return 'Codabar sadece sayısal karakterleri destekler.';
    } else if (widget.barcode == Barcode.dataMatrix()) {
      return 'Data Matrix iki boyutlu barkod formatıdır.';
    } else if (widget.barcode == Barcode.aztec()) {
      return 'Aztec iki boyutlu barkod formatıdır.';
    }
    return 'Bu barkod formatı hakkında bilgi mevcut değil.';
  }

  Future<void> _saveBarcode() async {
    try {
      // QR kod verisini metin dosyası olarak kaydet
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${widget.title.replaceAll(' ', '_')}_$timestamp.txt';

      // Downloads klasörüne kaydet
      final directory = await getDownloadsDirectory();
      if (directory == null) {
        _showErrorSnackBar('Downloads klasörü bulunamadı');
        return;
      }

      final file = File('${directory.path}/$fileName');
      final content =
          '${widget.title} QR Kodu\n'
          'Oluşturulma Tarihi: ${DateTime.now().toString()}\n'
          'Veri: ${_getFormattedData()}\n'
          'Format: ${widget.barcode.toString()}';

      await file.writeAsString(content);

      _showSuccessSnackBar('QR kod verisi kaydedildi: ${file.path}');
    } catch (e) {
      _showErrorSnackBar('Kaydetme hatası: $e');
    }
  }

  Future<void> _shareBarcode() async {
    try {
      // QR kod verisini paylaş
      final content =
          '${widget.title} QR Kodu\n\n'
          'Veri: ${_getFormattedData()}\n'
          'Format: ${widget.barcode.toString()}\n'
          'Oluşturulma Tarihi: ${DateTime.now().toString()}';

      await Share.share(content, subject: '${widget.title} QR Kodu');

      _showSuccessSnackBar('QR kod verisi paylaşıldı');
    } catch (e) {
      _showErrorSnackBar('Paylaşma hatası: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
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
                Icons.check_circle,
                color: Colors.white,
                size: 20,
              ),
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
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
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
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
