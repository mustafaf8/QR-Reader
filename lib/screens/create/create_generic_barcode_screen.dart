import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barcode_widget/barcode_widget.dart';
import '../../l10n/app_localizations.dart';
import '../../services/common_helpers.dart';

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
        shadowColor: Theme.of(
          context,
        ).colorScheme.shadow.withValues(alpha: 0.1),
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
                      ).colorScheme.primary.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.dataInput,
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
                                hintText:
                                    widget.hintText ??
                                    AppLocalizations.of(context)!.enterDataHint,
                                hintStyle: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                                filled: true,
                                fillColor: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest
                                    .withValues(alpha: 0.3),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.outline
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.outline
                                        .withValues(alpha: 0.3),
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
                                      .withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${AppLocalizations.of(context)!.preview}: ${_getFormattedData()}',
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
                      ).colorScheme.primary.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.preview,
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
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
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
                                            AppLocalizations.of(
                                              context,
                                            )!.enterData,
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
                                                      AppLocalizations.of(
                                                        context,
                                                      )!.invalidDataFormat;
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
                                      label: Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.saveAction,
                                      ),
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
                                      label: Text(
                                        AppLocalizations.of(context)!.share,
                                      ),
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
      return AppLocalizations.of(context)!.qrCodeInfo;
    } else if (widget.barcode == Barcode.ean13()) {
      return AppLocalizations.of(context)!.ean13Info;
    } else if (widget.barcode == Barcode.ean8()) {
      return AppLocalizations.of(context)!.ean8Info;
    } else if (widget.barcode == Barcode.upcA()) {
      return AppLocalizations.of(context)!.upcAInfo;
    } else if (widget.barcode == Barcode.upcE()) {
      return AppLocalizations.of(context)!.upcEInfo;
    } else if (widget.barcode == Barcode.code39()) {
      return AppLocalizations.of(context)!.code39Info;
    } else if (widget.barcode == Barcode.code93()) {
      return AppLocalizations.of(context)!.code93Info;
    } else if (widget.barcode == Barcode.code128()) {
      return AppLocalizations.of(context)!.code128Info;
    } else if (widget.barcode == Barcode.itf()) {
      return AppLocalizations.of(context)!.itfInfo;
    } else if (widget.barcode == Barcode.pdf417()) {
      return AppLocalizations.of(context)!.pdf417Info;
    } else if (widget.barcode == Barcode.codabar()) {
      return AppLocalizations.of(context)!.codabarInfo;
    } else if (widget.barcode == Barcode.dataMatrix()) {
      return AppLocalizations.of(context)!.dataMatrixInfo;
    } else if (widget.barcode == Barcode.aztec()) {
      return AppLocalizations.of(context)!.aztecInfo;
    }
    return AppLocalizations.of(context)!.unknownBarcodeInfo;
  }

  Future<void> _saveBarcode() async {
    final content =
        '${widget.title} QR Kodu\n'
        '${AppLocalizations.of(context)!.creationDateLabel}: ${DateTime.now().toString()}\n'
        'Veri: ${_getFormattedData()}\n'
        'Format: ${widget.barcode.toString()}';

    await CommonHelpers.saveQrData(
      content,
      widget.title,
      _getFormattedData(),
      context,
    );
  }

  Future<void> _shareBarcode() async {
    final content =
        '${widget.title} QR Kodu\n\n'
        'Veri: ${_getFormattedData()}\n'
        'Format: ${widget.barcode.toString()}\n'
        '${AppLocalizations.of(context)!.creationDateLabel}: ${DateTime.now().toString()}';

    await CommonHelpers.shareContent(
      content,
      '${widget.title} QR Kodu',
      context,
    );
  }
}
