import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
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
}
