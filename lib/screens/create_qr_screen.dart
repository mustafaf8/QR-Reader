import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'create/create_generic_barcode_screen.dart';
import 'create/create_wifi_screen.dart';
import 'create/create_contact_screen.dart';
import 'create/create_calendar_screen.dart';
import 'package:barcode_widget/barcode_widget.dart';
import '../models/barcode_constraints.dart';

class CreateQrScreen extends StatelessWidget {
  const CreateQrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.createQrCode),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // QR Kod Türleri Bölümü
          _buildSectionHeader(
            context,
            l10n.qrCodeTypes,
            Icons.qr_code,
            Theme.of(context).colorScheme.primary,
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
              primaryLabel: l10n.clipboardContent,
              hintText: l10n.enterYourText,
              infoText: l10n.qrCodeInfo,
              constraint: BarcodeConstraints.qr,
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
              primaryLabel: l10n.urlHint,
              hintText: l10n.urlHint,
              prefix: 'https://',
              infoText: l10n.qrCodeInfo,
              constraint: BarcodeConstraints.qr,
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
              primaryLabel: l10n.enterYourText,
              hintText: l10n.enterYourText,
              infoText: l10n.qrCodeInfo,
              constraint: BarcodeConstraints.qr,
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
              primaryLabel: l10n.emailAddress,
              hintText: l10n.emailAddressHint,
              prefix: 'mailto:',
              infoText: l10n.qrCodeInfo,
              constraint: BarcodeConstraints.qr,
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
              primaryLabel: l10n.phoneNumber,
              hintText: AppLocalizations.of(context)!.phoneNumberHint,
              prefix: 'sms:',
              enableSecondaryField: true,
              secondaryLabel: l10n.messageBody,
              secondaryHint: l10n.enterYourText,
              secondaryInputType: TextInputType.text,
              customFormatter: (number, message) {
                final trimmedNumber = number.trim();
                if (trimmedNumber.isEmpty) return '';
                final trimmedMessage = message.trim();
                final encodedMessage = trimmedMessage.isEmpty
                    ? ''
                    : '?body=${Uri.encodeComponent(trimmedMessage)}';
                return 'sms:$trimmedNumber$encodedMessage';
              },
              infoText: l10n.qrCodeInfo,
              constraint: BarcodeConstraints.qr,
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
              primaryLabel: l10n.locationHint,
              hintText: l10n.locationHint,
              prefix: 'geo:',
              infoText: l10n.qrCodeInfo,
              constraint: BarcodeConstraints.qr,
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
              primaryLabel: l10n.phoneNumber,
              hintText: l10n.phoneNumberHint,
              prefix: 'tel:',
              inputType: TextInputType.phone,
              infoText: l10n.qrCodeInfo,
              constraint: BarcodeConstraints.qr,
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
            Theme.of(context).colorScheme.secondary,
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
              primaryLabel: l10n.ean8Hint,
              hintText: l10n.ean8Hint,
              inputType: TextInputType.number,
              maxLength: 7,
              infoText: l10n.ean8Info,
              constraint: BarcodeConstraints.ean8,
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
              primaryLabel: l10n.ean13Hint,
              hintText: l10n.ean13Hint,
              inputType: TextInputType.number,
              maxLength: 12,
              infoText: l10n.ean13Info,
              constraint: BarcodeConstraints.ean13,
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
              primaryLabel: l10n.upcEHint,
              hintText: l10n.upcEHint,
              inputType: TextInputType.number,
              maxLength: 6,
              infoText: l10n.upcEInfo,
              constraint: BarcodeConstraints.upcE,
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
              primaryLabel: l10n.upcAHint,
              hintText: l10n.upcAHint,
              inputType: TextInputType.number,
              maxLength: 11,
              infoText: l10n.upcAInfo,
              constraint: BarcodeConstraints.upcA,
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
              primaryLabel: l10n.code39Hint,
              hintText: l10n.code39Hint,
              infoText: l10n.code39Info,
              constraint: BarcodeConstraints.code39,
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
              primaryLabel: l10n.code93Hint,
              hintText: l10n.code93Hint,
              infoText: l10n.code93Info,
              constraint: BarcodeConstraints.code93,
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
              primaryLabel: l10n.code128Hint,
              hintText: l10n.code128Hint,
              infoText: l10n.code128Info,
              constraint: BarcodeConstraints.code128,
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
              primaryLabel: l10n.itfHint,
              hintText: l10n.itfHint,
              inputType: TextInputType.number,
              infoText: l10n.itfInfo,
              constraint: BarcodeConstraints.itf,
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
              primaryLabel: l10n.pdf417Example,
              hintText: l10n.pdf417Example,
              infoText: l10n.pdf417Info,
              constraint: BarcodeConstraints.pdf417,
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
              primaryLabel: l10n.codabarSubtitle,
              hintText: l10n.itfHint,
              inputType: TextInputType.number,
              infoText: l10n.codabarInfo,
              constraint: BarcodeConstraints.codabar,
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
              primaryLabel: l10n.dataMatrixExample,
              hintText: l10n.dataMatrixExample,
              infoText: l10n.dataMatrixInfo,
              constraint: BarcodeConstraints.dataMatrix,
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
              primaryLabel: l10n.aztecExample,
              hintText: l10n.aztecExample,
              infoText: l10n.aztecInfo,
              constraint: BarcodeConstraints.aztec,
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
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
    String? primaryLabel,
    String? prefix,
    String? suffix,
    TextInputType? inputType,
    int? maxLength,
    bool isClipboard = false,
    String? infoText,
    bool enableSecondaryField = false,
    String? secondaryLabel,
    String? secondaryHint,
    TextInputType? secondaryInputType,
    int? secondaryMaxLength,
    String Function(String primary, String secondary)? customFormatter,
    BarcodeConstraint? constraint,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateGenericBarcodeScreen(
          title: title,
          barcode: barcode,
          hintText: hintText,
          primaryLabel: primaryLabel,
          prefix: prefix,
          suffix: suffix,
          inputType: inputType,
          maxLength: maxLength,
          isClipboard: isClipboard,
          infoText: infoText,
          enableSecondaryField: enableSecondaryField,
          secondaryLabel: secondaryLabel,
          secondaryHint: secondaryHint,
          secondaryInputType: secondaryInputType,
          secondaryMaxLength: secondaryMaxLength,
          customFormatter: customFormatter,
          constraint: constraint,
        ),
      ),
    );
  }
}
