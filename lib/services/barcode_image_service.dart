import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:saver_gallery/saver_gallery.dart';

import '../l10n/app_localizations.dart';
import 'error_service.dart';

class BarcodeImageService {
  const BarcodeImageService._();

  static Future<Uint8List?> capturePng(GlobalKey boundaryKey) async {
    final boundary =
        boundaryKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) return null;

    final buildContext = boundaryKey.currentContext;
    final pixelRatio = buildContext != null
        ? MediaQuery.of(buildContext).devicePixelRatio
        : WidgetsBinding
              .instance
              .platformDispatcher
              .views
              .first
              .devicePixelRatio;

    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  static Future<void> saveToGallery(
    Uint8List imageBytes,
    String title,
    BuildContext context,
  ) async {
    if (!await _ensureGalleryPermission(context)) return;

    try {
      final fileName = _createFileName(title);
      final result = await SaverGallery.saveImage(
        imageBytes,
        quality: 100,
        fileName: fileName,
        extension: 'png',
        androidRelativePath: 'Pictures/QRBarcode',
        skipIfExists: false,
      );

      if (result.isSuccess) {
        if (context.mounted) {
          ErrorService.showSuccessSnackBar(
            context,
            AppLocalizations.of(context)!.savedToGallery,
          );
        }
        return;
      }

      if (context.mounted) {
        ErrorService.showErrorSnackBar(
          context,
          result.errorMessage?.isNotEmpty == true
              ? result.errorMessage!
              : AppLocalizations.of(context)!.saveFailed,
        );
      }
    } catch (_) {
      if (context.mounted) {
        ErrorService.showErrorSnackBar(
          context,
          AppLocalizations.of(context)!.saveFailed,
        );
      }
    }
  }

  static Future<void> shareImage(
    Uint8List imageBytes,
    String title,
    BuildContext context,
  ) async {
    try {
      final fileName = '${_createFileName(title)}.png';
      final tempDirectory = await getTemporaryDirectory();
      final filePath = '${tempDirectory.path}/$fileName';
      final file = await File(filePath).create(recursive: true);
      await file.writeAsBytes(imageBytes);

      await Share.shareXFiles([XFile(file.path)], subject: title);

      if (context.mounted) {
        ErrorService.showSuccessSnackBar(
          context,
          AppLocalizations.of(context)!.qrCodeImageShared,
        );
      }
    } catch (_) {
      if (context.mounted) {
        ErrorService.showErrorSnackBar(
          context,
          AppLocalizations.of(context)!.shareFailed,
        );
      }
    }
  }

  static String _createFileName(String title) {
    final safeTitle = title.replaceAll(RegExp(r'[^A-Za-z0-9]'), '_');
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${safeTitle}_$timestamp';
  }

  static Future<bool> _ensureGalleryPermission(BuildContext context) async {
    if (!Platform.isAndroid && !Platform.isIOS) return true;

    final permissions = Platform.isIOS
        ? <Permission>[Permission.photosAddOnly, Permission.photos]
        : <Permission>[Permission.photos, Permission.storage];

    for (final permission in permissions) {
      final status = await permission.status;
      if (status.isGranted || status.isLimited) return true;

      if (status.isDenied || status.isLimited) {
        final result = await permission.request();
        if (result.isGranted || result.isLimited) return true;
        if (result.isPermanentlyDenied) {
          _showPermissionSnackbar(context, isPermanent: true);
          return false;
        }
      } else if (status.isPermanentlyDenied) {
        _showPermissionSnackbar(context, isPermanent: true);
        return false;
      }
    }

    _showPermissionSnackbar(context, isPermanent: false);
    return false;
  }

  static void _showPermissionSnackbar(
    BuildContext context, {
    required bool isPermanent,
  }) {
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context)!;
    ErrorService.showErrorSnackBar(
      context,
      isPermanent
          ? l10n.galleryPermissionPermanentlyDenied
          : l10n.galleryPermissionDenied,
    );
  }
}
