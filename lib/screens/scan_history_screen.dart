import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/qr_scan_model.dart';
import '../services/hive_service.dart';

class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({super.key});

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  final HiveService _hiveService = HiveService();
  List<QrScanModel> _scans = [];
  List<QrScanModel> _filteredScans = [];
  String _searchQuery = '';
  String? _selectedType;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadScans();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadScans() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final scans = _hiveService.getAllQrScans();
      setState(() {
        _scans = scans;
        _filteredScans = scans;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Log removed
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Geçmiş yüklenirken hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterScans() {
    setState(() {
      _filteredScans = _scans.where((scan) {
        final matchesSearch =
            _searchQuery.isEmpty ||
            scan.data.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            scan.type.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (scan.title?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
                false);

        final matchesType = _selectedType == null || scan.type == _selectedType;

        return matchesSearch && matchesType;
      }).toList();
    });
  }

  List<String> get _availableTypes {
    final types = _scans.map((scan) => scan.type).toSet().toList();
    types.sort();
    return types;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarama Geçmişi'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _loadScans,
            icon: const Icon(Icons.refresh),
            tooltip: 'Yenile',
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'clear':
                  await _clearAllScans();
                  break;
                case 'export':
                  await _exportScans();
                  break;
                case 'stats':
                  _showStatistics();
                  break;
                case 'removeDuplicates':
                  await _removeDuplicateScans();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'stats',
                child: Row(
                  children: [
                    Icon(Icons.analytics, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('İstatistikler'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Dışa Aktar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'removeDuplicates',
                child: Row(
                  children: [
                    Icon(Icons.cleaning_services, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Tekrarları Kaldır'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Tümünü Sil'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtre ve arama bölümü
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Arama kutusu
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tarama geçmişinde ara...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                              _filterScans();
                            },
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                    _filterScans();
                  },
                ),
                const SizedBox(height: 12),
                // Tip filtresi
                if (_availableTypes.isNotEmpty) ...[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('Tümü', null),
                        const SizedBox(width: 8),
                        ..._availableTypes.map(
                          (type) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildFilterChip(type, type),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Tarama listesi
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredScans.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Henüz tarama yapılmamış',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'QR kod taramaya başlayın!',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredScans.length,
                    itemBuilder: (context, index) {
                      final scan = _filteredScans[index];
                      return _buildScanItem(scan);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? type) {
    final isSelected = _selectedType == type;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedType = selected ? type : null;
        });
        _filterScans();
      },
      selectedColor: Colors.blue.shade100,
      checkmarkColor: Colors.blue,
    );
  }

  Widget _buildScanItem(QrScanModel scan) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTypeColor(scan.type),
          child: Icon(_getTypeIcon(scan.type), color: Colors.white, size: 20),
        ),
        title: Text(
          scan.title ?? scan.data,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              scan.type,
              style: TextStyle(
                fontSize: 12,
                color: _getTypeColor(scan.type),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (scan.type == 'WiFi' && scan.description != null)
              Text(
                'Şifre: ${_maskPassword(scan.description!)}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade700,
                  fontFamily: 'monospace',
                ),
              ),
            Text(
              _formatTimestamp(scan.timestamp),
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Yıldız ikonu (Sık kullanılanlara ekle/çıkar)
            IconButton(
              onPressed: () => _toggleFavorite(scan),
              icon: Icon(
                _hiveService.isFavorite(scan.id)
                    ? Icons.star
                    : Icons.star_border,
                color: _hiveService.isFavorite(scan.id)
                    ? Colors.amber
                    : Colors.grey,
                size: 20,
              ),
              tooltip: _hiveService.isFavorite(scan.id)
                  ? 'Sık kullanılanlardan çıkar'
                  : 'Sık kullanılanlara ekle',
            ),
            // Popup menü
            PopupMenuButton<String>(
              onSelected: (value) async {
                switch (value) {
                  case 'copy':
                    _copyToClipboard(scan);
                    break;
                  case 'delete':
                    await _deleteScan(scan);
                    break;
                  case 'open':
                    if (scan.isUrl) {
                      _openUrl(scan.data);
                    }
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
                if (scan.isUrl)
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
                  value: 'delete',
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
        onTap: () => _showScanDetails(scan),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'URL':
        return Colors.blue;
      case 'E-posta':
        return Colors.green;
      case 'Telefon':
        return Colors.orange;
      case 'SMS':
        return Colors.purple;
      case 'Konum':
        return Colors.red;
      case 'WiFi':
        return Colors.indigo;
      case 'vCard':
        return Colors.teal;
      case 'MeCard':
        return Colors.cyan;
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
        return Icons.contact_phone;
      case 'OTP':
        return Icons.security;
      case 'Kripto Para':
        return Icons.currency_bitcoin;
      default:
        return Icons.text_fields;
    }
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

  String _maskPassword(String password) {
    if (password.isEmpty ||
        password == 'Şifre yok' ||
        password == 'Gizli şifre') {
      return password;
    }

    if (password.length <= 4) {
      return '•' * password.length;
    }

    // İlk 2 ve son 2 karakteri göster, ortasını maskele
    final firstTwo = password.substring(0, 2);
    final lastTwo = password.substring(password.length - 2);
    final middle = '•' * (password.length - 4);

    return '$firstTwo$middle$lastTwo';
  }

  void _showScanDetails(QrScanModel scan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: _getTypeColor(scan.type),
              child: Icon(_getTypeIcon(scan.type), color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                scan.title ?? scan.type,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Tip:', scan.type),
            _buildDetailRow('Zaman:', _formatTimestamp(scan.timestamp)),
            if (scan.format != null) _buildDetailRow('Format:', scan.format!),
            const SizedBox(height: 12),
            const Text(
              'İçerik:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SelectableText(
                scan.data,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
            if (scan.type == 'WiFi' && scan.description != null) ...[
              const SizedBox(height: 12),
              const Text(
                'WiFi Şifresi:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: SelectableText(
                  scan.description!,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
          if (scan.isUrl)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _openUrl(scan.data);
              },
              icon: const Icon(Icons.open_in_browser),
              label: const Text('Aç'),
            ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _copyToClipboard(scan);
            },
            icon: const Icon(Icons.copy),
            label: const Text('Kopyala'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _copyToClipboard(QrScanModel scan) {
    String textToCopy;
    String message;

    if (scan.type == 'WiFi' && scan.description != null) {
      textToCopy = scan.description!;
      message = 'WiFi şifresi panoya kopyalandı';
    } else {
      textToCopy = scan.data;
      message = 'İçerik panoya kopyalandı';
    }

    Clipboard.setData(ClipboardData(text: textToCopy));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  Future<void> _deleteScan(QrScanModel scan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tarama Sil'),
        content: const Text('Bu taramayı silmek istediğinizden emin misiniz?'),
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
        await _hiveService.deleteQrScan(scan.id);
        await _loadScans();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tarama silindi'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Silme hatası: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _toggleFavorite(QrScanModel scan) async {
    try {
      if (_hiveService.isFavorite(scan.id)) {
        await _hiveService.removeFromFavorites(scan.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sık kullanılanlardan çıkarıldı'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        await _hiveService.addToFavorites(scan);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sık kullanılanlara eklendi'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
      setState(() {}); // UI'yi güncelle
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _removeDuplicateScans() async {
    try {
      await _hiveService.removeDuplicateScans();
      await _loadScans(); // Listeyi yenile
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tekrar eden taramalar kaldırıldı'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tekrarları kaldırma hatası: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _clearAllScans() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tüm Taramaları Sil'),
        content: const Text(
          'Tüm tarama geçmişini silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
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
        await _hiveService.deleteAllQrScans();
        await _loadScans();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tüm taramalar silindi'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Silme hatası: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _exportScans() async {
    try {
      final scansJson = _scans.map((scan) => scan.toJson()).toList();
      final jsonString = scansJson.toString();
      Clipboard.setData(ClipboardData(text: jsonString));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tarama geçmişi panoya kopyalandı'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dışa aktarma hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showStatistics() {
    final stats = _hiveService.getStatistics();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İstatistikler'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow('Toplam Tarama:', '${stats['totalScans']}'),
            _buildStatRow('URL Taraması:', '${stats['urlScans']}'),
            if (stats['lastScan'] != null)
              _buildStatRow('Son Tarama:', _formatTimestamp(stats['lastScan'])),
            if (stats['firstScan'] != null)
              _buildStatRow(
                'İlk Tarama:',
                _formatTimestamp(stats['firstScan']),
              ),
            const SizedBox(height: 12),
            const Text(
              'Tip Dağılımı:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...(stats['typeCounts'] as Map<String, int>).entries.map(
              (entry) => _buildStatRow('${entry.key}:', '${entry.value}'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _openUrl(String url) {
    // URL açma işlemi ana sayfadaki _launchUrl fonksiyonuna benzer
    // Burada sadece log yazıyoruz, gerçek açma işlemi ana sayfada yapılacak
    // Log removed
    // TODO: URL açma işlemi burada da implement edilebilir
  }
}
