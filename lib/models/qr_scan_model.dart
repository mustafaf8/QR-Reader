import 'package:hive/hive.dart';

part 'qr_scan_model.g.dart';

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
      return 'E-posta';
    } else if (data.startsWith('tel:')) {
      return 'Telefon';
    } else if (data.startsWith('sms:')) {
      return 'SMS';
    } else if (data.startsWith('geo:')) {
      return 'Konum';
    } else if (data.startsWith('WIFI:') || data.startsWith('wifi:')) {
      return 'WiFi';
    } else if (data.startsWith('vcard:') || data.startsWith('BEGIN:VCARD')) {
      return 'vCard';
    } else if (data.startsWith('mecard:')) {
      return 'MeCard';
    } else if (data.startsWith('otpauth:')) {
      return 'OTP';
    } else if (data.startsWith('bitcoin:') || data.startsWith('ethereum:')) {
      return 'Kripto Para';
    } else {
      return 'Metin';
    }
  }

  static bool _isUrl(String data) {
    return data.startsWith('http://') || data.startsWith('https://');
  }

  /// WiFi QR kodundan SSID'i çıkarır - Regex ile iyileştirildi
  static String _extractWiFiSSID(String data) {
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

  /// WiFi QR kodundan şifreyi çıkarır - Regex ile iyileştirildi
  static String _extractWiFiPassword(String data) {
    try {
      if (!data.startsWith('WIFI:')) return 'WiFi ağ bilgileri';

      // Regex ile P: etiketini ve değerini çıkar
      final passwordRegex = RegExp(r'P:([^;]*)');
      final match = passwordRegex.firstMatch(data);

      if (match != null && match.group(1) != null) {
        final password = match.group(1)!.trim();

        // Şifre boşsa veya gizliyse uygun mesaj döndür
        if (password.isEmpty) return 'Şifre yok';
        if (password == 'HIDDEN') return 'Gizli şifre';

        return password;
      }

      return 'WiFi ağ bilgileri';
    } catch (e) {
      return 'WiFi ağ bilgileri';
    }
  }

  static String _generateTitle(String data, String type) {
    switch (type) {
      case 'URL':
        try {
          final uri = Uri.parse(data);
          return uri.host;
        } catch (e) {
          return 'Web Adresi';
        }
      case 'E-posta':
        return data.replaceFirst('mailto:', '');
      case 'Telefon':
        return data.replaceFirst('tel:', '');
      case 'SMS':
        return 'SMS Mesajı';
      case 'Konum':
        return 'Konum Bilgisi';
      case 'WiFi':
        return _extractWiFiSSID(data);
      case 'vCard':
        return 'İletişim Kartı';
      case 'MeCard':
        return 'MeCard';
      case 'OTP':
        return 'OTP Kodu';
      case 'Kripto Para':
        return 'Kripto Para Adresi';
      default:
        return data.length > 30 ? '${data.substring(0, 30)}...' : data;
    }
  }

  static String _generateDescription(String data, String type) {
    switch (type) {
      case 'URL':
        return data;
      case 'E-posta':
        return 'E-posta adresi';
      case 'Telefon':
        return 'Telefon numarası';
      case 'SMS':
        return data.replaceFirst('sms:', '');
      case 'Konum':
        return data.replaceFirst('geo:', '');
      case 'WiFi':
        return _extractWiFiPassword(data);
      case 'vCard':
        return 'İletişim bilgileri';
      case 'MeCard':
        return 'MeCard bilgileri';
      case 'OTP':
        return 'İki faktörlü kimlik doğrulama';
      case 'Kripto Para':
        return 'Kripto para adresi';
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
