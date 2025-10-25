import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class CreateContactScreen extends StatefulWidget {
  const CreateContactScreen({super.key});

  @override
  State<CreateContactScreen> createState() => _CreateContactScreenState();
}

class _CreateContactScreenState extends State<CreateContactScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _organizationController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _firstNameController.addListener(_onDataChanged);
    _lastNameController.addListener(_onDataChanged);
    _phoneController.addListener(_onDataChanged);
    _emailController.addListener(_onDataChanged);
    _organizationController.addListener(_onDataChanged);
    _titleController.addListener(_onDataChanged);
    _websiteController.addListener(_onDataChanged);
    _addressController.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _organizationController.dispose();
    _titleController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    setState(() {
      _hasError = false;
      _errorMessage = '';
    });
  }

  String _getVCardString() {
    if (_firstNameController.text.isEmpty && _lastNameController.text.isEmpty) {
      return '';
    }

    String vcard = 'BEGIN:VCARD\n';
    vcard += 'VERSION:3.0\n';

    // İsim
    String fullName = '';
    if (_firstNameController.text.isNotEmpty) {
      fullName += _firstNameController.text;
    }
    if (_lastNameController.text.isNotEmpty) {
      if (fullName.isNotEmpty) fullName += ' ';
      fullName += _lastNameController.text;
    }

    if (fullName.isNotEmpty) {
      vcard += 'FN:$fullName\n';
      vcard +=
          'N:${_lastNameController.text};${_firstNameController.text};;;\n';
    }

    // Telefon
    if (_phoneController.text.isNotEmpty) {
      vcard += 'TEL:${_phoneController.text}\n';
    }

    // E-posta
    if (_emailController.text.isNotEmpty) {
      vcard += 'EMAIL:${_emailController.text}\n';
    }

    // Organizasyon
    if (_organizationController.text.isNotEmpty) {
      vcard += 'ORG:${_organizationController.text}\n';
    }

    // Unvan
    if (_titleController.text.isNotEmpty) {
      vcard += 'TITLE:${_titleController.text}\n';
    }

    // Website
    if (_websiteController.text.isNotEmpty) {
      String website = _websiteController.text;
      if (!website.startsWith('http://') && !website.startsWith('https://')) {
        website = 'https://$website';
      }
      vcard += 'URL:$website\n';
    }

    // Adres
    if (_addressController.text.isNotEmpty) {
      vcard += 'ADR:;;${_addressController.text};;;;\n';
    }

    vcard += 'END:VCARD';
    return vcard;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Kişi QR Kodu'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
        actions: [
          if ((_firstNameController.text.isNotEmpty ||
                  _lastNameController.text.isNotEmpty) &&
              !_hasError)
            IconButton(
              onPressed: _saveContact,
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
                    // Modern Kişi bilgileri girişi
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
                            Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Kişi Bilgileri',
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

                            // Ad ve Soyad
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _firstNameController,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: 'Ad',
                                      labelStyle: TextStyle(
                                        color: Colors.grey.shade300,
                                      ),
                                      hintText: 'Adınız',
                                      hintStyle: TextStyle(
                                        color: Colors.grey.shade400,
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
                                        Icons.person_outline,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _lastNameController,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: 'Soyad',
                                      labelStyle: TextStyle(
                                        color: Colors.grey.shade300,
                                      ),
                                      hintText: 'Soyadınız',
                                      hintStyle: TextStyle(
                                        color: Colors.grey.shade400,
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
                                        Icons.person_outline,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Telefon
                            TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Telefon',
                                labelStyle: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                hintText: '+90 555 123 45 67',
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
                                  Icons.phone,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // E-posta
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              decoration: InputDecoration(
                                labelText: 'E-posta',
                                labelStyle: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                hintText: 'ornek@email.com',
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
                                  Icons.email,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Organizasyon
                            TextField(
                              controller: _organizationController,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Organizasyon',
                                labelStyle: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                hintText: 'Şirket adı',
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
                                  Icons.business,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Unvan
                            TextField(
                              controller: _titleController,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Unvan',
                                labelStyle: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                hintText: 'Pozisyonunuz',
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
                                  Icons.work,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Website
                            TextField(
                              controller: _websiteController,
                              keyboardType: TextInputType.url,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Website',
                                labelStyle: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                hintText: 'www.ornek.com',
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
                                  Icons.web,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Adres
                            TextField(
                              controller: _addressController,
                              maxLines: 2,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Adres',
                                labelStyle: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                hintText: 'Adres bilginiz',
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
                                  Icons.location_on,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
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
                                child:
                                    (_firstNameController.text.isEmpty &&
                                        _lastNameController.text.isEmpty)
                                    ? Column(
                                        children: [
                                          Icon(
                                            Icons.person_off,
                                            size: 64,
                                            color: Colors.grey.shade400,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Ad veya soyad girin',
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
                                        data: _getVCardString(),
                                        width: 200,
                                        height: 200,
                                        errorBuilder: (context, error) {
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                                setState(() {
                                                  _hasError = true;
                                                  _errorMessage =
                                                      'Geçersiz kişi bilgisi';
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
                            if ((_firstNameController.text.isNotEmpty ||
                                    _lastNameController.text.isNotEmpty) &&
                                !_hasError) ...[
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _saveContact,
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
                                      onPressed: _shareContact,
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

                    // vCard bilgi kartı
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
                                  'vCard QR Kodu Hakkında',
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
                              'Bu QR kodu tarayan kişiler otomatik olarak kişi bilgilerinizi telefonlarına kaydedebilir. Ad veya soyad en az birinin girilmesi gereklidir.',
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
                    if (_firstNameController.text.isNotEmpty ||
                        _lastNameController.text.isNotEmpty)
                      Card(
                        color: Theme.of(context).colorScheme.surface,
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'vCard Verisi',
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
                                  ).colorScheme.surfaceVariant,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _getVCardString(),
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                    fontSize: 10,
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

  Future<void> _saveContact() async {
    try {
      // Kişi QR kod verisini metin dosyası olarak kaydet
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final name = '${_firstNameController.text}_${_lastNameController.text}'
          .replaceAll(' ', '_');
      final fileName = 'Contact_QR_$name$timestamp.txt';

      // Downloads klasörüne kaydet
      final directory = await getDownloadsDirectory();
      if (directory == null) {
        _showErrorSnackBar('Downloads klasörü bulunamadı');
        return;
      }

      final file = File('${directory.path}/$fileName');
      final content =
          'Kişi QR Kodu (vCard)\n'
          'Oluşturulma Tarihi: ${DateTime.now().toString()}\n'
          'Ad: ${_firstNameController.text}\n'
          'Soyad: ${_lastNameController.text}\n'
          'Telefon: ${_phoneController.text}\n'
          'E-posta: ${_emailController.text}\n'
          'Organizasyon: ${_organizationController.text}\n'
          'Unvan: ${_titleController.text}\n'
          'Website: ${_websiteController.text}\n'
          'Adres: ${_addressController.text}\n'
          'Ham Veri (vCard): ${_getVCardString()}';

      await file.writeAsString(content);

      _showSuccessSnackBar('Kişi QR kodu kaydedildi: ${file.path}');
    } catch (e) {
      _showErrorSnackBar('Kaydetme hatası: $e');
    }
  }

  Future<void> _shareContact() async {
    try {
      // Kişi QR kod verisini paylaş
      final content =
          'Kişi QR Kodu (vCard)\n\n'
          'Ad: ${_firstNameController.text}\n'
          'Soyad: ${_lastNameController.text}\n'
          'Telefon: ${_phoneController.text}\n'
          'E-posta: ${_emailController.text}\n'
          'Organizasyon: ${_organizationController.text}\n'
          'Unvan: ${_titleController.text}\n'
          'Website: ${_websiteController.text}\n'
          'Adres: ${_addressController.text}\n'
          'Ham Veri (vCard): ${_getVCardString()}\n'
          'Oluşturulma Tarihi: ${DateTime.now().toString()}';

      await Share.share(
        content,
        subject:
            'Kişi QR Kodu - ${_firstNameController.text} ${_lastNameController.text}',
      );

      _showSuccessSnackBar('Kişi QR kodu paylaşıldı');
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
