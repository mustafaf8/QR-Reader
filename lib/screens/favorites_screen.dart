import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/qr_scan_model.dart';
import '../services/hive_service.dart';
import '../services/log_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final HiveService _hiveService = HiveService();
  List<QrScanModel> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final favorites = _hiveService.getAllFavorites();
      setState(() {
        _favorites = favorites;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      LogService().error('Sık kullanılanları yükleme hatası', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sık Kullanılanlar'),
        backgroundColor: Colors.orange.shade600,
        foregroundColor: Colors.white,
        actions: [
          if (_favorites.isNotEmpty)
            IconButton(
              onPressed: _clearAllFavorites,
              icon: const Icon(Icons.clear_all),
              tooltip: 'Tümünü Temizle',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_border, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Henüz sık kullanılan yok',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tarama geçmişinden yıldız ikonuna tıklayarak\nsık kullanılanlara ekleyebilirsiniz',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _favorites.length,
              itemBuilder: (context, index) {
                final favorite = _favorites[index];
                return _buildFavoriteItem(favorite);
              },
            ),
    );
  }

  Widget _buildFavoriteItem(QrScanModel favorite) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTypeColor(favorite.type),
          child: Icon(
            _getTypeIcon(favorite.type),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          favorite.title ?? favorite.data,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              favorite.type,
              style: TextStyle(
                fontSize: 12,
                color: _getTypeColor(favorite.type),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (favorite.type == 'WiFi' && favorite.description != null)
              Text(
                'Şifre: ${_maskPassword(favorite.description!)}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade700,
                  fontFamily: 'monospace',
                ),
              ),
            Text(
              _formatTimestamp(favorite.timestamp),
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Yıldız ikonu (Sık kullanılanlardan çıkar)
            IconButton(
              onPressed: () => _removeFromFavorites(favorite),
              icon: const Icon(Icons.star, color: Colors.amber, size: 20),
              tooltip: 'Sık kullanılanlardan çıkar',
            ),
            // Popup menü
            PopupMenuButton<String>(
              onSelected: (value) async {
                switch (value) {
                  case 'copy':
                    _copyToClipboard(favorite);
                    break;
                  case 'open':
                    if (favorite.isUrl) {
                      _openUrl(favorite.data);
                    }
                    break;
                  case 'remove':
                    await _removeFromFavorites(favorite);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'copy',
                  child: Row(
                    children: [
                      Icon(Icons.copy, size: 16),
                      SizedBox(width: 8),
                      Text('Kopyala'),
                    ],
                  ),
                ),
                if (favorite.isUrl)
                  const PopupMenuItem(
                    value: 'open',
                    child: Row(
                      children: [
                        Icon(Icons.open_in_browser, size: 16),
                        SizedBox(width: 8),
                        Text('Aç'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'remove',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Sil', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () => _showFavoriteDetails(favorite),
      ),
    );
  }

  Future<void> _removeFromFavorites(QrScanModel favorite) async {
    try {
      await _hiveService.removeFromFavorites(favorite.id);
      await _loadFavorites(); // Listeyi yenile
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sık kullanılanlardan çıkarıldı'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _clearAllFavorites() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tüm Sık Kullanılanları Sil'),
        content: const Text(
          'Tüm sık kullanılanları silmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _hiveService.clearAllFavorites();
        await _loadFavorites();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tüm sık kullanılanlar silindi'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Silme hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _copyToClipboard(QrScanModel favorite) {
    String textToCopy = favorite.data;
    String message = 'Panoya kopyalandı';

    // WiFi QR kodu ise sadece şifreyi kopyala
    if (favorite.type == 'WiFi' && favorite.description != null) {
      final lines = favorite.description!.split('\n');
      if (lines.length >= 2) {
        final passwordLine = lines[1];
        if (passwordLine.startsWith('Şifre: ')) {
          textToCopy = passwordLine.substring(7); // "Şifre: " kısmını çıkar
          message = 'WiFi şifresi panoya kopyalandı';
        }
      }
    }

    Clipboard.setData(ClipboardData(text: textToCopy));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  void _openUrl(String url) {
    // URL açma işlemi - main.dart'taki _launchUrl metodunu kullanabilirsiniz
    LogService().info('URL açma isteği', extra: {'url': url});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('URL açma özelliği: $url'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showFavoriteDetails(QrScanModel favorite) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getTypeColor(favorite.type),
                      _getTypeColor(favorite.type).withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 25,
                      child: Icon(
                        _getTypeIcon(favorite.type),
                        color: _getTypeColor(favorite.type),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            favorite.title ?? 'Sık Kullanılan Detayı',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            favorite.type,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Veri bölümü
                      _buildDetailCard(
                        'Veri İçeriği',
                        Icons.data_object,
                        favorite.data,
                        Colors.blue,
                      ),

                      const SizedBox(height: 16),

                      // Açıklama bölümü (varsa)
                      if (favorite.description != null)
                        _buildDetailCard(
                          'Açıklama',
                          Icons.description,
                          favorite.description!,
                          Colors.green,
                        ),

                      if (favorite.description != null)
                        const SizedBox(height: 16),

                      // Tarih bölümü
                      _buildDetailCard(
                        'Tarih',
                        Icons.access_time,
                        _formatTimestamp(favorite.timestamp),
                        Colors.orange,
                      ),

                      const SizedBox(height: 16),

                      // WiFi özel bilgileri
                      if (favorite.type == 'WiFi' &&
                          favorite.description != null)
                        _buildWiFiDetails(favorite.description!),
                    ],
                  ),
                ),
              ),

              // Action buttons
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _copyToClipboard(favorite);
                        },
                        icon: const Icon(Icons.copy, size: 18),
                        label: const Text('Kopyala'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (favorite.isUrl)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _openUrl(favorite.data);
                          },
                          icon: const Icon(Icons.open_in_browser, size: 18),
                          label: const Text('Aç'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    if (favorite.isUrl) const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await _removeFromFavorites(favorite);
                        },
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text('Sil'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(
    String title,
    IconData icon,
    String content,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SelectableText(content, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildWiFiDetails(String description) {
    final lines = description.split('\n');
    String ssid = 'Bilinmiyor';
    String password = 'Bilinmiyor';

    for (final line in lines) {
      if (line.startsWith('WiFi Ağı: ')) {
        ssid = line.substring(10);
      } else if (line.startsWith('Şifre: ')) {
        password = line.substring(7);
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.cyan.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.cyan.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.wifi, color: Colors.cyan, size: 20),
              const SizedBox(width: 8),
              const Text(
                'WiFi Bilgileri',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.cyan,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildWiFiInfoRow('Ağ Adı (SSID)', ssid),
          const SizedBox(height: 8),
          _buildWiFiInfoRow('Şifre', password),
        ],
      ),
    );
  }

  Widget _buildWiFiInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SelectableText(
            value,
            style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
          ),
        ),
      ],
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'URL':
        return Colors.blue;
      case 'E-posta':
        return Colors.green;
      case 'Telefon':
        return Colors.purple;
      case 'SMS':
        return Colors.orange;
      case 'Konum':
        return Colors.red;
      case 'WiFi':
        return Colors.cyan;
      case 'vCard':
        return Colors.indigo;
      case 'MeCard':
        return Colors.teal;
      case 'OTP':
        return Colors.amber;
      case 'Kripto Para':
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'URL':
        return Icons.link;
      case 'E-posta':
        return Icons.email;
      case 'Telefon':
        return Icons.phone;
      case 'SMS':
        return Icons.message;
      case 'Konum':
        return Icons.location_on;
      case 'WiFi':
        return Icons.wifi;
      case 'vCard':
        return Icons.contact_page;
      case 'MeCard':
        return Icons.person;
      case 'OTP':
        return Icons.security;
      case 'Kripto Para':
        return Icons.currency_bitcoin;
      default:
        return Icons.text_fields;
    }
  }

  String _maskPassword(String description) {
    if (description.contains('Şifre: ')) {
      final parts = description.split('Şifre: ');
      if (parts.length > 1) {
        final password = parts[1];
        if (password.length > 2) {
          return '${password.substring(0, 2)}${'*' * (password.length - 2)}';
        }
      }
    }
    return description;
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }
}
