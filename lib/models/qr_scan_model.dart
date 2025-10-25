import 'package:hive/hive.dart';

part 'qr_scan_model.g.dart';

/// WiFi şifre durumu için enum
enum PasswordStatus {
  @HiveField(0)
  none, // Şifre yok
  @HiveField(1)
  hidden, // Gizli şifre
  @HiveField(2)
  available, // Şifre mevcut
}

@HiveType(typeId: 0)
class QrScanModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String data;

  @HiveField(2)
  final String type;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final String? format;

  @HiveField(5)
  final bool isUrl;

  @HiveField(6)
  final String? title;

  @HiveField(7)
  final String? description;

  QrScanModel({
    required this.id,
    required this.data,
    required this.type,
    required this.timestamp,
    this.format,
    this.isUrl = false,
    this.title,
    this.description,
  });

  /// Ham veriden QrScanModel oluşturur
  factory QrScanModel.fromData(String data) {
    final now = DateTime.now();
    final type = _getDataType(data);
    final format = 'QR_CODE';
    final isUrl = _isUrl(data);

    return QrScanModel(
      id: '${now.millisecondsSinceEpoch}_${data.hashCode}',
      data: data,
      type: type,
      timestamp: now,
      format: format,
      isUrl: isUrl,
      title: _generateTitle(data, type),
      description: _generateDescription(data, type),
    );
  }

  // Copy constructor
  QrScanModel.copy({
    required this.id,
    required this.data,
    required this.type,
    required this.timestamp,
    this.format,
    this.isUrl = false,
    this.title,
    this.description,
  });

  factory QrScanModel.fromScan({required String data, String? format}) {
    final now = DateTime.now();
    final type = _getDataType(data);
    final isUrl = _isUrl(data);

    return QrScanModel(
      id: '${now.millisecondsSinceEpoch}_${data.hashCode}',
      data: data,
      type: type,
      timestamp: now,
      format: format,
      isUrl: isUrl,
      title: _generateTitle(data, type),
      description: _generateDescription(data, type),
    );
  }

  static String _getDataType(String data) {
    if (data.startsWith('http://') || data.startsWith('https://')) {
      return 'URL';
    } else if (data.startsWith('mailto:')) {
      return 'EMAIL';
    } else if (data.startsWith('tel:')) {
      return 'PHONE';
    } else if (data.startsWith('sms:')) {
      return 'SMS';
    } else if (data.startsWith('geo:')) {
      return 'LOCATION';
    } else if (data.startsWith('WIFI:') || data.startsWith('wifi:')) {
      return 'WIFI';
    } else if (data.startsWith('vcard:') || data.startsWith('BEGIN:VCARD')) {
      return 'VCARD';
    } else if (data.startsWith('mecard:')) {
      return 'MECARD';
    } else if (data.startsWith('otpauth:')) {
      return 'OTP';
    } else if (data.startsWith('bitcoin:') || data.startsWith('ethereum:')) {
      return 'CRYPTO';
    } else {
      return 'TEXT';
    }
  }

  static bool _isUrl(String data) {
    return data.startsWith('http://') || data.startsWith('https://');
  }

  /// WiFi QR kodundan SSID'i çıkarır - Regex ile iyileştirildi
  static String extractWiFiSSID(String data) {
    try {
      if (!data.startsWith('WIFI:')) return 'WiFi Ağı';

      // Regex ile S: etiketini ve değerini çıkar
      final ssidRegex = RegExp(r'S:([^;]+)');
      final match = ssidRegex.firstMatch(data);

      if (match != null && match.group(1) != null) {
        final ssid = match.group(1)!.trim();
        return ssid.isNotEmpty ? ssid : 'WiFi Ağı';
      }

      return 'WiFi Ağı';
    } catch (e) {
      return 'WiFi Ağı';
    }
  }

  /// WiFi QR kodundan şifre durumunu belirler
  static PasswordStatus getWiFiPasswordStatus(String data) {
    try {
      if (!data.startsWith('WIFI:')) return PasswordStatus.none;

      // Regex ile P: etiketini ve değerini çıkar
      final passwordRegex = RegExp(r'P:([^;]*)');
      final match = passwordRegex.firstMatch(data);

      if (match != null && match.group(1) != null) {
        final password = match.group(1)!.trim();

        // Şifre durumunu belirle
        if (password.isEmpty) return PasswordStatus.none;
        if (password == 'HIDDEN') return PasswordStatus.hidden;
        return PasswordStatus.available;
      }

      return PasswordStatus.none;
    } catch (e) {
      return PasswordStatus.none;
    }
  }

  /// WiFi QR kodundan şifreyi çıkarır (sadece mevcut şifreler için)
  static String extractWiFiPassword(String data) {
    try {
      if (!data.startsWith('WIFI:')) return '';

      // Regex ile P: etiketini ve değerini çıkar
      final passwordRegex = RegExp(r'P:([^;]*)');
      final match = passwordRegex.firstMatch(data);

      if (match != null && match.group(1) != null) {
        final password = match.group(1)!.trim();

        // Sadece gerçek şifreleri döndür
        if (password.isNotEmpty && password != 'HIDDEN') {
          return password;
        }
      }

      return '';
    } catch (e) {
      return '';
    }
  }

  static String _generateTitle(String data, String type) {
    switch (type) {
      case 'URL':
        try {
          final uri = Uri.parse(data);
          return uri.host;
        } catch (e) {
          return data; // Fallback olarak orijinal data'yı döndür
        }
      case 'EMAIL':
        return data.replaceFirst('mailto:', '');
      case 'PHONE':
        return data.replaceFirst('tel:', '');
      case 'SMS':
        return data; // SMS içeriğini döndür
      case 'LOCATION':
        return data; // Konum bilgisini döndür
      case 'WIFI':
        return extractWiFiSSID(data);
      case 'VCARD':
        return data; // vCard içeriğini döndür
      case 'MECARD':
        return data; // MeCard içeriğini döndür
      case 'OTP':
        return data; // OTP içeriğini döndür
      case 'CRYPTO':
        return data; // Kripto adresini döndür
      default:
        return data.length > 30 ? '${data.substring(0, 30)}...' : data;
    }
  }

  static String _generateDescription(String data, String type) {
    switch (type) {
      case 'URL':
        return data;
      case 'EMAIL':
        return data.replaceFirst('mailto:', '');
      case 'PHONE':
        return data.replaceFirst('tel:', '');
      case 'SMS':
        return data.replaceFirst('sms:', '');
      case 'LOCATION':
        return data.replaceFirst('geo:', '');
      case 'WIFI':
        return extractWiFiPassword(data);
      case 'VCARD':
        return data; // vCard içeriğini döndür
      case 'MECARD':
        return data; // MeCard içeriğini döndür
      case 'OTP':
        return data; // OTP içeriğini döndür
      case 'CRYPTO':
        return data; // Kripto adresini döndür
      default:
        return data;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data': data,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'format': format,
      'isUrl': isUrl,
      'title': title,
      'description': description,
    };
  }

  factory QrScanModel.fromJson(Map<String, dynamic> json) {
    return QrScanModel(
      id: json['id'],
      data: json['data'],
      type: json['type'],
      timestamp: DateTime.parse(json['timestamp']),
      format: json['format'],
      isUrl: json['isUrl'] ?? false,
      title: json['title'],
      description: json['description'],
    );
  }

  QrScanModel copyWith({
    String? id,
    String? data,
    String? type,
    DateTime? timestamp,
    String? format,
    bool? isUrl,
    String? title,
    String? description,
  }) {
    return QrScanModel(
      id: id ?? this.id,
      data: data ?? this.data,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      format: format ?? this.format,
      isUrl: isUrl ?? this.isUrl,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'QrScanModel(id: $id, data: $data, type: $type, timestamp: $timestamp)';
  }
}
