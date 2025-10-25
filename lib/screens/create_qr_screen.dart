import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'create/create_generic_barcode_screen.dart';
import 'create/create_wifi_screen.dart';
import 'create/create_contact_screen.dart';
import 'create/create_calendar_screen.dart';
import 'package:barcode_widget/barcode_widget.dart';

class CreateQrScreen extends StatelessWidget {
  const CreateQrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(l10n.createQrCode),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // QR Kod Türleri Bölümü
          _buildSectionHeader(
            context,
            l10n.qrCodeTypes,
            Icons.qr_code,
            Colors.blue,
          ),
          const SizedBox(height: 8),

          _buildQrItem(
            context: context,
            icon: Icons.content_copy,
            title: l10n.clipboardContent,
            subtitle: l10n.clipboardContentSubtitle,
            onTap: () => _navigateToGeneric(
              context,
              l10n.clipboardContent,
              Barcode.qrCode(),
              isClipboard: true,
            ),
          ),

          _buildQrItem(
            context: context,
            icon: Icons.link,
            title: 'URL',
            subtitle: l10n.urlSubtitle,
            onTap: () => _navigateToGeneric(
              context,
              l10n.createUrl,
              Barcode.qrCode(),
              hintText: AppLocalizations.of(context)!.urlHint,
              prefix: 'https://',
            ),
          ),

          _buildQrItem(
            context: context,
            icon: Icons.text_fields,
            title: l10n.plainText,
            subtitle: l10n.plainTextSubtitle,
            onTap: () => _navigateToGeneric(
              context,
              l10n.createText,
              Barcode.qrCode(),
              hintText: l10n.enterYourText,
            ),
          ),

          _buildQrItem(
            context: context,
            icon: Icons.wifi,
            title: 'Wi-Fi',
            subtitle: l10n.wifiSubtitle,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateWifiScreen()),
            ),
          ),

          _buildQrItem(
            context: context,
            icon: Icons.person,
            title: l10n.contactVcard,
            subtitle: l10n.contactVcardSubtitle,
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
            title: l10n.emailAddress,
            subtitle: l10n.emailAddressSubtitle,
            onTap: () => _navigateToGeneric(
              context,
              l10n.createEmail,
              Barcode.qrCode(),
              hintText: AppLocalizations.of(context)!.emailAddressHint,
              prefix: 'mailto:',
            ),
          ),

          _buildQrItem(
            context: context,
            icon: Icons.sms,
            title: l10n.smsAddress,
            subtitle: l10n.smsAddressSubtitle,
            onTap: () => _navigateToGeneric(
              context,
              l10n.createSms,
              Barcode.qrCode(),
              hintText: AppLocalizations.of(context)!.phoneNumberHint,
              prefix: 'sms:',
              suffix: '?body=${l10n.messageBody}',
            ),
          ),

          _buildQrItem(
            context: context,
            icon: Icons.location_on,
            title: l10n.geographicCoordinates,
            subtitle: l10n.geographicCoordinatesSubtitle,
            onTap: () => _navigateToGeneric(
              context,
              l10n.createLocation,
              Barcode.qrCode(),
              hintText: AppLocalizations.of(context)!.locationHint,
              prefix: 'geo:',
            ),
          ),

          _buildQrItem(
            context: context,
            icon: Icons.phone,
            title: l10n.phoneNumber,
            subtitle: l10n.phoneNumberSubtitle,
            onTap: () => _navigateToGeneric(
              context,
              l10n.createPhone,
              Barcode.qrCode(),
              hintText: AppLocalizations.of(context)!.phoneNumberHint,
              prefix: 'tel:',
              inputType: TextInputType.phone,
            ),
          ),

          _buildQrItem(
            context: context,
            icon: Icons.event,
            title: l10n.calendarVevent,
            subtitle: l10n.calendarVeventSubtitle,
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
            l10n.barcodeTypes,
            Icons.view_headline,
            Colors.orange,
          ),
          const SizedBox(height: 8),

          _buildBarcodeItem(
            context: context,
            title: 'EAN-8',
            subtitle: l10n.ean8Subtitle,
            onTap: () => _navigateToGeneric(
              context,
              l10n.createEan8,
              Barcode.ean8(),
              hintText: AppLocalizations.of(context)!.ean8Hint,
              inputType: TextInputType.number,
              maxLength: 7,
            ),
          ),

          _buildBarcodeItem(
            context: context,
            title: 'EAN-13',
            subtitle: l10n.ean13Subtitle,
            onTap: () => _navigateToGeneric(
              context,
              l10n.createEan13,
              Barcode.ean13(),
              hintText: AppLocalizations.of(context)!.ean13Hint,
              inputType: TextInputType.number,
              maxLength: 12,
            ),
          ),

          _buildBarcodeItem(
            context: context,
            title: 'UPC-E',
            subtitle: l10n.upcESubtitle,
            onTap: () => _navigateToGeneric(
              context,
              l10n.createUpcE,
              Barcode.upcE(),
              hintText: AppLocalizations.of(context)!.upcEHint,
              inputType: TextInputType.number,
              maxLength: 6,
            ),
          ),

          _buildBarcodeItem(
            context: context,
            title: 'UPC-A',
            subtitle: l10n.upcASubtitle,
            onTap: () => _navigateToGeneric(
              context,
              l10n.createUpcA,
              Barcode.upcA(),
              hintText: AppLocalizations.of(context)!.ean13Hint,
              inputType: TextInputType.number,
              maxLength: 11,
            ),
          ),

          _buildBarcodeItem(
            context: context,
            title: 'CODE-39',
            subtitle: l10n.code39Subtitle,
            onTap: () => _navigateToGeneric(
              context,
              l10n.createCode39,
              Barcode.code39(),
              hintText: AppLocalizations.of(context)!.code39Hint,
            ),
          ),

          _buildBarcodeItem(
            context: context,
            title: 'CODE-93',
            subtitle: l10n.code93Subtitle,
            onTap: () => _navigateToGeneric(
              context,
              l10n.createCode93,
              Barcode.code93(),
              hintText: AppLocalizations.of(context)!.code39Hint,
            ),
          ),

          _buildBarcodeItem(
            context: context,
            title: 'CODE-128',
            subtitle: l10n.code128Subtitle,
            onTap: () => _navigateToGeneric(
              context,
              l10n.createCode128,
              Barcode.code128(),
              hintText: AppLocalizations.of(context)!.code39Hint,
            ),
          ),

          _buildBarcodeItem(
            context: context,
            title: l10n.itfInterleaved,
            subtitle: l10n.itfSubtitle,
            onTap: () => _navigateToGeneric(
              context,
              l10n.createItf,
              Barcode.itf(),
              hintText: AppLocalizations.of(context)!.itfHint,
              inputType: TextInputType.number,
            ),
          ),

          _buildBarcodeItem(
            context: context,
            title: 'PDF-417',
            subtitle: l10n.pdf417Subtitle,
            onTap: () => _navigateToGeneric(
              context,
              l10n.createPdf417,
              Barcode.pdf417(),
              hintText: l10n.pdf417Example,
            ),
          ),

          _buildBarcodeItem(
            context: context,
            title: 'Codabar',
            subtitle: l10n.codabarSubtitle,
            onTap: () => _navigateToGeneric(
              context,
              l10n.createCodabar,
              Barcode.codabar(),
              hintText: AppLocalizations.of(context)!.itfHint,
              inputType: TextInputType.number,
            ),
          ),

          _buildBarcodeItem(
            context: context,
            title: 'Data Matrix',
            subtitle: l10n.dataMatrixSubtitle,
            onTap: () => _navigateToGeneric(
              context,
              l10n.createDataMatrix,
              Barcode.dataMatrix(),
              hintText: l10n.dataMatrixExample,
            ),
          ),

          _buildBarcodeItem(
            context: context,
            title: 'Aztec',
            subtitle: l10n.aztecSubtitle,
            onTap: () => _navigateToGeneric(
              context,
              l10n.createAztec,
              Barcode.aztec(),
              hintText: l10n.aztecExample,
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
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
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
