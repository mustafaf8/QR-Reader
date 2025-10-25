import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import '../../l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class CreateWifiScreen extends StatefulWidget {
  const CreateWifiScreen({super.key});

  @override
  State<CreateWifiScreen> createState() => _CreateWifiScreenState();
}

class _CreateWifiScreenState extends State<CreateWifiScreen> {
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _securityController = TextEditingController();
  final TextEditingController _hiddenController = TextEditingController();

  String _securityType = 'WPA';
  bool _isHidden = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _ssidController.addListener(_onDataChanged);
    _passwordController.addListener(_onDataChanged);
    _securityController.addListener(_onDataChanged);
    _hiddenController.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _ssidController.dispose();
    _passwordController.dispose();
    _securityController.dispose();
    _hiddenController.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    setState(() {
      _hasError = false;
      _errorMessage = '';
    });
  }

  String _getWifiString() {
    if (_ssidController.text.isEmpty) return '';

    String wifiString = 'WIFI:';
    wifiString += 'S:${_ssidController.text};';
    wifiString += 'T:$_securityType;';

    if (_passwordController.text.isNotEmpty) {
      wifiString += 'P:${_passwordController.text};';
    }

    if (_isHidden) {
      wifiString += 'H:true;';
    }

    wifiString += ';';
    return wifiString;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.wifiQrCodeTitle),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Theme.of(
          context,
        ).colorScheme.shadow.withValues(alpha: 0.1),
        actions: [
          if (_ssidController.text.isNotEmpty && !_hasError)
            IconButton(
              onPressed: _saveWifi,
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
                    // Modern Wi-Fi bilgileri girişi
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
                            Row(
                              children: [
                                Icon(
                                  Icons.wifi,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Wi-Fi Bilgileri',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // SSID
                            TextField(
                              controller: _ssidController,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              decoration: InputDecoration(
                                labelText:
                                    '${AppLocalizations.of(context)!.networkNameLabel} *',
                                labelStyle: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                hintText: AppLocalizations.of(
                                  context,
                                )!.networkNameHint,
                                hintStyle: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                filled: true,
                                fillColor: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: Icon(
                                  Icons.router,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Güvenlik türü
                            DropdownButtonFormField<String>(
                              initialValue: _securityType,
                              dropdownColor: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(
                                  context,
                                )!.securityTypeLabel,
                                labelStyle: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                filled: true,
                                fillColor: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: Icon(
                                  Icons.security,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: 'WPA',
                                  child: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.wpaSecurityType,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'WEP',
                                  child: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.wepSecurityType,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'nopass',
                                  child: Text(
                                    AppLocalizations.of(context)!.noPassword,
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _securityType = value!;
                                });
                              },
                            ),

                            const SizedBox(height: 16),

                            // Şifre
                            if (_securityType != 'nopass')
                              TextField(
                                controller: _passwordController,
                                obscureText: true,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(
                                    context,
                                  )!.passwordLabel,
                                  labelStyle: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                  hintText: AppLocalizations.of(
                                    context,
                                  )!.passwordHint,
                                  hintStyle: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                  filled: true,
                                  fillColor: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.lock,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                              ),

                            const SizedBox(height: 16),

                            // Gizli ağ
                            SwitchListTile(
                              title: Text(
                                AppLocalizations.of(
                                  context,
                                )!.hiddenNetworkLabel,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                              subtitle: Text(
                                AppLocalizations.of(
                                  context,
                                )!.hiddenNetworkDescription,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                              value: _isHidden,
                              onChanged: (value) {
                                setState(() {
                                  _isHidden = value;
                                });
                              },
                              activeThumbColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              inactiveThumbColor: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // QR kod önizlemesi
                    Card(
                      color: Theme.of(context).colorScheme.surface,
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.qrCodePreview,
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
                                      color: Colors.black.withValues(
                                        alpha: 0.2,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: _ssidController.text.isEmpty
                                    ? Column(
                                        children: [
                                          Icon(
                                            Icons.wifi_off,
                                            size: 64,
                                            color: Colors.grey.shade400,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            AppLocalizations.of(
                                              context,
                                            )!.enterNetworkName,
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
                                        barcode: Barcode.qrCode(),
                                        data: _getWifiString(),
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
                                                      )!.invalidWifiInfo;
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
                            if (_ssidController.text.isNotEmpty &&
                                !_hasError) ...[
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _saveWifi,
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
                                      onPressed: _shareWifi,
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

                    // Wi-Fi bilgi kartı
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
                                  AppLocalizations.of(context)!.aboutWifiQrCode,
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
                              AppLocalizations.of(
                                context,
                              )!.wifiQrCodeDescription,
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

                    const SizedBox(height: 16),

                    // Ham veri gösterimi
                    if (_ssidController.text.isNotEmpty)
                      Card(
                        color: Theme.of(context).colorScheme.surface,
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ham Veri',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _getWifiString(),
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                  ),
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

  Future<void> _saveWifi() async {
    try {
      // Wi-Fi QR kod verisini metin dosyası olarak kaydet
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName =
          'WiFi_QR_${_ssidController.text.replaceAll(' ', '_')}_$timestamp.txt';

      // Downloads klasörüne kaydet
      final directory = await getDownloadsDirectory();
      if (directory == null) {
        _showErrorSnackBar(
          AppLocalizations.of(context)!.downloadsFolderNotFound,
        );
        return;
      }

      final file = File('${directory.path}/$fileName');
      final content =
          '${AppLocalizations.of(context)!.wifiQrCode}\n'
          '${AppLocalizations.of(context)!.creationDateLabel}: ${DateTime.now().toString()}\n'
          '${AppLocalizations.of(context)!.networkNameSSID}: ${_ssidController.text}\n'
          '${AppLocalizations.of(context)!.securityType}: $_securityType\n'
          '${AppLocalizations.of(context)!.passwordLabel}: ${_passwordController.text.isNotEmpty ? _passwordController.text : AppLocalizations.of(context)!.none}\n'
          '${AppLocalizations.of(context)!.hiddenNetwork}: ${_isHidden ? AppLocalizations.of(context)!.yes : AppLocalizations.of(context)!.no}\n'
          '${AppLocalizations.of(context)!.rawData}: ${_getWifiString()}';

      await file.writeAsString(content);

      _showSuccessSnackBar(
        '${AppLocalizations.of(context)!.wifiQrCodeShared}: ${file.path}',
      );
    } catch (e) {
      _showErrorSnackBar('${AppLocalizations.of(context)!.saveError}: $e');
    }
  }

  Future<void> _shareWifi() async {
    try {
      // Wi-Fi QR kod verisini paylaş
      final content =
          '${AppLocalizations.of(context)!.wifiQrCode}\n\n'
          '${AppLocalizations.of(context)!.networkNameSSID}: ${_ssidController.text}\n'
          '${AppLocalizations.of(context)!.securityType}: $_securityType\n'
          '${AppLocalizations.of(context)!.passwordLabel}: ${_passwordController.text.isNotEmpty ? _passwordController.text : AppLocalizations.of(context)!.none}\n'
          '${AppLocalizations.of(context)!.hiddenNetwork}: ${_isHidden ? AppLocalizations.of(context)!.yes : AppLocalizations.of(context)!.no}\n'
          '${AppLocalizations.of(context)!.rawData}: ${_getWifiString()}\n'
          '${AppLocalizations.of(context)!.creationDateLabel}: ${DateTime.now().toString()}';

      await Share.share(
        content,
        subject:
            '${AppLocalizations.of(context)!.wifiQrCode} - ${_ssidController.text}',
      );

      _showSuccessSnackBar(AppLocalizations.of(context)!.wifiQrCodeShared);
    } catch (e) {
      _showErrorSnackBar('${AppLocalizations.of(context)!.shareError}: $e');
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
                color: Colors.white.withValues(alpha: 0.2),
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
