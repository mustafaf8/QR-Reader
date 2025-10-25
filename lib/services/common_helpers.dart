import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import 'error_service.dart';

class CommonHelpers {
  /// Tarih formatlaması için ortak fonksiyon
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

  /// Dosya kaydetme
  static Future<void> saveToFile(
    String content,
    String fileName,
    BuildContext context,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
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
