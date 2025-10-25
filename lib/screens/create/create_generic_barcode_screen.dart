import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barcode_widget/barcode_widget.dart';

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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_currentData.isNotEmpty && !_hasError)
            IconButton(
              onPressed: _saveBarcode,
              icon: const Icon(Icons.save),
              tooltip: 'Kaydet',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Giriş alanı
            Card(
              color: Theme.of(context).colorScheme.surface,
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Veri Girişi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _controller,
                      keyboardType: widget.inputType ?? TextInputType.text,
                      maxLength: widget.maxLength,
                      inputFormatters: widget.inputType == TextInputType.number
                          ? [FilteringTextInputFormatter.digitsOnly]
                          : null,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: widget.hintText ?? 'Veri girin',
                        hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        prefixText: widget.prefix,
                        prefixStyle: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        suffixText: widget.suffix,
                        suffixStyle: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (widget.prefix != null || widget.suffix != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Önizleme: ${_getFormattedData()}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Barkod önizlemesi
            Card(
              color: Theme.of(context).colorScheme.surface,
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Önizleme',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
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
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    setState(() {
                                      _hasError = true;
                                      _errorMessage = 'Geçersiz veri formatı';
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
                                      borderRadius: BorderRadius.circular(8),
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
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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

  void _saveBarcode() {
    // Bu fonksiyon gelecekte barkodu kaydetmek için kullanılabilir
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.title} kaydedildi!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
