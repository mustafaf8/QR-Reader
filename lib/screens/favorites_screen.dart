import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/qr_scan_model.dart';
import '../services/hive_service.dart';

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
      // Sık kullanılanları yükleme hatası
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Sık Kullanılanlar'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
        actions: [
          if (_favorites.isNotEmpty)
            IconButton(
              onPressed: _clearAllFavorites,
              icon: const Icon(Icons.clear_all),
              tooltip: 'Tümünü Temizle',
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            ],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _favorites.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.star_border,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Henüz sık kullanılan yok',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'Tarama geçmişinden yıldız ikonuna tıklayarak\nsık kullanılanlara ekleyebilirsiniz',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _favorites.length,
                itemBuilder: (context, index) {
                  final favorite = _favorites[index];
                  return _buildFavoriteItem(favorite);
                },
              ),
      ),
    );
  }

  Widget _buildFavoriteItem(QrScanModel favorite) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 3,
        shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getTypeColor(favorite.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getTypeIcon(favorite.type),
              color: _getTypeColor(favorite.type),
              size: 20,
            ),
          ),
          title: Text(
            favorite.title ?? favorite.data,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getTypeColor(favorite.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  favorite.type,
                  style: TextStyle(
                    fontSize: 11,
                    color: _getTypeColor(favorite.type),
                    fontWeight: FontWeight.w600,
                  ),
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
    // URL açma isteği
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 650),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Modern Header with Gradient
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getTypeColor(favorite.type),
                      _getTypeColor(favorite.type).withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getTypeIcon(favorite.type),
                        color: Colors.white,
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
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              favorite.type,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),

              // Content with Better Spacing
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Veri bölümü - Modern Card Design
                      _buildModernDetailCard(
                        'Veri İçeriği',
                        Icons.data_object,
                        favorite.data,
                        _getTypeColor(favorite.type),
                      ),

                      const SizedBox(height: 16),

                      // Açıklama bölümü (varsa)
                      if (favorite.description != null)
                        _buildModernDetailCard(
                          'Açıklama',
                          Icons.description,
                          favorite.description!,
                          Colors.green,
                        ),

                      if (favorite.description != null)
                        const SizedBox(height: 16),

                      // WiFi özel bilgileri
                      if (favorite.type == 'WiFi' &&
                          favorite.description != null)
                        _buildModernWiFiDetails(favorite.description!),

                      const SizedBox(height: 16),

                      // Tarih bölümü - Bottom positioned
                      Card(
                        elevation: 0,
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceVariant.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Tarih: ${_formatTimestamp(favorite.timestamp)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Action buttons - Modern Design
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    if (favorite.isUrl)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _openUrl(favorite.data);
                          },
                          icon: const Icon(Icons.open_in_browser, size: 20),
                          label: const Text(
                            'Web Sayfasını Aç',
                            style: TextStyle(fontSize: 15),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 2,
                            shadowColor: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    if (favorite.isUrl) const SizedBox(height: 12),
                    Row(
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await _removeFromFavorites(favorite);
                            },
                            icon: const Icon(Icons.delete, size: 18),
                            label: const Text('Sil'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              elevation: 2,
                              shadowColor: Colors.red.withOpacity(0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildModernDetailCard(
    String title,
    IconData icon,
    String content,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shadowColor: color.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.08), color.withOpacity(0.03)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: SelectableText(
                content,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
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

  Widget _buildModernWiFiDetails(String description) {
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

    return Card(
      elevation: 2,
      shadowColor: Colors.cyan.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.cyan.withOpacity(0.08),
              Colors.cyan.withOpacity(0.03),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.cyan.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.wifi, color: Colors.cyan, size: 20),
                ),
                const SizedBox(width: 12),
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
            const SizedBox(height: 16),
            _buildModernWiFiInfoRow(
              'Ağ Adı (SSID)',
              ssid,
              Icons.router,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildModernWiFiInfoRow(
              'Şifre',
              password,
              Icons.lock,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernWiFiInfoRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                SelectableText(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
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
    // Sadece tarih formatı: "15.12.2024"
    return '${timestamp.day.toString().padLeft(2, '0')}.${timestamp.month.toString().padLeft(2, '0')}.${timestamp.year}';
  }
}
