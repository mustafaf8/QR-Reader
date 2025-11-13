import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barcode_widget/barcode_widget.dart';
import '../../l10n/app_localizations.dart';
import '../../models/barcode_constraints.dart';
import '../../services/barcode_image_service.dart';
import '../../services/error_service.dart';

class CreateGenericBarcodeScreen extends StatefulWidget {
  final String title;
  final Barcode barcode;
  final String? hintText;
  final String? primaryLabel;
  final String? prefix;
  final String? suffix;
  final TextInputType? inputType;
  final int? maxLength;
  final bool isClipboard;
  final String? infoText;
  final bool enableSecondaryField;
  final String? secondaryLabel;
  final String? secondaryHint;
  final TextInputType? secondaryInputType;
  final int? secondaryMaxLength;
  final String Function(String primary, String secondary)? customFormatter;
  final BarcodeConstraint? constraint;

  const CreateGenericBarcodeScreen({
    super.key,
    required this.title,
    required this.barcode,
    this.hintText,
    this.primaryLabel,
    this.prefix,
    this.suffix,
    this.inputType,
    this.maxLength,
    this.isClipboard = false,
    this.infoText,
    this.enableSecondaryField = false,
    this.secondaryLabel,
    this.secondaryHint,
    this.secondaryInputType,
    this.secondaryMaxLength,
    this.customFormatter,
    this.constraint,
  });

  @override
  State<CreateGenericBarcodeScreen> createState() =>
      _CreateGenericBarcodeScreenState();
}

class _CreateGenericBarcodeScreenState
    extends State<CreateGenericBarcodeScreen> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey _barcodeBoundaryKey = GlobalKey();
  String _currentData = '';
  TextEditingController? _secondaryController;
  String _secondaryData = '';
  bool _hasError = false;
  String _errorMessage = '';
  late BarcodeConstraint _constraint;

  @override
  void initState() {
    super.initState();
    _constraint = widget.constraint ?? BarcodeConstraints.qr;
    if (widget.isClipboard) {
      _loadFromClipboard();
    }
    _controller.addListener(_onTextChanged);
    _controller.value = _controller.value;
    if (widget.enableSecondaryField) {
      _secondaryController = TextEditingController();
      _secondaryController!.addListener(_onSecondaryChanged);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _secondaryController?.dispose();
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
    var text = _controller.text;
    if (_constraint.forceUppercase) {
      final uppercase = text.toUpperCase();
      if (uppercase != text) {
        text = uppercase;
        _controller.value = _controller.value.copyWith(
          text: uppercase,
          selection: TextSelection.collapsed(offset: uppercase.length),
        );
      }
    }

    setState(() {
      _currentData = text;
      _validatePrimary();
    });
  }

  void _validatePrimary() {
    final formatted = _currentData;
    if (formatted.isEmpty) {
      _hasError = false;
      _errorMessage = '';
      return;
    }
    if (!_constraint.validate(formatted)) {
      _hasError = true;
      _errorMessage =
          _constraint.description ??
          AppLocalizations.of(context)!.invalidDataFormat;
    } else if (widget.customFormatter == null) {
      _hasError = false;
      _errorMessage = '';
    }
  }

  void _onSecondaryChanged() {
    setState(() {
      _secondaryData = _secondaryController?.text ?? '';
      _hasError = false;
      _errorMessage = '';
    });
  }

  String _getFormattedData() {
    if (_currentData.isEmpty) return '';

    if (widget.customFormatter != null) {
      return widget.customFormatter!(
        _currentData,
        widget.enableSecondaryField ? _secondaryData : '',
      );
    }

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
                                  widget.inputType ??
                                  (_constraint.digitsOnly
                                      ? TextInputType.number
                                      : TextInputType.text),
                              maxLength:
                                  widget.maxLength ?? _constraint.maxLength,
                              inputFormatters: [
                                ..._constraint.buildInputFormatters(),
                                if (widget.inputType == TextInputType.number &&
                                    !_constraint.digitsOnly)
                                  FilteringTextInputFormatter.digitsOnly,
                              ],
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                              decoration: InputDecoration(
                                labelText: widget.primaryLabel,
                                hintText:
                                    widget.hintText ??
                                    AppLocalizations.of(context)!.enterDataHint,
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
                                labelStyle: _labelStyle(context),
                                floatingLabelStyle: _floatingLabelStyle(
                                  context,
                                ),
                                hintStyle: _labelStyle(context),
                              ),
                            ),
                            if (widget.enableSecondaryField) ...[
                              const SizedBox(height: 16),
                              TextField(
                                controller: _secondaryController,
                                keyboardType:
                                    widget.secondaryInputType ??
                                    TextInputType.text,
                                maxLength: widget.secondaryMaxLength,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                decoration: InputDecoration(
                                  labelText: widget.secondaryLabel,
                                  hintText: widget.secondaryHint,
                                  filled: true,
                                  fillColor: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withValues(alpha: 0.3),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline
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
                                  labelStyle: _labelStyle(context),
                                  floatingLabelStyle: _floatingLabelStyle(
                                    context,
                                  ),
                                  hintStyle: _labelStyle(context),
                                ),
                              ),
                            ],
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
                              child: _currentData.isEmpty
                                  ? _buildPreviewSurface(
                                      child: _buildEmptyPreviewContent(context),
                                      isSmallScreen: isSmallScreen,
                                    )
                                  : _hasError
                                  ? _buildPreviewSurface(
                                      child: _buildErrorPreviewContent(),
                                      isSmallScreen: isSmallScreen,
                                    )
                                  : _buildPreviewSurface(
                                      child: _buildBarcodeContent(),
                                      isSmallScreen: isSmallScreen,
                                      isCapturable: true,
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
                      elevation: 2,
                      shadowColor: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).colorScheme.primaryContainer
                                  .withValues(alpha: 0.8),
                              Theme.of(context).colorScheme.primaryContainer
                                  .withValues(alpha: 0.5),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.info_outline,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  AppLocalizations.of(context)!.info,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getInfoText(),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
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
    if (widget.infoText != null) {
      return widget.infoText!;
    }

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
    final bytes = await BarcodeImageService.capturePng(_barcodeBoundaryKey);
    if (bytes == null) {
      if (!mounted) return;
      ErrorService.showErrorSnackBar(
        context,
        AppLocalizations.of(context)!.saveFailed,
      );
      return;
    }

    if (!mounted) return;

    await BarcodeImageService.saveToGallery(bytes, widget.title, context);
  }

  Future<void> _shareBarcode() async {
    final bytes = await BarcodeImageService.capturePng(_barcodeBoundaryKey);
    if (bytes == null) {
      if (!mounted) return;
      ErrorService.showErrorSnackBar(
        context,
        AppLocalizations.of(context)!.shareFailed,
      );
      return;
    }

    if (!mounted) return;

    await BarcodeImageService.shareImage(bytes, widget.title, context);
  }

  Widget _buildPreviewSurface({
    required Widget child,
    required bool isSmallScreen,
    bool isCapturable = false,
  }) {
    final content = Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );

    if (!isCapturable) return content;

    return RepaintBoundary(key: _barcodeBoundaryKey, child: content);
  }

  Widget _buildEmptyPreviewContent(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.qr_code, size: 64, color: Colors.grey.shade400),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context)!.enterData,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildErrorPreviewContent() {
    return Column(
      children: [
        Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
        const SizedBox(height: 8),
        Text(
          _errorMessage,
          style: TextStyle(color: Colors.red.shade600, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBarcodeContent() {
    return BarcodeWidget(
      barcode: widget.barcode,
      data: _getFormattedData(),
      width: 200,
      height: 200,
      errorBuilder: (context, error) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() {
            _hasError = true;
            _errorMessage = AppLocalizations.of(context)!.invalidDataFormat;
          });
        });
        return Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            border: Border.all(color: Colors.red.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade400, size: 48),
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
    );
  }

  TextStyle? _labelStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }

  TextStyle? _floatingLabelStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Theme.of(context).colorScheme.primary,
    );
  }
}
