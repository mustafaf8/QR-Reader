import 'package:flutter/material.dart';
import 'create/create_generic_barcode_screen.dart';
import 'create/create_wifi_screen.dart';
import 'create/create_contact_screen.dart';
import 'create/create_calendar_screen.dart';
import 'package:barcode_widget/barcode_widget.dart';

class CreateQrScreen extends StatelessWidget {
  const CreateQrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('QR & Barkod Oluştur'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // QR Kod Türleri Bölümü
          _buildSectionHeader(
            context,
            'QR Kod Türleri',
            Icons.qr_code,
            Colors.blue,
          ),
          const SizedBox(height: 8),

          _buildQrItem(
            context: context,
            icon: Icons.content_copy,
            title: 'Panodan İçerik',
            subtitle: 'Panodaki metni QR koda dönüştür',
            onTap: () => _navigateToGeneric(
              context,
              'Panodan İçerik',
              Barcode.qrCode(),
              isClipboard: true,
            ),
          ),

          _buildQrItem(
            context: context,
            icon: Icons.link,
            title: 'URL',
            subtitle: 'Web sitesi adresi oluştur',
            onTap: () => _navigateToGeneric(
              context,
              'URL Oluştur',
              Barcode.qrCode(),
              hintText: 'https://example.com',
              prefix: 'https://',
            ),
          ),

          _buildQrItem(
            context: context,
            icon: Icons.text_fields,
            title: 'Düz Metin',
            subtitle: 'Herhangi bir metin oluştur',
            onTap: () => _navigateToGeneric(
              context,
              'Metin Oluştur',
              Barcode.qrCode(),
              hintText: 'Metninizi buraya yazın',
            ),
          ),

          _buildQrItem(
            context: context,
            icon: Icons.wifi,
            title: 'Wi-Fi',
            subtitle: 'Wi-Fi ağ bilgileri oluştur',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateWifiScreen()),
            ),
          ),

          _buildQrItem(
            context: context,
            icon: Icons.person,
            title: 'Kişi (vCard)',
            subtitle: 'İletişim bilgileri oluştur',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateContactScreen(),
              ),
            ),
          ),

          _buildQrItem(
            context: context,
            icon: Icons.email,
            title: 'E-posta Adresi',
            subtitle: 'E-posta adresi oluştur',
            onTap: () => _navigateToGeneric(
              context,
              'E-posta Oluştur',
              Barcode.qrCode(),
              hintText: 'ornek@email.com',
              prefix: 'mailto:',
            ),
          ),

          _buildQrItem(
            context: context,
            icon: Icons.sms,
            title: 'SMS Adresi',
            subtitle: 'SMS mesajı oluştur',
            onTap: () => _navigateToGeneric(
              context,
              'SMS Oluştur',
              Barcode.qrCode(),
              hintText: '+905551234567',
              prefix: 'sms:',
              suffix: '?body=Mesajınız',
            ),
          ),

          _buildQrItem(
            context: context,
            icon: Icons.location_on,
            title: 'Coğrafi Koordinatlar',
            subtitle: 'Konum bilgisi oluştur',
            onTap: () => _navigateToGeneric(
              context,
              'Konum Oluştur',
              Barcode.qrCode(),
              hintText: '41.0082,28.9784',
              prefix: 'geo:',
            ),
          ),

          _buildQrItem(
            context: context,
            icon: Icons.phone,
            title: 'Telefon Numarası',
            subtitle: 'Telefon numarası oluştur',
            onTap: () => _navigateToGeneric(
              context,
              'Telefon Oluştur',
              Barcode.qrCode(),
              hintText: '+905551234567',
              prefix: 'tel:',
              inputType: TextInputType.phone,
            ),
          ),

          _buildQrItem(
            context: context,
            icon: Icons.event,
            title: 'Takvim (vEvent)',
            subtitle: 'Etkinlik bilgileri oluştur',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateCalendarScreen(),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Barkod Türleri Bölümü
          _buildSectionHeader(
            context,
            'Barkod Türleri',
            Icons.view_headline,
            Colors.orange,
          ),
          const SizedBox(height: 8),

          _buildBarcodeItem(
            context: context,
            title: 'EAN-8',
            subtitle: '8 haneli ürün kodu',
            onTap: () => _navigateToGeneric(
              context,
              'EAN-8 Oluştur',
              Barcode.ean8(),
              hintText: '1234567',
              inputType: TextInputType.number,
              maxLength: 7,
            ),
          ),

          _buildBarcodeItem(
            context: context,
            title: 'EAN-13',
            subtitle: '13 haneli ürün kodu',
            onTap: () => _navigateToGeneric(
              context,
              'EAN-13 Oluştur',
              Barcode.ean13(),
              hintText: '123456789012',
              inputType: TextInputType.number,
              maxLength: 12,
            ),
          ),

          _buildBarcodeItem(
            context: context,
            title: 'UPC-E',
            subtitle: '6 haneli UPC kodu',
            onTap: () => _navigateToGeneric(
              context,
              'UPC-E Oluştur',
              Barcode.upcE(),
              hintText: '123456',
              inputType: TextInputType.number,
              maxLength: 6,
            ),
          ),

          _buildBarcodeItem(
            context: context,
            title: 'UPC-A',
            subtitle: '12 haneli UPC kodu',
            onTap: () => _navigateToGeneric(
              context,
              'UPC-A Oluştur',
              Barcode.upcA(),
              hintText: '123456789012',
              inputType: TextInputType.number,
              maxLength: 11,
            ),
          ),

          _buildBarcodeItem(
            context: context,
            title: 'CODE-39',
            subtitle: 'Alfanumerik kod',
            onTap: () => _navigateToGeneric(
              context,
              'CODE-39 Oluştur',
              Barcode.code39(),
              hintText: 'ABC123',
            ),
          ),

          _buildBarcodeItem(
            context: context,
            title: 'CODE-93',
            subtitle: 'Gelişmiş alfanumerik kod',
            onTap: () => _navigateToGeneric(
              context,
              'CODE-93 Oluştur',
              Barcode.code93(),
              hintText: 'ABC123',
            ),
          ),

          _buildBarcodeItem(
            context: context,
            title: 'CODE-128',
            subtitle: 'Yüksek yoğunluklu kod',
            onTap: () => _navigateToGeneric(
              context,
              'CODE-128 Oluştur',
              Barcode.code128(),
              hintText: 'ABC123',
            ),
          ),

          _buildBarcodeItem(
            context: context,
            title: 'ITF (Interleaved 2 of 5)',
            subtitle: 'Sayısal kod',
            onTap: () => _navigateToGeneric(
              context,
              'ITF Oluştur',
              Barcode.itf(),
              hintText: '1234567890',
              inputType: TextInputType.number,
            ),
          ),

          _buildBarcodeItem(
            context: context,
            title: 'PDF-417',
            subtitle: 'İki boyutlu barkod',
            onTap: () => _navigateToGeneric(
              context,
              'PDF-417 Oluştur',
              Barcode.pdf417(),
              hintText: 'PDF417 örneği',
            ),
          ),

          _buildBarcodeItem(
            context: context,
            title: 'Codabar',
            subtitle: 'Sayısal kod',
            onTap: () => _navigateToGeneric(
              context,
              'Codabar Oluştur',
              Barcode.codabar(),
              hintText: '1234567890',
              inputType: TextInputType.number,
            ),
          ),

          _buildBarcodeItem(
            context: context,
            title: 'Data Matrix',
            subtitle: 'İki boyutlu barkod',
            onTap: () => _navigateToGeneric(
              context,
              'Data Matrix Oluştur',
              Barcode.dataMatrix(),
              hintText: 'Data Matrix örneği',
            ),
          ),

          _buildBarcodeItem(
            context: context,
            title: 'Aztec',
            subtitle: 'İki boyutlu barkod',
            onTap: () => _navigateToGeneric(
              context,
              'Aztec Oluştur',
              Barcode.aztec(),
              hintText: 'Aztec örneği',
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Theme.of(context).colorScheme.surface,
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildBarcodeItem({
    required BuildContext context,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Theme.of(context).colorScheme.surface,
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          child: Icon(
            Icons.view_headline,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  void _navigateToGeneric(
    BuildContext context,
    String title,
    Barcode barcode, {
    String? hintText,
    String? prefix,
    String? suffix,
    TextInputType? inputType,
    int? maxLength,
    bool isClipboard = false,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateGenericBarcodeScreen(
          title: title,
          barcode: barcode,
          hintText: hintText,
          prefix: prefix,
          suffix: suffix,
          inputType: inputType,
          maxLength: maxLength,
          isClipboard: isClipboard,
        ),
      ),
    );
  }
}
