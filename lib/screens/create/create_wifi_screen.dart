import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';

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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Wi-Fi QR Kodu'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_ssidController.text.isNotEmpty && !_hasError)
            IconButton(
              onPressed: _saveWifi,
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
            // Wi-Fi bilgileri girişi
            Card(
              color: Theme.of(context).colorScheme.surface,
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
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
                            color: Theme.of(context).colorScheme.onSurface,
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
                        labelText: 'Ağ Adı (SSID) *',
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        hintText: 'Wi-Fi ağ adınız',
                        hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceVariant,
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
                      value: _securityType,
                      dropdownColor: Theme.of(
                        context,
                      ).colorScheme.surfaceVariant,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Güvenlik Türü',
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(
                          Icons.security,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'WPA', child: Text('WPA/WPA2')),
                        DropdownMenuItem(value: 'WEP', child: Text('WEP')),
                        DropdownMenuItem(
                          value: 'nopass',
                          child: Text('Şifresiz'),
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
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Şifre',
                          labelStyle: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          hintText: 'Wi-Fi şifreniz',
                          hintStyle: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          filled: true,
                          fillColor: Theme.of(
                            context,
                          ).colorScheme.surfaceVariant,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(
                            Icons.lock,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Gizli ağ
                    SwitchListTile(
                      title: Text(
                        'Gizli Ağ',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        'Bu ağ SSID yayınlamıyor',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      value: _isHidden,
                      onChanged: (value) {
                        setState(() {
                          _isHidden = value;
                        });
                      },
                      activeColor: Theme.of(context).colorScheme.primary,
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
                      'QR Kod Önizlemesi',
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
                                    'Ağ adını girin',
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
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    setState(() {
                                      _hasError = true;
                                      _errorMessage = 'Geçersiz Wi-Fi bilgisi';
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
                          'Wi-Fi QR Kodu Hakkında',
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
                      'Bu QR kodu tarayan kişiler otomatik olarak Wi-Fi ağınıza bağlanabilir. Ağ adı (SSID) zorunludur. Şifreli ağlar için şifre de gereklidir.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
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
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant,
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
        ),
      ),
    );
  }

  void _saveWifi() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Wi-Fi QR kodu kaydedildi!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
