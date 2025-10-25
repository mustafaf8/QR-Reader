import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/qr_scan_model.dart';
import 'error_service.dart';

class CommonHelpers {
  /// Tarih formatlaması için ortak fonksiyon - göreceli format
  static String formatDateTime(DateTime dateTime, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return l10n.yesterday;
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${l10n.daysAgo}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  /// Standart tarih formatlaması - GG.AA.YYYY HH:MM
  static String formatDateTimeStandard(
    DateTime dateTime,
    BuildContext context,
  ) {
    final locale = Localizations.localeOf(context);
    final formatter = DateFormat('dd.MM.yyyy HH:mm', locale.toString());
    return formatter.format(dateTime);
  }

  /// Sadece tarih formatlaması - GG.AA.YYYY
  static String formatDate(DateTime dateTime, BuildContext context) {
    final locale = Localizations.localeOf(context);
    final formatter = DateFormat('dd.MM.yyyy', locale.toString());
    return formatter.format(dateTime);
  }

  /// Sadece saat formatlaması - HH:MM
  static String formatTime(DateTime dateTime, BuildContext context) {
    final locale = Localizations.localeOf(context);
    final formatter = DateFormat('HH:mm', locale.toString());
    return formatter.format(dateTime);
  }

  /// Metin kopyalama
  static Future<void> copyToClipboard(String text, BuildContext context) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      ErrorService.showSuccessSnackBar(
        context,
        AppLocalizations.of(context)!.copiedToClipboard,
      );
    } catch (e) {
      ErrorService.showErrorSnackBar(
        context,
        AppLocalizations.of(context)!.copyFailed,
      );
    }
  }

  /// Dosya kaydetme - Downloads klasörüne
  static Future<void> saveToFile(
    String content,
    String fileName,
    BuildContext context,
  ) async {
    try {
      final directory =
          await getDownloadsDirectory() ??
          await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(content);
      ErrorService.showSuccessSnackBar(
        context,
        AppLocalizations.of(context)!.savedToDownloads,
      );
    } catch (e) {
      ErrorService.showErrorSnackBar(
        context,
        AppLocalizations.of(context)!.saveFailed,
      );
    }
  }

  /// QR/Barkod kaydetme - otomatik dosya adı oluşturur
  static Future<void> saveQrData(
    String content,
    String type,
    String title,
    BuildContext context,
  ) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = '${type}_${title}_$timestamp.txt';
    await saveToFile(content, fileName, context);
  }

  /// WiFi QR kaydetme - özel format
  static Future<void> saveWiFiQr(
    String ssid,
    String securityType,
    String password,
    bool isHidden,
    String rawData,
    BuildContext context,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final content =
        '${l10n.wifiQrCode}\n'
        '${l10n.creationDateLabel}: ${DateTime.now().toString()}\n'
        '${l10n.networkNameSSID}: $ssid\n'
        '${l10n.securityType}: $securityType\n'
        '${l10n.passwordLabel}: ${password.isNotEmpty ? password : l10n.none}\n'
        '${l10n.hiddenNetwork}: ${isHidden ? l10n.yes : l10n.no}\n'
        '${l10n.rawData}: $rawData';

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'WiFi_QR_${ssid.replaceAll(' ', '_')}_$timestamp.txt';
    await saveToFile(content, fileName, context);
  }

  /// WiFi QR paylaşma - özel format
  static Future<void> shareWiFiQr(
    String ssid,
    String securityType,
    String password,
    bool isHidden,
    String rawData,
    BuildContext context,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final content =
        '${l10n.wifiQrCode}\n\n'
        '${l10n.networkNameSSID}: $ssid\n'
        '${l10n.securityType}: $securityType\n'
        '${l10n.passwordLabel}: ${password.isNotEmpty ? password : l10n.none}\n'
        '${l10n.hiddenNetwork}: ${isHidden ? l10n.yes : l10n.no}\n'
        '${l10n.rawData}: $rawData\n'
        '${l10n.creationDateLabel}: ${DateTime.now().toString()}';

    await shareContent(content, '${l10n.wifiQrCode} - $ssid', context);
  }

  /// Calendar Event QR kaydetme - özel format
  static Future<void> saveCalendarQr(
    String title,
    String description,
    String location,
    String organizer,
    DateTime startDate,
    TimeOfDay startTime,
    DateTime endDate,
    TimeOfDay endTime,
    String rawData,
    BuildContext context,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final content =
        '${l10n.eventQrCodeVevent}\n'
        '${l10n.creationDateLabel}: ${DateTime.now().toString()}\n'
        '${l10n.titleLabel}: $title\n'
        '${l10n.descriptionLabel}: $description\n'
        '${l10n.location}: $location\n'
        '${l10n.organizerLabel}: $organizer\n'
        '${l10n.startDateLabel}: ${startDate.day}/${startDate.month}/${startDate.year} ${startTime.format(context)}\n'
        '${l10n.endDateLabel}: ${endDate.day}/${endDate.month}/${endDate.year} ${endTime.format(context)}\n'
        '${l10n.vEventData}: $rawData';

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'Event_QR_${title.replaceAll(' ', '_')}_$timestamp.txt';
    await saveToFile(content, fileName, context);
  }

  /// Calendar Event QR paylaşma - özel format
  static Future<void> shareCalendarQr(
    String title,
    String description,
    String location,
    String organizer,
    DateTime startDate,
    TimeOfDay startTime,
    DateTime endDate,
    TimeOfDay endTime,
    String rawData,
    BuildContext context,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final content =
        '${l10n.eventQrCodeVevent}\n\n'
        '${l10n.titleLabel}: $title\n'
        '${l10n.descriptionLabel}: $description\n'
        '${l10n.location}: $location\n'
        '${l10n.organizerLabel}: $organizer\n'
        '${l10n.startDateLabel}: ${startDate.day}/${startDate.month}/${startDate.year} ${startTime.format(context)}\n'
        '${l10n.endDateLabel}: ${endDate.day}/${endDate.month}/${endDate.year} ${endTime.format(context)}\n'
        '${l10n.vEventData}: $rawData\n'
        '${l10n.creationDateLabel}: ${DateTime.now().toString()}';

    await shareContent(content, '${l10n.eventQrCodeVevent} - $title', context);
  }

  /// Contact QR kaydetme - özel format
  static Future<void> saveContactQr(
    String firstName,
    String lastName,
    String phone,
    String email,
    String organization,
    String title,
    String address,
    String website,
    String rawData,
    BuildContext context,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final content =
        '${l10n.contactQrCodeVcard}\n'
        '${l10n.creationDateLabel}: ${DateTime.now().toString()}\n'
        '${l10n.firstNameLabel}: $firstName\n'
        '${l10n.lastNameLabel}: $lastName\n'
        '${l10n.phoneLabel}: $phone\n'
        '${l10n.emailLabel}: $email\n'
        '${l10n.organizationLabel}: $organization\n'
        '${l10n.titleLabel}: $title\n'
        '${l10n.addressLabel}: $address\n'
        '${l10n.websiteLabel}: $website\n'
        '${l10n.rawData}: $rawData';

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'Contact_QR_${firstName}_${lastName}_$timestamp.txt';
    await saveToFile(content, fileName, context);
  }

  /// Contact QR paylaşma - özel format
  static Future<void> shareContactQr(
    String firstName,
    String lastName,
    String phone,
    String email,
    String organization,
    String title,
    String address,
    String website,
    String rawData,
    BuildContext context,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final content =
        '${l10n.contactQrCodeVcard}\n\n'
        '${l10n.firstNameLabel}: $firstName\n'
        '${l10n.lastNameLabel}: $lastName\n'
        '${l10n.phoneLabel}: $phone\n'
        '${l10n.emailLabel}: $email\n'
        '${l10n.organizationLabel}: $organization\n'
        '${l10n.titleLabel}: $title\n'
        '${l10n.addressLabel}: $address\n'
        '${l10n.websiteLabel}: $website\n'
        '${l10n.rawData}: $rawData\n'
        '${l10n.creationDateLabel}: ${DateTime.now().toString()}';

    await shareContent(
      content,
      '${l10n.contactQrCodeVcard} - $firstName $lastName',
      context,
    );
  }

  /// Paylaşma
  static Future<void> shareContent(
    String content,
    String subject,
    BuildContext context,
  ) async {
    try {
      await Share.share(content, subject: subject);
    } catch (e) {
      ErrorService.showErrorSnackBar(
        context,
        AppLocalizations.of(context)!.shareFailed,
      );
    }
  }

  /// URL açma
  static Future<void> openUrl(String url, BuildContext context) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ErrorService.showErrorSnackBar(
          context,
          AppLocalizations.of(context)!.urlNotFound,
        );
      }
    } catch (e) {
      ErrorService.showErrorSnackBar(
        context,
        AppLocalizations.of(context)!.urlOpenFailed,
      );
    }
  }

  /// Metin kısaltma
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// QR kod türüne göre renk döndürme
  static Color getTypeColor(String type, BuildContext context) {
    final theme = Theme.of(context);
    switch (type) {
      case 'URL':
        return theme.colorScheme.primary;
      case 'WiFi':
        return Colors.orange;
      case 'Contact':
        return Colors.green;
      case 'Calendar':
        return Colors.purple;
      case 'SMS':
        return Colors.blue;
      case 'Email':
        return Colors.red;
      case 'Phone':
        return Colors.teal;
      case 'Text':
        return Colors.grey;
      default:
        return theme.colorScheme.primary;
    }
  }

  /// QR kod türüne göre ikon döndürme
  static IconData getTypeIcon(String type) {
    switch (type) {
      case 'URL':
        return Icons.link;
      case 'WiFi':
        return Icons.wifi;
      case 'Contact':
        return Icons.person;
      case 'Calendar':
        return Icons.calendar_today;
      case 'SMS':
        return Icons.message;
      case 'Email':
        return Icons.email;
      case 'Phone':
        return Icons.phone;
      case 'Text':
        return Icons.text_fields;
      default:
        return Icons.qr_code;
    }
  }

  /// QR tipini yerelleştirilmiş metne çevirir
  static String getLocalizedType(String type, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case 'EMAIL':
        return l10n.emailType;
      case 'PHONE':
        return l10n.phoneType;
      case 'LOCATION':
        return l10n.locationType;
      case 'WIFI':
        return l10n.wifiType;
      case 'VCARD':
        return l10n.vcardType;
      case 'MECARD':
        return l10n.mecardType;
      case 'OTP':
        return l10n.otpType;
      case 'CRYPTO':
        return l10n.cryptoType;
      case 'TEXT':
        return l10n.textType;
      default:
        return type;
    }
  }

  /// WiFi şifre durumunu yerelleştirilmiş metne çevirir
  static String getLocalizedPasswordStatus(
    PasswordStatus status,
    BuildContext context,
  ) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case PasswordStatus.none:
        return l10n.noPasswordText;
      case PasswordStatus.hidden:
        return l10n.hiddenPassword;
      case PasswordStatus.available:
        return l10n.wifiNetwork;
    }
  }

  /// WiFi QR kodu için kopyalama seçenekleri
  static Future<void> showWiFiCopyOptions(
    QrScanModel scan,
    BuildContext context,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    return showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.wifiCopyOptions,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.wifi, color: Colors.cyan),
                title: Text(l10n.copyWifiPassword),
                subtitle: Text(l10n.copyWifiPasswordDesc),
                onTap: () async {
                  Navigator.pop(context);
                  await _copyWiFiPassword(scan, context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.data_object, color: Colors.blue),
                title: Text(l10n.copyRawData),
                subtitle: Text(l10n.copyRawDataDesc),
                onTap: () async {
                  Navigator.pop(context);
                  await copyToClipboard(scan.data, context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.info, color: Colors.green),
                title: Text(l10n.copyWifiInfo),
                subtitle: Text(l10n.copyWifiInfoDesc),
                onTap: () async {
                  Navigator.pop(context);
                  await _copyWiFiInfo(scan, context);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  /// WiFi şifresini kopyalar
  static Future<void> _copyWiFiPassword(
    QrScanModel scan,
    BuildContext context,
  ) async {
    final password = QrScanModel.extractWiFiPassword(scan.data);
    if (password.isNotEmpty) {
      await copyToClipboard(password, context);
    } else {
      final l10n = AppLocalizations.of(context)!;
      ErrorService.showInfoSnackBar(context, l10n.noPasswordToCopy);
    }
  }

  /// WiFi bilgilerini kopyalar
  static Future<void> _copyWiFiInfo(
    QrScanModel scan,
    BuildContext context,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final ssid = QrScanModel.extractWiFiSSID(scan.data);
    final password = QrScanModel.extractWiFiPassword(scan.data);
    final passwordStatus = QrScanModel.getWiFiPasswordStatus(scan.data);

    String info = '${l10n.networkNameSSID}: $ssid\n';
    info +=
        '${l10n.passwordLabel}: ${getLocalizedPasswordStatus(passwordStatus, context)}';

    if (password.isNotEmpty) {
      info += '\n$password';
    }

    await copyToClipboard(info, context);
  }

  /// Responsive dialog boyutları hesaplar
  static BoxConstraints getResponsiveDialogConstraints(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Ekran oranına göre dinamik boyutlar
    final aspectRatio = screenWidth / screenHeight;

    double maxWidth;
    double maxHeight;

    if (aspectRatio > 1.2) {
      // Yatay mod veya tablet landscape
      maxWidth = (screenWidth * 0.6).clamp(300.0, 500.0);
      maxHeight = (screenHeight * 0.85).clamp(400.0, 700.0);
    } else if (screenHeight < 600) {
      // Çok küçük ekranlar
      maxWidth = (screenWidth * 0.95).clamp(280.0, 400.0);
      maxHeight = (screenHeight * 0.9).clamp(300.0, 500.0);
    } else {
      // Normal telefon ekranları
      maxWidth = (screenWidth * 0.9).clamp(300.0, 400.0);
      maxHeight = (screenHeight * 0.8).clamp(400.0, 650.0);
    }

    return BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight);
  }

  /// Responsive text style hesaplar
  static TextStyle getResponsiveTextStyle(
    BuildContext context, {
    double? baseFontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Ekran boyutuna göre font boyutu hesapla
    double fontSize = baseFontSize ?? 14.0;

    if (screenHeight < 600) {
      // Çok küçük ekranlar - daha küçük font
      fontSize = (fontSize * 0.85).clamp(10.0, 16.0);
    } else if (screenWidth < 360) {
      // Dar ekranlar - biraz küçük font
      fontSize = (fontSize * 0.9).clamp(11.0, 18.0);
    } else if (screenWidth > 600) {
      // Geniş ekranlar - biraz büyük font
      fontSize = (fontSize * 1.1).clamp(12.0, 20.0);
    }

    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.normal,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }

  /// Responsive InputDecoration oluşturur
  static InputDecoration getResponsiveInputDecoration(
    BuildContext context, {
    required String labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 600 || screenSize.width < 360;

    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      labelStyle: getResponsiveTextStyle(
        context,
        baseFontSize: isSmallScreen ? 12.0 : 14.0,
        color: Colors.grey.shade300,
      ),
      hintStyle: getResponsiveTextStyle(
        context,
        baseFontSize: isSmallScreen ? 12.0 : 14.0,
        color: Colors.grey.shade400,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: isSmallScreen ? 12 : 16,
      ),
    );
  }

  /// Responsive ListTile subtitle oluşturur
  static Widget buildResponsiveSubtitle(
    BuildContext context,
    String text, {
    int? maxLines,
    TextOverflow? overflow,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 600 || screenSize.width < 360;

    return Text(
      text,
      maxLines: maxLines ?? (isSmallScreen ? 2 : 1),
      overflow:
          overflow ??
          (isSmallScreen ? TextOverflow.ellipsis : TextOverflow.ellipsis),
      style: getResponsiveTextStyle(
        context,
        baseFontSize: isSmallScreen ? 12.0 : 14.0,
        color: Colors.grey.shade600,
      ),
    );
  }
}
